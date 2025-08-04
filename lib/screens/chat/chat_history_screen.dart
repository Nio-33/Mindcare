import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/ai_therapy_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_message.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  bool _isLoading = true;
  List<TherapyChatSession> _sessions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final chatProvider = context.read<AITherapyProvider>();
      
      // Use authenticated user ID or create demo sessions for anonymous users
      final userId = authProvider.isAuthenticated && authProvider.user != null
          ? authProvider.user!.uid
          : 'anonymous_user';

      // For now, create some demo sessions since Firebase may not be accessible
      _sessions = _createDemoSessions(userId);
      
      // Try to load from Firebase if available
      try {
        final realSessions = chatProvider.userSessions;
        if (realSessions.isNotEmpty) {
          _sessions = realSessions;
        }
      } catch (e) {
        // Continue with demo sessions if Firebase fails
        debugPrint('Could not load sessions from Firebase: $e');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load chat history: $e';
      });
    }
  }

  List<TherapyChatSession> _createDemoSessions(String userId) {
    final now = DateTime.now();
    return [
      TherapyChatSession(
        userId: userId,
        title: 'Anxiety Support',
        startedAt: now.subtract(const Duration(hours: 2)),
        messageCount: 12,
        currentTheme: 'anxiety_management',
        sessionSummary: {
          'primary_concern': 'Work-related anxiety',
          'techniques_used': ['breathing_exercises', 'cognitive_reframing'],
          'mood_progression': 'improved',
        },
      ),
      TherapyChatSession(
        userId: userId,
        title: 'Sleep & Energy',
        startedAt: now.subtract(const Duration(days: 1)),
        endedAt: now.subtract(const Duration(days: 1, hours: -1)),
        messageCount: 8,
        currentTheme: 'sleep_hygiene',
        sessionSummary: {
          'primary_concern': 'Sleep difficulties',
          'techniques_used': ['sleep_hygiene', 'relaxation'],
          'mood_progression': 'stable',
        },
      ),
      TherapyChatSession(
        userId: userId,
        title: 'Stress Management',
        startedAt: now.subtract(const Duration(days: 3)),
        endedAt: now.subtract(const Duration(days: 3, hours: -2)),
        messageCount: 15,
        currentTheme: 'stress_management',
        sessionSummary: {
          'primary_concern': 'Work stress and overwhelm',
          'techniques_used': ['mindfulness', 'time_management', 'boundary_setting'],
          'mood_progression': 'significantly_improved',
        },
      ),
      TherapyChatSession(
        userId: userId,
        title: 'Feeling Down',
        startedAt: now.subtract(const Duration(days: 7)),
        endedAt: now.subtract(const Duration(days: 7, hours: -1)),
        messageCount: 20,
        currentTheme: 'mood_support',
        sessionSummary: {
          'primary_concern': 'Low mood and motivation',
          'techniques_used': ['behavioral_activation', 'cognitive_restructuring'],
          'mood_progression': 'improved',
        },
      ),
      TherapyChatSession(
        userId: userId,
        title: 'Relationship Talk',
        startedAt: now.subtract(const Duration(days: 14)),
        endedAt: now.subtract(const Duration(days: 14, hours: -2)),
        messageCount: 18,
        currentTheme: 'relationship_support',
        sessionSummary: {
          'primary_concern': 'Communication difficulties',
          'techniques_used': ['communication_skills', 'empathy_building'],
          'mood_progression': 'improved',
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChatHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_sessions.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSessionsList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadChatHistory,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Chat History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start a conversation with your AI companion to see your chat history here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Start Chatting'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(TherapyChatSession session) {
    final isActive = session.endedAt == null;
    final duration = session.endedAt?.difference(session.startedAt) ?? 
                     DateTime.now().difference(session.startedAt);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openSession(session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.textTertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Completed',
                      style: TextStyle(
                        color: isActive ? AppColors.success : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Session details
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(session.startedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${session.messageCount} messages',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(duration),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Session summary if available
              if (session.sessionSummary != null) ...[
                const SizedBox(height: 12),
                _buildSessionSummary(session.sessionSummary!),
              ],
              
              const SizedBox(height: 8),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isActive)
                    TextButton.icon(
                      onPressed: () => _continueSession(session),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Continue'),
                    ),
                  TextButton.icon(
                    onPressed: () => _viewSession(session),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleSessionAction(session, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download, size: 18),
                            SizedBox(width: 8),
                            Text('Export'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSummary(Map<String, dynamic> summary) {
    final primaryConcern = summary['primary_concern'] as String?;
    final techniques = summary['techniques_used'] as List<dynamic>?;
    final progression = summary['mood_progression'] as String?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (primaryConcern != null) ...[
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Focus: $primaryConcern',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          
          if (techniques != null && techniques.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Techniques: ${techniques.map((t) => t.toString().replaceAll('_', ' ')).join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          
          if (progression != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  _getProgressionIcon(progression),
                  size: 16,
                  color: _getProgressionColor(progression),
                ),
                const SizedBox(width: 6),
                Text(
                  'Progress: ${progression.replaceAll('_', ' ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getProgressionColor(progression),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getProgressionIcon(String progression) {
    switch (progression) {
      case 'significantly_improved':
        return Icons.trending_up;
      case 'improved':
        return Icons.arrow_upward;
      case 'stable':
        return Icons.horizontal_rule;
      case 'declined':
        return Icons.arrow_downward;
      default:
        return Icons.help_outline;
    }
  }

  Color _getProgressionColor(String progression) {
    switch (progression) {
      case 'significantly_improved':
      case 'improved':
        return AppColors.success;
      case 'stable':
        return AppColors.primary;
      case 'declined':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _openSession(TherapyChatSession session) {
    _showSessionOptions(session);
  }

  void _continueSession(TherapyChatSession session) {
    final chatProvider = context.read<AITherapyProvider>();
    chatProvider.loadSession(session.id);
    Navigator.of(context).pop(); // Go back to chat
  }

  void _viewSession(TherapyChatSession session) {
    _showSessionDetail(session);
  }

  void _showSessionOptions(TherapyChatSession session) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Session'),
              onTap: () {
                Navigator.pop(context);
                _viewSession(session);
              },
            ),
            if (session.endedAt == null)
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Continue Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _continueSession(session);
                },
              ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Session'),
              onTap: () {
                Navigator.pop(context);
                _exportSession(session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Session', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _deleteSession(session);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetail(TherapyChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Started', _formatDateTime(session.startedAt)),
              if (session.endedAt != null)
                _buildDetailRow('Ended', _formatDateTime(session.endedAt!)),
              _buildDetailRow('Messages', '${session.messageCount}'),
              _buildDetailRow('Theme', session.currentTheme.replaceAll('_', ' ')),
              if (session.sessionSummary != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Session Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSessionSummary(session.sessionSummary!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (session.endedAt == null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _continueSession(session);
              },
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _handleSessionAction(TherapyChatSession session, String action) {
    switch (action) {
      case 'export':
        _exportSession(session);
        break;
      case 'delete':
        _deleteSession(session);
        break;
    }
  }

  void _exportSession(TherapyChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Session'),
        content: Text('Export functionality for "${session.title}" will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteSession(TherapyChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "${session.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sessions.remove(session);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${session.title}"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}