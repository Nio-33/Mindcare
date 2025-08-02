import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/learning_models.dart';

class LearningFilters extends StatefulWidget {
  final LearningCategory? selectedCategory;
  final ContentType? selectedContentType;
  final Difficulty? selectedDifficulty;
  final Function(LearningCategory?, ContentType?, Difficulty?) onApplyFilters;

  const LearningFilters({
    super.key,
    this.selectedCategory,
    this.selectedContentType,
    this.selectedDifficulty,
    required this.onApplyFilters,
  });

  @override
  State<LearningFilters> createState() => _LearningFiltersState();
}

class _LearningFiltersState extends State<LearningFilters> {
  LearningCategory? _selectedCategory;
  ContentType? _selectedContentType;
  Difficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedContentType = widget.selectedContentType;
    _selectedDifficulty = widget.selectedDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter Resources',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedContentType = null;
                    _selectedDifficulty = null;
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LearningCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(_getCategoryDisplayName(category)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
                selectedColor: _getCategoryColor(category).withOpacity(0.2),
                checkmarkColor: _getCategoryColor(category),
                labelStyle: TextStyle(
                  color: isSelected ? _getCategoryColor(category) : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? _getCategoryColor(category) : AppColors.divider,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Content Type filter
          Text(
            'Content Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ContentType.values.map((type) {
              final isSelected = _selectedContentType == type;
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getContentTypeIcon(type),
                      size: 16,
                      color: isSelected ? _getContentTypeColor(type) : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(_getContentTypeDisplayName(type)),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedContentType = selected ? type : null;
                  });
                },
                selectedColor: _getContentTypeColor(type).withOpacity(0.2),
                checkmarkColor: _getContentTypeColor(type),
                labelStyle: TextStyle(
                  color: isSelected ? _getContentTypeColor(type) : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? _getContentTypeColor(type) : AppColors.divider,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Difficulty filter
          Text(
            'Difficulty Level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: Difficulty.values.map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(
                        _getDifficultyDisplayName(difficulty),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDifficulty = selected ? difficulty : null;
                      });
                    },
                    selectedColor: _getDifficultyColor(difficulty).withOpacity(0.2),
                    checkmarkColor: _getDifficultyColor(difficulty),
                    labelStyle: TextStyle(
                      color: isSelected ? _getDifficultyColor(difficulty) : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? _getDifficultyColor(difficulty) : AppColors.divider,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(
                      _selectedCategory,
                      _selectedContentType,
                      _selectedDifficulty,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}