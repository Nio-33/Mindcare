import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userProfile;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 30,
                            child: Text(
                              user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'User',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Privacy & Security Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                      title: const Text('Privacy Settings'),
                      subtitle: const Text('Data sharing and privacy controls'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Privacy Settings');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.security_outlined, color: AppColors.primary),
                      title: const Text('Security'),
                      subtitle: const Text('Two-factor authentication and session settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Security Settings');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.lock_outlined, color: AppColors.primary),
                      title: const Text('Data Encryption'),
                      subtitle: const Text('End-to-end encryption settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Data Encryption');
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notifications Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.notifications_outlined, color: AppColors.primary),
                      title: const Text('Notifications'),
                      subtitle: const Text('Manage notification preferences'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Notification Settings');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.crisis_alert_outlined, color: AppColors.error),
                      title: const Text('Crisis Alerts'),
                      subtitle: const Text('Emergency notification settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Crisis Alert Settings');
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // App Preferences Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.palette_outlined, color: AppColors.primary),
                      title: const Text('Theme'),
                      subtitle: const Text('Light, dark, or system'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Theme Settings');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.language_outlined, color: AppColors.primary),
                      title: const Text('Language'),
                      subtitle: const Text('App language preferences'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Language Settings');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.backup_outlined, color: AppColors.primary),
                      title: const Text('Data Backup'),
                      subtitle: const Text('Backup and sync settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Backup Settings');
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Support Section
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.help_outline, color: AppColors.primary),
                      title: const Text('Help & Support'),
                      subtitle: const Text('FAQs and contact support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'Help & Support');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.info_outline, color: AppColors.primary),
                      title: const Text('About'),
                      subtitle: const Text('App version and legal information'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showComingSoon(context, 'About');
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Sign Out Button
              Card(
                color: AppColors.error.withOpacity(0.1),
                child: ListTile(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Sign out of your account'),
                  onTap: () {
                    _showSignOutDialog(context, authProvider);
                  },
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: Text('$feature will be available in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}