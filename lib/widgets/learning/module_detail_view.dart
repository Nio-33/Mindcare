import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/learning_models.dart';
import '../../providers/learning_provider.dart';
import '../../providers/auth_provider.dart';

class ModuleDetailView extends StatelessWidget {
  final LearningModule module;
  final UserProgress? progress;
  final VoidCallback onBack;

  const ModuleDetailView({
    super.key,
    required this.module,
    this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with module info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getCategoryColor(module.category),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Toggle favorite
                },
              ),
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 16),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Report'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getCategoryColor(module.category),
                      _getCategoryColor(module.category).withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Module type and difficulty
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getContentTypeDisplayName(module.type),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getDifficultyDisplayName(module.difficulty),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (module.isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Module title
                      Text(
                        module.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Module content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  if (progress != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                progress!.completionPercentage >= 100
                                    ? Icons.check_circle
                                    : Icons.play_circle_outline,
                                color: progress!.completionPercentage >= 100
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                progress!.completionPercentage >= 100
                                    ? 'Completed!'
                                    : 'Continue Learning',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${progress!.completionPercentage.toInt()}%',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress!.completionPercentage / 100,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress!.completionPercentage >= 100
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                          if (progress!.timeSpentMinutes > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Time spent: ${progress!.timeSpentMinutes} minutes',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Module info
                  Row(
                    children: [
                      // Duration
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${module.estimatedMinutes} minutes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Rating
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${module.rating.toStringAsFixed(1)} (${module.ratingCount})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Author
                      Text(
                        'by ${module.authorName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'About This Resource',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  // Tags
                  if (module.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Topics Covered',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: module.tags.map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Content sections
                  if (module.content.isNotEmpty) ...[
                    Text(
                      'Content Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...module.content.asMap().entries.map((entry) {
                      final content = entry.value;
                      final isCompleted = progress?.completedContentIds.contains(content.id) ?? false;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: isCompleted
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : _getContentTypeColor(content.type).withValues(alpha: 0.2),
                              child: Icon(
                                isCompleted
                                    ? Icons.check
                                    : _getContentTypeIcon(content.type),
                                size: 16,
                                color: isCompleted
                                    ? AppColors.success
                                    : _getContentTypeColor(content.type),
                              ),
                            ),
                            title: Text(
                              content.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              _getContentTypeDisplayName(content.type),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: isCompleted
                                ? Icon(Icons.check_circle, color: AppColors.success)
                                : Icon(Icons.chevron_right, color: AppColors.textSecondary),
                            onTap: () {
                              // TODO: Navigate to content detail
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: Consumer2<LearningProvider, AuthProvider>(
                      builder: (context, learningProvider, authProvider, child) {
                        return ElevatedButton(
                          onPressed: authProvider.isAuthenticated
                              ? () => _handleStartLearning(context, learningProvider, authProvider)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getCategoryColor(module.category),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: learningProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  progress == null || progress!.completionPercentage == 0
                                      ? 'Start Learning'
                                      : progress!.completionPercentage >= 100
                                          ? 'Review Content'
                                          : 'Continue Learning',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStartLearning(BuildContext context, LearningProvider learningProvider, AuthProvider authProvider) async {
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    try {
      if (progress == null || progress!.completionPercentage == 0) {
        // Start learning from the beginning
        await learningProvider.startLearning(userId, module.id);
        
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Started learning "${module.title}"'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Continue learning or review content
        learningProvider.continueLearning();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                progress!.completionPercentage >= 100
                    ? 'Reviewing "${module.title}"'
                    : 'Continuing "${module.title}"'
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      
      // Track time spent
      learningProvider.trackTimeSpent(userId, module.id, 1);
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.article:
        return Icons.article_outlined;
      case ContentType.video:
        return Icons.play_circle_outline;
      case ContentType.audio:
        return Icons.headphones_outlined;
      case ContentType.exercise:
        return Icons.fitness_center_outlined;
      case ContentType.worksheet:
        return Icons.assignment_outlined;
      case ContentType.quiz:
        return Icons.quiz_outlined;
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