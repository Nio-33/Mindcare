import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/community_models.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;
  final Function(String) onLike;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header
              Row(
                children: [
                  // Author avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _getPostTypeColor(post.type).withValues(alpha: 0.2),
                    child: post.isAnonymous
                        ? Icon(
                            Icons.person_outline,
                            size: 16,
                            color: _getPostTypeColor(post.type),
                          )
                        : Text(
                            post.authorName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getPostTypeColor(post.type),
                            ),
                          ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Author name and post type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.authorName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPostTypeColor(post.type).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getPostTypeDisplayName(post.type),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getPostTypeColor(post.type),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTimeAgo(post.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    itemBuilder: (context) => [
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
                      const PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('Block User'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      // Handle menu actions
                      switch (value) {
                        case 'report':
                          _showReportDialog(context);
                          break;
                        case 'block':
                          _showBlockUserDialog(context);
                          break;
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Post title
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Post content preview
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Tags
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: post.tags.take(3).map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Post actions
              Row(
                children: [
                  // Like button
                  InkWell(
                    onTap: () => onLike(post.id),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 16,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likeCount}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Reply button
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.replyCount}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Share button
                  InkWell(
                    onTap: () {
                      // TODO: Implement share functionality
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(
                        Icons.share_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Read more indicator
                  if (post.content.length > 150)
                    Text(
                      'Read more...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Are you sure you want to report this post for inappropriate content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post reported. Thank you for helping keep our community safe.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${post.authorName}? You won\'t see their posts or messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${post.authorName} has been blocked.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}