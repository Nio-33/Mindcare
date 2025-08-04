import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/therapy_journal.dart';

class JournalEntryCard extends StatelessWidget {
  final TherapyJournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(entry.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Entry type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(entry.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getTypeColor(entry.type).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getTypeLabel(entry.type),
                  style: TextStyle(
                    color: _getTypeColor(entry.type),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Content preview
              Text(
                entry.content.length > 150 
                    ? '${entry.content.substring(0, 150)}...' 
                    : entry.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Footer with actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (entry.isPrivate)
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  const SizedBox(width: 8),
                  if (entry.isEncrypted)
                    Icon(
                      Icons.security,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _getTypeLabel(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.personal:
        return 'General';
      case JournalEntryType.gratitude:
        return 'Gratitude';
      case JournalEntryType.thoughtPattern:
        return 'Thought Pattern';
      case JournalEntryType.sessionNotes:
        return 'Session Notes';
      case JournalEntryType.medication:
        return 'Medication';
      case JournalEntryType.crisis:
        return 'Crisis';
      case JournalEntryType.therapy:
        return 'Therapy';
      case JournalEntryType.progress:
        return 'Progress';
    }
  }

  Color _getTypeColor(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.personal:
        return AppColors.primary;
      case JournalEntryType.gratitude:
        return AppColors.success;
      case JournalEntryType.thoughtPattern:
        return AppColors.info;
      case JournalEntryType.sessionNotes:
        return AppColors.secondary;
      case JournalEntryType.medication:
        return AppColors.warning;
      case JournalEntryType.crisis:
        return AppColors.error;
      case JournalEntryType.therapy:
        return AppColors.secondary;
      case JournalEntryType.progress:
        return AppColors.success;
    }
  }
}