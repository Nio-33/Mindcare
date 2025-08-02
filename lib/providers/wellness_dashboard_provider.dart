import 'package:flutter/foundation.dart';
import '../models/wellness_dashboard.dart';
import '../models/mood_entry.dart';
import '../models/therapy_journal.dart';
import '../models/user_profile.dart';
import '../services/wellness_service.dart';

class WellnessDashboardProvider extends ChangeNotifier {
  final WellnessService _wellnessService = WellnessService();
  
  WellnessDashboard? _dashboard;
  List<MoodEntry> _moodEntries = [];
  List<TherapyJournalEntry> _journalEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  WellnessDashboard? get dashboard => _dashboard;
  List<MoodEntry> get moodEntries => _moodEntries;
  List<TherapyJournalEntry> get journalEntries => _journalEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get current wellness score or generate default
  WellnessScore get currentWellnessScore {
    if (_dashboard != null) {
      return _dashboard!.currentScore;
    }
    
    // Generate default score if no dashboard exists
    return WellnessScore(
      overall: 50.0,
      mood: 50.0,
      energy: 50.0,
      sleep: 50.0,
      anxiety: 30.0,
      consistency: 0.0,
      calculatedAt: DateTime.now(),
    );
  }

  // Get recent insights
  List<WellnessInsight> get currentInsights {
    return _dashboard?.insights ?? [];
  }

  // Get current recommendations
  List<PersonalizedRecommendation> get currentRecommendations {
    final now = DateTime.now();
    return _dashboard?.recommendations
        .where((r) => r.expiresAt == null || r.expiresAt!.isAfter(now))
        .toList() ?? [];
  }

  // Initialize or refresh dashboard
  Future<void> refreshDashboard(String userId, UserProfile userProfile) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load existing dashboard
      _dashboard = await _wellnessService.loadWellnessDashboard(userId);

