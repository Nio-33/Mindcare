import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/therapy_journal_provider.dart';
import '../../models/therapy_journal.dart';

class AIInsightsSummary extends StatelessWidget {
  const AIInsightsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TherapyJournalProvider>(
      builder: (context, provider, child) {
        final recentEntries = provider.entries.take(10).toList();
        final entriesWithInsights = recentEntries.where((e) => e.aiInsights != null).toList();
        
        if (entriesWithInsights.isEmpty) {
          return _buildEmptyState(context);
        }

        final insights = _generateSummaryInsights(entriesWithInsights);
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Insights Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Last ${entriesWithInsights.length} entries',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Sentiment Trend
                _buildSentimentTrend(context, insights),
                const SizedBox(height: 16),
                
                // Common Themes
                _buildCommonThemes(context, insights),
                const SizedBox(height: 16),
                
                // Key Recommendations
                _buildKeyRecommendations(context, insights),
                const SizedBox(height: 16),
                
                // Writing Patterns
                _buildWritingPatterns(context, insights),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'AI Insights Coming Soon',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Continue journaling to unlock personalized AI insights about your mental health patterns and progress.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentTrend(BuildContext context, Map<String, dynamic> insights) {
    final trend = insights['sentiment_trend'] as Map<String, dynamic>;
    final current = trend['current'] as double;
    final change = trend['change'] as double;
    
    Color trendColor;
    IconData trendIcon;
    String trendText;
    
    if (change > 0.05) {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
      trendText = 'Improving';
    } else if (change < -0.05) {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
      trendText = 'Declining';
    } else {
      trendColor = Colors.blue;
      trendIcon = Icons.trending_flat;
      trendText = 'Stable';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: trendColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(trendIcon, color: trendColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emotional Trend: $trendText',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: trendColor,
                  ),
                ),
                Text(
                  'Current sentiment: ${_formatSentiment(current)} (${change > 0 ? '+' : ''}${(change * 100).toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonThemes(BuildContext context, Map<String, dynamic> insights) {
    final themes = insights['common_themes'] as List<Map<String, dynamic>>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Discussed Themes',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: themes.take(6).map((themeData) {
            final theme = themeData['theme'] as String;
            final count = themeData['count'] as int;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    theme,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKeyRecommendations(BuildContext context, Map<String, dynamic> insights) {
    final recommendations = insights['key_recommendations'] as List<String>;
    
    if (recommendations.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Recommendations',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.take(3).map((recommendation) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  size: 12,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildWritingPatterns(BuildContext context, Map<String, dynamic> insights) {
    final patterns = insights['writing_patterns'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Writing Patterns',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPatternStat(
                  context,
                  'Avg. Words',
                  '${patterns['avg_words']}',
                  Icons.article_outlined,
                ),
              ),
              Expanded(
                child: _buildPatternStat(
                  context,
                  'Most Active',
                  patterns['most_active_time'],
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildPatternStat(
                  context,
                  'Consistency',
                  '${patterns['consistency_score']}/10',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _generateSummaryInsights(List<TherapyJournalEntry> entries) {
    // Calculate sentiment trend
    final sentiments = entries.map((e) => e.sentimentScore ?? 0.0).toList();
    final currentSentiment = sentiments.isNotEmpty ? sentiments.first : 0.0;
    final avgSentiment = sentiments.isNotEmpty 
        ? sentiments.reduce((a, b) => a + b) / sentiments.length 
        : 0.0;
    final sentimentChange = sentiments.length > 1 
        ? currentSentiment - (sentiments.sublist(1).reduce((a, b) => a + b) / (sentiments.length - 1))
        : 0.0;

    // Analyze common themes
    final themeCount = <String, int>{};
    for (final entry in entries) {
      final themes = entry.aiInsights?['themes'] as List?;
      if (themes != null) {
        for (final theme in themes) {
          themeCount[theme.toString()] = (themeCount[theme.toString()] ?? 0) + 1;
        }
      }
    }
    
    final commonThemes = themeCount.entries
        .map((e) => {'theme': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    // Collect recommendations
    final allRecommendations = <String>{};
    for (final entry in entries) {
      final recommendations = entry.aiInsights?['recommendations'] as List?;
      if (recommendations != null) {
        allRecommendations.addAll(recommendations.cast<String>());
      }
    }

    // Analyze writing patterns
    final wordCounts = entries.map((e) => e.wordCount).toList();
    final avgWords = wordCounts.isNotEmpty 
        ? wordCounts.reduce((a, b) => a + b) / wordCounts.length 
        : 0;
    
    // Determine most active time (simplified)
    final hours = entries.map((e) => e.timestamp.hour).toList();
    final hourCount = <int, int>{};
    for (final hour in hours) {
      hourCount[hour] = (hourCount[hour] ?? 0) + 1;
    }
    final mostActiveHour = hourCount.entries
        .fold<MapEntry<int, int>?>(null, (prev, curr) => 
            prev == null || curr.value > prev.value ? curr : prev)
        ?.key ?? 12;
    
    String mostActiveTime;
    if (mostActiveHour < 12) {
      mostActiveTime = '${mostActiveHour}AM';
    } else if (mostActiveHour == 12) {
      mostActiveTime = '12PM';
    } else {
      mostActiveTime = '${mostActiveHour - 12}PM';
    }

    // Calculate consistency (entries per week)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentEntries = entries.where((e) => e.timestamp.isAfter(weekAgo)).length;
    final consistencyScore = (recentEntries * 10 / 7).clamp(0, 10).round();

    return {
      'sentiment_trend': {
        'current': currentSentiment,
        'average': avgSentiment,
        'change': sentimentChange,
      },
      'common_themes': commonThemes,
      'key_recommendations': allRecommendations.take(5).toList(),
      'writing_patterns': {
        'avg_words': avgWords.round(),
        'most_active_time': mostActiveTime,
        'consistency_score': consistencyScore,
      },
    };
  }

  String _formatSentiment(double sentiment) {
    if (sentiment > 0.2) return 'Very Positive';
    if (sentiment > 0.1) return 'Positive';
    if (sentiment > -0.1) return 'Neutral';
    if (sentiment > -0.2) return 'Negative';
    return 'Very Negative';
  }
}