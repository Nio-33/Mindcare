import 'package:uuid/uuid.dart';

enum SupportGroupType {
  anxiety,
  depression,
  addiction,
  grief,
  ptsd,
  bipolar,
  eating,
  general,
}

enum PostType {
  discussion,
  question,
  victory,
  support,
  resource,
}

class SupportGroup {
  final String id;
  final String name;
  final String description;
  final SupportGroupType type;
  final String moderatorId;
  final List<String> memberIds;
  final DateTime createdAt;
  final bool isPrivate;
  final String? imageUrl;
  final Map<String, dynamic>? guidelines;
  final int memberCount;
  final int postCount;

  SupportGroup({
    String? id,
    required this.name,
    required this.description,
    required this.type,
    required this.moderatorId,
    List<String>? memberIds,
    DateTime? createdAt,
    this.isPrivate = false,
    this.imageUrl,
    this.guidelines,
    this.memberCount = 0,
    this.postCount = 0,
  })  : id = id ?? const Uuid().v4(),
        memberIds = memberIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'moderator_id': moderatorId,
      'member_ids': memberIds,
      'created_at': createdAt.toIso8601String(),
      'is_private': isPrivate,
      'image_url': imageUrl,
      'guidelines': guidelines,
      'member_count': memberCount,
      'post_count': postCount,
    };
  }

  factory SupportGroup.fromMap(Map<String, dynamic> map) {
    return SupportGroup(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: SupportGroupType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => SupportGroupType.general,
      ),
      moderatorId: map['moderator_id'],
      memberIds: List<String>.from(map['member_ids'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      isPrivate: map['is_private'] ?? false,
      imageUrl: map['image_url'],
      guidelines: map['guidelines'],
      memberCount: map['member_count'] ?? 0,
      postCount: map['post_count'] ?? 0,
    );
  }
}

class CommunityPost {
  final String id;
  final String groupId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final PostType type;
  final DateTime createdAt;
  final List<String> tags;
  final int likeCount;
  final int replyCount;
  final bool isAnonymous;
  final Map<String, dynamic>? metadata;

  CommunityPost({
    String? id,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.type,
    DateTime? createdAt,
    List<String>? tags,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isAnonymous = false,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'author_id': authorId,
      'author_name': authorName,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'tags': tags,
      'like_count': likeCount,
      'reply_count': replyCount,
      'is_anonymous': isAnonymous,
      'metadata': metadata,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'],
      groupId: map['group_id'],
      authorId: map['author_id'],
      authorName: map['author_name'],
      title: map['title'],
      content: map['content'],
      type: PostType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => PostType.discussion,
      ),
      createdAt: DateTime.parse(map['created_at']),
      tags: List<String>.from(map['tags'] ?? []),
      likeCount: map['like_count'] ?? 0,
      replyCount: map['reply_count'] ?? 0,
      isAnonymous: map['is_anonymous'] ?? false,
      metadata: map['metadata'],
    );
  }
}

class PostReply {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isAnonymous;

  PostReply({
    String? id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    DateTime? createdAt,
    this.likeCount = 0,
    this.isAnonymous = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'author_name': authorName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'like_count': likeCount,
      'is_anonymous': isAnonymous,
    };
  }

  factory PostReply.fromMap(Map<String, dynamic> map) {
    return PostReply(
      id: map['id'],
      postId: map['post_id'],
      authorId: map['author_id'],
      authorName: map['author_name'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      likeCount: map['like_count'] ?? 0,
      isAnonymous: map['is_anonymous'] ?? false,
    );
  }
}