import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/learning_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/learning_models.dart';
import 'learning_module_card.dart';
import 'learning_path_card.dart';
import 'module_detail_view.dart';
import 'learning_filters.dart';

class LearningCenterInterface extends StatefulWidget {
  const LearningCenterInterface({super.key});

  @override
  State<LearningCenterInterface> createState() => _LearningCenterInterfaceState();
}

class _LearningCenterInterfaceState extends State<LearningCenterInterface>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _hasSearchText = false;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLearning();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (hasText != _hasSearchText) {
      setState(() {
        _hasSearchText = hasText;
      });
    }
  }

  void _onSearchTextChanged(String query) {
    // Cancel previous timer
    _searchTimer?.cancel();
    
    // Start new timer for debounced search
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      final learningProvider = context.read<LearningProvider>();
      if (query.trim().isEmpty) {
        learningProvider.loadModules();
      } else {
        learningProvider.searchModules(query);
      }
    });
  }

  void _initializeLearning() {
    final learningProvider = context.read<LearningProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Load real data
    learningProvider.loadFeaturedModules();
    learningProvider.loadModules();
    learningProvider.loadLearningPaths();
    
    if (authProvider.isAuthenticated) {
      // learningProvider.loadUserProgress(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, child) {
        // Show module detail view if a module is selected
        if (learningProvider.selectedModule != null) {
          return ModuleDetailView(
            module: learningProvider.selectedModule!,
            progress: learningProvider.currentProgress,
            onBack: learningProvider.clearSelection,
          );
        }

        return CustomScrollView(
          slivers: [
            // App bar with title only
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Learning Center'),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                ),
              ),
            ),
            
            // Search bar as separate sliver
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for topics, techniques, or resources...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          suffixIcon: _hasSearchText
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white70),
                                  onPressed: () {
                                    _searchController.clear();
                                    final learningProvider = context.read<LearningProvider>();
                                    learningProvider.loadModules();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: _onSearchTextChanged,
                        onSubmitted: (query) {
                          final learningProvider = context.read<LearningProvider>();
                          learningProvider.searchModules(query);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () {
                          final learningProvider = context.read<LearningProvider>();
                          final query = _searchController.text.trim();
                          if (query.isNotEmpty) {
                            learningProvider.searchModules(query);
                          }
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                        iconSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Explore'),
                    Tab(text: 'My Learning'),
                    Tab(text: 'Paths'),
                  ],
                ),
              ),
            ),
            
            // Tab content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExploreTab(learningProvider),
                  _buildMyLearningTab(learningProvider),
                  _buildPathsTab(learningProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExploreTab(LearningProvider learningProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          Row(
            children: [
              Expanded(
                child: Text(
                  'Discover Resources',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showFilters(learningProvider),
                icon: Icon(
                  Icons.filter_list,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Active filters
          if (learningProvider.selectedCategory != null ||
              learningProvider.selectedContentType != null ||
              learningProvider.selectedDifficulty != null) ...[
            Wrap(
              spacing: 8,
              children: [
                if (learningProvider.selectedCategory != null)
                  _buildFilterChip(
                    learningProvider.getCategoryDisplayName(learningProvider.selectedCategory!),
                    () => learningProvider.applyFilters(
                      contentType: learningProvider.selectedContentType,
                      difficulty: learningProvider.selectedDifficulty,
                    ),
                  ),
                if (learningProvider.selectedContentType != null)
                  _buildFilterChip(
                    learningProvider.getContentTypeDisplayName(learningProvider.selectedContentType!),
                    () => learningProvider.applyFilters(
                      category: learningProvider.selectedCategory,
                      difficulty: learningProvider.selectedDifficulty,
                    ),
                  ),
                if (learningProvider.selectedDifficulty != null)
                  _buildFilterChip(
                    learningProvider.getDifficultyDisplayName(learningProvider.selectedDifficulty!),
                    () => learningProvider.applyFilters(
                      category: learningProvider.selectedCategory,
                      contentType: learningProvider.selectedContentType,
                    ),
                  ),
                TextButton(
                  onPressed: learningProvider.clearFilters,
                  child: const Text('Clear all'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Featured section
          if (learningProvider.featuredModules.isNotEmpty) ...[
            Text(
              'Featured Content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: learningProvider.featuredModules.length,
                itemBuilder: (context, index) {
                  final module = learningProvider.featuredModules[index];
                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index < learningProvider.featuredModules.length - 1 ? 12 : 0,
                    ),
                    child: LearningModuleCard(
                      module: module,
                      progress: learningProvider.getModuleProgress(module.id),
                      isFavorite: learningProvider.favoriteModules[module.id] ?? false,
                      onTap: () => _selectModule(learningProvider, module),
                      onFavorite: () => _toggleFavorite(learningProvider, module.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // All modules section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Resources',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${learningProvider.allModules.length} resources',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Error handling
          if (learningProvider.errorMessage != null) ...[
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
                      learningProvider.errorMessage!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: learningProvider.clearError,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ],
          
          // Loading or modules grid
          if (learningProvider.isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (learningProvider.allModules.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No resources found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: learningProvider.allModules.length,
              itemBuilder: (context, index) {
                final module = learningProvider.allModules[index];
                return LearningModuleCard(
                  module: module,
                  progress: learningProvider.getModuleProgress(module.id),
                  isFavorite: learningProvider.favoriteModules[module.id] ?? false,
                  onTap: () => _selectModule(learningProvider, module),
                  onFavorite: () => _toggleFavorite(learningProvider, module.id),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyLearningTab(LearningProvider learningProvider) {
    final inProgressModules = learningProvider.userProgress.where((p) => p.completionPercentage > 0 && p.completionPercentage < 100).toList();
    final completedModules = learningProvider.userProgress.where((p) => p.completionPercentage >= 100).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress overview
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
                  Icons.school_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Learning Journey',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${completedModules.length} completed • ${inProgressModules.length} in progress',
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
          
          // In Progress section
          if (inProgressModules.isNotEmpty) ...[
            Text(
              'Continue Learning',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...inProgressModules.map((progress) {
              // In a real app, you'd fetch the module details
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: CircularProgressIndicator(
                      value: progress.completionPercentage / 100,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    title: Text('Module ${progress.moduleId.substring(0, 8)}...'),
                    subtitle: Text('${progress.completionPercentage.toInt()}% complete'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to module
                    },
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
          
          // Completed section
          if (completedModules.isNotEmpty) ...[
            Text(
              'Completed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...completedModules.map((progress) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                    title: Text('Module ${progress.moduleId.substring(0, 8)}...'),
                    subtitle: Text('Completed ${_formatDate(progress.completedAt!)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to module
                    },
                  ),
                ),
              );
            }).toList(),
          ],
          
          // Empty state
          if (learningProvider.userProgress.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start Your Learning Journey',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore the available resources to begin learning',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _tabController.animateTo(0),
                      child: const Text('Explore Resources'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPathsTab(LearningProvider learningProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Learning Paths',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Structured journeys to master specific skills and topics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Learning paths list
          if (learningProvider.learningPaths.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Learning Paths Available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for curated learning journeys',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: learningProvider.learningPaths.length,
              itemBuilder: (context, index) {
                final path = learningProvider.learningPaths[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: LearningPathCard(
                    path: path,
                    onTap: () {
                      // TODO: Navigate to path detail
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: AppColors.primary),
      deleteIconColor: AppColors.primary,
    );
  }

  void _selectModule(LearningProvider learningProvider, LearningModule module) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      learningProvider.selectModule(module, authProvider.user!.uid);
    }
  }

  void _toggleFavorite(LearningProvider learningProvider, String moduleId) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      learningProvider.toggleFavorite(authProvider.user!.uid, moduleId);
    }
  }

  void _showFilters(LearningProvider learningProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LearningFilters(
        selectedCategory: learningProvider.selectedCategory,
        selectedContentType: learningProvider.selectedContentType,
        selectedDifficulty: learningProvider.selectedDifficulty,
        onApplyFilters: (category, contentType, difficulty) {
          learningProvider.applyFilters(
            category: category,
            contentType: contentType,
            difficulty: difficulty,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  _StickyTabBarDelegate(this.child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}