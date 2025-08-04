import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/learning_models.dart';

class LearningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available learning modules
  Future<List<LearningModule>> getLearningModules({
    LearningCategory? category,
    ContentType? type,
    Difficulty? difficulty,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('learning_modules');
      
      if (category != null) {
        query = query.where('category', isEqualTo: category.toString().split('.').last);
      }
      
      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }
      
      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.toString().split('.').last);
      }

      final querySnapshot = await query
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => LearningModule.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting learning modules: $e');
      }
      return [];
    }
  }

  // Get featured/recommended modules
  Future<List<LearningModule>> getFeaturedModules({int limit = 6}) async {
    try {
      final query = await _firestore
          .collection('learning_modules')
          .where('rating', isGreaterThan: 4.0)
          .orderBy('rating', descending: true)
          .orderBy('rating_count', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => LearningModule.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting featured modules: $e');
      }
      return [];
    }
  }

  // Get learning paths
  Future<List<LearningPath>> getLearningPaths({
    LearningCategory? category,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection('learning_paths');
      
      if (category != null) {
        query = query.where('category', isEqualTo: category.toString().split('.').last);
      }

      final querySnapshot = await query
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => LearningPath.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting learning paths: $e');
      }
      return [];
    }
  }

  // Get user's progress for all modules
  Future<List<UserProgress>> getUserProgress(String userId) async {
    try {
      final query = await _firestore
          .collection('user_progress')
          .where('user_id', isEqualTo: userId)
          .orderBy('last_accessed_at', descending: true)
          .get();

      return query.docs
          .map((doc) => UserProgress.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user progress: $e');
      }
      return [];
    }
  }

  // Get progress for a specific module
  Future<UserProgress?> getModuleProgress(String userId, String moduleId) async {
    try {
      final query = await _firestore
          .collection('user_progress')
          .where('user_id', isEqualTo: userId)
          .where('module_id', isEqualTo: moduleId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserProgress.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting module progress: $e');
      }
      return null;
    }
  }

  // Start or update user progress
  Future<void> updateUserProgress(UserProgress progress) async {
    try {
      await _firestore
          .collection('user_progress')
          .doc(progress.id)
          .set(progress.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user progress: $e');
      }
      throw Exception('Failed to update progress');
    }
  }

  // Mark content as completed
  Future<void> markContentCompleted(
    String userId,
    String moduleId,
    String contentId,
  ) async {
    try {
      final progressDoc = await _firestore
          .collection('user_progress')
          .where('user_id', isEqualTo: userId)
          .where('module_id', isEqualTo: moduleId)
          .limit(1)
          .get();

      if (progressDoc.docs.isNotEmpty) {
        final progressRef = progressDoc.docs.first.reference;
        final currentProgress = UserProgress.fromMap(progressDoc.docs.first.data());
        
        if (!currentProgress.completedContentIds.contains(contentId)) {
          final updatedContentIds = [...currentProgress.completedContentIds, contentId];
          
          // Get module to calculate completion percentage
          final moduleDoc = await _firestore
              .collection('learning_modules')
              .doc(moduleId)
              .get();
          
          if (moduleDoc.exists) {
            final module = LearningModule.fromMap(moduleDoc.data()!);
            final completionPercentage = (updatedContentIds.length / module.content.length) * 100;
            
            await progressRef.update({
              'completed_content_ids': updatedContentIds,
              'completion_percentage': completionPercentage,
              'last_accessed_at': DateTime.now().toIso8601String(),
              'completed_at': completionPercentage >= 100 ? DateTime.now().toIso8601String() : null,
            });
          }
        }
      } else {
        // Create new progress record
        final newProgress = UserProgress(
          userId: userId,
          moduleId: moduleId,
          completedContentIds: [contentId],
          completionPercentage: 0, // Will be calculated above
        );
        
        await updateUserProgress(newProgress);
        
        // Recursive call to update completion percentage
        await markContentCompleted(userId, moduleId, contentId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking content completed: $e');
      }
      throw Exception('Failed to mark content as completed');
    }
  }

  // Search learning modules
  Future<List<LearningModule>> searchModules(String query, {int limit = 20}) async {
    try {
      // Note: Firestore doesn't support full-text search natively.
      // In production, you'd use a search service like Algolia.
      // For now, we'll do a simple title search.
      
      final querySnapshot = await _firestore
          .collection('learning_modules')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          .orderBy('title')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => LearningModule.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching modules: $e');
      }
      return [];
    }
  }

  // Rate a learning module
  Future<void> rateModule(String moduleId, String userId, double rating) async {
    try {
      final batch = _firestore.batch();

      // Add/update user rating
      final ratingRef = _firestore
          .collection('module_ratings')
          .doc('${moduleId}_$userId');
      
      batch.set(ratingRef, {
        'module_id': moduleId,
        'user_id': userId,
        'rating': rating,
        'created_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Update module's average rating
      // Note: In production, this would be handled by Cloud Functions for better consistency
      batch.commit();
      
      await _updateModuleAverageRating(moduleId);
    } catch (e) {
      if (kDebugMode) {
        print('Error rating module: $e');
      }
      throw Exception('Failed to rate module');
    }
  }

  // Update module's average rating (helper method)
  Future<void> _updateModuleAverageRating(String moduleId) async {
    try {
      final ratingsQuery = await _firestore
          .collection('module_ratings')
          .where('module_id', isEqualTo: moduleId)
          .get();

      if (ratingsQuery.docs.isNotEmpty) {
        final ratings = ratingsQuery.docs
            .map((doc) => (doc.data()['rating'] as num).toDouble())
            .toList();
        
        final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
        
        await _firestore
            .collection('learning_modules')
            .doc(moduleId)
            .update({
              'rating': averageRating,
              'rating_count': ratings.length,
            });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating module average rating: $e');
      }
    }
  }

  // Get user's favorite modules
  Future<List<LearningModule>> getFavoriteModules(String userId) async {
    try {
      final favoritesQuery = await _firestore
          .collection('user_favorites')
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: 'module')
          .get();

      final moduleIds = favoritesQuery.docs
          .map((doc) => doc.data()['item_id'] as String)
          .toList();

      if (moduleIds.isEmpty) return [];

      final modulesQuery = await _firestore
          .collection('learning_modules')
          .where(FieldPath.documentId, whereIn: moduleIds)
          .get();

      return modulesQuery.docs
          .map((doc) => LearningModule.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting favorite modules: $e');
      }
      return [];
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String userId, String moduleId) async {
    try {
      final favoriteRef = _firestore
          .collection('user_favorites')
          .doc('${userId}_module_$moduleId');
      
      final favoriteDoc = await favoriteRef.get();
      
      if (favoriteDoc.exists) {
        // Remove from favorites
        await favoriteRef.delete();
      } else {
        // Add to favorites
        await favoriteRef.set({
          'user_id': userId,
          'item_id': moduleId,
          'type': 'module',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling favorite: $e');
      }
      throw Exception('Failed to toggle favorite');
    }
  }

  // Check if module is favorited by user
  Future<bool> isFavorite(String userId, String moduleId) async {
    try {
      final favoriteDoc = await _firestore
          .collection('user_favorites')
          .doc('${userId}_module_$moduleId')
          .get();
      
      return favoriteDoc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking favorite status: $e');
      }
      return false;
    }
  }

  // Track time spent on module
  Future<void> trackTimeSpent(String userId, String moduleId, int minutes) async {
    try {
      final progressQuery = await _firestore
          .collection('user_progress')
          .where('user_id', isEqualTo: userId)
          .where('module_id', isEqualTo: moduleId)
          .limit(1)
          .get();

      if (progressQuery.docs.isNotEmpty) {
        final progressRef = progressQuery.docs.first.reference;
        final currentProgress = UserProgress.fromMap(progressQuery.docs.first.data());
        
        await progressRef.update({
          'time_spent_minutes': currentProgress.timeSpentMinutes + minutes,
          'last_accessed_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking time spent: $e');
      }
    }
  }

  // Create initial user progress record
  Future<void> createUserProgress(String userId, String moduleId) async {
    try {
      final existingProgress = await getModuleProgress(userId, moduleId);
      
      if (existingProgress == null) {
        final newProgress = UserProgress(
          userId: userId,
          moduleId: moduleId,
          completedContentIds: [],
          completionPercentage: 0,
          timeSpentMinutes: 0,
          startedAt: DateTime.now(),
          lastAccessedAt: DateTime.now(),
        );
        
        await updateUserProgress(newProgress);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user progress: $e');
      }
      throw Exception('Failed to create user progress');
    }
  }
}