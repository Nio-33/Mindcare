import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/colors.dart';
import '../../models/wellness_dashboard.dart';

class WellnessScoreCard extends StatelessWidget {
  final WellnessScore score;
  final VoidCallback? onTap;

  const WellnessScoreCard({
    super.key,
    required this.score,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wellness Score',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _getWellnessIcon(score.overall),
                    color: _getWellnessColor(score.overall),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Main Score Display
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${score.overall.round()}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: _getWellnessColor(score.overall),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'out of 100',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getWellnessDescription(score.overall),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getWellnessColor(score.overall),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Radial Progress
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 100,
                      child: PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 0,
                          centerSpaceRadius: 35,
                          sections: [
                            PieChartSectionData(
                              value: score.overall,
                              color: _getWellnessColor(score.overall),
                              radius: 10,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 100 - score.overall,
                              color: AppColors.divider,
                              radius: 10,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Breakdown Metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricChip(
                      label: 'Mood',
                      value: score.mood,
                      icon: Icons.sentiment_satisfied,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      label: 'Energy',
                      value: score.energy,
                      icon: Icons.battery_charging_full,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      label: 'Sleep',
                      value: score.sleep,
                      icon: Icons.bedtime,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _MetricChip(
                      label: 'Anxiety',
                      value: 100 - score.anxiety, // Invert for display (lower anxiety = better)
                      icon: Icons.psychology,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      label: 'Consistency',
                      value: score.consistency,
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: SizedBox()), // Empty space for alignment
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Last Updated
              Text(
                'Updated ${_formatLastUpdated(score.calculatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWellnessIcon(double score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    if (score >= 40) return Icons.sentiment_neutral;
    if (score >= 20) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  Color _getWellnessColor(double score) {
    if (score >= 70) return AppColors.wellnessHigh;
    if (score >= 40) return AppColors.wellnessMedium;
    return AppColors.wellnessLow;
  }

  String _getWellnessDescription(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 40) return 'Needs Attention';
    if (score >= 20) return 'Concerning';
    return 'Critical';
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getMetricColor(value);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            '${value.round()}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(double value) {
    if (value >= 70) return AppColors.wellnessHigh;
    if (value >= 40) return AppColors.wellnessMedium;
    return AppColors.wellnessLow;
  }
}