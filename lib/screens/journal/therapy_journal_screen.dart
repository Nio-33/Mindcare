import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/therapy_journal_provider.dart';
import '../../models/therapy_journal.dart';
import '../../widgets/journal/journal_entry_card.dart';
import '../../widgets/journal/journal_composer.dart';
import '../../widgets/journal/thought_pattern_analysis_card.dart';
import '../../widgets/journal/medication_tracker_card.dart';

class TherapyJournalScreen extends StatefulWidget {
  const TherapyJournalScreen({super.key});

  @override
  State<TherapyJournalScreen> createState() => _TherapyJournalScreenState();
}

class _TherapyJournalScreenState extends State<TherapyJournalScreen> {
  bool _showComposer = false;
  TherapyJournalEntry? _editingEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJournalEntries();
    });
  }

  void _loadJournalEntries() {
    final authProvider = context.read<AuthProvider>();
    final journalProvider = context.read<TherapyJournalProvider>();
    
    if (authProvider.isAuthenticated) {
      journalProvider.loadEntries(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapy Journal'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showJournalComposer,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showJournalSettings,
          ),
        ],
      ),
      body: Consumer<TherapyJournalProvider>(
        builder: (context, journalProvider, child) {
          if (journalProvider.isLoading && journalProvider.entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final journalEntries = journalProvider.entries;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Medication Tracker Card
              const MedicationTrackerCard(),
              
              const SizedBox(height: 16),
              
              // Thought Pattern Analysis Card
              ThoughtPatternAnalysisCard(entries: journalEntries),
              
              const SizedBox(height: 16),
              
              // Journal Entries
              if (journalEntries.isEmpty)
                _buildEmptyState()
              else
                ...journalEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final journalEntry = entry.value;
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 16),
                      JournalEntryCard(
                        entry: journalEntry,
                        onTap: () => _viewEntry(journalEntry),
                        onEdit: () => _editEntry(journalEntry),
                        onDelete: () => _deleteEntry(journalEntry),
                      ),
                    ],
                  );
                }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: _showComposer 
          ? null 
          : FloatingActionButton(
              onPressed: _showJournalComposer,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.edit, color: Colors.white),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 24),
          Text(
            'Your Private Journal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start writing to track your thoughts, feelings, and progress on your mental wellness journey.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showJournalComposer,
            icon: const Icon(Icons.edit),
            label: const Text('Write Your First Entry'),
          ),
        ],
      ),
    );
  }

  void _showJournalComposer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => JournalComposer(
        entry: _editingEntry,
        onSave: _saveJournalEntry,
      ),
    );
  }

  void _saveJournalEntry(TherapyJournalEntry entry) {
    final journalProvider = context.read<TherapyJournalProvider>();
    if (_editingEntry == null) {
      journalProvider.addEntry(entry, context);
    } else {
      journalProvider.updateEntry(entry);
    }
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_editingEntry == null 
          ? 'Journal entry saved' 
          : 'Journal entry updated'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    _editingEntry = null;
  }

  void _viewEntry(TherapyJournalEntry entry) {
    // For now, we'll just show a simple dialog with the entry details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.title),
        content: SingleChildScrollView(
          child: Text(entry.content),
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

  void _editEntry(TherapyJournalEntry entry) {
    _editingEntry = entry;
    _showJournalComposer();
  }

  void _deleteEntry(TherapyJournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final journalProvider = context.read<TherapyJournalProvider>();
              journalProvider.deleteEntry(entry.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entry deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showJournalSettings() {
    // TODO: Implement journal settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal settings coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}