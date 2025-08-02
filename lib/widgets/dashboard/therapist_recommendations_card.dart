import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/therapy_provider.dart';
import '../../providers/wellness_dashboard_provider.dart';
import '../therapy/therapist_card.dart';

class TherapistRecommendationsCard extends StatelessWidget {
  const TherapistRecommendationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TherapyProvider, WellnessDashboardProvider>(
      builder: (context, therapyProvider, wellnessProvider, child) {
        final recommendations = therapyProvider.recommendedTherapists;
        final isAtRisk = wellnessProvider.isAtRisk;
        
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
                      Icons.psychology_outlined,
                      color: isAtRisk ? Colors.orange : AppColors.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAtRisk ? 'Professional Support Recommended' : 'Therapist Recommendations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAtRisk ? Colors.orange : AppColors.secondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _viewAllTherapists(context),
                      child: Text(
                        'View All',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                
                if (isAtRisk) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Based on your recent wellness data, consider speaking with a professional therapist.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                if (recommendations.isEmpty) ...[
                  _buildEmptyState(context, therapyProvider),
                ] else ...[
                  // Show first 2 recommendations
                  ...recommendations.take(2).map((therapist) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildCompactTherapistCard(context, therapist),
                    ),
                  ),
                  
                  if (recommendations.length > 2) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _viewAllTherapists(context),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text('View ${recommendations.length - 2} More'),
                      ),
                    ),
                  ],
                ],
                
                const SizedBox(height: 16),
                _buildCrisisResources(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TherapyProvider therapyProvider) {
    return Column(
      children: [
        Icon(
          Icons.psychology_outlined,
          size: 48,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 16),
        Text(
          'Personalized Recommendations',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Continue tracking your wellness to receive personalized therapist recommendations based on your needs.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Load mock data for demo
            therapyProvider.loadMockData();
          },
          child: const Text('Load Recommendations'),
        ),
      ],
    );
  }

  Widget _buildCompactTherapistCard(BuildContext context, therapist) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Profile placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.person,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          
          // Therapist info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  therapist.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  therapist.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${therapist.rating.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    if (therapist.offersOnlineTherapy) ...[
                      Icon(
                        Icons.videocam,
                        size: 12,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Online',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Action button
          OutlinedButton(
            onPressed: () => _viewTherapistDetails(context, therapist),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'View',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisResources(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emergency,
                color: Colors.red,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Crisis Resources',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'If you\'re in crisis or having thoughts of self-harm:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showCrisisResources(context),
                  icon: Icon(Icons.phone, size: 16, color: Colors.red),
                  label: Text(
                    'Emergency: 911',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showCrisisResources(context),
                  icon: Icon(Icons.message, size: 16, color: Colors.red),
                  label: Text(
                    'Crisis Line: 988',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewAllTherapists(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full therapist directory coming soon'),
      ),
    );
  }

  void _viewTherapistDetails(BuildContext context, therapist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(therapist.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(therapist.title),
            const SizedBox(height: 8),
            Text(
              '${therapist.yearsExperience} years experience',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Specializations: ${therapist.specializations.map((s) => s.toString().split('.').last).join(', ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              therapist.bio,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
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
                  content: Text('Appointment booking coming soon'),
                ),
              );
            },
            child: const Text('Book Appointment'),
          ),
        ],
      ),
    );
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
          '📞 National Suicide Prevention Lifeline: 988\n'
          '📞 SAMHSA National Helpline: 1-800-662-4357\n\n'
          'You are not alone. Help is available 24/7.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement emergency contact functionality
            },
            icon: const Icon(Icons.phone),
            label: const Text('Call 988'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}