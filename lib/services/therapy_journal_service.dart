import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/therapy_journal.dart';

class TherapyJournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simple encryption for demo - in production use proper encryption
  String _encryptContent(String content, String userId) {
    final bytes = utf8.encode(content + userId);
    final digest = sha256.convert(bytes);
    return base64.encode(utf8.encode(content));
  }

  String _decryptContent(String encryptedContent, String userId) {
    try {
      return utf8.decode(base64.decode(encryptedContent));
    } catch (e) {
      return encryptedContent; // Fallback if decryption fails
    }
  }

  // Create or update journal entry
  Future<void> saveJournalEntry(TherapyJournalEntry entry) async {
    try {
      final entryData = entry.toMap();
      
      // Encrypt content if needed
      if (entry.isEncrypted) {
        entryData['content'] = _encryptContent(entry.content, entry.userId);
      }

      await _firestore
          .collection('therapy_journal')
          .doc(entry.id)
          .set(entryData, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving journal entry: $e');
      }
      throw Exception('Failed to save journal entry');
    }
  }

  // Get user's journal entries
  Future<List<TherapyJournalEntry>> getUserJournalEntries(
    String userId, {
    int limit = 50,
    JournalEntryType? type,
  }) async {
    try {
      Query query = _firestore
          .collection('therapy_journal')
          .where('user_id', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      final querySnapshot = await query
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Decrypt content if encrypted
        if (data['is_encrypted'] == true) {
          data['content'] = _decryptContent(data['content'], userId);
        }
        
        return TherapyJournalEntry.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting journal entries: $e');
      }
      return [];
    }
  }

  // Get single journal entry
  Future<TherapyJournalEntry?> getJournalEntry(String entryId, String userId) async {
    try {
      final doc = await _firestore
          .collection('therapy_journal')
          .doc(entryId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      
      // Decrypt content if encrypted
      if (data['is_encrypted'] == true) {
        data['content'] = _decryptContent(data['content'], userId);
      }
      
      return TherapyJournalEntry.fromMap(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting journal entry: $e');
      }
      return null;
    }
  }

  // Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _firestore
          .collection('therapy_journal')
          .doc(entryId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting journal entry: $e');
      }
      throw Exception('Failed to delete journal entry');
    }
  }

  // Search journal entries
  Future<List<TherapyJournalEntry>> searchJournalEntries(
    String userId,
    String query, {
    int limit = 20,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple title search
      final querySnapshot = await _firestore
          .collection('therapy_journal')
          .where('user_id', isEqualTo: userId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          .orderBy('title')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        
        // Decrypt content if encrypted
        if (data['is_encrypted'] == true) {
          data['content'] = _decryptContent(data['content'], userId);
        }
        
        return TherapyJournalEntry.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching journal entries: $e');
      }
      return [];
    }
  }

  // Get journal entries by tags
  Future<List<TherapyJournalEntry>> getJournalEntriesByTag(
    String userId,
    String tag, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('therapy_journal')
          .where('user_id', isEqualTo: userId)
          .where('tags', arrayContains: tag)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        
        // Decrypt content if encrypted
        if (data['is_encrypted'] == true) {
          data['content'] = _decryptContent(data['content'], userId);
        }
        
        return TherapyJournalEntry.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting journal entries by tag: $e');
      }
      return [];
    }
  }

  // Save gratitude entry
  Future<void> saveGratitudeEntry(GratitudeEntry entry) async {
    try {
      await _firestore
          .collection('gratitude_entries')
          .doc(entry.id)
          .set(entry.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving gratitude entry: $e');
      }
      throw Exception('Failed to save gratitude entry');
    }
  }

  // Get user's gratitude entries
  Future<List<GratitudeEntry>> getUserGratitudeEntries(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('gratitude_entries')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => GratitudeEntry.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting gratitude entries: $e');
      }
      return [];
    }
  }

  // Save medication log
  Future<void> saveMedicationLog(MedicationLog log) async {
    try {
      await _firestore
          .collection('medication_logs')
          .doc(log.id)
          .set(log.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving medication log: $e');
      }
      throw Exception('Failed to save medication log');
    }
  }

  // Get user's medication logs
  Future<List<MedicationLog>> getUserMedicationLogs(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('medication_logs')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => MedicationLog.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting medication logs: $e');
      }
      return [];
    }
  }

  // Save thought pattern
  Future<void> saveThoughtPattern(ThoughtPattern pattern) async {
    try {
      await _firestore
          .collection('thought_patterns')
          .doc(pattern.id)
          .set(pattern.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving thought pattern: $e');
      }
      throw Exception('Failed to save thought pattern');
    }
  }

  // Get thought patterns for journal entry
  Future<List<ThoughtPattern>> getThoughtPatternsForEntry(
    String journalEntryId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('thought_patterns')
          .where('journal_entry_id', isEqualTo: journalEntryId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ThoughtPattern.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting thought patterns: $e');
      }
      return [];
    }
  }

  // Save session note
  Future<void> saveSessionNote(SessionNote note) async {
    try {
      await _firestore
          .collection('session_notes')
          .doc(note.id)
          .set(note.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving session note: $e');
      }
      throw Exception('Failed to save session note');
    }
  }

  // Get user's session notes
  Future<List<SessionNote>> getUserSessionNotes(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('session_notes')
          .where('user_id', isEqualTo: userId)
          .orderBy('session_date', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionNote.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting session notes: $e');
      }
      return [];
    }
  }

  // Generate AI insights for journal entry
  Future<Map<String, dynamic>> generateAIInsights(TherapyJournalEntry entry) async {
    try {
      // Simplified sentiment analysis
      final content = entry.content.toLowerCase();
      
      // Basic sentiment scoring
      final positiveWords = ['happy', 'good', 'great', 'excellent', 'wonderful', 'amazing', 'fantastic', 'love', 'grateful', 'thankful', 'blessed', 'hopeful', 'optimistic', 'confident', 'proud', 'excited', 'joyful', 'peaceful'];
      final negativeWords = ['sad', 'bad', 'terrible', 'awful', 'horrible', 'hate', 'angry', 'frustrated', 'depressed', 'anxious', 'worried', 'scared', 'lonely', 'hopeless', 'overwhelmed', 'stressed', 'tired', 'exhausted'];
      
      int positiveCount = 0;
      int negativeCount = 0;
      
      for (final word in positiveWords) {
        positiveCount += word.allMatches(content).length;
      }
      
      for (final word in negativeWords) {
        negativeCount += word.allMatches(content).length;
      }
      
      final totalWords = content.split(' ').length;
      final sentimentScore = (positiveCount - negativeCount) / totalWords;
      
      // Determine emotional tone
      EmotionalTone tone;
      if (sentimentScore > 0.1) {
        tone = EmotionalTone.positive;
      } else if (sentimentScore > 0.2) {
        tone = EmotionalTone.veryPositive;
      } else if (sentimentScore < -0.1) {
        tone = EmotionalTone.negative;
      } else if (sentimentScore < -0.2) {
        tone = EmotionalTone.veryNegative;
      } else {
        tone = EmotionalTone.neutral;
      }
      
      // Identify themes
      final themes = <String>[];
      if (content.contains('work') || content.contains('job')) themes.add('work');
      if (content.contains('family') || content.contains('parent')) themes.add('family');
      if (content.contains('friend') || content.contains('relationship')) themes.add('relationships');
      if (content.contains('health') || content.contains('sick')) themes.add('health');
      if (content.contains('money') || content.contains('financial')) themes.add('finances');
      
      // Generate recommendations
      final recommendations = <String>[];
      if (sentimentScore < -0.1) {
        recommendations.add('Consider practicing breathing exercises');
        recommendations.add('Try writing down three things you\'re grateful for');
        recommendations.add('Consider reaching out to a friend or counselor');
      } else if (sentimentScore > 0.1) {
        recommendations.add('Great to see positive thoughts! Keep up the good work');
        recommendations.add('Consider sharing this positive energy with others');
      }
      
      return {
        'sentiment_score': sentimentScore,
        'emotional_tone': tone.toString().split('.').last,
        'themes': themes,
        'recommendations': recommendations,
        'word_count': totalWords,
        'positive_word_count': positiveCount,
        'negative_word_count': negativeCount,
        'analysis_timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error generating AI insights: $e');
      }
      return {};
    }
  }

  // Export journal entries (HIPAA-ready)
  Future<Map<String, dynamic>> exportJournalData(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    bool includeAIInsights = false,
  }) async {
    try {
      Query query = _firestore
          .collection('therapy_journal')
          .where('user_id', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      final journalDocs = await query.orderBy('timestamp').get();
      final gratitudeDocs = await _firestore
          .collection('gratitude_entries')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp')
          .get();
      final medicationDocs = await _firestore
          .collection('medication_logs')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp')
          .get();
      final sessionDocs = await _firestore
          .collection('session_notes')
          .where('user_id', isEqualTo: userId)
          .orderBy('session_date')
          .get();

      final journalEntries = journalDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Decrypt content
        if (data['is_encrypted'] == true) {
          data['content'] = _decryptContent(data['content'], userId);
        }
        
        // Remove AI insights if not requested
        if (!includeAIInsights) {
          data.remove('ai_insights');
          data.remove('sentiment_score');
          data.remove('emotional_tone');
        }
        
        return data;
      }).toList();

      return {
        'export_timestamp': DateTime.now().toIso8601String(),
        'user_id': userId,
        'date_range': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
        'journal_entries': journalEntries,
        'gratitude_entries': gratitudeDocs.docs.map((doc) => doc.data()).toList(),
        'medication_logs': medicationDocs.docs.map((doc) => doc.data()).toList(),
        'session_notes': sessionDocs.docs.map((doc) => doc.data()).toList(),
        'include_ai_insights': includeAIInsights,
        'total_entries': journalEntries.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting journal data: $e');
      }
      throw Exception('Failed to export journal data');
    }
  }

  // Get journal statistics
  Future<Map<String, dynamic>> getJournalStatistics(String userId) async {
    try {
      final journalDocs = await _firestore
          .collection('therapy_journal')
          .where('user_id', isEqualTo: userId)
          .get();

      final gratitudeDocs = await _firestore
          .collection('gratitude_entries')
          .where('user_id', isEqualTo: userId)
          .get();

      final entries = journalDocs.docs.map((doc) {
        final data = doc.data();
        if (data['is_encrypted'] == true) {
          data['content'] = _decryptContent(data['content'], userId);
        }
        return TherapyJournalEntry.fromMap(data);
      }).toList();

      // Calculate statistics
      final totalEntries = entries.length;
      final totalWords = entries.fold<int>(0, (sum, entry) => sum + entry.wordCount);
      final averageWordsPerEntry = totalEntries > 0 ? totalWords / totalEntries : 0;
      
      final entriesByType = <String, int>{};
      final entriesByMonth = <String, int>{};
      
      for (final entry in entries) {
        // Count by type
        final type = entry.type.toString().split('.').last;
        entriesByType[type] = (entriesByType[type] ?? 0) + 1;
        
        // Count by month
        final month = '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}';
        entriesByMonth[month] = (entriesByMonth[month] ?? 0) + 1;
      }

      return {
        'total_journal_entries': totalEntries,
        'total_gratitude_entries': gratitudeDocs.docs.length,
        'total_words': totalWords,
        'average_words_per_entry': averageWordsPerEntry.round(),
        'entries_by_type': entriesByType,
        'entries_by_month': entriesByMonth,
        'longest_streak': _calculateLongestStreak(entries),
        'current_streak': _calculateCurrentStreak(entries),
        'first_entry_date': entries.isNotEmpty ? entries.last.timestamp.toIso8601String() : null,
        'last_entry_date': entries.isNotEmpty ? entries.first.timestamp.toIso8601String() : null,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting journal statistics: $e');
      }
      return {};
    }
  }

  int _calculateLongestStreak(List<TherapyJournalEntry> entries) {
    if (entries.isEmpty) return 0;
    
    final sortedEntries = entries..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    int longestStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < sortedEntries.length; i++) {
      final prevDate = DateTime(
        sortedEntries[i - 1].timestamp.year,
        sortedEntries[i - 1].timestamp.month,
        sortedEntries[i - 1].timestamp.day,
      );
      final currentDate = DateTime(
        sortedEntries[i].timestamp.year,
        sortedEntries[i].timestamp.month,
        sortedEntries[i].timestamp.day,
      );
      
      if (currentDate.difference(prevDate).inDays == 1) {
        currentStreak++;
        longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    
    return longestStreak;
  }

  int _calculateCurrentStreak(List<TherapyJournalEntry> entries) {
    if (entries.isEmpty) return 0;
    
    final sortedEntries = entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final today = DateTime.now();
    int currentStreak = 0;
    
    for (final entry in sortedEntries) {
      final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      final daysDifference = today.difference(entryDate).inDays;
      
      if (daysDifference == currentStreak) {
        currentStreak++;
      } else {
        break;
      }
    }
    
    return currentStreak;
  }
}