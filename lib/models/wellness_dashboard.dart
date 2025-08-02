// Note: These imports will be used when implementing wellness calculation logic
// import 'mood_entry.dart';
// import 'therapy_journal.dart';

class WellnessScore {
  final double overall; // 0-100
  final double mood; // 0-100
  final double energy; // 0-100
  final double sleep; // 0-100
  final double anxiety; // 0-100 (lower is better)
  final double consistency; // 0-100
  final DateTime calculatedAt;
  final Map<String, double>? confidenceIntervals;

  WellnessScore({
    required this.overall,
    required this.mood,
    required this.energy,
    required this.sleep,
    required this.anxiety,
    required this.consistency,
    required this.calculatedAt,
    this.confidenceIntervals,
  });

  Map<String, dynamic> toMap() {
    return {
      'overall': overall,
      'mood': mood,
      'energy': energy,
      'sleep': sleep,
      'anxiety': anxiety,
      'consistency': consistency,
      'calculated_at': calculatedAt.toIso8601String(),
      'confidence_intervals': confidenceIntervals,
    };
  }

  factory WellnessScore.fromMap(Map<String, dynamic> map) {
    return WellnessScore(
      overall: map['overall'].toDouble(),
      mood: map['mood'].toDouble(),
      energy: map['energy'].toDouble(),
      sleep: map['sleep'].toDouble(),
      anxiety: map['anxiety'].toDouble(),
      consistency: map['consistency'].toDouble(),
      calculatedAt: DateTime.parse(map['calculated_at']),
      confidenceIntervals: map['confidence_intervals'] != null
          ? Map<String, double>.from(map['confidence_intervals'])
          : null,
    );
  }
}

class WellnessInsight {
  final String id;
  final String title;
  final String description;
  final String category; // 'pattern', 'trend', 'risk', 'achievement'
  final String severity; // 'low', 'medium', 'high', 'critical'
  final List<String> recommendations;
  final DateTime generatedAt;
  final Map<String, dynamic>? supportingData;

  WellnessInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.recommendations,
    required this.generatedAt,
    this.supportingData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'recommendations': recommendations,
      'generated_at': generatedAt.toIso8601String(),
      'supporting_data': supportingData,
    };
  }

  factory WellnessInsight.fromMap(Map<String, dynamic> map) {
    return WellnessInsight(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      severity: map['severity'],
      recommendations: List<String>.from(map['recommendations']),
      generatedAt: DateTime.parse(map['generated_at']),
      supportingData: map['supporting_data'],
    );
  }
}

class PersonalizedRecommendation {
  final String id;
  final String title;
  final String description;
  final String actionType; // 'exercise', 'breathing', 'journaling', 'therapy', 'crisis'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final Duration? estimatedDuration;
  final String? resourceUrl;
  final Map<String, dynamic>? parameters;
  final DateTime generatedAt;
  final DateTime? expiresAt;

  PersonalizedRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.actionType,
    required this.priority,
    this.estimatedDuration,
    this.resourceUrl,
    this.parameters,
    required this.generatedAt,
    this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'action_type': actionType,
      'priority': priority,
      'estimated_duration': estimatedDuration?.inMinutes,
      'resource_url': resourceUrl,
      'parameters': parameters,
      'generated_at': generatedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  factory PersonalizedRecommendation.fromMap(Map<String, dynamic> map) {
    return PersonalizedRecommendation(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      actionType: map['action_type'],
      priority: map['priority'],
      estimatedDuration: map['estimated_duration'] != null
          ? Duration(minutes: map['estimated_duration'])
          : null,
      resourceUrl: map['resource_url'],
      parameters: map['parameters'],
      generatedAt: DateTime.parse(map['generated_at']),
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'])
          : null,
    );
  }
}

class WellnessDashboard {
  final String userId;
  final WellnessScore currentScore;
  final List<WellnessScore> historicalScores;
  final List<WellnessInsight> insights;
  final List<PersonalizedRecommendation> recommendations;
  final Map<String, dynamic> trendAnalysis;
  final Map<String, dynamic>? predictiveModeling;
  final DateTime lastUpdated;

  WellnessDashboard({
    required this.userId,
    required this.currentScore,
    required this.historicalScores,
    required this.insights,
    required this.recommendations,
    required this.trendAnalysis,
    this.predictiveModeling,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'current_score': currentScore.toMap(),
      'historical_scores': historicalScores.map((x) => x.toMap()).toList(),
      'insights': insights.map((x) => x.toMap()).toList(),
      'recommendations': recommendations.map((x) => x.toMap()).toList(),
      'trend_analysis': trendAnalysis,
      'predictive_modeling': predictiveModeling,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory WellnessDashboard.fromMap(Map<String, dynamic> map) {
    return WellnessDashboard(
      userId: map['user_id'],
      currentScore: WellnessScore.fromMap(map['current_score']),
      historicalScores: List<WellnessScore>.from(
        map['historical_scores']?.map((x) => WellnessScore.fromMap(x)) ?? [],
      ),
      insights: List<WellnessInsight>.from(
        map['insights']?.map((x) => WellnessInsight.fromMap(x)) ?? [],
      ),
      recommendations: List<PersonalizedRecommendation>.from(
        map['recommendations']?.map((x) => PersonalizedRecommendation.fromMap(x)) ?? [],
      ),
      trendAnalysis: map['trend_analysis'] ?? {},
      predictiveModeling: map['predictive_modeling'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
}