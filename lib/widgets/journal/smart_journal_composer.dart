import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/therapy_journal_provider.dart';
import '../../models/therapy_journal.dart';

class SmartJournalComposer extends StatefulWidget {
  final TherapyJournalEntry? existingEntry;
  final JournalEntryType? suggestedType;

  const SmartJournalComposer({
    super.key,
    this.existingEntry,
    this.suggestedType,
  });

  @override
  State<SmartJournalComposer> createState() => _SmartJournalComposerState();
}

class _SmartJournalComposerState extends State<SmartJournalComposer> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  JournalEntryType _selectedType = JournalEntryType.personal;
  List<String> _selectedTags = [];
  bool _isPrivate = true;
  bool _showPrompts = true;
  String _selectedPrompt = '';
  
  final List<String> _availableTags = [
    'anxiety', 'depression', 'gratitude', 'progress', 'therapy',
    'meditation', 'exercise', 'sleep', 'work', 'relationships',
    'family', 'health', 'stress', 'achievement', 'reflection'
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.existingEntry != null) {
      _titleController.text = widget.existingEntry!.title;
      _contentController.text = widget.existingEntry!.content;
      _selectedType = widget.existingEntry!.type;
      _selectedTags = List.from(widget.existingEntry!.tags);
      _isPrivate = widget.existingEntry!.sharingPermission == SharingPermission.private;
    } else if (widget.suggestedType != null) {
      _selectedType = widget.suggestedType!;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry != null ? 'Edit Entry' : 'New Journal Entry'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showPrompts ? Icons.lightbulb : Icons.lightbulb_outline),
            onPressed: () {
              setState(() {
                _showPrompts = !_showPrompts;
              });
            },
          ),
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_showPrompts) _buildSmartPrompts(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 16),
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildContentField(),
                    const SizedBox(height: 16),
                    _buildTagsSection(),
                    const SizedBox(height: 16),
                    _buildPrivacySettings(),
                    const SizedBox(height: 16),
                    _buildSmartSuggestions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartPrompts() {
    final prompts = _getPromptsForType(_selectedType);
    
    return Container(
      color: AppColors.accent.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'Writing Prompts',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                final isSelected = _selectedPrompt == prompt;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : AppColors.accent,
                      ),
                    ),
                    backgroundColor: isSelected ? AppColors.accent : Colors.transparent,
                    side: BorderSide(color: AppColors.accent),
                    onPressed: () => _usePrompt(prompt),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entry Type',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: JournalEntryType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(_formatEntryType(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                  _selectedPrompt = '';
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: _getTitleHint(_selectedType),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      maxLines: 10,
      decoration: InputDecoration(
        labelText: 'Content',
        hintText: _getContentHint(_selectedType),
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter some content';
        }
        return null;
      },
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppColors.secondary.withOpacity(0.2),
              checkmarkColor: AppColors.secondary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Keep Private'),
              subtitle: Text(
                _isPrivate 
                  ? 'Only you can see this entry'
                  : 'This entry may be visible to others',
              ),
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartSuggestions() {
    final suggestions = _getSmartSuggestions();
    
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Suggestions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<String> _getPromptsForType(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.personal:
        return [
          'How am I feeling today?',
          'What challenged me today?',
          'What am I grateful for?',
          'What did I learn about myself?',
        ];
      case JournalEntryType.gratitude:
        return [
          'Three things I\'m grateful for',
          'Someone who made my day better',
          'A moment that brought me joy',
          'Progress I\'ve made recently',
        ];
      case JournalEntryType.therapy:
        return [
          'Key insights from therapy',
          'Goals I\'m working on',
          'Thoughts and patterns I noticed',
          'How I applied coping strategies',
        ];
      case JournalEntryType.progress:
        return [
          'How I\'ve grown this week',
          'Challenges I\'ve overcome',
          'Skills I\'m developing',
          'Goals I\'m achieving',
        ];
      case JournalEntryType.crisis:
        return [
          'What I\'m struggling with',
          'Support I need right now',
          'Coping strategies that help',
          'People I can reach out to',
        ];
      case JournalEntryType.medication:
        return [
          'How medication is affecting me',
          'Side effects I\'ve noticed',
          'Changes in my mood or energy',
          'Questions for my doctor',
        ];
    }
  }

  String _getTitleHint(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.personal:
        return 'My thoughts today...';
      case JournalEntryType.gratitude:
        return 'Gratitude - ${DateTime.now().toString().substring(0, 10)}';
      case JournalEntryType.therapy:
        return 'Therapy session - ${DateTime.now().toString().substring(0, 10)}';
      case JournalEntryType.progress:
        return 'Progress update...';
      case JournalEntryType.crisis:
        return 'Difficult moment...';
      case JournalEntryType.medication:
        return 'Medication log - ${DateTime.now().toString().substring(0, 10)}';
    }
  }

  String _getContentHint(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.personal:
        return 'Share your thoughts, feelings, and experiences...';
      case JournalEntryType.gratitude:
        return 'What are you grateful for today?';
      case JournalEntryType.therapy:
        return 'Reflect on your therapy session and key insights...';
      case JournalEntryType.progress:
        return 'Document your progress and achievements...';
      case JournalEntryType.crisis:
        return 'Express what you\'re going through. Remember, help is available...';
      case JournalEntryType.medication:
        return 'Note any effects, side effects, or changes you\'ve noticed...';
    }
  }

  String _formatEntryType(JournalEntryType type) {
    switch (type) {
      case JournalEntryType.personal:
        return 'Personal';
      case JournalEntryType.therapy:
        return 'Therapy';
      case JournalEntryType.gratitude:
        return 'Gratitude';
      case JournalEntryType.medication:
        return 'Medication';
      case JournalEntryType.crisis:
        return 'Crisis';
      case JournalEntryType.progress:
        return 'Progress';
    }
  }

  List<String> _getSmartSuggestions() {
    final content = _contentController.text.toLowerCase();
    final suggestions = <String>[];

    // Content-based suggestions
    if (content.contains('stress') || content.contains('anxious')) {
      suggestions.add('Consider adding breathing exercises or meditation to your routine');
    }
    
    if (content.contains('sleep') && content.contains('trouble')) {
      suggestions.add('Try creating a bedtime routine for better sleep hygiene');
    }
    
    if (content.contains('sad') || content.contains('down')) {
      suggestions.add('Physical activity can help improve mood - even a short walk helps');
    }
    
    if (content.contains('overwhelmed')) {
      suggestions.add('Breaking tasks into smaller steps can make them more manageable');
    }

    // Type-based suggestions
    if (_selectedType == JournalEntryType.crisis) {
      suggestions.add('Remember: Crisis resources are available 24/7 if you need immediate help');
    }

    return suggestions;
  }

  void _usePrompt(String prompt) {
    setState(() {
      _selectedPrompt = prompt;
      if (_titleController.text.isEmpty) {
        _titleController.text = prompt;
      }
      if (_contentController.text.isEmpty) {
        _contentController.text = '$prompt\n\n';
        // Move cursor to end
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      }
    });
  }

  void _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final journalProvider = context.read<TherapyJournalProvider>();
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save entries')),
      );
      return;
    }

    try {
      await journalProvider.saveJournalEntry(
        entryId: widget.existingEntry?.id,
        userId: authProvider.user!.uid,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        tags: _selectedTags,
        sharingPermission: _isPrivate ? SharingPermission.private : SharingPermission.anonymous,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingEntry != null 
              ? 'Journal entry updated with AI insights' 
              : 'Journal entry saved with AI insights'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    }
  }
}