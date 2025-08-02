import 'package:flutter/foundation.dart';
import '../models/learning_models.dart';
import '../services/learning_service.dart';

class LearningProvider extends ChangeNotifier {
  final LearningService _learningService = LearningService();

  List<LearningModule> _featuredModules = [];
  List<LearningModule> _allModules = [];
  List<LearningPath> _learningPaths = [];
  List<UserProgress> _userProgress = [];
  Map<String, bool> _favoriteModules = {};
  
  LearningModule? _selectedModule;
  UserProgress? _currentProgress;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  LearningCategory? _selectedCategory;
  ContentType? _selectedContentType;
  Difficulty? _selectedDifficulty;

  // Getters
  List<LearningModule> get featuredModules => _featuredModules;
  List<LearningModule> get allModules => _allModules;
  List<LearningPath> get learningPaths => _learningPaths;
  List<UserProgress> get userProgress => _userProgress;
  Map<String, bool> get favoriteModules => _favoriteModules;
  LearningModule? get selectedModule => _selectedModule;
  UserProgress? get currentProgress => _currentProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LearningCategory? get selectedCategory => _selectedCategory;
  ContentType? get selectedContentType => _selectedContentType;
  Difficulty? get selectedDifficulty => _selectedDifficulty;

  // Load featured modules
  Future<void> loadFeaturedModules() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _featuredModules = await _learningService.getFeaturedModules();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load featured modules: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading featured modules: $e');
      }
    }
  }

  // Load all modules with filters
  Future<void> loadModules({
    LearningCategory? category,
    ContentType? type,
    Difficulty? difficulty,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _allModules = await _learningService.getLearningModules(
        category: category,
        type: type,
        difficulty: difficulty,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load modules: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading modules: $e');
      }
    }
  }

  // Load learning paths
  Future<void> loadLearningPaths({LearningCategory? category}) async {
    try {
      _learningPaths = await _learningService.getLearningPaths(category: category);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading learning paths: $e');
      }
    }
  }

  // Load user progress
  Future<void> loadUserProgress(String userId) async {
    try {
      _userProgress = await _learningService.getUserProgress(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user progress: $e');
      }
    }
  }

  // Select a module for detailed view
  Future<void> selectModule(LearningModule module, String userId) async {
    _selectedModule = module;
    
    try {
      _currentProgress = await _learningService.getModuleProgress(userId, module.id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading module progress: $e');
      }
    }
  }

  // Mark content as completed
  Future<void> markContentCompleted(String userId, String moduleId, String contentId) async {
    try {
      await _learningService.markContentCompleted(userId, moduleId, contentId);
      
      // Refresh current progress
      if (_selectedModule?.id == moduleId) {
        _currentProgress = await _learningService.getModuleProgress(userId, moduleId);
        notifyListeners();
      }
      
      // Refresh user progress list
      await loadUserProgress(userId);
    } catch (e) {
      _errorMessage = 'Failed to mark content as completed: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error marking content completed: $e');
      }
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String userId, String moduleId) async {
    try {
      await _learningService.toggleFavorite(userId, moduleId);
      
      // Update local favorite status
      final isFavorite = await _learningService.isFavorite(userId, moduleId);
      _favoriteModules[moduleId] = isFavorite;
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update favorite: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error toggling favorite: $e');
      }
    }
  }

  // Load favorite status for modules
  Future<void> loadFavoriteStatus(String userId, List<String> moduleIds) async {
    try {
      for (final moduleId in moduleIds) {
        final isFavorite = await _learningService.isFavorite(userId, moduleId);
        _favoriteModules[moduleId] = isFavorite;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorite status: $e');
      }
    }
  }

  // Rate a module
  Future<void> rateModule(String moduleId, String userId, double rating) async {
    try {
      await _learningService.rateModule(moduleId, userId, rating);
      
      // Refresh modules to get updated rating
      await loadFeaturedModules();
      await loadModules();
    } catch (e) {
      _errorMessage = 'Failed to rate module: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error rating module: $e');
      }
    }
  }

  // Search modules
  Future<void> searchModules(String query) async {
    if (query.trim().isEmpty) {
      await loadModules();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _allModules = await _learningService.searchModules(query);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to search modules: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error searching modules: $e');
      }
    }
  }

  // Apply filters
  void applyFilters({
    LearningCategory? category,
    ContentType? contentType,
    Difficulty? difficulty,
  }) {
    _selectedCategory = category;
    _selectedContentType = contentType;
    _selectedDifficulty = difficulty;
    
    loadModules(
      category: category,
      type: contentType,
      difficulty: difficulty,
    );
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedContentType = null;
    _selectedDifficulty = null;
    
    loadModules();
  }

  // Get progress for a specific module
  double getModuleProgress(String moduleId) {
    final progress = _userProgress.firstWhere(
      (p) => p.moduleId == moduleId,
      orElse: () => UserProgress(userId: '', moduleId: moduleId),
    );
    return progress.completionPercentage;
  }

  // Check if module is completed
  bool isModuleCompleted(String moduleId) {
    return getModuleProgress(moduleId) >= 100.0;
  }

  // Check if module is started
  bool isModuleStarted(String moduleId) {
    return getModuleProgress(moduleId) > 0.0;
  }

  // Get category display name
  String getCategoryDisplayName(LearningCategory category) {
    switch (category) {
      case LearningCategory.cbt:
        return 'Cognitive Behavioral Therapy';
      case LearningCategory.dbt:
        return 'Dialectical Behavior Therapy';
      case LearningCategory.mindfulness:
        return 'Mindfulness & Meditation';
      case LearningCategory.anxiety:
        return 'Anxiety Management';
      case LearningCategory.depression:
        return 'Depression Support';
      case LearningCategory.stress:
        return 'Stress Management';
      case LearningCategory.selfCare:
        return 'Self-Care';
      case LearningCategory.relationships:
        return 'Relationships';
      case LearningCategory.sleep:
        return 'Sleep & Rest';
      case LearningCategory.general:
        return 'General Wellness';
    }
  }

  // Get content type display name
  String getContentTypeDisplayName(ContentType type) {
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

  // Get difficulty display name
  String getDifficultyDisplayName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedModule = null;
    _currentProgress = null;
    notifyListeners();
  }

  // Track time spent on module
  Future<void> trackTimeSpent(String userId, String moduleId, int minutes) async {
    try {
      await _learningService.trackTimeSpent(userId, moduleId, minutes);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking time spent: $e');
      }
    }
  }

  // Load mock data for testing
  void loadMockData() {
    _featuredModules = [
      LearningModule(
        title: 'Understanding Anxiety',
        description: 'Learn about anxiety disorders, their symptoms, and evidence-based treatment approaches.',
        category: LearningCategory.anxiety,
        type: ContentType.article,
        difficulty: Difficulty.beginner,
        estimatedMinutes: 15,
        authorId: 'expert1',
        authorName: 'Dr. Sarah Johnson',
        rating: 4.8,
        ratingCount: 234,
        tags: ['anxiety', 'basics', 'symptoms'],
        content: [
          LearningContent(
            title: 'What is Anxiety?',
            content: 'Anxiety is a normal human emotion that everyone experiences from time to time...',
            type: ContentType.article,
            order: 1,
          ),
          LearningContent(
            title: 'Types of Anxiety Disorders',
            content: 'There are several types of anxiety disorders, each with unique characteristics...',
            type: ContentType.article,
            order: 2,
          ),
        ],
      ),
      LearningModule(
        title: 'Mindful Breathing Techniques',
        description: 'Practical breathing exercises to reduce stress and increase mindfulness.',
        category: LearningCategory.mindfulness,
        type: ContentType.exercise,
        difficulty: Difficulty.beginner,
        estimatedMinutes: 10,
        authorId: 'expert2',
        authorName: 'Maria Rodriguez, LCSW',
        rating: 4.9,
        ratingCount: 189,
        tags: ['breathing', 'mindfulness', 'relaxation'],
        content: [
          LearningContent(
            title: '4-7-8 Breathing',
            content: 'This technique involves breathing in for 4 counts, holding for 7, and exhaling for 8...',
            type: ContentType.exercise,
            order: 1,
          ),
        ],
      ),
      LearningModule(
        title: 'Cognitive Restructuring Basics',
        description: 'Learn to identify and challenge negative thought patterns using CBT techniques.',
        category: LearningCategory.cbt,
        type: ContentType.worksheet,
        difficulty: Difficulty.intermediate,
        estimatedMinutes: 25,
        authorId: 'expert3',
        authorName: 'Dr. Michael Chen',
        rating: 4.7,
        ratingCount: 156,
        tags: ['cbt', 'thoughts', 'cognitive'],
        content: [
          LearningContent(
            title: 'Identifying Thought Patterns',
            content: 'The first step in cognitive restructuring is becoming aware of automatic thoughts...',
            type: ContentType.article,
            order: 1,
          ),
          LearningContent(
            title: 'Thought Record Worksheet',
            content: 'Use this worksheet to track and analyze your thoughts throughout the day...',
            type: ContentType.worksheet,
            order: 2,
          ),
        ],
      ),
    ];

    _learningPaths = [
      LearningPath(
        title: 'Anxiety Mastery Path',
        description: 'A comprehensive journey through understanding and managing anxiety.',
        moduleIds: ['mod1', 'mod2', 'mod3'],
        category: LearningCategory.anxiety,
        difficulty: Difficulty.beginner,
        estimatedHours: 2,
        authorId: 'expert1',
        authorName: 'Dr. Sarah Johnson',
      ),
      LearningPath(
        title: 'Mindfulness Foundation',
        description: 'Build a strong foundation in mindfulness and meditation practices.',
        moduleIds: ['mod2', 'mod4', 'mod5'],
        category: LearningCategory.mindfulness,
        difficulty: Difficulty.beginner,
        estimatedHours: 3,
        authorId: 'expert2',
        authorName: 'Maria Rodriguez, LCSW',
      ),
    ];

    notifyListeners();
  }
}