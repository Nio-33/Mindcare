import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/learning_models.dart';

class LearningModuleCard extends StatelessWidget {
  final LearningModule module;
  final double progress;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const LearningModuleCard({
    super.key,
    required this.module,
    this.progress = 0.0,
    this.isFavorite = false,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with thumbnail and favorite
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: _getCategoryColor(module.category).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  // Thumbnail placeholder or category icon
                  Center(
                    child: Icon(
                      _getCategoryIcon(module.category),
                      size: 48,
                      color: _getCategoryColor(module.category).withValues(alpha: 0.7),
                    ),
                  ),
                  
                  // Premium badge
                  if (module.isPremium)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : Colors.white70,
                      ),
                      onPressed: onFavorite,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ),
                  
                  // Progress indicator
                  if (progress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 100 ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 3,
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type and difficulty badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getContentTypeColor(module.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getContentTypeDisplayName(module.type),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getContentTypeColor(module.type),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(module.difficulty).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getDifficultyDisplayName(module.difficulty),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getDifficultyColor(module.difficulty),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Title
                    Text(
                      module.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Description
                    Expanded(
                      child: Text(
                        module.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Footer info
                    Row(
                      children: [
                        // Duration
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${module.estimatedMinutes}min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Rating
                        Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          module.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Author
                        Text(
                          module.authorName.split(' ').first,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  IconData _getCategoryIcon(LearningCategory category) {
    switch (category) {
      case LearningCategory.cbt:
        return Icons.psychology_outlined;
      case LearningCategory.dbt:
        return Icons.balance_outlined;
      case LearningCategory.mindfulness:
        return Icons.self_improvement_outlined;
      case LearningCategory.anxiety:
        return Icons.healing_outlined;
      case LearningCategory.depression:
        return Icons.favorite_border;
      case LearningCategory.stress:
        return Icons.spa_outlined;
      case LearningCategory.selfCare:
        return Icons.self_improvement_outlined;
      case LearningCategory.relationships:
        return Icons.people_outline;
      case LearningCategory.sleep:
        return Icons.bedtime_outlined;
      case LearningCategory.general:
        return Icons.library_books_outlined;
    }
  }

  Color _getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.article:
        return AppColors.primary;
      case ContentType.video:
        return AppColors.error;
      case ContentType.audio:
        return AppColors.accentPurple;
      case ContentType.exercise:
        return AppColors.success;
      case ContentType.worksheet:
        return AppColors.warning;
      case ContentType.quiz:
        return AppColors.info;
    }
  }

  String _getContentTypeDisplayName(ContentType type) {
    switch (type) {
      case ContentType.article:
        return 'Article';
      case ContentType.video:
        return 'Video';
      case ContentType.audio:
        return 'Audio';
      case ContentType.exercise:
        return 'Exercise';
      case ContentType.worksheet:
        return 'Worksheet';
      case ContentType.quiz:
        return 'Quiz';
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