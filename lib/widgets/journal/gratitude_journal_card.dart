import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/therapy_journal_provider.dart';

class GratitudeJournalCard extends StatefulWidget {
  const GratitudeJournalCard({super.key});

  @override
  State<GratitudeJournalCard> createState() => _GratitudeJournalCardState();
}

class _GratitudeJournalCardState extends State<GratitudeJournalCard> {
  final _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gratitude Practice',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Text(
                'What are three things you\'re grateful for today?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '1. ...\n2. ...\n3. ...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGratitudeEntry,
                  child: const Text('Save Gratitude Entry'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveGratitudeEntry() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter what you\'re grateful for'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final journalProvider = context.read<TherapyJournalProvider>();
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to save a gratitude entry'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Parse gratitude items from content (split by line breaks)
    final gratitudeItems = _controller.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
    
    journalProvider.saveGratitudeEntry(
      userId: authProvider.user!.uid,
      content: _controller.text,
      gratitudeItems: gratitudeItems,
      rating: 8, // Default high rating for gratitude
    );
    
    _controller.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gratitude entry saved'),
        duration: Duration(seconds: 2),
      ),
    );
    
    setState(() {
      _isExpanded = false;
    });
  }
}