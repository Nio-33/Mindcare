import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/wellness_dashboard.dart';

class RecommendationsCard extends StatelessWidget {
  final List<PersonalizedRecommendation> recommendations;
  final Function(String)? onCompleteRecommendation;

  const RecommendationsCard({
    super.key,
    required this.recommendations,
    this.onCompleteRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    final activeRecommendations = recommendations
        .where((r) => r.expiresAt == null || r.expiresAt!.isAfter(DateTime.now()))
        .toList();

    if (activeRecommendations.isEmpty) {
      return _EmptyRecommendationsCard();
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
                  'For You Today',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Recommendations List
            ...activeRecommendations.take(3).map((rec) => _RecommendationItem(
              recommendation: rec,
              onComplete: onCompleteRecommendation,
            )),
            
            // View More Button
            if (activeRecommendations.length > 3) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _showAllRecommendations(context);
                },
                child: Text('View All ${activeRecommendations.length} Recommendations'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllRecommendations(BuildContext context) {
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
        builder: (context, scrollController) => _AllRecommendationsView(
          recommendations: recommendations,
          scrollController: scrollController,
          onCompleteRecommendation: onCompleteRecommendation,
        ),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final PersonalizedRecommendation recommendation;
  final Function(String)? onComplete;

  const _RecommendationItem({
    required this.recommendation,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPriorityColor(recommendation.priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(recommendation.priority).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and priority
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getPriorityColor(recommendation.priority).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActionIcon(recommendation.actionType),
                  color: _getPriorityColor(recommendation.priority),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (recommendation.estimatedDuration != null)
                      Text(
                        '${recommendation.estimatedDuration!.inMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              _PriorityBadge(priority: recommendation.priority),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            recommendation.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (onComplete != null) {
                      onComplete!(recommendation.id);
                    }
                    _showRecommendationDetail(context);
                  },
                  icon: Icon(
                    Icons.play_arrow,
                    size: 18,
                    color: _getPriorityColor(recommendation.priority),
                  ),
                  label: const Text('Start'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _getPriorityColor(recommendation.priority),
                    side: BorderSide(
                      color: _getPriorityColor(recommendation.priority),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  if (onComplete != null) {
                    onComplete!(recommendation.id);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRecommendationDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RecommendationDetailDialog(
        recommendation: recommendation,
        onComplete: onComplete,
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
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

  IconData _getActionIcon(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'exercise':
        return Icons.fitness_center;
      case 'breathing':
        return Icons.air;
      case 'journaling':
        return Icons.edit_note;
      case 'therapy':
        return Icons.psychology;
      case 'crisis':
        return Icons.emergency;
      default:
        return Icons.auto_awesome;
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
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
}

class _EmptyRecommendationsCard extends StatelessWidget {
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
                  'For You Today',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Empty State
            Icon(
              Icons.task_alt,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'All Caught Up!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No new recommendations right now. Keep up the great work!',
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

class _AllRecommendationsView extends StatelessWidget {
  final List<PersonalizedRecommendation> recommendations;
  final ScrollController scrollController;
  final Function(String)? onCompleteRecommendation;

  const _AllRecommendationsView({
    required this.recommendations,
    required this.scrollController,
    this.onCompleteRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    final activeRecommendations = recommendations
        .where((r) => r.expiresAt == null || r.expiresAt!.isAfter(DateTime.now()))
        .toList();

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
                'All Recommendations',
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
          
          // Recommendations List
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: activeRecommendations.length,
              itemBuilder: (context, index) => _RecommendationItem(
                recommendation: activeRecommendations[index],
                onComplete: onCompleteRecommendation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationDetailDialog extends StatelessWidget {
  final PersonalizedRecommendation recommendation;
  final Function(String)? onComplete;

  const _RecommendationDetailDialog({
    required this.recommendation,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getActionIcon(recommendation.actionType),
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(recommendation.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recommendation.description),
          if (recommendation.estimatedDuration != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Estimated time: ${recommendation.estimatedDuration!.inMinutes} minutes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (onComplete != null) {
              onComplete!(recommendation.id);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Start Activity'),
        ),
      ],
    );
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'exercise':
        return Icons.fitness_center;
      case 'breathing':
        return Icons.air;
      case 'journaling':
        return Icons.edit_note;
      case 'therapy':
        return Icons.psychology;
      case 'crisis':
        return Icons.emergency;
      default:
        return Icons.auto_awesome;
    }
  }
}