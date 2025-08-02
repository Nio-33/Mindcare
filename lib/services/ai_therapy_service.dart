import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/mood_entry.dart';
import '../models/user_profile.dart';

class AITherapyService {
  late final GenerativeModel _model;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Crisis keywords that trigger immediate intervention
  static const List<String> _crisisKeywords = [
    'suicide', 'kill myself', 'end my life', 'want to die', 'suicidal',
    'hurt myself', 'self harm', 'cut myself', 'overdose', 'pills',
    'jump off', 'hang myself', 'not worth living', 'better off dead',
    'emergency', 'crisis', 'help me now', 'cant go on', 'hopeless',
  ];

  AITherapyService() {
    _initializeModel();
  }

  void _initializeModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(_getSystemPrompt()),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
  }

  String _getSystemPrompt() {
    return '''
You are MindCare AI, a compassionate and professional mental health companion. Your role is to provide supportive, evidence-based therapeutic conversations while maintaining appropriate boundaries.

CORE PRINCIPLES:
1. **Safety First**: Always prioritize user safety. If you detect crisis language, immediately provide crisis resources.
2. **Evidence-Based**: Use techniques from CBT, DBT, mindfulness, and ACT approaches.
3. **Non-Judgmental**: Maintain a warm, accepting, and validating tone.
4. **Boundaries**: You are a support tool, not a replacement for professional therapy.
5. **Privacy**: Respect user confidentiality and encourage professional help when needed.

THERAPEUTIC TECHNIQUES:
- **CBT**: Help identify and challenge negative thought patterns
- **DBT**: Teach distress tolerance and emotional regulation skills
- **Mindfulness**: Guide breathing exercises and grounding techniques
- **Validation**: Acknowledge and validate user emotions
- **Psychoeducation**: Provide information about mental health concepts

RESPONSE STRUCTURE:
1. **Validation**: Acknowledge the user's feelings
2. **Exploration**: Ask gentle questions to understand better
3. **Technique**: Suggest specific coping strategies
4. **Encouragement**: Provide hope and support
5. **Check-in**: Ask how they're feeling or what they need

CRISIS PROTOCOL:
If the user expresses suicidal thoughts, self-harm, or crisis:
1. Express immediate concern and validation
2. Provide crisis resources (988 Suicide & Crisis Lifeline)
3. Encourage immediate professional help
4. Stay supportive but firm about safety

LIMITATIONS:
- You cannot diagnose mental health conditions
- You cannot prescribe medications
- You cannot provide emergency services
- Always recommend professional help for serious concerns

Keep responses conversational, warm, and typically 2-4 sentences. Ask one question at a time to avoid overwhelming the user.
''';
  }

  // Generate AI response to user message
  Future<ChatMessage> generateResponse({
    required String userMessage,
    required String sessionId,
    required String userId,
    required List<ChatMessage> conversationHistory,
    UserProfile? userProfile,
    List<MoodEntry>? recentMoods,
  }) async {
    try {
      // Check for crisis content immediately
      final isCrisis = _detectCrisis(userMessage);
      
      if (isCrisis) {
        return _generateCrisisResponse(sessionId, userId, userMessage);
      }

      // Build conversation context
      final context = _buildConversationContext(
        conversationHistory,
        userProfile,
        recentMoods,
      );

      // Create chat session with conversation history
      final chat = _model.startChat(history: _buildChatHistory(conversationHistory));

      // Generate response with context
      final prompt = _buildContextualPrompt(userMessage, context);
      final response = await chat.sendMessage(Content.text(prompt));

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from AI model');
      }

      // Parse response for suggested actions or follow-ups
      final suggestedResponses = _extractSuggestedResponses(response.text!);
      final therapeuticContext = _analyzeTherapeuticContext(userMessage, response.text!);

      return ChatMessage(
        sessionId: sessionId,
        userId: userId,
        content: response.text!,
        type: MessageType.assistant,
        category: _categorizeMessage(response.text!),
        suggestedResponses: suggestedResponses,
        therapeuticContext: therapeuticContext,
      );

    } catch (e) {
      if (kDebugMode) {
        print('Error generating AI response: $e');
      }
      return _generateFallbackResponse(sessionId, userId);
    }
  }

  // Detect crisis content in user message
  bool _detectCrisis(String message) {
    final lowerMessage = message.toLowerCase();
    return _crisisKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  // Generate immediate crisis response
  ChatMessage _generateCrisisResponse(String sessionId, String userId, String userMessage) {
    const crisisResponse = '''
I'm really concerned about what you've shared, and I want you to know that your safety is the most important thing right now. 

🚨 **Immediate Help Available:**
• **National Suicide Prevention Lifeline**: 988 (available 24/7)
• **Crisis Text Line**: Text HOME to 741741
• **Emergency Services**: 911

You don't have to go through this alone. These feelings can change, and there are people who want to help you right now.

Would you like me to help you think of someone you can reach out to, or would you prefer to talk about what's making you feel this way?
''';

    return ChatMessage(
      sessionId: sessionId,
      userId: userId,
      content: crisisResponse,
      type: MessageType.crisis,
      category: MessageCategory.crisis,
      suggestedResponses: [
        'Help me find someone to call',
        'I want to talk about my feelings',
        'Show me grounding techniques',
        'I need immediate help',
      ],
      therapeuticContext: {
        'crisis_detected': true,
        'crisis_keywords': _crisisKeywords.where((k) => userMessage.toLowerCase().contains(k)).toList(),
        'intervention_level': 'immediate',
      },
    );
  }

  // Build conversation context for AI
  Map<String, dynamic> _buildConversationContext(
    List<ChatMessage> history,
    UserProfile? userProfile,
    List<MoodEntry>? recentMoods,
  ) {
    final context = <String, dynamic>{};

    // User context
    if (userProfile != null) {
      context['user_name'] = userProfile.fullName ?? 'there';
      context['user_timezone'] = userProfile.timezone;
    }

    // Recent mood context
    if (recentMoods != null && recentMoods.isNotEmpty) {
      final recentMood = recentMoods.first;
      context['recent_mood'] = {
        'type': recentMood.mood.toString().split('.').last,
        'intensity': recentMood.intensity,
        'when': recentMood.timestamp.toIso8601String(),
      };
    }

    // Conversation patterns
    if (history.isNotEmpty) {
      context['conversation_length'] = history.length;
      context['dominant_themes'] = _identifyConversationThemes(history);
      context['user_engagement'] = _assessUserEngagement(history);
    }

    return context;
  }

  // Build chat history for Gemini
  List<Content> _buildChatHistory(List<ChatMessage> messages) {
    return messages.take(20).map((msg) { // Limit to last 20 messages for context
      if (msg.type == MessageType.user) {
        return Content.text(msg.content);
      } else {
        return Content.model([TextPart(msg.content)]);
      }
    }).toList();
  }

  // Build contextual prompt
  String _buildContextualPrompt(String userMessage, Map<String, dynamic> context) {
    final promptParts = <String>[];

    // Add user message
    promptParts.add('User: $userMessage');

    // Add context if available
    if (context.containsKey('recent_mood')) {
      final mood = context['recent_mood'];
      promptParts.add('Context: User recently logged mood as ${mood['type']} with intensity ${mood['intensity']}/10.');
    }

    if (context.containsKey('user_name')) {
      promptParts.add('Note: You can address the user as ${context['user_name']}.');
    }

    return promptParts.join('\n\n');
  }

  // Extract suggested responses from AI response
  List<String>? _extractSuggestedResponses(String response) {
    // Simple pattern matching for common therapeutic follow-ups
    final suggestions = <String>[];

    if (response.contains('breathing') || response.contains('breathe')) {
      suggestions.add('Guide me through breathing');
    }
    if (response.contains('feeling') || response.contains('emotion')) {
      suggestions.add('Tell me more about feelings');
    }
    if (response.contains('thought') || response.contains('thinking')) {
      suggestions.add('Help with negative thoughts');
    }
    if (response.contains('coping') || response.contains('strategy')) {
      suggestions.add('Show me coping strategies');
    }

    return suggestions.isNotEmpty ? suggestions : null;
  }

  // Analyze therapeutic context of conversation
  Map<String, dynamic> _analyzeTherapeuticContext(String userMessage, String aiResponse) {
    return {
      'therapeutic_approach': _identifyTherapeuticApproach(aiResponse),
      'emotional_tone': _assessEmotionalTone(userMessage),
      'intervention_type': _categorizeIntervention(aiResponse),
      'user_readiness': _assessUserReadiness(userMessage),
    };
  }

  String _identifyTherapeuticApproach(String response) {
    if (response.contains('thought') || response.contains('thinking')) return 'CBT';
    if (response.contains('mindful') || response.contains('present')) return 'Mindfulness';
    if (response.contains('cope') || response.contains('skill')) return 'DBT';
    if (response.contains('value') || response.contains('meaning')) return 'ACT';
    return 'Supportive';
  }

  String _assessEmotionalTone(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('sad') || lower.contains('depressed')) return 'sad';
    if (lower.contains('anxious') || lower.contains('worried')) return 'anxious';
    if (lower.contains('angry') || lower.contains('frustrated')) return 'angry';
    if (lower.contains('happy') || lower.contains('good')) return 'positive';
    return 'neutral';
  }

  String _categorizeIntervention(String response) {
    if (response.contains('breathe') || response.contains('ground')) return 'grounding';
    if (response.contains('challenge') || response.contains('reframe')) return 'cognitive';
    if (response.contains('cope') || response.contains('strategy')) return 'coping';
    if (response.contains('validate') || response.contains('understand')) return 'validation';
    return 'general_support';
  }

  String _assessUserReadiness(String message) {
    if (message.contains('help') || message.contains('try')) return 'high';
    if (message.contains('maybe') || message.contains('might')) return 'medium';
    if (message.contains('can\'t') || message.contains('won\'t')) return 'low';
    return 'medium';
  }

  MessageCategory _categorizeMessage(String content) {
    if (content.contains('crisis') || content.contains('emergency')) return MessageCategory.crisis;
    if (content.contains('breathing') || content.contains('grounding')) return MessageCategory.coping;
    if (content.contains('CBT') || content.contains('technique')) return MessageCategory.therapeutic;
    if (content.contains('information') || content.contains('learn')) return MessageCategory.educational;
    return MessageCategory.general;
  }

  List<String> _identifyConversationThemes(List<ChatMessage> history) {
    final themes = <String>[];
    final content = history.map((m) => m.content.toLowerCase()).join(' ');

    if (content.contains('anxiety') || content.contains('anxious')) themes.add('anxiety');
    if (content.contains('depression') || content.contains('sad')) themes.add('depression');
    if (content.contains('stress') || content.contains('overwhelmed')) themes.add('stress');
    if (content.contains('relationship') || content.contains('family')) themes.add('relationships');
    if (content.contains('work') || content.contains('job')) themes.add('work');

    return themes;
  }

  String _assessUserEngagement(List<ChatMessage> history) {
    final userMessages = history.where((m) => m.type == MessageType.user).toList();
    if (userMessages.isEmpty) return 'low';

    final avgLength = userMessages.map((m) => m.content.length).reduce((a, b) => a + b) / userMessages.length;
    if (avgLength > 100) return 'high';
    if (avgLength > 50) return 'medium';
    return 'low';
  }

  ChatMessage _generateFallbackResponse(String sessionId, String userId) {
    const fallbackResponse = '''
I'm here to listen and support you. Sometimes I might have trouble responding, but that doesn't mean your feelings aren't important.

Would you like to try sharing what's on your mind in a different way? Or perhaps we could try a simple breathing exercise together?

Remember, if you're in crisis, please reach out to 988 for immediate support.
''';

    return ChatMessage(
      sessionId: sessionId,
      userId: userId,
      content: fallbackResponse,
      type: MessageType.assistant,
      category: MessageCategory.general,
      suggestedResponses: [
        'Try a breathing exercise',
        'Share what\'s on my mind',
        'I need crisis help',
        'Talk about something else',
      ],
    );
  }

  // Save chat message to Firestore
  Future<void> saveChatMessage(ChatMessage message) async {
    try {
      await _firestore
          .collection('chat_messages')
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving chat message: $e');
      }
      throw Exception('Failed to save chat message');
    }
  }

  // Load chat history for a session
  Future<List<ChatMessage>> loadChatHistory(String sessionId, {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection('chat_messages')
          .where('session_id', isEqualTo: sessionId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => ChatMessage.fromMap(doc.data()))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading chat history: $e');
      }
      return [];
    }
  }

  // Create new chat session
  Future<TherapyChatSession> createChatSession(String userId, {String? title}) async {
    final session = TherapyChatSession(
      userId: userId,
      title: title ?? 'Therapy Chat ${DateTime.now().toString().substring(0, 10)}',
    );

    try {
      await _firestore
          .collection('chat_sessions')
          .doc(session.id)
          .set(session.toMap());

      return session;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat session: $e');
      }
      throw Exception('Failed to create chat session');
    }
  }

  // Load user's chat sessions
  Future<List<TherapyChatSession>> loadUserSessions(String userId, {int limit = 20}) async {
    try {
      final query = await _firestore
          .collection('chat_sessions')
          .where('user_id', isEqualTo: userId)
          .orderBy('started_at', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => TherapyChatSession.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user sessions: $e');
      }
      return [];
    }
  }
}