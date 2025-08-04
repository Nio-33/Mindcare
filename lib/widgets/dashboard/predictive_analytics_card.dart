import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/wellness_dashboard_provider.dart';

class PredictiveAnalyticsCard extends StatelessWidget {
  const PredictiveAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WellnessDashboardProvider>(
      builder: (context, provider, child) {
        final analytics = provider.predictiveAnalytics;
        final riskAssessment = provider.riskAssessment;
        final trajectory = provider.wellnessTrajectory;
        
        if (analytics == null) {
          return _buildInsufficientDataCard(context);
        }

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
                      Icons.analytics_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Predictive Insights',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (riskAssessment != null) ...[
                  _buildRiskAssessment(context, riskAssessment),
                  const SizedBox(height: 16),
                ],
                
                if (trajectory != null) ...[
                  _buildWellnessTrajectory(context, trajectory),
                  const SizedBox(height: 16),
                ],
                
                _buildPredictionsPreview(context, provider),
                
                const SizedBox(height: 16),
                _buildConfidenceIndicator(context, analytics['confidence']?.toDouble() ?? 0.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsufficientDataCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.trending_up,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Predictive Analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Continue tracking your mood and journaling to unlock personalized predictions and insights.',
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

  Widget _buildRiskAssessment(BuildContext context, Map<String, dynamic> risk) {
    final overallRisk = risk['overall_risk'] as String;
    final riskColor = _getRiskColor(overallRisk);
    final riskPatterns = List<String>.from(risk['risk_patterns'] ?? []);
    final earlyWarnings = List<String>.from(risk['early_warning_signs'] ?? []);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRiskIcon(overallRisk),
                color: riskColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Risk Level: ${overallRisk.toUpperCase()}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ],
          ),
          if (riskPatterns.isNotEmpty || earlyWarnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (riskPatterns.isNotEmpty) ...[
              Text(
                'Patterns detected: ${riskPatterns.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (earlyWarnings.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Early warnings: ${earlyWarnings.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: riskColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildWellnessTrajectory(BuildContext context, Map<String, dynamic> trajectory) {
    final currentTrajectory = trajectory['current_trajectory'] as String;
    final projected30Day = trajectory['projected_30_day']?.toDouble() ?? 0.0;
    final confidence = trajectory['confidence']?.toDouble() ?? 0.0;
    
    final trajectoryIcon = currentTrajectory == 'improving' 
        ? Icons.trending_up
        : currentTrajectory == 'declining' 
            ? Icons.trending_down 
            : Icons.trending_flat;
    
    final trajectoryColor = currentTrajectory == 'improving' 
        ? Colors.green
        : currentTrajectory == 'declining' 
            ? Colors.red 
            : Colors.orange;

    return Row(
      children: [
        Icon(
          trajectoryIcon,
          color: trajectoryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wellness trajectory: ${currentTrajectory.toUpperCase()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: trajectoryColor,
                ),
              ),
              Text(
                '30-day projection: ${projected30Day.round()}/100 (${(confidence * 100).round()}% confidence)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsPreview(BuildContext context, WellnessDashboardProvider provider) {
    final predictions = provider.wellnessPredictions;
    if (predictions == null) return const SizedBox.shrink();
    
    final next7Days = predictions['next_7_days'] as Map<String, dynamic>?;
    if (next7Days == null || next7Days.isEmpty) return const SizedBox.shrink();
    
    // Show prediction for tomorrow
    final tomorrowPrediction = next7Days['day_1'] as Map<String, dynamic>?;
    if (tomorrowPrediction == null) return const SizedBox.shrink();
    
    final overallScore = tomorrowPrediction['overall']?.toDouble() ?? 0.0;
    final moodScore = tomorrowPrediction['mood']?.toDouble() ?? 0.0;
    final anxietyScore = tomorrowPrediction['anxiety']?.toDouble() ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tomorrow\'s Predictions',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPredictionMetric(
                context, 
                'Overall', 
                overallScore, 
                Icons.favorite_outline,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPredictionMetric(
                context, 
                'Mood', 
                moodScore, 
                Icons.sentiment_satisfied_alt,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPredictionMetric(
                context, 
                'Anxiety', 
                anxietyScore, 
                Icons.warning_amber_outlined,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPredictionMetric(
    BuildContext context, 
    String label, 
    double value, 
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            '${value.round()}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(BuildContext context, double confidence) {
    final confidencePercent = (confidence * 100).round();
    final confidenceColor = confidence > 0.8 
        ? Colors.green 
        : confidence > 0.6 
            ? Colors.orange 
            : Colors.red;
    
    return Row(
      children: [
        Icon(
          Icons.psychology_outlined,
          size: 16,
          color: confidenceColor,
        ),
        const SizedBox(width: 6),
        Text(
          'Prediction confidence: $confidencePercent%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }
}