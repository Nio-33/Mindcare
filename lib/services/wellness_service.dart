import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/mood_entry.dart';
import '../models/therapy_journal.dart';
import '../models/wellness_dashboard.dart';
import '../models/user_profile.dart';

class WellnessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Calculate comprehensive wellness score based on multiple factors
  WellnessScore calculateWellnessScore({
    required List<MoodEntry> recentMoods,
    required List<TherapyJournalEntry> recentJournals,
    required UserProfile userProfile,
    DateTime? calculatedAt,
  }) {
    final now = calculatedAt ?? DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    // Filter recent data
    final weekMoods = recentMoods.where((m) => m.timestamp.isAfter(last7Days)).toList();
    final monthMoods = recentMoods.where((m) => m.timestamp.isAfter(last30Days)).toList();
    final weekJournals = recentJournals.where((j) => j.timestamp.isAfter(last7Days)).toList();

    // Calculate individual components
    final moodScore = _calculateMoodScore(weekMoods, monthMoods);
    final energyScore = _calculateEnergyScore(weekMoods);
    final sleepScore = _calculateSleepScore(weekJournals);
    final anxietyScore = _calculateAnxietyScore(weekMoods, weekJournals);
    final consistencyScore = _calculateConsistencyScore(recentMoods, recentJournals);

    // Calculate overall wellness score (weighted average)
    final overall = (moodScore * 0.3 + 
                    energyScore * 0.2 + 
                    sleepScore * 0.2 + 
                    (100 - anxietyScore) * 0.2 + // Anxiety is inverse (lower is better)
                    consistencyScore * 0.1);

    return WellnessScore(
      overall: overall.clamp(0, 100),
      mood: moodScore,
      energy: energyScore,
      sleep: sleepScore,
      anxiety: anxietyScore,
      consistency: consistencyScore,
      calculatedAt: now,
      confidenceIntervals: {
        'overall': _calculateConfidence(weekMoods.length + weekJournals.length),
        'mood': _calculateConfidence(weekMoods.length),
        'energy': _calculateConfidence(weekMoods.length),
        'sleep': _calculateConfidence(weekJournals.length),
        'anxiety': _calculateConfidence(weekMoods.length + weekJournals.length),
        'consistency': _calculateConfidence(recentMoods.length + recentJournals.length),
      },
    );
  }

  double _calculateMoodScore(List<MoodEntry> weekMoods, List<MoodEntry> monthMoods) {
    if (weekMoods.isEmpty) return 50.0; // Neutral if no data

    // Calculate average mood intensity and type weighting
    double totalScore = 0;
    for (final mood in weekMoods) {
      double moodMultiplier = _getMoodTypeMultiplier(mood.mood);
      double intensityScore = (mood.intensity / 10.0) * 100;
      totalScore += intensityScore * moodMultiplier;
    }

    double weekScore = totalScore / weekMoods.length;

    // Apply trend adjustment based on month vs week comparison
    if (monthMoods.length > weekMoods.length) {
      double monthAvg = monthMoods.map((m) => m.intensity).reduce((a, b) => a + b) / monthMoods.length;
      double weekAvg = weekMoods.map((m) => m.intensity).reduce((a, b) => a + b) / weekMoods.length;
      double trendAdjustment = (weekAvg - monthAvg) * 5; // Small trend bonus/penalty
      weekScore += trendAdjustment;
    }

    return weekScore.clamp(0, 100);
  }

  double _getMoodTypeMultiplier(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
      case MoodType.excited:
      case MoodType.calm:
        return 1.0; // Positive moods at full value
      case MoodType.neutral:
        return 0.5; // Neutral mood
      case MoodType.tired:
        return 0.3; // Somewhat negative
      case MoodType.sad:
      case MoodType.stressed:
        return 0.2; // Negative moods
      case MoodType.anxious:
      case MoodType.angry:
      case MoodType.overwhelmed:
        return 0.1; // Most concerning moods
    }
  }

  double _calculateEnergyScore(List<MoodEntry> weekMoods) {
    if (weekMoods.isEmpty) return 50.0;

    // Energy is inferred from mood patterns and intensity
    double energySum = 0;
    for (final mood in weekMoods) {
      switch (mood.mood) {
        case MoodType.excited:
        case MoodType.happy:
          energySum += mood.intensity * 10;
          break;
        case MoodType.calm:
        case MoodType.neutral:
          energySum += mood.intensity * 6;
          break;
        case MoodType.tired:
          energySum += mood.intensity * 2;
          break;
        case MoodType.overwhelmed:
        case MoodType.stressed:
          energySum += mood.intensity * 3;
          break;
        default:
          energySum += mood.intensity * 5;
      }
    }

    return (energySum / (weekMoods.length * 10)).clamp(0, 100);
  }

  double _calculateSleepScore(List<TherapyJournalEntry> weekJournals) {
    // Extract sleep-related insights from journal entries
    double sleepScore = 50.0; // Default neutral

    for (final journal in weekJournals) {
      final content = journal.content.toLowerCase();
      
      // Positive sleep indicators
      if (content.contains('slept well') || content.contains('good sleep') || 
          content.contains('rested') || content.contains('refreshed')) {
        sleepScore += 10;
      }
      
      // Negative sleep indicators
      if (content.contains('insomnia') || content.contains("couldn't sleep") || 
          content.contains('tired') || content.contains('exhausted') ||
          content.contains('sleepless')) {
        sleepScore -= 15;
      }
    }

    return sleepScore.clamp(0, 100);
  }

  double _calculateAnxietyScore(List<MoodEntry> weekMoods, List<TherapyJournalEntry> weekJournals) {
    double anxietyScore = 0;

    // Mood-based anxiety indicators
    for (final mood in weekMoods) {
      if (mood.mood == MoodType.anxious) {
        anxietyScore += mood.intensity * 8;
      } else if (mood.mood == MoodType.overwhelmed || mood.mood == MoodType.stressed) {
        anxietyScore += mood.intensity * 6;
      } else if (mood.mood == MoodType.angry) {
        anxietyScore += mood.intensity * 4;
      }
    }

    // Journal-based anxiety indicators
    for (final journal in weekJournals) {
      final content = journal.content.toLowerCase();
      if (content.contains('anxious') || content.contains('anxiety') || 
          content.contains('panic') || content.contains('worried') ||
          content.contains('stress')) {
        anxietyScore += 15;
      }
    }

    if (weekMoods.isEmpty && weekJournals.isEmpty) return 20.0; // Low anxiety if no data

    double avgAnxiety = anxietyScore / (weekMoods.length + weekJournals.length).clamp(1, double.infinity);
    return avgAnxiety.clamp(0, 100);
  }

  double _calculateConsistencyScore(List<MoodEntry> allMoods, List<TherapyJournalEntry> allJournals) {
    final now = DateTime.now();
    double consistencyScore = 0;

    // Check daily engagement over last 7 days
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayMoods = allMoods.where((m) => 
        m.timestamp.isAfter(dayStart) && m.timestamp.isBefore(dayEnd)).length;
      final dayJournals = allJournals.where((j) => 
        j.timestamp.isAfter(dayStart) && j.timestamp.isBefore(dayEnd)).length;

      if (dayMoods > 0 || dayJournals > 0) {
        consistencyScore += 14.3; // ~100/7 points per day
      }
    }

    return consistencyScore.clamp(0, 100);
  }

  double _calculateConfidence(int dataPoints) {
    if (dataPoints == 0) return 0.0;
    if (dataPoints >= 14) return 0.95; // High confidence with 2+ weeks
    if (dataPoints >= 7) return 0.80;  // Good confidence with 1 week
    if (dataPoints >= 3) return 0.60;  // Moderate confidence
    return 0.30; // Low confidence with limited data
  }

  // Generate personalized insights based on data patterns
  List<WellnessInsight> generateInsights({
    required WellnessScore currentScore,
    required List<WellnessScore> historicalScores,
    required List<MoodEntry> recentMoods,
    required List<TherapyJournalEntry> recentJournals,
  }) {
    List<WellnessInsight> insights = [];
    final now = DateTime.now();

    // Trend Analysis
    if (historicalScores.length >= 2) {
      final trend = _analyzeTrend(historicalScores);
      if (trend.isNotEmpty) {
        insights.addAll(trend);
      }
    }

    // Pattern Recognition
    final patterns = _recognizePatterns(recentMoods, recentJournals);
    insights.addAll(patterns);

    // Risk Assessment
    final riskInsights = _assessRisk(currentScore, recentMoods, recentJournals);
    insights.addAll(riskInsights);

    return insights;
  }

  List<WellnessInsight> _analyzeTrend(List<WellnessScore> scores) {
    final insights = <WellnessInsight>[];
    final recent = scores.take(3).toList();
    
    if (recent.length < 2) return insights;

    final currentScore = recent.first.overall;
    final previousScore = recent[1].overall;
    final change = currentScore - previousScore;

    if (change > 10) {
      insights.add(WellnessInsight(
        id: 'trend_positive',
        title: 'Wellness Improving! 📈',
        description: 'Your overall wellness has improved by ${change.round()} points recently.',
        category: 'trend',
        severity: 'low',
        recommendations: [
          'Keep up the great work with your current routine',
          'Consider what changes have been most helpful',
          'Share your progress with your support network'
        ],
        generatedAt: DateTime.now(),
      ));
    } else if (change < -10) {
      insights.add(WellnessInsight(
        id: 'trend_concerning',
        title: 'Wellness Declining',
        description: 'Your wellness score has decreased by ${change.abs().round()} points.',
        category: 'risk',
        severity: 'medium',
        recommendations: [
          'Consider reaching out to a mental health professional',
          'Review recent stressors or changes in your life',
          'Focus on self-care activities that have helped before'
        ],
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  List<WellnessInsight> _recognizePatterns(List<MoodEntry> moods, List<TherapyJournalEntry> journals) {
    final insights = <WellnessInsight>[];
    
    // Weekly pattern analysis
    final weekdayMoods = <int, List<MoodEntry>>{};
    for (final mood in moods) {
      final weekday = mood.timestamp.weekday;
      weekdayMoods.putIfAbsent(weekday, () => []).add(mood);
    }

    // Find challenging days
    double lowestDayScore = 100;
    int challengingDay = 1;
    
    weekdayMoods.forEach((day, dayMoods) {
      if (dayMoods.isNotEmpty) {
        final avgIntensity = dayMoods.map((m) => m.intensity).reduce((a, b) => a + b) / dayMoods.length;
        if (avgIntensity < lowestDayScore) {
          lowestDayScore = avgIntensity;
          challengingDay = day;
        }
      }
    });

    if (lowestDayScore < 4) {
      final dayName = _getDayName(challengingDay);
      insights.add(WellnessInsight(
        id: 'pattern_difficult_day',
        title: '$dayName Challenges',
        description: 'You tend to have more difficult days on ${dayName}s.',
        category: 'pattern',
        severity: 'medium',
        recommendations: [
          'Plan extra self-care activities for ${dayName}s',
          'Consider what makes ${dayName}s more challenging',
          'Schedule lighter commitments on this day when possible'
        ],
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  List<WellnessInsight> _assessRisk(WellnessScore score, List<MoodEntry> moods, List<TherapyJournalEntry> journals) {
    final insights = <WellnessInsight>[];

    // High anxiety risk
    if (score.anxiety > 70) {
      insights.add(WellnessInsight(
        id: 'risk_high_anxiety',
        title: 'Elevated Anxiety Levels',
        description: 'Your anxiety levels have been consistently high recently.',
        category: 'risk',
        severity: 'high',
        recommendations: [
          'Practice deep breathing exercises',
          'Consider speaking with a therapist',
          'Try grounding techniques (5-4-3-2-1 method)',
          'Limit caffeine and news consumption'
        ],
        generatedAt: DateTime.now(),
      ));
    }

    // Low overall wellness
    if (score.overall < 30) {
      insights.add(WellnessInsight(
        id: 'risk_low_wellness',
        title: 'Low Overall Wellness',
        description: 'Your overall wellness score suggests you may be struggling.',
        category: 'risk',
        severity: 'critical',
        recommendations: [
          'Reach out to a mental health professional immediately',
          'Contact your support network',
          'Focus on basic self-care: sleep, nutrition, hydration',
          'Consider crisis resources if feeling unsafe'
        ],
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  String _getDayName(int weekday) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday];
  }

  // Generate personalized recommendations
  List<PersonalizedRecommendation> generateRecommendations({
    required WellnessScore currentScore,
    required List<MoodEntry> recentMoods,
    required UserProfile userProfile,
  }) {
    final recommendations = <PersonalizedRecommendation>[];
    final now = DateTime.now();

    // Mood-based recommendations
    if (currentScore.mood < 40) {
      recommendations.add(PersonalizedRecommendation(
        id: 'mood_boost',
        title: 'Mood Boosting Activity',
        description: 'Try a 10-minute guided meditation or gentle walk outside',
        actionType: 'exercise',
        priority: 'high',
        estimatedDuration: const Duration(minutes: 10),
        generatedAt: now,
        expiresAt: now.add(const Duration(hours: 4)),
      ));
    }

    // Anxiety management
    if (currentScore.anxiety > 60) {
      recommendations.add(PersonalizedRecommendation(
        id: 'anxiety_relief',
        title: 'Anxiety Relief',
        description: 'Practice the 4-7-8 breathing technique for immediate calm',
        actionType: 'breathing',
        priority: 'high',
        estimatedDuration: const Duration(minutes: 5),
        generatedAt: now,
        expiresAt: now.add(const Duration(hours: 2)),
      ));
    }

    // Consistency encouragement
    if (currentScore.consistency < 50) {
      recommendations.add(PersonalizedRecommendation(
        id: 'consistency_boost',
        title: 'Daily Check-in',
        description: 'Take 2 minutes to log your current mood and thoughts',
        actionType: 'journaling',
        priority: 'medium',
        estimatedDuration: const Duration(minutes: 2),
        generatedAt: now,
        expiresAt: now.add(const Duration(hours: 8)),
      ));
    }

    return recommendations;
  }

  // Save wellness data to Firestore
  Future<void> saveWellnessDashboard(String userId, WellnessDashboard dashboard) async {
    try {
      await _firestore
          .collection('wellness_dashboards')
          .doc(userId)
          .set(dashboard.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving wellness dashboard: $e');
      }
      throw Exception('Failed to save wellness data');
    }
  }

  // Load wellness data from Firestore
  Future<WellnessDashboard?> loadWellnessDashboard(String userId) async {
    try {
      final doc = await _firestore
          .collection('wellness_dashboards')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return WellnessDashboard.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading wellness dashboard: $e');
      }
      return null;
    }
  }

  // Predictive Analytics
  Map<String, dynamic> generatePredictiveAnalytics({
    required List<WellnessScore> historicalScores,
    required List<MoodEntry> recentMoods,
    required List<TherapyJournalEntry> recentJournals,
  }) {
    if (historicalScores.length < 3) {
      return {
        'confidence': 0.0,
        'message': 'Insufficient data for predictions',
      };
    }

    // Simple linear regression for trend prediction
    final predictions = _calculateTrendPredictions(historicalScores);
    
    // Risk assessment based on patterns
    final riskAssessment = _predictRiskLevels(historicalScores, recentMoods, recentJournals);
    
    // Wellness trajectory
    final trajectory = _predictWellnessTrajectory(historicalScores);
    
    // Intervention recommendations
    final interventions = _recommendInterventions(predictions, riskAssessment);

    return {
      'predictions': predictions,
      'risk_assessment': riskAssessment,
      'trajectory': trajectory,
      'interventions': interventions,
      'confidence': _calculatePredictionConfidence(historicalScores.length),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _calculateTrendPredictions(List<WellnessScore> scores) {
    final recentScores = scores.take(10).toList();
    
    // Calculate trends for each metric
    final overallTrend = _calculateLinearTrend(recentScores.map((s) => s.overall).toList());
    final moodTrend = _calculateLinearTrend(recentScores.map((s) => s.mood).toList());
    final anxietyTrend = _calculateLinearTrend(recentScores.map((s) => s.anxiety).toList());
    final energyTrend = _calculateLinearTrend(recentScores.map((s) => s.energy).toList());
    
    // Predict next 7 days
    final predictions = <String, dynamic>{};
    for (int i = 1; i <= 7; i++) {
      predictions['day_$i'] = {
        'overall': (recentScores.first.overall + (overallTrend * i)).clamp(0, 100),
        'mood': (recentScores.first.mood + (moodTrend * i)).clamp(0, 100),
        'anxiety': (recentScores.first.anxiety + (anxietyTrend * i)).clamp(0, 100),
        'energy': (recentScores.first.energy + (energyTrend * i)).clamp(0, 100),
      };
    }
    
    return {
      'next_7_days': predictions,
      'trends': {
        'overall': overallTrend,
        'mood': moodTrend,
        'anxiety': anxietyTrend,
        'energy': energyTrend,
      },
    };
  }

  double _calculateLinearTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    final sumX = (n * (n - 1)) / 2; // 0 + 1 + 2 + ... + (n-1)
    final sumY = values.reduce((a, b) => a + b);
    final sumXY = values.asMap().entries.map((e) => e.key * e.value).reduce((a, b) => a + b);
    final sumXX = (n * (n - 1) * (2 * n - 1)) / 6; // Sum of squares
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope.isFinite ? slope : 0.0;
  }

  Map<String, dynamic> _predictRiskLevels(List<WellnessScore> scores, List<MoodEntry> moods, List<TherapyJournalEntry> journals) {
    final currentScore = scores.first;
    final volatility = _calculateVolatility(scores.take(7).toList());
    
    // Risk factors
    final anxietyRisk = currentScore.anxiety > 70 ? 'high' : currentScore.anxiety > 50 ? 'medium' : 'low';
    final moodRisk = currentScore.mood < 30 ? 'high' : currentScore.mood < 50 ? 'medium' : 'low';
    final consistencyRisk = currentScore.consistency < 40 ? 'high' : currentScore.consistency < 60 ? 'medium' : 'low';
    
    // Pattern-based risks
    final patterns = _identifyRiskPatterns(moods, journals);
    
    return {
      'overall_risk': _calculateOverallRisk([anxietyRisk, moodRisk, consistencyRisk]),
      'anxiety_risk': anxietyRisk,
      'mood_risk': moodRisk,
      'consistency_risk': consistencyRisk,
      'volatility': volatility,
      'risk_patterns': patterns,
      'early_warning_signs': _identifyEarlyWarnings(scores, moods),
    };
  }

  double _calculateVolatility(List<WellnessScore> scores) {
    if (scores.length < 2) return 0.0;
    
    final values = scores.map((s) => s.overall).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  String _calculateOverallRisk(List<String> risks) {
    final highCount = risks.where((r) => r == 'high').length;
    final mediumCount = risks.where((r) => r == 'medium').length;
    
    if (highCount >= 2) return 'high';
    if (highCount >= 1 || mediumCount >= 2) return 'medium';
    return 'low';
  }

  List<String> _identifyRiskPatterns(List<MoodEntry> moods, List<TherapyJournalEntry> journals) {
    final patterns = <String>[];
    
    // Check for concerning mood patterns
    final recentMoods = moods.take(7).toList();
    final anxiousMoods = recentMoods.where((m) => m.mood == MoodType.anxious).length;
    final lowMoods = recentMoods.where((m) => m.intensity <= 3).length;
    
    if (anxiousMoods >= 3) patterns.add('frequent_anxiety');
    if (lowMoods >= 4) patterns.add('persistent_low_mood');
    
    // Check journal sentiment patterns
    final recentJournals = journals.take(5).toList();
    final negativeSentiment = recentJournals.where((j) => (j.sentimentScore ?? 0) < -0.2).length;
    
    if (negativeSentiment >= 3) patterns.add('negative_journaling_trend');
    
    return patterns;
  }

  List<String> _identifyEarlyWarnings(List<WellnessScore> scores, List<MoodEntry> moods) {
    final warnings = <String>[];
    
    if (scores.length >= 3) {
      final recent = scores.take(3).toList();
      final declining = recent[0].overall < recent[1].overall && recent[1].overall < recent[2].overall;
      if (declining) warnings.add('declining_wellness_trend');
    }
    
    final recentMoods = moods.take(3).toList();
    final allLowIntensity = recentMoods.every((m) => m.intensity <= 4);
    if (allLowIntensity && recentMoods.isNotEmpty) warnings.add('consistently_low_mood');
    
    return warnings;
  }

  Map<String, dynamic> _predictWellnessTrajectory(List<WellnessScore> scores) {
    final recentScores = scores.take(10).toList();
    final trend = _calculateLinearTrend(recentScores.map((s) => s.overall).toList());
    
    String trajectory;
    if (trend > 2) {
      trajectory = 'improving';
    } else if (trend < -2) {
      trajectory = 'declining';
    } else {
      trajectory = 'stable';
    }
    
    // Project 30 days ahead
    final currentScore = recentScores.first.overall;
    final projected30Day = (currentScore + (trend * 30)).clamp(0, 100);
    
    return {
      'current_trajectory': trajectory,
      'trend_slope': trend,
      'projected_30_day': projected30Day,
      'confidence': _calculateTrendConfidence(recentScores.length, trend),
    };
  }

  List<Map<String, dynamic>> _recommendInterventions(Map<String, dynamic> predictions, Map<String, dynamic> riskAssessment) {
    final interventions = <Map<String, dynamic>>[];
    
    final overallRisk = riskAssessment['overall_risk'];
    final trends = predictions['trends'] as Map<String, dynamic>;
    
    if (overallRisk == 'high') {
      interventions.add({
        'type': 'immediate',
        'title': 'Immediate Support Recommended',
        'description': 'Consider reaching out to a mental health professional',
        'priority': 'urgent',
        'action': 'therapy',
      });
    }
    
    if (trends['mood'] < -1) {
      interventions.add({
        'type': 'preventive',
        'title': 'Mood Support Activities',
        'description': 'Increase mood-boosting activities like exercise or social connection',
        'priority': 'high',
        'action': 'exercise',
      });
    }
    
    if (trends['anxiety'] > 1) {
      interventions.add({
        'type': 'preventive',
        'title': 'Anxiety Management',
        'description': 'Focus on stress reduction and relaxation techniques',
        'priority': 'medium',
        'action': 'breathing',
      });
    }
    
    return interventions;
  }

  double _calculatePredictionConfidence(int dataPoints) {
    if (dataPoints >= 30) return 0.90;
    if (dataPoints >= 20) return 0.80;
    if (dataPoints >= 10) return 0.70;
    if (dataPoints >= 5) return 0.60;
    return 0.40;
  }

  double _calculateTrendConfidence(int dataPoints, double trend) {
    final baseConfidence = _calculatePredictionConfidence(dataPoints);
    final trendStrength = math.min(trend.abs() / 5.0, 1.0); // Normalize trend strength
    return (baseConfidence * (0.7 + 0.3 * trendStrength)).clamp(0.0, 1.0);
  }
}