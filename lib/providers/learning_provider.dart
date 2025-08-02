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
    // Create comprehensive learning modules
    final mockModules = [
      LearningModule(
        id: 'anxiety-basics',
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
            content: 'Anxiety is a normal human emotion that everyone experiences from time to time. However, when anxiety becomes persistent, excessive, and interferes with daily life, it may indicate an anxiety disorder. Understanding the difference between normal anxiety and anxiety disorders is crucial for seeking appropriate help.',
            type: ContentType.article,
            order: 1,
          ),
          LearningContent(
            title: 'Types of Anxiety Disorders',
            content: 'There are several types of anxiety disorders, including Generalized Anxiety Disorder (GAD), Panic Disorder, Social Anxiety Disorder, and Specific Phobias. Each has unique characteristics but shares common features of excessive fear and worry.',
            type: ContentType.article,
            order: 2,
          ),
        ],
      ),
      LearningModule(
        id: 'mindful-breathing',
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
            content: 'This technique involves breathing in for 4 counts, holding for 7, and exhaling for 8. It activates the parasympathetic nervous system and promotes relaxation.',
            type: ContentType.exercise,
            order: 1,
          ),
          LearningContent(
            title: 'Box Breathing',
            content: 'Also known as square breathing, this technique involves equal counts for inhaling, holding, exhaling, and holding again. Try 4 counts for each phase.',
            type: ContentType.exercise,
            order: 2,
          ),
        ],
      ),
      LearningModule(
        id: 'cognitive-restructuring',
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
            content: 'The first step in cognitive restructuring is becoming aware of automatic thoughts. These are the immediate thoughts that pop into your mind in response to situations.',
            type: ContentType.article,
            order: 1,
          ),
          LearningContent(
            title: 'Thought Record Worksheet',
            content: 'Use this worksheet to track and analyze your thoughts throughout the day. Record the situation, your automatic thought, emotions, and evidence for/against the thought.',
            type: ContentType.worksheet,
            order: 2,
          ),
        ],
      ),
      LearningModule(
        id: 'stress-management',
        title: 'Effective Stress Management',
        description: 'Discover proven strategies for managing stress in daily life.',
        category: LearningCategory.stress,
        type: ContentType.article,
        difficulty: Difficulty.beginner,
        estimatedMinutes: 20,
        authorId: 'expert4',
        authorName: 'Dr. Lisa Park',
        rating: 4.6,
        ratingCount: 298,
        tags: ['stress', 'coping', 'management'],
        content: [
          LearningContent(
            title: 'Understanding Stress Response',
            content: 'Stress is your body\'s natural response to challenges. Learning to recognize stress signals early can help you manage them more effectively.',
            type: ContentType.article,
            order: 1,
          ),
        ],
      ),
      LearningModule(
        id: 'sleep-hygiene',
        title: 'Better Sleep Habits',
        description: 'Improve your sleep quality with evidence-based sleep hygiene practices.',
        category: LearningCategory.sleep,
        type: ContentType.exercise,
        difficulty: Difficulty.beginner,
        estimatedMinutes: 15,
        authorId: 'expert5',
        authorName: 'Dr. Robert Kim',
        rating: 4.8,
        ratingCount: 167,
        tags: ['sleep', 'hygiene', 'rest'],
        content: [
          LearningContent(
            title: 'Creating a Sleep Routine',
            content: 'Establishing consistent bedtime and wake-up times helps regulate your circadian rhythm for better sleep quality.',
            type: ContentType.exercise,
            order: 1,
          ),
        ],
      ),
      LearningModule(
        id: 'self-compassion',
        title: 'Practicing Self-Compassion',
        description: 'Learn to treat yourself with kindness and understanding.',
        category: LearningCategory.selfCare,
        type: ContentType.exercise,
        difficulty: Difficulty.intermediate,
        estimatedMinutes: 18,
        authorId: 'expert6',
        authorName: 'Dr. Emma Thompson',
        rating: 4.9,
        ratingCount: 145,
        tags: ['self-care', 'compassion', 'kindness'],
        content: [
          LearningContent(
            title: 'The Three Components of Self-Compassion',
            content: 'Self-compassion involves mindfulness, common humanity, and self-kindness. These three components work together to create a healthier relationship with yourself.',
            type: ContentType.article,
            order: 1,
          ),
        ],
      ),
    ];

    // Set featured modules (first 3)
    _featuredModules = mockModules.take(3).toList();
    
    // Set all modules
    _allModules = mockModules;

    // Create learning paths
    _learningPaths = [
      LearningPath(
        id: 'anxiety-mastery',
        title: 'Anxiety Mastery Path',
        description: 'A comprehensive journey through understanding and managing anxiety.',
        moduleIds: ['anxiety-basics', 'mindful-breathing', 'cognitive-restructuring'],
        category: LearningCategory.anxiety,
        difficulty: Difficulty.beginner,
        estimatedHours: 2,
        authorId: 'expert1',
        authorName: 'Dr. Sarah Johnson',
      ),
      LearningPath(
        id: 'mindfulness-foundation',
        title: 'Mindfulness Foundation',
        description: 'Build a strong foundation in mindfulness and meditation practices.',
        moduleIds: ['mindful-breathing', 'stress-management', 'self-compassion'],
        category: LearningCategory.mindfulness,
        difficulty: Difficulty.beginner,
        estimatedHours: 3,
        authorId: 'expert2',
        authorName: 'Maria Rodriguez, LCSW',
      ),
      LearningPath(
        id: 'wellness-basics',
        title: 'Wellness Fundamentals',
        description: 'Essential skills for mental health and well-being.',
        moduleIds: ['stress-management', 'sleep-hygiene', 'self-compassion'],
        category: LearningCategory.general,
        difficulty: Difficulty.beginner,
        estimatedHours: 2,
        authorId: 'expert4',
        authorName: 'Dr. Lisa Park',
      ),
    ];

    notifyListeners();
  }
}