      // If no dashboard exists or it's outdated, generate new one
      final now = DateTime.now();
      if (_dashboard == null || 
          _dashboard!.lastUpdated.isBefore(now.subtract(const Duration(hours: 6)))) {
        await _generateNewDashboard(userId, userProfile);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load wellness dashboard: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error refreshing dashboard: $e');
      }
    }
  }

  // Generate new dashboard with current data
  Future<void> _generateNewDashboard(String userId, UserProfile userProfile) async {
    // Calculate current wellness score
    final currentScore = _wellnessService.calculateWellnessScore(
      recentMoods: _moodEntries,
      recentJournals: _journalEntries,
      userProfile: userProfile,
    );

    // Get historical scores for trend analysis
    final historicalScores = _dashboard?.historicalScores ?? [];
    historicalScores.insert(0, currentScore);
    
    // Keep only last 30 scores (roughly 1 month of data)
    if (historicalScores.length > 30) {
      historicalScores.removeLast();
    }

    // Generate insights
    final insights = _wellnessService.generateInsights(
      currentScore: currentScore,
      historicalScores: historicalScores,
      recentMoods: _moodEntries,
      recentJournals: _journalEntries,
    );

    // Generate recommendations
    final recommendations = _wellnessService.generateRecommendations(
      currentScore: currentScore,
      recentMoods: _moodEntries,
      userProfile: userProfile,
    );

      // Create trend analysis
    final trendAnalysis = _generateTrendAnalysis(historicalScores);
    
    // Generate predictive analytics
    final predictiveModeling = _wellnessService.generatePredictiveAnalytics(
      historicalScores: historicalScores,
      recentMoods: _moodEntries,
      recentJournals: _journalEntries,
    );

    // Create new dashboard
    _dashboard = WellnessDashboard(
      userId: userId,
      currentScore: currentScore,
      historicalScores: historicalScores,
      insights: insights,
      recommendations: recommendations,
      trendAnalysis: trendAnalysis,
      predictiveModeling: predictiveModeling,
      lastUpdated: DateTime.now(),
    );

    // Save to Firestore
    await _wellnessService.saveWellnessDashboard(userId, _dashboard!);
  }

  Map<String, dynamic> _generateTrendAnalysis(List<WellnessScore> scores) {
    if (scores.length < 2) {
      return {
        'overall_trend': 'insufficient_data',
        'trend_direction': 'stable',
        'trend_strength': 0.0,
        'weekly_average': 50.0,
        'monthly_average': 50.0,
      };
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final weekScores = scores.where((s) => s.calculatedAt.isAfter(weekAgo)).toList();
    final monthScores = scores.where((s) => s.calculatedAt.isAfter(monthAgo)).toList();

    final weeklyAvg = weekScores.isNotEmpty 
        ? weekScores.map((s) => s.overall).reduce((a, b) => a + b) / weekScores.length
        : 50.0;
    
    final monthlyAvg = monthScores.isNotEmpty
        ? monthScores.map((s) => s.overall).reduce((a, b) => a + b) / monthScores.length
        : 50.0;

    // Calculate trend direction and strength
    final firstScore = scores.last.overall;
    final lastScore = scores.first.overall;
    final change = lastScore - firstScore;
    final changePercent = (change / firstScore) * 100;

    String trendDirection;
    if (changePercent > 5) {
      trendDirection = 'improving';
    } else if (changePercent < -5) {
      trendDirection = 'declining';
    } else {
      trendDirection = 'stable';
    }

    return {
      'overall_trend': trendDirection,
      'trend_direction': trendDirection,
      'trend_strength': changePercent.abs(),
      'weekly_average': weeklyAvg,
      'monthly_average': monthlyAvg,
      'total_change': change,
      'change_percent': changePercent,
    };
  }

  // Add new mood entry and refresh insights
  Future<void> addMoodEntry(MoodEntry entry) async {
    _moodEntries.insert(0, entry);
    
    // Keep only recent entries for calculations
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _moodEntries = _moodEntries.where((m) => m.timestamp.isAfter(cutoff)).toList();
    
    notifyListeners();
  }

  // Add new journal entry and refresh insights
  Future<void> addJournalEntry(TherapyJournalEntry entry) async {
    _journalEntries.insert(0, entry);
    
    // Keep only recent entries for calculations
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _journalEntries = _journalEntries.where((j) => j.timestamp.isAfter(cutoff)).toList();
    
    notifyListeners();
  }

  // Get mood trends for charts
  List<Map<String, dynamic>> getMoodTrendData() {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: i)));
    
    return last7Days.map((day) {
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayMoods = _moodEntries.where((m) => 
        m.timestamp.isAfter(dayStart) && m.timestamp.isBefore(dayEnd)
      ).toList();
      
      double avgIntensity = 0;
      if (dayMoods.isNotEmpty) {
        avgIntensity = dayMoods.map((m) => m.intensity).reduce((a, b) => a + b) / dayMoods.length;
      }
      
      return {
        'date': day,
        'intensity': avgIntensity,
        'count': dayMoods.length,
      };
    }).toList().reversed.toList();
  }

  // Get wellness score history for charts
  List<Map<String, dynamic>> getWellnessScoreHistory() {
    if (_dashboard == null) return [];
    
    return _dashboard!.historicalScores.map((score) => {
      'date': score.calculatedAt,
      'overall': score.overall,
      'mood': score.mood,
      'energy': score.energy,
      'sleep': score.sleep,
      'anxiety': score.anxiety,
      'consistency': score.consistency,
    }).toList();
  }

  // Mark recommendation as completed
  void completeRecommendation(String recommendationId) {
    if (_dashboard != null) {
      _dashboard!.recommendations.removeWhere((r) => r.id == recommendationId);
      notifyListeners();
    }
  }

  // Dismiss insight
  void dismissInsight(String insightId) {
    if (_dashboard != null) {
      _dashboard!.insights.removeWhere((i) => i.id == insightId);
      notifyListeners();
    }
  }

  // Get predictive analytics data
  Map<String, dynamic>? get predictiveAnalytics {
    return _dashboard?.predictiveModeling;
  }
  
  // Get risk assessment
  Map<String, dynamic>? get riskAssessment {
    return _dashboard?.predictiveModeling?['risk_assessment'];
  }
  
  // Get wellness predictions for next 7 days
  Map<String, dynamic>? get wellnessPredictions {
    return _dashboard?.predictiveModeling?['predictions'];
  }
  
  // Get intervention recommendations
  List<Map<String, dynamic>>? get interventionRecommendations {
    final interventions = _dashboard?.predictiveModeling?['interventions'];
    return interventions != null ? List<Map<String, dynamic>>.from(interventions) : null;
  }
  
  // Get wellness trajectory
  Map<String, dynamic>? get wellnessTrajectory {
    return _dashboard?.predictiveModeling?['trajectory'];
  }
  
  // Check if user is at risk
  bool get isAtRisk {
    final riskLevel = riskAssessment?['overall_risk'];
    return riskLevel == 'high' || riskLevel == 'medium';
  }
  
  // Get risk level color
  String getRiskLevelColor(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return '#F44336'; // Red
      case 'medium':
        return '#FF9800'; // Orange
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load mock data for testing
  void loadMockData() {
    final now = DateTime.now();
    
    // Generate mock mood entries for the last 14 days
    _moodEntries = List.generate(14, (i) {
      final date = now.subtract(Duration(days: i));
      final moods = [MoodType.happy, MoodType.neutral, MoodType.sad, MoodType.anxious, MoodType.calm];
      final mood = moods[i % moods.length];
      final intensity = 3 + (i % 7); // Vary intensity
      
      return MoodEntry(
        userId: 'mock_user',
        mood: mood,
        intensity: intensity,
        notes: 'Mock mood entry for testing',
        timestamp: date,
      );
    });

    // Generate mock journal entries
    _journalEntries = List.generate(7, (i) {
      final date = now.subtract(Duration(days: i * 2));
      
      return TherapyJournalEntry(
        userId: 'mock_user',
        title: 'Daily Reflection ${i + 1}',
        content: 'This is a mock journal entry for testing the wellness dashboard. Today I felt ${i % 2 == 0 ? 'good' : 'stressed'} and worked on self-care.',
        timestamp: date,
        sentimentScore: i % 2 == 0 ? 0.3 : -0.2,
        emotionalTone: i % 2 == 0 ? EmotionalTone.positive : EmotionalTone.negative,
      );
    });

    notifyListeners();
  }
}