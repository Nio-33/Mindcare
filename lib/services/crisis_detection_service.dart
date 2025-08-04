import '../models/therapy_journal.dart';

class CrisisDetectionService {
  // Crisis keywords that trigger immediate intervention
  static const List<String> _crisisKeywords = [
    'suicide', 'kill myself', 'end my life', 'want to die', 'suicidal',
    'hurt myself', 'self harm', 'cut myself', 'overdose', 'pills',
    'jump off', 'hang myself', 'not worth living', 'better off dead',
    'emergency', 'crisis', 'help me now', 'cant go on', 'hopeless',
    'give up', 'no reason to live', 'done with life', 'life isnt worth',
  ];

  // Check if a journal entry contains crisis keywords
  static bool containsCrisisKeywords(String content) {
    final lowerContent = content.toLowerCase();
    return _crisisKeywords.any((keyword) => lowerContent.contains(keyword));
  }

  // Check a list of journal entries for crisis patterns
  static bool detectCrisisInEntries(List<TherapyJournalEntry> entries) {
    // Check recent entries (last 3)
    final recentEntries = entries.take(3);
    
    for (final entry in recentEntries) {
      if (containsCrisisKeywords(entry.content)) {
        return true;
      }
    }
    
    return false;
  }

  // Get crisis keywords found in content
  static List<String> getCrisisKeywords(String content) {
    final lowerContent = content.toLowerCase();
    return _crisisKeywords.where((keyword) => lowerContent.contains(keyword)).toList();
  }
}