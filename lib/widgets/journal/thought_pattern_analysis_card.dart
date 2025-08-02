import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/therapy_journal.dart';

class ThoughtPatternAnalysisCard extends StatelessWidget {
  final List<TherapyJournalEntry> entries;

  const ThoughtPatternAnalysisCard({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    // Filter for thought pattern entries
    final thoughtEntries = entries.where((entry) => entry.type == JournalEntryType.thoughtPattern).toList();
    
    if (thoughtEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Analyze patterns (simple example)
    final negativeThoughts = thoughtEntries.where((entry) {
      final content = entry.content.toLowerCase();
      return content.contains('can\'t') || 
             content.contains('won\'t') || 
             content.contains('never') || 
             content.contains('always');
    }).length;

    final positiveShifts = thoughtEntries.where((entry) {
      final content = entry.content.toLowerCase();
      return content.contains('can') && !content.contains('can\'t') ||
             content.contains('will') && !content.contains('won\'t') ||
             content.contains('sometimes') ||
             content.contains('maybe');
    }).length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thought Pattern Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ve recorded ${thoughtEntries.length} thought patterns this week.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: negativeThoughts / thoughtEntries.length,
              backgroundColor: AppColors.divider,
              color: negativeThoughts > thoughtEntries.length * 0.5 
                  ? AppColors.error 
                  : AppColors.warning,
            ),
            const SizedBox(height: 8),
            Text(
              '${(negativeThoughts / thoughtEntries.length * 100).round()}% of your thoughts show negative patterns',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            if (positiveShifts > 0) ...[
              Icon(
                Icons.trending_up,
                color: AppColors.success,
              ),
              const SizedBox(height: 4),
              Text(
                'You\'ve shown positive shifts in ${positiveShifts} entries!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}