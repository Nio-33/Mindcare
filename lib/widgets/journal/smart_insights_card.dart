import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/therapy_journal.dart';

class SmartInsightsCard extends StatelessWidget {
  final TherapyJournalEntry entry;

  const SmartInsightsCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final aiInsights = entry.aiInsights;
    
    if (aiInsights == null || aiInsights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const Spacer(),
                _buildConfidenceIndicator(context, aiInsights),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sentiment Analysis
            if (entry.sentimentScore != null) ...[
              _buildSentimentSection(context),
              const SizedBox(height: 16),
            ],
            
            // Themes
            if (aiInsights['themes'] != null && (aiInsights['themes'] as List).isNotEmpty) ...[
              _buildThemesSection(context, aiInsights['themes'] as List),
              const SizedBox(height: 16),
            ],
            
            // Recommendations
            if (aiInsights['recommendations'] != null && (aiInsights['recommendations'] as List).isNotEmpty) ...[
              _buildRecommendationsSection(context, aiInsights['recommendations'] as List),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(BuildContext context, Map<String, dynamic> insights) {
    // Simple confidence based on word count and analysis depth
    final wordCount = insights['word_count'] ?? 0;
    final hasThemes = insights['themes'] != null && (insights['themes'] as List).isNotEmpty;
    final hasRecommendations = insights['recommendations'] != null && (insights['recommendations'] as List).isNotEmpty;
    
    double confidence = 0.5; // Base confidence
    if (wordCount > 50) confidence += 0.2;
    if (wordCount > 100) confidence += 0.2;
    if (hasThemes) confidence += 0.1;
    if (hasRecommendations) confidence += 0.1;
    
    confidence = confidence.clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(confidence * 100).round()}% accuracy',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.accent,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSentimentSection(BuildContext context) {
    final sentimentScore = entry.sentimentScore!;
    final emotionalTone = entry.emotionalTone;
    
    Color sentimentColor;
    IconData sentimentIcon;
    String sentimentText;
    
    if (sentimentScore > 0.1) {
      sentimentColor = Colors.green;
      sentimentIcon = Icons.sentiment_satisfied_alt;
      sentimentText = 'Positive';
    } else if (sentimentScore < -0.1) {
      sentimentColor = Colors.red;
      sentimentIcon = Icons.sentiment_dissatisfied;
      sentimentText = 'Negative';
    } else {
      sentimentColor = Colors.orange;
      sentimentIcon = Icons.sentiment_neutral;
      sentimentText = 'Neutral';
    }
    
    return Row(
      children: [
        Icon(
          sentimentIcon,
          color: sentimentColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          'Sentiment: $sentimentText',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: sentimentColor,
          ),
        ),
        if (emotionalTone != null) ...[
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: sentimentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatEmotionalTone(emotionalTone),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: sentimentColor,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThemesSection(BuildContext context, List themes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Themes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: themes.map<Widget>((theme) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                theme.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, List recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized Suggestions',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...recommendations.take(3).map<Widget>((recommendation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: 12,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatEmotionalTone(EmotionalTone tone) {
    switch (tone) {
      case EmotionalTone.veryPositive:
        return 'Very Positive';
      case EmotionalTone.positive:
        return 'Positive';
      case EmotionalTone.neutral:
        return 'Neutral';
      case EmotionalTone.negative:
        return 'Negative';
      case EmotionalTone.veryNegative:
        return 'Very Negative';
    }
  }
}