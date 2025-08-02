import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../constants/colors.dart';
import '../../models/therapy_journal.dart';
import '../../providers/auth_provider.dart';
import '../../services/crisis_detection_service.dart';

class JournalComposer extends StatefulWidget {
  final TherapyJournalEntry? entry;
  final Function(TherapyJournalEntry) onSave;

  const JournalComposer({
    super.key,
    this.entry,
    required this.onSave,
  });

  @override
  State<JournalComposer> createState() => _JournalComposerState();
}

class _JournalComposerState extends State<JournalComposer> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  JournalEntryType _entryType = JournalEntryType.personal;
  bool _isPrivate = true;
  bool _isEncrypted = true;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _entryType = widget.entry!.type;
      _isPrivate = widget.entry!.isPrivate;
      _isEncrypted = widget.entry!.isEncrypted;
      _tags = widget.entry!.tags ?? [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.entry == null ? 'New Journal Entry' : 'Edit Entry',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Entry type selector
                        DropdownButtonFormField<JournalEntryType>(
                          value: _entryType,
                          decoration: const InputDecoration(
                            labelText: 'Entry Type',
                            border: OutlineInputBorder(),
                          ),
                          items: JournalEntryType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_getTypeLabel(type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _entryType = value;
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Content field
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 8,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                      return 'Please enter content for your journal entry';
                    }
                    return null;
                          },
                          onChanged: (value) {
                            // Check for crisis keywords as user types
                            setState(() {});
                          },
                        ),
                        
                        // Crisis warning
                        if (CrisisDetectionService.containsCrisisKeywords(_contentController.text)) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Immediate help available: Call 988 for suicide prevention',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Tags field
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma separated)',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _saveEntry(),
                          initialValue: _tags.join(', '),
                          onChanged: (value) {
                            setState(() {
                              _tags = value.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Privacy settings
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Privacy Settings',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SwitchListTile(
                                  title: const Text('Private Entry'),
                                  subtitle: const Text('Only you can see this entry'),
                                  value: _isPrivate,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPrivate = value;
                                    });
                                  },
                                ),
                                SwitchListTile(
                                  title: const Text('End-to-End Encrypted'),
                                  subtitle: const Text('Entry is encrypted on your device'),
                                  value: _isEncrypted,
                                  onChanged: (value) {
                                    setState(() {
                                      _isEncrypted = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveEntry,
                            child: Text(widget.entry == null ? 'Save Entry' : 'Update Entry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to save a journal entry'),
        ),
      );
      return;
    }
    
    final entry = TherapyJournalEntry(
      id: widget.entry?.id ?? const Uuid().v4(),
      userId: authProvider.user!.uid,
      title: _titleController.text,
      content: _contentController.text,
      type: _entryType,
      tags: _tags,
      sharingPermission: _isPrivate ? SharingPermission.private : SharingPermission.community,
      isEncrypted: _isEncrypted,
      timestamp: widget.entry?.timestamp ?? DateTime.now(),
    );
    
    widget.onSave(entry);
  }

  String _getTypeLabel(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.personal:
        return 'General Entry';
      case JournalEntryType.gratitude:
        return 'Gratitude Practice';
      case JournalEntryType.thoughtPattern:
        return 'Thought Pattern Analysis';
      case JournalEntryType.sessionNotes:
        return 'Therapy Session Notes';
      case JournalEntryType.medication:
        return 'Medication Tracking';
      case JournalEntryType.crisis:
        return 'Crisis Documentation';
      case JournalEntryType.therapy:
        return 'Therapy Session';
      case JournalEntryType.progress:
        return 'Progress Update';
    }
  }
}