import 'package:uuid/uuid.dart';

enum JournalEntryType {
  personal,
  therapy,
  gratitude,
  medication,
  crisis,
  progress,
  thoughtPattern,
  sessionNotes,
}

enum EmotionalTone {
  veryPositive,
  positive,
  neutral,
  negative,
  veryNegative,
}

enum SharingPermission {
  private,
  therapistOnly,
  anonymous,
  community,
}

class TherapyJournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final JournalEntryType type;
  final DateTime timestamp;
  final DateTime? lastEdited;
  final List<String> tags;
  final SharingPermission sharingPermission;
  final bool isEncrypted;
  final String? encryptedContent;
  final String? moodId; // Link to mood entry
  final Map<String, dynamic>? aiInsights;
  final Map<String, dynamic>? thoughtPatterns;
  final List<String> attachmentUrls;
  final bool isFavorite;
  final int wordCount;
  final double? sentimentScore;
  final EmotionalTone? emotionalTone;
  final Map<String, dynamic>? metadata;

  TherapyJournalEntry({
    String? id,
    required this.userId,
    required this.title,
    required this.content,
    this.type = JournalEntryType.personal,
    DateTime? timestamp,
    this.lastEdited,
    List<String>? tags,
    this.sharingPermission = SharingPermission.private,
    this.isEncrypted = true,
    this.encryptedContent,
    this.moodId,
    this.aiInsights,
    this.thoughtPatterns,
    List<String>? attachmentUrls,
    this.isFavorite = false,
    int? wordCount,
    this.sentimentScore,
    this.emotionalTone,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        tags = tags ?? [],
        attachmentUrls = attachmentUrls ?? [],
        wordCount = wordCount ?? content.split(' ').length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': isEncrypted ? encryptedContent : content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'last_edited': lastEdited?.toIso8601String(),
      'tags': tags,
      'sharing_permission': sharingPermission.toString().split('.').last,
      'is_encrypted': isEncrypted,
      'mood_id': moodId,
      'ai_insights': aiInsights,
      'thought_patterns': thoughtPatterns,
      'attachment_urls': attachmentUrls,
      'is_favorite': isFavorite,
      'word_count': wordCount,
      'sentiment_score': sentimentScore,
      'emotional_tone': emotionalTone?.toString().split('.').last,
      'metadata': metadata,
    };
  }

  factory TherapyJournalEntry.fromMap(Map<String, dynamic> map) {
    return TherapyJournalEntry(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      type: JournalEntryType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => JournalEntryType.personal,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      lastEdited: map['last_edited'] != null ? DateTime.parse(map['last_edited']) : null,
      tags: List<String>.from(map['tags'] ?? []),
      sharingPermission: SharingPermission.values.firstWhere(
        (e) => e.toString().split('.').last == map['sharing_permission'],
        orElse: () => SharingPermission.private,
      ),
      isEncrypted: map['is_encrypted'] ?? true,
      encryptedContent: map['is_encrypted'] == true ? map['content'] : null,
      moodId: map['mood_id'],
      aiInsights: map['ai_insights'],
      thoughtPatterns: map['thought_patterns'],
      attachmentUrls: List<String>.from(map['attachment_urls'] ?? []),
      isFavorite: map['is_favorite'] ?? false,
      wordCount: map['word_count'],
      sentimentScore: map['sentiment_score']?.toDouble(),
      emotionalTone: map['emotional_tone'] != null
          ? EmotionalTone.values.firstWhere(
              (e) => e.toString().split('.').last == map['emotional_tone'],
              orElse: () => EmotionalTone.neutral,
            )
          : null,
      metadata: map['metadata'],
    );
  }

  // Compatibility getters for the old model
  bool get isPrivate => sharingPermission == SharingPermission.private;
  
  TherapyJournalEntry copyWith({
    String? title,
    String? content,
    JournalEntryType? type,
    DateTime? lastEdited,
    List<String>? tags,
    SharingPermission? sharingPermission,
    String? moodId,
    Map<String, dynamic>? aiInsights,
    Map<String, dynamic>? thoughtPatterns,
    List<String>? attachmentUrls,
    bool? isFavorite,
    double? sentimentScore,
    EmotionalTone? emotionalTone,
    Map<String, dynamic>? metadata,
  }) {
    return TherapyJournalEntry(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp,
      lastEdited: lastEdited ?? DateTime.now(),
      tags: tags ?? this.tags,
      sharingPermission: sharingPermission ?? this.sharingPermission,
      isEncrypted: isEncrypted,
      encryptedContent: encryptedContent,
      moodId: moodId ?? this.moodId,
      aiInsights: aiInsights ?? this.aiInsights,
      thoughtPatterns: thoughtPatterns ?? this.thoughtPatterns,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      isFavorite: isFavorite ?? this.isFavorite,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      metadata: metadata ?? this.metadata,
    );
  }
}

class GratitudeEntry {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final List<String> gratitudeItems;
  final int rating; // 1-10 gratitude intensity
  final String? category;
  final bool isShared;

  GratitudeEntry({
    String? id,
    required this.userId,
    required this.content,
    DateTime? timestamp,
    List<String>? gratitudeItems,
    this.rating = 5,
    this.category,
    this.isShared = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        gratitudeItems = gratitudeItems ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'gratitude_items': gratitudeItems,
      'rating': rating,
      'category': category,
      'is_shared': isShared,
    };
  }

