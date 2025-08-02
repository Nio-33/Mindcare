import 'package:uuid/uuid.dart';

enum MessageType {
  user,
  assistant,
  system,
  crisis,
}

enum MessageCategory {
  general,
  assessment,
  coping,
  crisis,
  educational,
  therapeutic,
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String userId;
  final String content;
  final MessageType type;
  final MessageCategory category;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final bool isEncrypted;
  final List<String>? suggestedResponses;
  final Map<String, dynamic>? therapeuticContext;

  ChatMessage({
    String? id,
    required this.sessionId,
    required this.userId,
    required this.content,
    required this.type,
    this.category = MessageCategory.general,
    DateTime? timestamp,
    this.metadata,
    this.isEncrypted = true,
    this.suggestedResponses,
    this.therapeuticContext,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'content': content,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'is_encrypted': isEncrypted,
      'suggested_responses': suggestedResponses,
      'therapeutic_context': therapeuticContext,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      sessionId: map['session_id'],
      userId: map['user_id'],
      content: map['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.user,
      ),
      category: MessageCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => MessageCategory.general,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      metadata: map['metadata'],
      isEncrypted: map['is_encrypted'] ?? true,
      suggestedResponses: map['suggested_responses'] != null
          ? List<String>.from(map['suggested_responses'])
          : null,
      therapeuticContext: map['therapeutic_context'],
    );
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? content,
    MessageType? type,
    MessageCategory? category,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isEncrypted,
    List<String>? suggestedResponses,
    Map<String, dynamic>? therapeuticContext,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      suggestedResponses: suggestedResponses ?? this.suggestedResponses,
      therapeuticContext: therapeuticContext ?? this.therapeuticContext,
    );
  }
}

class TherapyChatSession {
  final String id;
  final String userId;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int messageCount;
  final Map<String, dynamic>? sessionSummary;
  final List<String> therapeuticGoals;
  final String currentTheme;
  final Map<String, dynamic>? riskAssessment;

  TherapyChatSession({
    String? id,
    required this.userId,
    required this.title,
    DateTime? startedAt,
    this.endedAt,
    this.messageCount = 0,
    this.sessionSummary,
    this.therapeuticGoals = const [],
    this.currentTheme = 'general_support',
    this.riskAssessment,
  })  : id = id ?? const Uuid().v4(),
        startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'message_count': messageCount,
      'session_summary': sessionSummary,
      'therapeutic_goals': therapeuticGoals,
      'current_theme': currentTheme,
      'risk_assessment': riskAssessment,
    };
  }

  factory TherapyChatSession.fromMap(Map<String, dynamic> map) {
    return TherapyChatSession(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      startedAt: DateTime.parse(map['started_at']),
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at']) : null,
      messageCount: map['message_count'] ?? 0,
      sessionSummary: map['session_summary'],
      therapeuticGoals: map['therapeutic_goals'] != null
          ? List<String>.from(map['therapeutic_goals'])
          : [],
      currentTheme: map['current_theme'] ?? 'general_support',
      riskAssessment: map['risk_assessment'],
    );
  }
}