import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/therapist.dart';

class TherapistCard extends StatelessWidget {
  final Therapist therapist;
  final VoidCallback? onTap;

  const TherapistCard({
    super.key,
    required this.therapist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Therapist info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          therapist.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          therapist.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Rating and experience
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${therapist.rating.toStringAsFixed(1)} (${therapist.reviewCount})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.work_outline,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${therapist.yearsExperience} years',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Session rate
                  if (therapist.sessionRates.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${therapist.sessionRates.values.first.round()}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'per session',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Specializations
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: therapist.specializations.take(3).map((spec) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatSpecialization(spec),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              if (therapist.specializations.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  '+${therapist.specializations.length - 3} more',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Service options
              Row(
                children: [
                  if (therapist.offersOnlineTherapy) ...[
                    Icon(
                      Icons.videocam,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (therapist.offersInPersonTherapy) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'In-person',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (therapist.acceptsInsurance) ...[
                    Icon(
                      Icons.verified_user,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Insurance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSpecialization(TherapistSpecialization spec) {
    switch (spec) {
      case TherapistSpecialization.depression:
        return 'Depression';
      case TherapistSpecialization.anxiety:
        return 'Anxiety';
      case TherapistSpecialization.trauma:
        return 'Trauma';
      case TherapistSpecialization.addiction:
        return 'Addiction';
      case TherapistSpecialization.relationships:
        return 'Relationships';
      case TherapistSpecialization.grief:
        return 'Grief';
      case TherapistSpecialization.eatingDisorders:
        return 'Eating Disorders';
      case TherapistSpecialization.bipolar:
        return 'Bipolar';
      case TherapistSpecialization.adhd:
        return 'ADHD';
      case TherapistSpecialization.general:
        return 'General';
    }
  }
}