import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/community_models.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';

class SupportGroupCard extends StatelessWidget {
  final SupportGroup group;
  final VoidCallback onTap;
  final Function(String) onJoin;
  final Function(String) onLeave;

  const SupportGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommunityProvider, AuthProvider>(
      builder: (context, communityProvider, authProvider, child) {
        final isUserMember = authProvider.isAuthenticated && 
            communityProvider.isUserMember(group.id, authProvider.user!.uid);
        
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Group type icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getGroupTypeColor(group.type).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getGroupTypeIcon(group.type),
                      color: _getGroupTypeColor(group.type),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Group info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Privacy indicator
                            if (group.isPrivate)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_outline,
                                      size: 12,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Private',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.warning,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          group.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Stats row
                        Row(
                          children: [
                            // Group type badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getGroupTypeColor(group.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                communityProvider.getGroupTypeDisplayName(group.type),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getGroupTypeColor(group.type),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Member count
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${group.memberCount}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Post count
                            Icon(
                              Icons.forum_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${group.postCount}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Join/Leave button
                            if (authProvider.isAuthenticated) ...[
                              if (isUserMember) ...[
                                OutlinedButton(
                                  onPressed: () => onLeave(group.id),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                                    minimumSize: const Size(60, 28),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  child: const Text(
                                    'Leave',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  onPressed: () => onJoin(group.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(60, 28),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  child: const Text(
                                    'Join',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getGroupTypeColor(SupportGroupType type) {
    switch (type) {
      case SupportGroupType.anxiety:
        return AppColors.accentOrange;
      case SupportGroupType.depression:
        return AppColors.info;
      case SupportGroupType.addiction:
        return AppColors.accentPurple;
      case SupportGroupType.grief:
        return AppColors.textSecondary;
      case SupportGroupType.ptsd:
        return AppColors.error;
      case SupportGroupType.bipolar:
        return AppColors.warning;
      case SupportGroupType.eating:
        return AppColors.accentYellow;
      case SupportGroupType.general:
        return AppColors.primary;
    }
  }

  IconData _getGroupTypeIcon(SupportGroupType type) {
    switch (type) {
      case SupportGroupType.anxiety:
        return Icons.psychology_outlined;
      case SupportGroupType.depression:
        return Icons.healing_outlined;
      case SupportGroupType.addiction:
        return Icons.local_hospital_outlined;
      case SupportGroupType.grief:
        return Icons.favorite_border;
      case SupportGroupType.ptsd:
        return Icons.shield_outlined;
      case SupportGroupType.bipolar:
        return Icons.balance_outlined;
      case SupportGroupType.eating:
        return Icons.restaurant_outlined;
      case SupportGroupType.general:
        return Icons.people_outline;
    }
  }
}