import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/wellness_dashboard.dart';

class InsightsCard extends StatelessWidget {
  final List<WellnessInsight> insights;
  final Function(String)? onDismissInsight;

  const InsightsCard({
    super.key,
    required this.insights,
    this.onDismissInsight,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return _EmptyInsightsCard();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wellness Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Insights List
            ...insights.take(3).map((insight) => _InsightItem(
              insight: insight,
              onDismiss: onDismissInsight,
            )),
            
            // View More Button (if more than 3 insights)
            if (insights.length > 3) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _showAllInsights(context);
                },
                child: Text('View All ${insights.length} Insights'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _AllInsightsView(
          insights: insights,
          scrollController: scrollController,
          onDismissInsight: onDismissInsight,
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final WellnessInsight insight;
  final Function(String)? onDismiss;

  const _InsightItem({
    required this.insight,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeverityColor(insight.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeverityColor(insight.severity).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and dismiss button
          Row(
            children: [
              Icon(
                _getSeverityIcon(insight.severity),
                color: _getSeverityColor(insight.severity),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getSeverityColor(insight.severity),
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => onDismiss!(insight.id),
                  color: AppColors.textTertiary,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            insight.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          // Recommendations (show first 2)
          if (insight.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...insight.recommendations.take(2).map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      rec,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            
            if (insight.recommendations.length > 2)
              Text(
                '...and ${insight.recommendations.length - 2} more suggestions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'medium':
        return AppColors.info;
      case 'low':
      default:
        return AppColors.success;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
      default:
        return Icons.check_circle;
    }
  }
}

class _EmptyInsightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wellness Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Empty State
            Icon(
              Icons.psychology_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No Insights Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep tracking your mood and journaling to get personalized insights',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AllInsightsView extends StatelessWidget {
  final List<WellnessInsight> insights;
  final ScrollController scrollController;
  final Function(String)? onDismissInsight;

  const _AllInsightsView({
    required this.insights,
    required this.scrollController,
    this.onDismissInsight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Text(
                'All Wellness Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Insights List
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: insights.length,
              itemBuilder: (context, index) => _InsightItem(
                insight: insights[index],
                onDismiss: onDismissInsight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}