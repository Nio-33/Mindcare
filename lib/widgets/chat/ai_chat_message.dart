import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../models/chat_message.dart';

class AIChatMessage extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onSuggestedResponseTap;

  const AIChatMessage({
    super.key,
    required this.message,
    this.onSuggestedResponseTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isCrisis = message.type == MessageType.crisis;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(isCrisis),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: _getMessageBackgroundColor(isUser, isCrisis),
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  topRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: isCrisis 
                    ? Border.all(color: AppColors.error, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crisis indicator
                  if (isCrisis)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emergency, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'CRISIS SUPPORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Message content
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  
                  // Message metadata
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: TextStyle(
                          color: isUser 
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(context, message.content),
                          child: Icon(
                            Icons.copy,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isCrisis) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCrisis ? AppColors.error : AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isCrisis ? Icons.emergency : Icons.psychology,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Color _getMessageBackgroundColor(bool isUser, bool isCrisis) {
    if (isUser) {
      return AppColors.primary;
    } else if (isCrisis) {
      return AppColors.error.withOpacity(0.1);
    } else {
      return AppColors.surface;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}