import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/community_models.dart';

class CreatePostDialog extends StatefulWidget {
  final String groupId;
  final Function(String title, String content, PostType type, List<String> tags, bool isAnonymous) onCreatePost;

  const CreatePostDialog({
    super.key,
    required this.groupId,
    required this.onCreatePost,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  
  PostType _selectedType = PostType.discussion;
  List<String> _tags = [];
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create New Post',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post type selection
                      Text(
                        'Post Type',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: PostType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return FilterChip(
                            label: Text(_getPostTypeDisplayName(type)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedType = type;
                                });
                              }
                            },
                            selectedColor: _getPostTypeColor(type).withValues(alpha: 0.2),
                            checkmarkColor: _getPostTypeColor(type),
                            labelStyle: TextStyle(
                              color: isSelected ? _getPostTypeColor(type) : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Title field
                      Text(
                        'Title',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: _getTitleHint(_selectedType),
                          prefixIcon: Icon(_getPostTypeIcon(_selectedType)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                        maxLength: 100,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Content field
                      Text(
                        'Content',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: _getContentHint(_selectedType),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter content';
                          }
                          if (value.trim().length < 10) {
                            return 'Content must be at least 10 characters';
                          }
                          return null;
                        },
                        maxLength: 1000,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tags field
                      Text(
                        'Tags (optional)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          hintText: 'Add tags separated by commas (e.g., anxiety, coping, support)',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _tags = value
                                .split(',')
                                .map((tag) => tag.trim())
                                .where((tag) => tag.isNotEmpty)
                                .take(5)
                                .toList();
                          });
                        },
                      ),
                      
                      // Tag preview
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _tags.map(
                            (tag) => Chip(
                              label: Text('#$tag'),
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Privacy options
                      Row(
                        children: [
                          Icon(
                            Icons.privacy_tip_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Privacy Options',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Post anonymously'),
                        subtitle: const Text('Your name will be hidden from other users'),
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer with actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreatePost,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Post'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreatePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      widget.onCreatePost(
        _titleController.text.trim(),
        _contentController.text.trim(),
        _selectedType,
        _tags,
        _isAnonymous,
      );

      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create post: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.discussion:
        return AppColors.primary;
      case PostType.question:
        return AppColors.info;
      case PostType.victory:
        return AppColors.success;
      case PostType.support:
        return AppColors.warning;
      case PostType.resource:
        return AppColors.accentPurple;
    }
  }

  IconData _getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.discussion:
        return Icons.forum_outlined;
      case PostType.question:
        return Icons.help_outline;
      case PostType.victory:
        return Icons.celebration_outlined;
      case PostType.support:
        return Icons.support_outlined;
      case PostType.resource:
        return Icons.library_books_outlined;
    }
  }

  String _getPostTypeDisplayName(PostType type) {
    switch (type) {
      case PostType.discussion:
        return 'Discussion';
      case PostType.question:
        return 'Question';
      case PostType.victory:
        return 'Victory';
      case PostType.support:
        return 'Support';
      case PostType.resource:
        return 'Resource';
    }
  }

  String _getTitleHint(PostType type) {
    switch (type) {
      case PostType.discussion:
        return 'What would you like to discuss?';
      case PostType.question:
        return 'What would you like to ask?';
      case PostType.victory:
        return 'Share your victory or achievement';
      case PostType.support:
        return 'What support do you need?';
      case PostType.resource:
        return 'What resource are you sharing?';
    }
  }

  String _getContentHint(PostType type) {
    switch (type) {
      case PostType.discussion:
        return 'Share your thoughts and start a meaningful conversation...';
      case PostType.question:
        return 'Describe your question in detail to get the best help...';
      case PostType.victory:
        return 'Tell us about your achievement and how you got there...';
      case PostType.support:
        return 'Share what you\'re going through and what kind of support you need...';
      case PostType.resource:
        return 'Describe the resource and how it might help others...';
    }
  }
}