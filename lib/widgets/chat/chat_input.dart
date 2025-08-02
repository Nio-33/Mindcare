import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final bool isEnabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final isComposing = widget.controller.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
  }

  void _handleSend() {
    if (!_isComposing || !widget.isEnabled) return;
    
    final message = widget.controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quick Action Button
            IconButton(
              onPressed: widget.isEnabled ? _showQuickActions : null,
              icon: Icon(
                Icons.add_circle_outline,
                color: widget.isEnabled ? AppColors.primary : AppColors.disabled,
              ),
              tooltip: 'Quick actions',
            ),
            
            const SizedBox(width: 8),
            
            // Text Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        enabled: widget.isEnabled,
                        maxLines: null,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: widget.isEnabled ? (text) => _handleSend() : null,
                      ),
                    ),
                    
                    // Voice Input Button (placeholder)
                    IconButton(
                      onPressed: widget.isEnabled ? _startVoiceInput : null,
                      icon: Icon(
                        Icons.mic_outlined,
                        color: widget.isEnabled ? AppColors.textSecondary : AppColors.disabled,
                      ),
                      tooltip: 'Voice input (coming soon)',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: (_isComposing && widget.isEnabled) ? _handleSend : null,
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (_isComposing && widget.isEnabled) 
                        ? AppColors.primary 
                        : AppColors.disabled,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _QuickActionsSheet(
        onActionSelected: (action) {
          Navigator.of(context).pop();
          widget.controller.text = action;
          _handleSend();
        },
      ),
    );
  }

  void _startVoiceInput() {
    // Placeholder for voice input functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  final Function(String) onActionSelected;

  const _QuickActionsSheet({
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Actions Grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: [
              _QuickActionButton(
                icon: Icons.sentiment_dissatisfied,
                label: 'I\'m feeling anxious',
                color: AppColors.moodAnxious,
                onTap: () => onActionSelected('I\'m feeling anxious and need some support'),
              ),
              _QuickActionButton(
                icon: Icons.sentiment_very_dissatisfied,
                label: 'I\'m feeling sad',
                color: AppColors.moodSad,
                onTap: () => onActionSelected('I\'m feeling sad today'),
              ),
              _QuickActionButton(
                icon: Icons.local_fire_department,
                label: 'I\'m stressed',
                color: AppColors.moodAngry,
                onTap: () => onActionSelected('I\'m feeling really stressed'),
              ),
              _QuickActionButton(
                icon: Icons.battery_0_bar,
                label: 'I\'m tired',
                color: AppColors.moodNeutral,
                onTap: () => onActionSelected('I\'m feeling exhausted'),
              ),
              _QuickActionButton(
                icon: Icons.psychology,
                label: 'Need coping skills',
                color: AppColors.primary,
                onTap: () => onActionSelected('Can you teach me some coping strategies?'),
              ),
              _QuickActionButton(
                icon: Icons.chat,
                label: 'Just want to talk',
                color: AppColors.secondary,
                onTap: () => onActionSelected('I just need someone to talk to'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}