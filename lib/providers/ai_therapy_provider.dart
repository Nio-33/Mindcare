import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../models/mood_entry.dart';
import '../services/ai_therapy_service.dart';

class AITherapyProvider extends ChangeNotifier {
  final AITherapyService _aiService = AITherapyService();

  TherapyChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;
  List<TherapyChatSession> _userSessions = [];

  TherapyChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  List<TherapyChatSession> get userSessions => _userSessions;

  // Start a new chat session
  Future<void> startNewSession(String userId, {String? title}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create local session if Firebase fails
      try {
        _currentSession = await _aiService.createChatSession(userId, title: title);
      } catch (e) {
        // Fallback to local session
        _currentSession = TherapyChatSession(
          userId: userId,
          title: title ?? 'Local Therapy Chat',
        );
        if (kDebugMode) {
          print('Using local session due to Firebase error: $e');
        }
      }
      
      _messages.clear();

      // Add welcome message
      final welcomeMessage = ChatMessage(
        sessionId: _currentSession!.id,
        userId: userId,
        content: _getWelcomeMessage(),
        type: MessageType.assistant,
        category: MessageCategory.general,
        suggestedResponses: [
          'I\'m feeling anxious',
          'I had a rough day',
          'I want to learn coping skills',
          'I need someone to talk to',
        ],
      );

      _messages.add(welcomeMessage);
      
      // Try to save to Firebase, but don't fail if it doesn't work
      try {
        await _aiService.saveChatMessage(welcomeMessage);
      } catch (e) {
        if (kDebugMode) {
          print('Could not save to Firebase, continuing with local chat: $e');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to start chat session: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error starting new session: $e');
      }
    }
  }

  // Send user message and get AI response
  Future<void> sendMessage(
    String content, 
    String userId, {
    UserProfile? userProfile,
    List<MoodEntry>? recentMoods,
  }) async {
    if (_currentSession == null) {
      await startNewSession(userId);
    }

    try {
      _errorMessage = null;
      
      // Add user message
      final userMessage = ChatMessage(
        sessionId: _currentSession!.id,
        userId: userId,
        content: content,
        type: MessageType.user,
        category: MessageCategory.general,
      );

      _messages.add(userMessage);
      notifyListeners();

      // Try to save user message (don't fail if Firebase is down)
      try {
        await _aiService.saveChatMessage(userMessage);
      } catch (e) {
        if (kDebugMode) {
          print('Could not save user message to Firebase: $e');
        }
      }

      // Show typing indicator
      _isTyping = true;
      notifyListeners();

      // Generate AI response
      final aiResponse = await _aiService.generateResponse(
        userMessage: content,
        sessionId: _currentSession!.id,
        userId: userId,
        conversationHistory: _messages,
        userProfile: userProfile,
        recentMoods: recentMoods,
      );

      // Hide typing indicator
      _isTyping = false;

      // Add AI response
      _messages.add(aiResponse);
      
      // Try to save AI response (don't fail if Firebase is down)
      try {
        await _aiService.saveChatMessage(aiResponse);
      } catch (e) {
        if (kDebugMode) {
          print('Could not save AI response to Firebase: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      _isTyping = false;
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }

  // Load existing chat session
  Future<void> loadSession(String sessionId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final messages = await _aiService.loadChatHistory(sessionId);
      _messages = messages;

      // Find session in user sessions or current session
      _currentSession = _userSessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => _currentSession!,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load session: $e';
      notifyListeners();
      if (kDebugMode) {
        print('Error loading session: $e');
      }
    }
  }

  // Load user's chat sessions
  Future<void> loadUserSessions(String userId) async {
    try {
      _userSessions = await _aiService.loadUserSessions(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user sessions: $e');
      }
    }
  }

  // Send a suggested response
  Future<void> sendSuggestedResponse(
    String response, 
    String userId, {
    UserProfile? userProfile,
    List<MoodEntry>? recentMoods,
  }) async {
    await sendMessage(response, userId, userProfile: userProfile, recentMoods: recentMoods);
  }

  // Clear current session
  void clearSession() {
    _currentSession = null;
    _messages.clear();
    _errorMessage = null;
    _isLoading = false;
    _isTyping = false;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get appropriate welcome message
  String _getWelcomeMessage() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return '''
$greeting! I'm your MindCare AI companion. I'm here to listen, support you, and help you work through whatever is on your mind.

I use evidence-based approaches like cognitive behavioral therapy (CBT), mindfulness, and other proven techniques to provide you with personalized support.

**Important**: I'm here to supplement, not replace, professional mental health care. If you're in a crisis, please contact emergency services or call 988 for immediate help.

What would you like to talk about today?
''';
  }

  // Generate session title based on conversation
  String generateSessionTitle() {
    if (_messages.isEmpty) return 'New Chat';

    final userMessages = _messages.where((m) => m.type == MessageType.user);
    if (userMessages.isEmpty) return 'New Chat';

    // Analyze first few user messages for theme
    final firstMessage = userMessages.first.content.toLowerCase();
    
    if (firstMessage.contains('anxious') || firstMessage.contains('anxiety')) {
      return 'Anxiety Support';
    }
    if (firstMessage.contains('sad') || firstMessage.contains('depression')) {
      return 'Feeling Down';
    }
    if (firstMessage.contains('stress') || firstMessage.contains('overwhelmed')) {
      return 'Stress Management';
    }
    if (firstMessage.contains('relationship') || firstMessage.contains('family')) {
      return 'Relationship Talk';
    }
    if (firstMessage.contains('work') || firstMessage.contains('job')) {
      return 'Work Concerns';
    }
    if (firstMessage.contains('sleep') || firstMessage.contains('tired')) {
      return 'Sleep & Energy';
    }

    // Default to time-based title
    final now = DateTime.now();
    final timeStr = '${now.month}/${now.day}';
    return 'Chat $timeStr';
  }

  // Check if current message indicates crisis
  bool get isInCrisis {
    return _messages.isNotEmpty && 
           _messages.last.type == MessageType.crisis;
  }

  // Get last AI message
  ChatMessage? get lastAIMessage {
    final aiMessages = _messages.where((m) => m.type == MessageType.assistant || m.type == MessageType.crisis);
    return aiMessages.isNotEmpty ? aiMessages.last : null;
  }

  // Get message statistics
  Map<String, int> get messageStats {
    final userMessages = _messages.where((m) => m.type == MessageType.user).length;
    final aiMessages = _messages.where((m) => m.type == MessageType.assistant).length;
    final crisisMessages = _messages.where((m) => m.type == MessageType.crisis).length;
    
    return {
      'total': _messages.length,
      'user': userMessages,
      'ai': aiMessages,
      'crisis': crisisMessages,
    };
  }

  // End current session
  Future<void> endSession() async {
    if (_currentSession == null) return;

    try {
      // Update session with end time and summary
      // This would typically involve updating Firestore
      // For now, just clear the session locally
      
      clearSession();
    } catch (e) {
      if (kDebugMode) {
        print('Error ending session: $e');
      }
    }
  }
}