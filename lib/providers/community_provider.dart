import 'package:flutter/foundation.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();

  List<SupportGroup> _supportGroups = [];
  List<CommunityPost> _currentGroupPosts = [];
  List<PostReply> _currentPostReplies = [];
  SupportGroup? _selectedGroup;
  CommunityPost? _selectedPost;

  bool _isLoading = false;
  String? _errorMessage;

  List<SupportGroup> get supportGroups => _supportGroups;
  List<CommunityPost> get currentGroupPosts => _currentGroupPosts;
  List<PostReply> get currentPostReplies => _currentPostReplies;
  SupportGroup? get selectedGroup => _selectedGroup;
  CommunityPost? get selectedPost => _selectedPost;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load available support groups
  Future<void> loadSupportGroups() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _supportGroups = await _communityService.getSupportGroups();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load support groups: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading support groups: $e');
      }
    }
  }

  // Join a support group
  Future<void> joinGroup(String groupId, String userId) async {
    try {
      _errorMessage = null;
      
      await _communityService.joinGroup(groupId, userId);
      
      // Update local group data
      final groupIndex = _supportGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _supportGroups[groupIndex];
        if (!group.memberIds.contains(userId)) {
          group.memberIds.add(userId);
          notifyListeners();
        }
      }
      
      // Refresh groups to get updated member count
      await loadSupportGroups();
    } catch (e) {
      _errorMessage = 'Failed to join group: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error joining group: $e');
      }
    }
  }

  // Leave a support group
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      _errorMessage = null;
      
      await _communityService.leaveGroup(groupId, userId);
      
      // Update local group data
      final groupIndex = _supportGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _supportGroups[groupIndex];
        group.memberIds.remove(userId);
        notifyListeners();
      }
      
      // Refresh groups to get updated member count
      await loadSupportGroups();
    } catch (e) {
      _errorMessage = 'Failed to leave group: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error leaving group: $e');
      }
    }
  }

  // Select a group and load its posts
  Future<void> selectGroup(SupportGroup group) async {
    _selectedGroup = group;
    notifyListeners();
    
    await loadGroupPosts(group.id);
  }

  // Load posts for a specific group
  Future<void> loadGroupPosts(String groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentGroupPosts = await _communityService.getGroupPosts(groupId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load posts: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading posts: $e');
      }
    }
  }

  // Create a new post
  Future<void> createPost({
    required String groupId,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    required PostType type,
    List<String>? tags,
    bool isAnonymous = false,
  }) async {
    try {
      _errorMessage = null;
      
      final post = CommunityPost(
        groupId: groupId,
        authorId: authorId,
        authorName: isAnonymous ? 'Anonymous' : authorName,
        title: title,
        content: content,
        type: type,
        tags: tags,
        isAnonymous: isAnonymous,
      );
      
      await _communityService.createPost(post);
      
      // Refresh posts for current group
      if (_selectedGroup?.id == groupId) {
        await loadGroupPosts(groupId);
      }
    } catch (e) {
      _errorMessage = 'Failed to create post: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error creating post: $e');
      }
    }
  }

  // Select a post and load its replies
  Future<void> selectPost(CommunityPost post) async {
    _selectedPost = post;
    notifyListeners();
    
    await loadPostReplies(post.id);
  }

  // Load replies for a specific post
  Future<void> loadPostReplies(String postId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentPostReplies = await _communityService.getPostReplies(postId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load replies: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading replies: $e');
      }
    }
  }

  // Reply to a post
  Future<void> replyToPost({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    bool isAnonymous = false,
  }) async {
    try {
      _errorMessage = null;
      
      final reply = PostReply(
        postId: postId,
        authorId: authorId,
        authorName: isAnonymous ? 'Anonymous' : authorName,
        content: content,
        isAnonymous: isAnonymous,
      );
      
      await _communityService.createReply(reply);
      
      // Refresh replies for current post
      if (_selectedPost?.id == postId) {
        await loadPostReplies(postId);
      }
      
      // Update post reply count
      final postIndex = _currentGroupPosts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        // This would normally be updated by the service, but for now we'll increment locally
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to reply to post: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error replying to post: $e');
      }
    }
  }

  // Like/unlike a post
  Future<void> togglePostLike(String postId, String userId) async {
    try {
      await _communityService.togglePostLike(postId, userId);
      
      // Refresh posts to get updated like count
      if (_selectedGroup != null) {
        await loadGroupPosts(_selectedGroup!.id);
      }
    } catch (e) {
      _errorMessage = 'Failed to update like: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error toggling post like: $e');
      }
    }
  }

  // Get user's joined groups
  Future<List<SupportGroup>> getUserGroups(String userId) async {
    try {
      return await _communityService.getUserGroups(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user groups: $e');
      }
      return [];
    }
  }

  // Check if user is member of group
  bool isUserMember(String groupId, String userId) {
    final group = _supportGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => SupportGroup(
        name: '',
        description: '',
        type: SupportGroupType.general,
        moderatorId: '',
      ),
    );
    return group.memberIds.contains(userId);
  }

  // Get group type display name
  String getGroupTypeDisplayName(SupportGroupType type) {
    switch (type) {
      case SupportGroupType.anxiety:
        return 'Anxiety Support';
      case SupportGroupType.depression:
        return 'Depression Support';
      case SupportGroupType.addiction:
        return 'Addiction Recovery';
      case SupportGroupType.grief:
        return 'Grief & Loss';
      case SupportGroupType.ptsd:
        return 'PTSD Support';
      case SupportGroupType.bipolar:
        return 'Bipolar Support';
      case SupportGroupType.eating:
        return 'Eating Disorders';
      case SupportGroupType.general:
        return 'General Support';
    }
  }

  // Get post type display name
  String getPostTypeDisplayName(PostType type) {
    switch (type) {
      case PostType.discussion:
        return 'Discussion';
      case PostType.question:
        return 'Question';
      case PostType.victory:
        return 'Victory';
      case PostType.support:
        return 'Support Needed';
      case PostType.resource:
        return 'Resource';
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Go back to group list
  void backToGroups() {
    _selectedGroup = null;
    _currentGroupPosts.clear();
    notifyListeners();
  }

  // Go back to post list
  void backToPosts() {
    _selectedPost = null;
    _currentPostReplies.clear();
    notifyListeners();
  }

  // Load mock data for testing
  void loadMockData() {
    _supportGroups = [
      SupportGroup(
        name: 'Anxiety Support Circle',
        description: 'A safe space to discuss anxiety management techniques and share experiences.',
        type: SupportGroupType.anxiety,
        moderatorId: 'moderator1',
        memberIds: ['user1', 'user2', 'user3', 'user4', 'user5'],
        memberCount: 42,
        postCount: 18,
      ),
      SupportGroup(
        name: 'Depression Recovery Community',
        description: 'Supporting each other through depression with understanding and hope.',
        type: SupportGroupType.depression,
        moderatorId: 'moderator2',
        memberIds: ['user1', 'user6', 'user7'],
        memberCount: 28,
        postCount: 12,
      ),
      SupportGroup(
        name: 'Mindfulness & Meditation',
        description: 'Explore mindfulness practices and meditation techniques together.',
        type: SupportGroupType.general,
        moderatorId: 'moderator3',
        memberIds: ['user1', 'user8', 'user9', 'user10'],
        memberCount: 67,
        postCount: 25,
      ),
      SupportGroup(
        name: 'Grief & Loss Support',
        description: 'A compassionate community for those dealing with loss and grief.',
        type: SupportGroupType.grief,
        moderatorId: 'moderator4',
        memberIds: ['user11', 'user12'],
        memberCount: 15,
        postCount: 8,
      ),
    ];
    notifyListeners();
  }
}