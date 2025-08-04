import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/therapy_journal.dart';
import '../services/therapy_journal_service.dart';

class TherapyJournalProvider extends ChangeNotifier {
  final TherapyJournalService _journalService = TherapyJournalService();

  List<TherapyJournalEntry> _entries = [];
  List<GratitudeEntry> _gratitudeEntries = [];
  final List<MedicationLog> _medicationLogs = [];
  final List<SessionNote> _sessionNotes = [];
  final List<ThoughtPattern> _thoughtPatterns = [];
  
  TherapyJournalEntry? _selectedEntry;
  final Map<String, dynamic> _journalStatistics = {};
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filter options
  JournalEntryType? _selectedType;
  String? _selectedTag;

  // Getters
  List<TherapyJournalEntry> get entries => _entries;
  List<GratitudeEntry> get gratitudeEntries => _gratitudeEntries;
  List<MedicationLog> get medicationLogs => _medicationLogs;
  List<SessionNote> get sessionNotes => _sessionNotes;
  List<ThoughtPattern> get thoughtPatterns => _thoughtPatterns;
  TherapyJournalEntry? get selectedEntry => _selectedEntry;
  Map<String, dynamic> get journalStatistics => _journalStatistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  JournalEntryType? get selectedType => _selectedType;
  String? get selectedTag => _selectedTag;

