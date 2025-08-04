import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import 'support_group_card.dart';
import 'community_post_card.dart';
import 'create_post_dialog.dart';
import 'post_detail_view.dart';

class CommunityInterface extends StatefulWidget {
  const CommunityInterface({super.key});

  @override
  State<CommunityInterface> createState() => _CommunityInterfaceState();
}

class _CommunityInterfaceState extends State<CommunityInterface> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCommunity();
    });
  }

  void _initializeCommunity() {
    final communityProvider = context.read<CommunityProvider>();
    
    // Load mock data for testing
    communityProvider.loadMockData();
    
    // In production, you would load real data:
    // communityProvider.loadSupportGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, child) {
        // Show post detail view if a post is selected
        if (communityProvider.selectedPost != null) {
          return PostDetailView(
            post: communityProvider.selectedPost!,
            onBack: communityProvider.backToPosts,
          );
        }

        // Show group posts if a group is selected
        if (communityProvider.selectedGroup != null) {
          return _buildGroupPostsView(communityProvider);
        }

        // Show main community interface with support groups
        return _buildMainCommunityView(communityProvider);
      },
    );
  }

  Widget _buildMainCommunityView(CommunityProvider communityProvider) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          flexibleSpace: const FlexibleSpaceBar(
            title: Text('Community Support'),
            background: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Community Support',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Connect with others who understand your journey. Join support groups, share experiences, and find encouragement.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Support Groups',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Show create group dialog
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Group'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Error handling
                if (communityProvider.errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            communityProvider.errorMessage!,
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: communityProvider.clearError,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Loading indicator
                if (communityProvider.isLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ] else ...[
                  // Support groups grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 3.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: communityProvider.supportGroups.length,
                    itemBuilder: (context, index) {
                      final group = communityProvider.supportGroups[index];
                      return SupportGroupCard(
                        group: group,
                        onTap: () => communityProvider.selectGroup(group),
                        onJoin: (groupId) => _handleJoinGroup(groupId),
                        onLeave: (groupId) => _handleLeaveGroup(groupId),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupPostsView(CommunityProvider communityProvider) {
    final group = communityProvider.selectedGroup!;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: communityProvider.backToGroups,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreatePostDialog(group.id),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              group.name,
              style: const TextStyle(fontSize: 16),
            ),
            background: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              communityProvider.getGroupTypeDisplayName(group.type),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${group.memberCount} members',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        group.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Posts section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Posts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${communityProvider.currentGroupPosts.length} posts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // Posts list
        if (communityProvider.isLoading) ...[
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ] else if (communityProvider.currentGroupPosts.isEmpty) ...[
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to start a conversation!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showCreatePostDialog(group.id),
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Post'),
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
                final post = communityProvider.currentGroupPosts[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: index == communityProvider.currentGroupPosts.length - 1 ? 16 : 8,
                  ),
                  child: CommunityPostCard(
                    post: post,
                    onTap: () => communityProvider.selectPost(post),
                    onLike: (postId) => _handleLikePost(postId),
                  ),
                );
              },
              childCount: communityProvider.currentGroupPosts.length,
            ),
          ),
        ],
      ],
    );
  }

  void _handleJoinGroup(String groupId) {
    final authProvider = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    
    if (authProvider.isAuthenticated) {
      communityProvider.joinGroup(groupId, authProvider.user!.uid);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined support group'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleLeaveGroup(String groupId) {
    final authProvider = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    
    if (authProvider.isAuthenticated) {
      communityProvider.leaveGroup(groupId, authProvider.user!.uid);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Left support group'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleLikePost(String postId) {
    final authProvider = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    
    if (authProvider.isAuthenticated) {
      communityProvider.togglePostLike(postId, authProvider.user!.uid);
    }
  }

  void _showCreatePostDialog(String groupId) {
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.isAuthenticated) return;
    
    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        groupId: groupId,
        onCreatePost: (title, content, type, tags, isAnonymous) {
          final communityProvider = context.read<CommunityProvider>();
          communityProvider.createPost(
            groupId: groupId,
            authorId: authProvider.user!.uid,
            authorName: authProvider.userProfile?.fullName ?? 'User',
            title: title,
            content: content,
            type: type,
            tags: tags,
            isAnonymous: isAnonymous,
          );
        },
      ),
    );
  }
}