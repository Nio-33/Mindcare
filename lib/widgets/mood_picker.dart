import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/mood_entry.dart';

class MoodPicker extends StatefulWidget {
  final MoodType? selectedMood;
  final int selectedIntensity;
  final Function(MoodType mood, int intensity)? onMoodSelected;

  const MoodPicker({
    super.key,
    this.selectedMood,
    this.selectedIntensity = 5,
    this.onMoodSelected,
  });

  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker> {
  MoodType? _selectedMood;
  int _selectedIntensity = 5;

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.selectedMood;
    _selectedIntensity = widget.selectedIntensity;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How are you feeling?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.sentiment_satisfied,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mood Types Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
              children: MoodType.values.map((mood) => _MoodButton(
                mood: mood,
                isSelected: _selectedMood == mood,
                onTap: () {
                  setState(() {
                    _selectedMood = mood;
                  });
                  _notifySelection();
                },
              )).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Intensity Slider
            if (_selectedMood != null) ...[
              Text(
                'Intensity: $_selectedIntensity/10',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getMoodColor(_selectedMood!),
                  thumbColor: _getMoodColor(_selectedMood!),
                  overlayColor: _getMoodColor(_selectedMood!).withValues(alpha: 0.2),
                  inactiveTrackColor: AppColors.divider,
                ),
                child: Slider(
                  value: _selectedIntensity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() {
                      _selectedIntensity = value.round();
                    });
                    _notifySelection();
                  },
                ),
              ),
              
              // Intensity Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mild',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Intense',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _notifySelection() {
    if (_selectedMood != null && widget.onMoodSelected != null) {
      widget.onMoodSelected!(_selectedMood!, _selectedIntensity);
    }
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
      case MoodType.excited:
        return AppColors.moodHappy;
      case MoodType.calm:
      case MoodType.neutral:
        return AppColors.moodNeutral;
      case MoodType.sad:
      case MoodType.tired:
        return AppColors.moodSad;
      case MoodType.anxious:
      case MoodType.overwhelmed:
        return AppColors.moodAnxious;
      case MoodType.angry:
      case MoodType.stressed:
        return AppColors.moodAngry;
    }
  }
}

class _MoodButton extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getMoodColor(mood);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getMoodEmoji(mood),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              _getMoodLabel(mood),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
      case MoodType.excited:
        return AppColors.moodHappy;
      case MoodType.calm:
      case MoodType.neutral:
        return AppColors.moodNeutral;
      case MoodType.sad:
      case MoodType.tired:
        return AppColors.moodSad;
      case MoodType.anxious:
      case MoodType.overwhelmed:
        return AppColors.moodAnxious;
      case MoodType.angry:
      case MoodType.stressed:
        return AppColors.moodAngry;
    }
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return '😊';
      case MoodType.excited:
        return '🤩';
      case MoodType.calm:
        return '😌';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😢';
      case MoodType.tired:
        return '😴';
      case MoodType.anxious:
        return '😰';
      case MoodType.overwhelmed:
        return '😵';
      case MoodType.angry:
        return '😠';
      case MoodType.stressed:
        return '😤';
    }
  }

  String _getMoodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.excited:
        return 'Excited';
      case MoodType.calm:
        return 'Calm';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.tired:
        return 'Tired';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.overwhelmed:
        return 'Overwhelmed';
      case MoodType.angry:
        return 'Angry';
      case MoodType.stressed:
        return 'Stressed';
    }
  }
}