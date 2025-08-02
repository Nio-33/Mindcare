import 'package:uuid/uuid.dart';

enum MoodType {
  happy,
  neutral,
  sad,
  anxious,
  angry,
  excited,
  tired,
  stressed,
  calm,
  overwhelmed,
}

class MoodEntry {
  final String id;
  final String userId;
  final MoodType mood;
  final int intensity; // 1-10 scale
  final String? notes;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodEntry({
    String? id,
    required this.userId,
    required this.mood,
    required this.intensity,
    this.notes,
    this.additionalData,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood.toString().split('.').last,
      'intensity': intensity,
      'notes': notes,
      'additional_data': additionalData,
      'timestamp': timestamp.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      userId: map['user_id'],
      mood: MoodType.values.firstWhere(
        (e) => e.toString().split('.').last == map['mood'],
        orElse: () => MoodType.neutral,
      ),
      intensity: map['intensity'],
      notes: map['notes'],
      additionalData: map['additional_data'],
      timestamp: DateTime.parse(map['timestamp']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    MoodType? mood,
    int? intensity,
    String? notes,
    Map<String, dynamic>? additionalData,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      additionalData: additionalData ?? this.additionalData,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}