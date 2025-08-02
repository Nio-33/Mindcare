import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_models.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available support groups
  Future<List<SupportGroup>> getSupportGroups({int limit = 20}) async {
    try {
      final query = await _firestore
          .collection('support_groups')
          .orderBy('member_count', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => SupportGroup.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting support groups: $e');
      }
      return [];
    }
  }

  // Get support groups that a user has joined
  Future<List<SupportGroup>> getUserGroups(String userId, {int limit = 20}) async {
    try {
      final query = await _firestore
          .collection('support_groups')
          .where('member_ids', arrayContains: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => SupportGroup.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user groups: $e');
      }
      return [];
    }
  }

  // Join a support group
  Future<void> joinGroup(String groupId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Add user to group's member list
      final groupRef = _firestore.collection('support_groups').doc(groupId);
      batch.update(groupRef, {
        'member_ids': FieldValue.arrayUnion([userId]),
        'member_count': FieldValue.increment(1),
      });

      // Create membership record for quick lookups
      final membershipRef = _firestore
          .collection('group_memberships')
          .doc('${groupId}_$userId');
      batch.set(membershipRef, {
        'group_id': groupId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error joining group: $e');
      }
      throw Exception('Failed to join group');
    }
  }

  // Leave a support group
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Remove user from group's member list
      final groupRef = _firestore.collection('support_groups').doc(groupId);
      batch.update(groupRef, {
        'member_ids': FieldValue.arrayRemove([userId]),
        'member_count': FieldValue.increment(-1),
      });

      // Update membership record
      final membershipRef = _firestore
          .collection('group_memberships')
          .doc('${groupId}_$userId');
      batch.update(membershipRef, {
        'is_active': false,
        'left_at': DateTime.now().toIso8601String(),
      });

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving group: $e');
      }
      throw Exception('Failed to leave group');
    }
  }

  // Get posts for a specific support group
  Future<List<CommunityPost>> getGroupPosts(String groupId, {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection('community_posts')
          .where('group_id', isEqualTo: groupId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => CommunityPost.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting group posts: $e');
      }
      return [];
    }
  }

  // Create a new post in a support group
  Future<void> createPost(CommunityPost post) async {
    try {
      final batch = _firestore.batch();

      // Add the post
      final postRef = _firestore.collection('community_posts').doc(post.id);
      batch.set(postRef, post.toMap());

      // Update group post count
      final groupRef = _firestore.collection('support_groups').doc(post.groupId);
      batch.update(groupRef, {
        'post_count': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating post: $e');
      }
      throw Exception('Failed to create post');
    }
  }

  // Get replies for a specific post
  Future<List<PostReply>> getPostReplies(String postId, {int limit = 100}) async {
    try {
      final query = await _firestore
          .collection('post_replies')
          .where('post_id', isEqualTo: postId)
          .orderBy('created_at', descending: false)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => PostReply.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting post replies: $e');
      }
      return [];
    }
  }

  // Create a reply to a post
  Future<void> createReply(PostReply reply) async {
    try {
      final batch = _firestore.batch();

      // Add the reply
      final replyRef = _firestore.collection('post_replies').doc(reply.id);
      batch.set(replyRef, reply.toMap());

      // Update post reply count
      final postRef = _firestore.collection('community_posts').doc(reply.postId);
      batch.update(postRef, {
        'reply_count': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating reply: $e');
      }
      throw Exception('Failed to create reply');
    }
  }

  // Toggle like on a post
  Future<void> togglePostLike(String postId, String userId) async {
    try {
      final likeRef = _firestore
          .collection('post_likes')
          .doc('${postId}_$userId');
      
      final likeDoc = await likeRef.get();
      final batch = _firestore.batch();

      if (likeDoc.exists) {
        // Remove like
        batch.delete(likeRef);
        
        final postRef = _firestore.collection('community_posts').doc(postId);
        batch.update(postRef, {
          'like_count': FieldValue.increment(-1),
        });
      } else {
        // Add like
        batch.set(likeRef, {
          'post_id': postId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
        
        final postRef = _firestore.collection('community_posts').doc(postId);
        batch.update(postRef, {
          'like_count': FieldValue.increment(1),
        });
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling post like: $e');
      }
      throw Exception('Failed to update like');
    }
  }

  // Toggle like on a reply
  Future<void> toggleReplyLike(String replyId, String userId) async {
    try {
      final likeRef = _firestore
          .collection('reply_likes')
          .doc('${replyId}_$userId');
      
      final likeDoc = await likeRef.get();
      final batch = _firestore.batch();

      if (likeDoc.exists) {
        // Remove like
        batch.delete(likeRef);
        
        final replyRef = _firestore.collection('post_replies').doc(replyId);
        batch.update(replyRef, {
          'like_count': FieldValue.increment(-1),
        });
      } else {
        // Add like
        batch.set(likeRef, {
          'reply_id': replyId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
        
        final replyRef = _firestore.collection('post_replies').doc(replyId);
        batch.update(replyRef, {
          'like_count': FieldValue.increment(1),
        });
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling reply like: $e');
      }
      throw Exception('Failed to update like');
    }
  }

  // Check if user has liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    try {
      final likeDoc = await _firestore
          .collection('post_likes')
          .doc('${postId}_$userId')
          .get();
      
      return likeDoc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking post like: $e');
      }
      return false;
    }
  }

  // Check if user has liked a reply
  Future<bool> hasUserLikedReply(String replyId, String userId) async {
    try {
      final likeDoc = await _firestore
          .collection('reply_likes')
          .doc('${replyId}_$userId')
          .get();
      
      return likeDoc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking reply like: $e');
      }
      return false;
    }
  }

  // Search posts across groups
  Future<List<CommunityPost>> searchPosts(String query, {int limit = 20}) async {
    try {
      // Note: Firestore doesn't support full-text search natively.
      // In a production app, you'd use a search service like Algolia or Elasticsearch.
      // For now, we'll do a simple title search.
      
      final querySnapshot = await _firestore
          .collection('community_posts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          .orderBy('title')
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => CommunityPost.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching posts: $e');
      }
      return [];
    }
  }

  // Get trending posts (most liked in recent time)
  Future<List<CommunityPost>> getTrendingPosts({int limit = 10}) async {
    try {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final query = await _firestore
          .collection('community_posts')
          .where('created_at', isGreaterThan: oneWeekAgo.toIso8601String())
          .orderBy('created_at')
          .orderBy('like_count', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => CommunityPost.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting trending posts: $e');
      }
      return [];
    }
  }

  // Report inappropriate content
  Future<void> reportContent({
    required String contentId,
    required String contentType, // 'post' or 'reply'
    required String reporterId,
    required String reason,
    String? details,
  }) async {
    try {
      await _firestore.collection('content_reports').add({
        'content_id': contentId,
        'content_type': contentType,
        'reporter_id': reporterId,
        'reason': reason,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error reporting content: $e');
      }
      throw Exception('Failed to report content');
    }
  }
}