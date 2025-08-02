import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/community_models.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';

class PostDetailView extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback onBack;

  const PostDetailView({
    super.key,
    required this.post,
    required this.onBack,
  });

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final _replyController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommunityProvider, AuthProvider>(
      builder: (context, communityProvider, authProvider, child) {
        return CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              title: const Text('Post Details'),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Report Post'),
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
                  },
                ),
              ],
            ),
            
            // Post content
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: _getPostTypeColor(widget.post.type).withOpacity(0.2),
                          child: widget.post.isAnonymous
                              ? Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: _getPostTypeColor(widget.post.type),
                                )
                              : Text(
                                  widget.post.authorName.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getPostTypeColor(widget.post.type),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.post.authorName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getPostTypeColor(widget.post.type).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getPostTypeDisplayName(widget.post.type),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getPostTypeColor(widget.post.type),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(widget.post.createdAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Post title
                    Text(
                      widget.post.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Post content
                    Text(
                      widget.post.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    // Tags
                    if (widget.post.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.post.tags.map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
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
                    
                    const SizedBox(height: 20),
                    
                    // Post actions
                    Row(
                      children: [
                        // Like button
                        InkWell(
                          onTap: () => _handleLikePost(widget.post.id),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.post.likeCount}',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Reply count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.post.replyCount} replies',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Share button
                        IconButton(
                          onPressed: () {
                            // TODO: Implement share functionality
                          },
                          icon: Icon(
                            Icons.share_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Reply section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Replies (${communityProvider.currentPostReplies.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (communityProvider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            
            // Replies list
            if (communityProvider.currentPostReplies.isEmpty && !communityProvider.isLoading) ...[
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No replies yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to reply and start the conversation!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reply = communityProvider.currentPostReplies[index];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reply header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.secondary.withOpacity(0.3),
                                child: reply.isAnonymous
                                    ? Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: AppColors.primary,
                                      )
                                    : Text(
                                        reply.authorName.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reply.authorName,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _formatTimeAgo(reply.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Like button for reply
                              InkWell(
                                onTap: () {
                                  // TODO: Implement reply like
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.favorite_border,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      if (reply.likeCount > 0) ...[
                                        const SizedBox(width: 2),
                                        Text(
                                          '${reply.likeCount}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Reply content
                          Text(
                            reply.content,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: communityProvider.currentPostReplies.length,
                ),
              ),
            ],
            
            // Reply input
            if (authProvider.isAuthenticated) ...[
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a reply',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _replyController,
                        decoration: const InputDecoration(
                          hintText: 'Share your thoughts, offer support, or ask a question...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        maxLines: 3,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 12),
                      // Privacy and actions
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _isAnonymous,
                                onChanged: (value) {
                                  setState(() {
                                    _isAnonymous = value ?? false;
                                  });
                                },
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const Text('Reply anonymously'),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _replyController.text.trim().isEmpty
                                ? null
                                : () => _handleReply(authProvider, communityProvider),
                            child: const Text('Reply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _handleLikePost(String postId) {
    final authProvider = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    
    if (authProvider.isAuthenticated) {
      communityProvider.togglePostLike(postId, authProvider.user!.uid);
    }
  }

  void _handleReply(AuthProvider authProvider, CommunityProvider communityProvider) {
    if (_replyController.text.trim().isEmpty) return;
    
    communityProvider.replyToPost(
      postId: widget.post.id,
      authorId: authProvider.user!.uid,
      authorName: authProvider.userProfile?.fullName ?? 'User',
      content: _replyController.text.trim(),
      isAnonymous: _isAnonymous,
    );
    
    _replyController.clear();
    setState(() {
      _isAnonymous = false;
    });
    
    FocusScope.of(context).unfocus();
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 1) {
      return _formatTimeAgo(dateTime);
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
    } else {
      return '${difference.inDays}d ago';
    }
  }
}