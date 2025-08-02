import 'package:uuid/uuid.dart';

enum LearningCategory {
  cbt,
  dbt,
  mindfulness,
  anxiety,
  depression,
  stress,
  selfCare,
  relationships,
  sleep,
  general,
}

enum ContentType {
  article,
  video,
  audio,
  exercise,
  worksheet,
  quiz,
}

enum Difficulty {
  beginner,
  intermediate,
  advanced,
}

class LearningModule {
  final String id;
  final String title;
  final String description;
  final LearningCategory category;
  final ContentType type;
  final Difficulty difficulty;
  final int estimatedMinutes;
  final String? thumbnailUrl;
  final List<String> tags;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final String authorName;
  final bool isPremium;
  final List<LearningContent> content;
  final Map<String, dynamic>? metadata;

  LearningModule({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.estimatedMinutes,
    this.thumbnailUrl,
    List<String>? tags,
    this.rating = 0.0,
    this.ratingCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.authorId,
    required this.authorName,
    this.isPremium = false,
    List<LearningContent>? content,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        content = content ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'estimated_minutes': estimatedMinutes,
      'thumbnail_url': thumbnailUrl,
      'tags': tags,
      'rating': rating,
      'rating_count': ratingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author_id': authorId,
      'author_name': authorName,
      'is_premium': isPremium,
      'content': content.map((c) => c.toMap()).toList(),
      'metadata': metadata,
    };
  }

  factory LearningModule.fromMap(Map<String, dynamic> map) {
    return LearningModule(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: LearningCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => LearningCategory.general,
      ),
      type: ContentType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ContentType.article,
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.toString().split('.').last == map['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      estimatedMinutes: map['estimated_minutes'] ?? 0,
      thumbnailUrl: map['thumbnail_url'],
      tags: List<String>.from(map['tags'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['rating_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      authorId: map['author_id'],
      authorName: map['author_name'],
      isPremium: map['is_premium'] ?? false,
      content: (map['content'] as List<dynamic>?)
          ?.map((c) => LearningContent.fromMap(c))
          .toList() ?? [],
      metadata: map['metadata'],
    );
  }
}

class LearningContent {
  final String id;
  final String title;
  final String content;
  final ContentType type;
  final int order;
  final String? mediaUrl;
  final Map<String, dynamic>? interactiveData;

  LearningContent({
    String? id,
    required this.title,
    required this.content,
    required this.type,
    required this.order,
    this.mediaUrl,
    this.interactiveData,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'order': order,
      'media_url': mediaUrl,
      'interactive_data': interactiveData,
    };
  }

  factory LearningContent.fromMap(Map<String, dynamic> map) {
    return LearningContent(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      type: ContentType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ContentType.article,
      ),
      order: map['order'] ?? 0,
      mediaUrl: map['media_url'],
      interactiveData: map['interactive_data'],
    );
  }
}

class UserProgress {
  final String id;
  final String userId;
  final String moduleId;
  final double completionPercentage;
  final List<String> completedContentIds;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final int timeSpentMinutes;
  final Map<String, dynamic>? exerciseResults;

  UserProgress({
    String? id,
    required this.userId,
    required this.moduleId,
    this.completionPercentage = 0.0,
    List<String>? completedContentIds,
    DateTime? startedAt,
    this.completedAt,
    DateTime? lastAccessedAt,
    this.timeSpentMinutes = 0,
    this.exerciseResults,
  })  : id = id ?? const Uuid().v4(),
        completedContentIds = completedContentIds ?? [],
        startedAt = startedAt ?? DateTime.now(),
        lastAccessedAt = lastAccessedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'module_id': moduleId,
      'completion_percentage': completionPercentage,
      'completed_content_ids': completedContentIds,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'time_spent_minutes': timeSpentMinutes,
      'exercise_results': exerciseResults,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'],
      userId: map['user_id'],
      moduleId: map['module_id'],
      completionPercentage: (map['completion_percentage'] ?? 0.0).toDouble(),
      completedContentIds: List<String>.from(map['completed_content_ids'] ?? []),
      startedAt: DateTime.parse(map['started_at']),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      lastAccessedAt: DateTime.parse(map['last_accessed_at']),
      timeSpentMinutes: map['time_spent_minutes'] ?? 0,
      exerciseResults: map['exercise_results'],
    );
  }

  UserProgress copyWith({
    double? completionPercentage,
    List<String>? completedContentIds,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    int? timeSpentMinutes,
    Map<String, dynamic>? exerciseResults,
  }) {
    return UserProgress(
      id: id,
      userId: userId,
      moduleId: moduleId,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      completedContentIds: completedContentIds ?? this.completedContentIds,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      exerciseResults: exerciseResults ?? this.exerciseResults,
    );
  }
}

class LearningPath {
  final String id;
  final String title;
  final String description;
  final List<String> moduleIds;
  final LearningCategory category;
  final Difficulty difficulty;
  final int estimatedHours;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final String authorId;
  final String authorName;
  final bool isPremium;

  LearningPath({
    String? id,
    required this.title,
    required this.description,
    required this.moduleIds,
    required this.category,
    required this.difficulty,
    required this.estimatedHours,
    this.thumbnailUrl,
    DateTime? createdAt,
    required this.authorId,
    required this.authorName,
    this.isPremium = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'module_ids': moduleIds,
      'category': category.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'estimated_hours': estimatedHours,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'author_id': authorId,
      'author_name': authorName,
      'is_premium': isPremium,
    };
  }

  factory LearningPath.fromMap(Map<String, dynamic> map) {
    return LearningPath(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      moduleIds: List<String>.from(map['module_ids'] ?? []),
      category: LearningCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => LearningCategory.general,
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.toString().split('.').last == map['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      estimatedHours: map['estimated_hours'] ?? 0,
      thumbnailUrl: map['thumbnail_url'],
      createdAt: DateTime.parse(map['created_at']),
      authorId: map['author_id'],
      authorName: map['author_name'],
      isPremium: map['is_premium'] ?? false,
    );
  }
}