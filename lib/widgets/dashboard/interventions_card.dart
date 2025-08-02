import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/wellness_dashboard_provider.dart';

class InterventionsCard extends StatelessWidget {
  const InterventionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WellnessDashboardProvider>(
      builder: (context, provider, child) {
        final interventions = provider.interventionRecommendations;
        
        if (interventions == null || interventions.isEmpty) {
          return _buildNoInterventionsCard(context);
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ...interventions.map((intervention) => _buildInterventionItem(context, intervention)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoInterventionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'re doing great!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No immediate interventions needed. Keep up your current wellness practices.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionItem(BuildContext context, Map<String, dynamic> intervention) {
    final type = intervention['type'] as String;
    final title = intervention['title'] as String;
    final description = intervention['description'] as String;
    final priority = intervention['priority'] as String;
    final action = intervention['action'] as String;
    
    final priorityColor = _getPriorityColor(priority);
    final actionIcon = _getActionIcon(action);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.left(
          color: priorityColor,
          width: 4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              actionIcon,
              color: priorityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      type == 'immediate' ? Icons.emergency : Icons.schedule,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type == 'immediate' ? 'Take action now' : 'Preventive measure',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _takeAction(context, action, title),
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: priorityColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'therapy':
        return Icons.psychology;
      case 'exercise':
        return Icons.fitness_center;
      case 'breathing':
        return Icons.air;
      case 'journaling':
        return Icons.edit_note;
      case 'crisis':
        return Icons.emergency;
      default:
        return Icons.lightbulb_outline;
    }
  }

  void _takeAction(BuildContext context, String action, String title) {
    switch (action) {
      case 'therapy':
        _showTherapyOptions(context);
        break;
      case 'exercise':
        _showExerciseOptions(context);
        break;
      case 'breathing':
        _showBreathingExercise(context);
        break;
      case 'journaling':
        _openJournal(context);
        break;
      case 'crisis':
        _showCrisisResources(context);
        break;
      default:
        _showGeneralAction(context, title);
    }
  }

  void _showTherapyOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Professional Support'),
        content: const Text(
          'Consider reaching out to a mental health professional. Would you like to:\n\n'
          '• Find a therapist near you\n'
          '• Access crisis resources\n'
          '• Schedule a consultation',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Professional therapy integration coming soon'),
                ),
              );
            },
            child: const Text('Find Help'),
          ),
        ],
      ),
    );
  }

  void _showExerciseOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mood-Boosting Activities'),
        content: const Text(
          'Physical activity can significantly improve your mood. Try:\n\n'
          '• 10-minute walk outside\n'
          '• Simple stretching routine\n'
          '• Dancing to your favorite music\n'
          '• Yoga or meditation',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Great choice! Remember to track how you feel afterward.'),
                ),
              );
            },
            child: const Text('Let\'s Go!'),
          ),
        ],
      ),
    );
  }

  void _showBreathingExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('4-7-8 Breathing Exercise'),
        content: const Text(
          'This technique can help reduce anxiety:\n\n'
          '1. Inhale through your nose for 4 counts\n'
          '2. Hold your breath for 7 counts\n'
          '3. Exhale through your mouth for 8 counts\n'
          '4. Repeat 3-4 times\n\n'
          'Find a comfortable position and breathe slowly and deeply.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Breathing exercises are most effective when practiced regularly.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Start Exercise'),
          ),
        ],
      ),
    );
  }

  void _openJournal(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening journal... Express your thoughts and feelings.'),
      ),
    );
    // TODO: Navigate to journal screen
  }

  void _showCrisisResources(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Crisis Resources'),
          ],
        ),
        content: const Text(
          'If you\'re in immediate danger or having thoughts of self-harm:\n\n'
          '🆘 Emergency: 911\n'
          '📞 Crisis Text Line: Text HOME to 741741\n'
          '📞 National Suicide Prevention Lifeline: 988\n\n'
          'You are not alone. Help is available 24/7.',
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement emergency contact functionality
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showGeneralAction(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Taking action on: $title'),
      ),
    );
  }
}