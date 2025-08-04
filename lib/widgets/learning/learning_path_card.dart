import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/learning_models.dart';

class LearningPathCard extends StatelessWidget {
  final LearningPath path;
  final VoidCallback onTap;

  const LearningPathCard({
    super.key,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Path icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(path.category).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.route_outlined,
                      color: _getCategoryColor(path.category),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Title and badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          path.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Category badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(path.category).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getCategoryDisplayName(path.category),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getCategoryColor(path.category),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Difficulty badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(path.difficulty).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getDifficultyDisplayName(path.difficulty),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getDifficultyColor(path.difficulty),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Premium badge
                            if (path.isPremium) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                path.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Path stats
              Row(
                children: [
                  // Module count
                  Icon(
                    Icons.library_books_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${path.moduleIds.length} modules',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Estimated time
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${path.estimatedHours}h estimated',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Author
                  Text(
                    'by ${path.authorName.split(' ').first}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress visualization (mock)
              Row(
                children: [
                  Text(
                    'Learning Path:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: List.generate(
                        path.moduleIds.length.clamp(1, 6),
                        (index) => Container(
                          width: 12,
                          height: 12,
                          margin: EdgeInsets.only(
                            right: index < path.moduleIds.length - 1 ? 4 : 0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.divider,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (path.moduleIds.length > 6)
                    Text(
                      '+${path.moduleIds.length - 6}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(LearningCategory category) {
    switch (category) {
      case LearningCategory.cbt:
        return AppColors.primary;
      case LearningCategory.dbt:
        return AppColors.accentPurple;
      case LearningCategory.mindfulness:
        return AppColors.secondary;
      case LearningCategory.anxiety:
        return AppColors.accentOrange;
      case LearningCategory.depression:
        return AppColors.info;
      case LearningCategory.stress:
        return AppColors.warning;
      case LearningCategory.selfCare:
        return AppColors.accentYellow;
      case LearningCategory.relationships:
        return AppColors.error;
      case LearningCategory.sleep:
        return AppColors.accentPurple;
      case LearningCategory.general:
        return AppColors.textSecondary;
    }
  }

  String _getCategoryDisplayName(LearningCategory category) {
    switch (category) {
      case LearningCategory.cbt:
        return 'CBT';
      case LearningCategory.dbt:
        return 'DBT';
      case LearningCategory.mindfulness:
        return 'Mindfulness';
      case LearningCategory.anxiety:
        return 'Anxiety';
      case LearningCategory.depression:
        return 'Depression';
      case LearningCategory.stress:
        return 'Stress';
      case LearningCategory.selfCare:
        return 'Self-Care';
      case LearningCategory.relationships:
        return 'Relationships';
      case LearningCategory.sleep:
        return 'Sleep';
      case LearningCategory.general:
        return 'General';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return AppColors.success;
      case Difficulty.intermediate:
        return AppColors.warning;
      case Difficulty.advanced:
        return AppColors.error;
    }
  }

  String _getDifficultyDisplayName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }
}