import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/ai_therapy_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wellness_dashboard_provider.dart';
import '../../models/chat_message.dart';
import 'ai_chat_message.dart';
import 'chat_input.dart';
import 'suggested_responses.dart';
import 'typing_indicator.dart';
import '../../screens/chat/chat_history_screen.dart';

class AIChatInterface extends StatefulWidget {
  const AIChatInterface({super.key});

  @override
  State<AIChatInterface> createState() => _AIChatInterfaceState();
}

class _AIChatInterfaceState extends State<AIChatInterface> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<AITherapyProvider>();

    // Use authenticated user ID or fallback to anonymous ID
    final userId = authProvider.isAuthenticated && authProvider.user != null
        ? authProvider.user!.uid
        : 'anonymous_user_${DateTime.now().millisecondsSinceEpoch}';

    if (chatProvider.currentSession == null) {
      chatProvider.startNewSession(userId);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<AITherapyProvider>();
    final wellnessProvider = context.read<WellnessDashboardProvider>();

    // Use authenticated user ID or fallback to anonymous ID
    final userId = authProvider.isAuthenticated && authProvider.user != null
        ? authProvider.user!.uid
        : 'anonymous_user_${DateTime.now().millisecondsSinceEpoch}';

    chatProvider.sendMessage(
      message.trim(),
      userId,
      userProfile: authProvider.userProfile,
      recentMoods: wellnessProvider.moodEntries.take(5).toList(),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _sendSuggestedResponse(String response) {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<AITherapyProvider>();
    final wellnessProvider = context.read<WellnessDashboardProvider>();

    // Use authenticated user ID or fallback to anonymous ID
    final userId = authProvider.isAuthenticated && authProvider.user != null
        ? authProvider.user!.uid
        : 'anonymous_user_${DateTime.now().millisecondsSinceEpoch}';

    chatProvider.sendSuggestedResponse(
      response,
      userId,
      userProfile: authProvider.userProfile,
      recentMoods: wellnessProvider.moodEntries.take(5).toList(),
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AITherapyProvider>(
      builder: (context, chatProvider, child) {
        return Column(
          children: [
            // Chat Header
            _buildChatHeader(chatProvider),
            
            // Messages List
            Expanded(
              child: _buildMessagesList(chatProvider),
            ),
            
            // Suggested Responses
            if (chatProvider.lastAIMessage?.suggestedResponses != null)
              SuggestedResponses(
                suggestions: chatProvider.lastAIMessage!.suggestedResponses!,
                onSuggestionTap: _sendSuggestedResponse,
              ),
            
            // Typing Indicator
            if (chatProvider.isTyping)
              const TypingIndicator(),
            
            // Error Message
            if (chatProvider.errorMessage != null)
              _buildErrorMessage(chatProvider),
            
            // Chat Input
            ChatInput(
              controller: _messageController,
              onSendMessage: _sendMessage,
              isEnabled: !chatProvider.isTyping,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatHeader(AITherapyProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // AI Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MindCare AI Companion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  chatProvider.isTyping ? 'Typing...' : 'Online • Here to help',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: chatProvider.isTyping ? AppColors.primary : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          
          // Session Info
          if (chatProvider.currentSession != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'new_session':
                    _startNewSession();
                    break;
                  case 'view_sessions':
                    _showSessionHistory();
                    break;
                  case 'crisis_help':
                    _showCrisisResources();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'new_session',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, size: 18),
                      SizedBox(width: 8),
                      Text('New Session'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_sessions',
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 18),
                      SizedBox(width: 8),
                      Text('Chat History'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'crisis_help',
                  child: Row(
                    children: [
                      Icon(Icons.emergency, size: 18),
                      SizedBox(width: 8),
                      Text('Crisis Resources'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(AITherapyProvider chatProvider) {
    if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatProvider.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return AIChatMessage(
          message: message,
          onSuggestedResponseTap: _sendSuggestedResponse,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to AI Therapy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start a conversation with your AI companion for supportive, evidence-based mental health guidance.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AITherapyProvider chatProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
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
              chatProvider.errorMessage!,
              style: TextStyle(color: AppColors.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: chatProvider.clearError,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  void _startNewSession() {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<AITherapyProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Session'),
        content: const Text('This will start a fresh conversation. Your current chat will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Use authenticated user ID or fallback to anonymous ID
              final userId = authProvider.isAuthenticated && authProvider.user != null
                  ? authProvider.user!.uid
                  : 'anonymous_user_${DateTime.now().millisecondsSinceEpoch}';
              
              chatProvider.startNewSession(userId);
            },
            child: const Text('Start New'),
          ),
        ],
      ),
    );
  }

  void _showSessionHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatHistoryScreen(),
      ),
    );
  }

  void _showCrisisResources() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: AppColors.error),
            SizedBox(width: 8),
            Text('Crisis Resources'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'If you\'re in crisis or need immediate help:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('🚨 National Suicide Prevention Lifeline'),
              Text('988 (available 24/7)', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('💬 Crisis Text Line'),
              Text('Text HOME to 741741', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('🆘 Emergency Services'),
              Text('911', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                'Remember: You are not alone, and help is available.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}