  // Load user's journal entries
  Future<void> loadEntries(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _entries = await _journalService.getUserJournalEntries(
        userId,
        type: _selectedType,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load journal entries: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading journal entries: $e');
      }
    }
  }

  // Load gratitude entries
  Future<void> loadGratitudeEntries(String userId) async {
    try {
      _gratitudeEntries = await _journalService.getUserGratitudeEntries(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading gratitude entries: $e');
      }
    }
  }

  // Create or update journal entry
  Future<void> saveJournalEntry({
    String? entryId,
    required String userId,
    required String title,
    required String content,
    JournalEntryType type = JournalEntryType.personal,
    List<String>? tags,
    SharingPermission sharingPermission = SharingPermission.private,
    String? moodId,
  }) async {
    try {
      _errorMessage = null;
      
      final entry = TherapyJournalEntry(
        id: entryId,
        userId: userId,
        title: title,
        content: content,
        type: type,
        tags: tags,
        sharingPermission: sharingPermission,
        moodId: moodId,
        lastEdited: entryId != null ? DateTime.now() : null,
      );

      // Generate AI insights
      final aiInsights = await _journalService.generateAIInsights(entry);
      final updatedEntry = entry.copyWith(
        sentimentScore: aiInsights['sentiment_score']?.toDouble(),
        emotionalTone: aiInsights['emotional_tone'] != null
            ? EmotionalTone.values.firstWhere(
                (e) => e.toString().split('.').last == aiInsights['emotional_tone'],
                orElse: () => EmotionalTone.neutral,
              )
            : null,
        aiInsights: aiInsights,
      );

      await _journalService.saveJournalEntry(updatedEntry);
      
      // Update local list
      if (entryId != null) {
        // Update existing entry
        final index = _entries.indexWhere((e) => e.id == entryId);
        if (index != -1) {
          _entries[index] = updatedEntry;
        }
      } else {
        // Add new entry
        _entries.insert(0, updatedEntry);
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save journal entry: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error saving journal entry: $e');
      }
    }
  }

  // Legacy method for backward compatibility
  Future<void> addEntry(TherapyJournalEntry entry, BuildContext? context) async {
    await saveJournalEntry(
      userId: entry.userId,
      title: entry.title,
      content: entry.content,
      type: entry.type,
      tags: entry.tags,
      sharingPermission: entry.sharingPermission,
      moodId: entry.moodId,
    );
  }

  // Legacy method for backward compatibility
  Future<void> updateEntry(TherapyJournalEntry updatedEntry) async {
    await saveJournalEntry(
      entryId: updatedEntry.id,
      userId: updatedEntry.userId,
      title: updatedEntry.title,
      content: updatedEntry.content,
      type: updatedEntry.type,
      tags: updatedEntry.tags,
      sharingPermission: updatedEntry.sharingPermission,
      moodId: updatedEntry.moodId,
    );
  }

  // Delete journal entry
  Future<void> deleteEntry(String entryId) async {
    try {
      _errorMessage = null;
      
      await _journalService.deleteJournalEntry(entryId);
      
      // Remove from local list
      _entries.removeWhere((entry) => entry.id == entryId);
      
      // Clear selection if deleted entry was selected
      if (_selectedEntry?.id == entryId) {
        _selectedEntry = null;
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete journal entry: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error deleting journal entry: $e');
      }
    }
  }

  // Get entries by type
  List<TherapyJournalEntry> getEntriesByType(JournalEntryType type) {
    return _entries.where((entry) => entry.type == type).toList();
  }

  // Get entries by tag
  List<TherapyJournalEntry> getEntriesByTag(String tag) {
    return _entries.where((entry) => entry.tags.contains(tag)).toList();
  }

  // Search entries by content
  List<TherapyJournalEntry> searchEntries(String query) {
    if (query.isEmpty) return _entries;
    
    return _entries.where((entry) {
      return entry.title.toLowerCase().contains(query.toLowerCase()) ||
             entry.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Save gratitude entry
  Future<void> saveGratitudeEntry({
    required String userId,
    required String content,
    required List<String> gratitudeItems,
    int rating = 5,
    String? category,
  }) async {
    try {
      final entry = GratitudeEntry(
        userId: userId,
        content: content,
        gratitudeItems: gratitudeItems,
        rating: rating,
        category: category,
      );

      await _journalService.saveGratitudeEntry(entry);
      _gratitudeEntries.insert(0, entry);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save gratitude entry: $e';
      notifyListeners();
    }
  }

  // Get all unique tags
  List<String> get allTags {
    final tags = <String>{};
    for (final entry in _entries) {
      tags.addAll(entry.tags);
    }
    return tags.toList()..sort();
  }

  // Get recent entries (last 7 days)
  List<TherapyJournalEntry> get recentEntries {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _entries.where((entry) => entry.timestamp.isAfter(weekAgo)).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load mock data for testing
  void loadMockData(String userId) {
    _entries = [
      TherapyJournalEntry(
        userId: userId,
        title: 'Feeling Better Today',
        content: 'I woke up feeling more optimistic than usual. The breathing exercises from yesterday really helped me sleep better. I\'m grateful for small improvements.',
        type: JournalEntryType.personal,
        tags: ['gratitude', 'progress', 'sleep'],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        sentimentScore: 0.3,
        emotionalTone: EmotionalTone.positive,
        aiInsights: {
          'themes': ['sleep', 'progress'],
          'recommendations': ['Continue breathing exercises', 'Consider tracking sleep patterns'],
        },
      ),
      TherapyJournalEntry(
        userId: userId,
        title: 'Therapy Session Notes',
        content: 'Today we discussed my anxiety triggers at work. Dr. Smith helped me identify the pattern of catastrophic thinking. Need to practice the STOP technique.',
        type: JournalEntryType.therapy,
        tags: ['therapy', 'anxiety', 'work'],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        sentimentScore: 0.1,
        emotionalTone: EmotionalTone.neutral,
      ),
      TherapyJournalEntry(
        userId: userId,
        title: 'Rough Day',
        content: 'Work was overwhelming today. Too many deadlines and I felt like I couldn\'t catch up. Need to remember my coping strategies.',
        type: JournalEntryType.personal,
        tags: ['work', 'stress', 'overwhelmed'],
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        sentimentScore: -0.2,
        emotionalTone: EmotionalTone.negative,
      ),
    ];

    _gratitudeEntries = [
      GratitudeEntry(
        userId: userId,
        content: 'I\'m grateful for my supportive family, the sunny weather today, and having a job even when it\'s stressful.',
        gratitudeItems: ['Family support', 'Sunny weather', 'Having a job'],
        rating: 8,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    notifyListeners();
  }
}