  factory GratitudeEntry.fromMap(Map<String, dynamic> map) {
    return GratitudeEntry(
      id: map['id'],
      userId: map['user_id'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      gratitudeItems: List<String>.from(map['gratitude_items'] ?? []),
      rating: map['rating'] ?? 5,
      category: map['category'],
      isShared: map['is_shared'] ?? false,
    );
  }
}

class MedicationLog {
  final String id;
  final String userId;
  final String medicationName;
  final String dosage;
  final DateTime timestamp;
  final String? notes;
  final int? effectivenessRating; // 1-10
  final List<String> sideEffects;
  final bool taken;
  final String? prescribedBy;

  MedicationLog({
    String? id,
    required this.userId,
    required this.medicationName,
    required this.dosage,
    DateTime? timestamp,
    this.notes,
    this.effectivenessRating,
    List<String>? sideEffects,
    this.taken = true,
    this.prescribedBy,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        sideEffects = sideEffects ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'medication_name': medicationName,
      'dosage': dosage,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'effectiveness_rating': effectivenessRating,
      'side_effects': sideEffects,
      'taken': taken,
      'prescribed_by': prescribedBy,
    };
  }

  factory MedicationLog.fromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'],
      userId: map['user_id'],
      medicationName: map['medication_name'],
      dosage: map['dosage'],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
      effectivenessRating: map['effectiveness_rating'],
      sideEffects: List<String>.from(map['side_effects'] ?? []),
      taken: map['taken'] ?? true,
      prescribedBy: map['prescribed_by'],
    );
  }
}

class ThoughtPattern {
  final String id;
  final String userId;
  final String journalEntryId;
  final String automaticThought;
  final String cognitiveDistortion;
  final String challengedThought;
  final String balancedThought;
  final int emotionIntensityBefore; // 1-10
  final int emotionIntensityAfter; // 1-10
  final DateTime timestamp;
  final List<String> emotions;
  final String? triggerSituation;

  ThoughtPattern({
    String? id,
    required this.userId,
    required this.journalEntryId,
    required this.automaticThought,
    required this.cognitiveDistortion,
    required this.challengedThought,
    required this.balancedThought,
    required this.emotionIntensityBefore,
    required this.emotionIntensityAfter,
    DateTime? timestamp,
    List<String>? emotions,
    this.triggerSituation,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        emotions = emotions ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'journal_entry_id': journalEntryId,
      'automatic_thought': automaticThought,
      'cognitive_distortion': cognitiveDistortion,
      'challenged_thought': challengedThought,
      'balanced_thought': balancedThought,
      'emotion_intensity_before': emotionIntensityBefore,
      'emotion_intensity_after': emotionIntensityAfter,
      'timestamp': timestamp.toIso8601String(),
      'emotions': emotions,
      'trigger_situation': triggerSituation,
    };
  }

  factory ThoughtPattern.fromMap(Map<String, dynamic> map) {
    return ThoughtPattern(
      id: map['id'],
      userId: map['user_id'],
      journalEntryId: map['journal_entry_id'],
      automaticThought: map['automatic_thought'],
      cognitiveDistortion: map['cognitive_distortion'],
      challengedThought: map['challenged_thought'],
      balancedThought: map['balanced_thought'],
      emotionIntensityBefore: map['emotion_intensity_before'],
      emotionIntensityAfter: map['emotion_intensity_after'],
      timestamp: DateTime.parse(map['timestamp']),
      emotions: List<String>.from(map['emotions'] ?? []),
      triggerSituation: map['trigger_situation'],
    );
  }
}

class SessionNote {
  final String id;
  final String userId;
  final String therapistName;
  final String sessionType; // 'individual', 'group', 'family'
  final DateTime sessionDate;
  final int durationMinutes;
  final String notes;
  final List<String> keyInsights;
  final List<String> homework;
  final String? nextSessionDate;
  final int sessionRating; // 1-10
  final List<String> topicsDiscussed;
  final String? moodBefore;
  final String? moodAfter;

  SessionNote({
    String? id,
    required this.userId,
    required this.therapistName,
    required this.sessionType,
    required this.sessionDate,
    required this.durationMinutes,
    required this.notes,
    List<String>? keyInsights,
    List<String>? homework,
    this.nextSessionDate,
    this.sessionRating = 5,
    List<String>? topicsDiscussed,
    this.moodBefore,
    this.moodAfter,
  })  : id = id ?? const Uuid().v4(),
        keyInsights = keyInsights ?? [],
        homework = homework ?? [],
        topicsDiscussed = topicsDiscussed ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'therapist_name': therapistName,
      'session_type': sessionType,
      'session_date': sessionDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': notes,
      'key_insights': keyInsights,
      'homework': homework,
      'next_session_date': nextSessionDate,
      'session_rating': sessionRating,
      'topics_discussed': topicsDiscussed,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
    };
  }

  factory SessionNote.fromMap(Map<String, dynamic> map) {
    return SessionNote(
      id: map['id'],
      userId: map['user_id'],
      therapistName: map['therapist_name'],
      sessionType: map['session_type'],
      sessionDate: DateTime.parse(map['session_date']),
      durationMinutes: map['duration_minutes'],
      notes: map['notes'],
      keyInsights: List<String>.from(map['key_insights'] ?? []),
      homework: List<String>.from(map['homework'] ?? []),
      nextSessionDate: map['next_session_date'],
      sessionRating: map['session_rating'] ?? 5,
      topicsDiscussed: List<String>.from(map['topics_discussed'] ?? []),
      moodBefore: map['mood_before'],
      moodAfter: map['mood_after'],
    );
  }
}