import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'providers/auth_provider.dart';
import 'providers/wellness_dashboard_provider.dart';
import 'providers/ai_therapy_provider.dart';
import 'providers/community_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/therapy_journal_provider.dart';
import 'widgets/auth_guard.dart';
import 'widgets/dashboard/wellness_score_card.dart';
import 'widgets/dashboard/mood_trend_chart.dart';
import 'widgets/dashboard/insights_card.dart';
import 'widgets/dashboard/recommendations_card.dart';
import 'widgets/mood_picker.dart';
import 'widgets/chat/ai_chat_interface.dart';
import 'widgets/community/community_interface.dart';
import 'widgets/learning/learning_center_interface.dart';
import 'widgets/journal/gratitude_journal_card.dart';
import 'screens/journal/therapy_journal_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'models/mood_entry.dart';

class MindCareApp extends StatefulWidget {
  const MindCareApp({super.key});

  @override
  State<MindCareApp> createState() => _MindCareAppState();
}

class _MindCareAppState extends State<MindCareApp> {
  int _index = 0;

  final _tabs = const [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Learning'),
    NavigationDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology), label: 'AI Chat'),
    NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Community'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomePage(),
      const _LearningPage(),
      const _AIChatPage(),
      const _CommunityPage(),
      const _ProfilePage(),
    ];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => WellnessDashboardProvider()),
        ChangeNotifierProvider(create: (context) => AITherapyProvider()),
        ChangeNotifierProvider(create: (context) => CommunityProvider()),
        ChangeNotifierProvider(create: (context) => LearningProvider()),
        ChangeNotifierProvider(create: (context) => TherapyJournalProvider()),
      ],
      child: MaterialApp(
        title: 'MindCare',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: AuthGuard(
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(child: pages[_index]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              destinations: _tabs,
              onDestinationSelected: (i) => setState(() => _index = i),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionScaffold({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(title)),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: child)),
      ],
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();
  
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  void _initializeDashboard() {
    final authProvider = context.read<AuthProvider>();
    final wellnessProvider = context.read<WellnessDashboardProvider>();
    
    if (authProvider.isAuthenticated && authProvider.userProfile != null) {
      // Load mock data for testing
      wellnessProvider.loadMockData();
      
      // Refresh dashboard with user data
      wellnessProvider.refreshDashboard(
        authProvider.user!.uid,
        authProvider.userProfile!,
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: 'Wellness Dashboard',
      child: Consumer<WellnessDashboardProvider>(
        builder: (context, wellnessProvider, child) {
          if (wellnessProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick Mood Check
              MoodPicker(
                onMoodSelected: (mood, intensity) {
                  _addMoodEntry(mood, intensity);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Gratitude Journal Card
              const GratitudeJournalCard(),
              
              const SizedBox(height: 16),
              
              // Therapy Journal Card
              Card(
                child: ListTile(
                  leading: Icon(Icons.book_outlined, color: AppColors.primary),
                  title: const Text('Therapy Journal'),
                  subtitle: const Text('Secure, encrypted personal journaling'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TherapyJournalScreen(),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Wellness Score Card
              WellnessScoreCard(
                score: wellnessProvider.currentWellnessScore,
                onTap: () {
                  // Navigate to detailed wellness view
                },
              ),
              
              const SizedBox(height: 16),
              
              // Mood Trend Chart
              MoodTrendChart(
                trendData: wellnessProvider.getMoodTrendData(),
              ),
              
              const SizedBox(height: 16),
              
              // Recommendations
              RecommendationsCard(
                recommendations: wellnessProvider.currentRecommendations,
                onCompleteRecommendation: (id) {
                  wellnessProvider.completeRecommendation(id);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Insights
              InsightsCard(
                insights: wellnessProvider.currentInsights,
                onDismissInsight: (id) {
                  wellnessProvider.dismissInsight(id);
                },
              ),
              
              // Recent Journal Entries Preview
              Consumer<TherapyJournalProvider>(
                builder: (context, journalProvider, child) {
                  if (journalProvider.entries.isNotEmpty) {
                    final recentEntries = journalProvider.entries.take(3).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Recent Journal Entries',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...recentEntries.map((entry) => Card(
                          child: ListTile(
                            title: Text(entry.title),
                            subtitle: Text(
                              entry.content.length > 60 
                                  ? '${entry.content.substring(0, 60)}...' 
                                  : entry.content,
                            ),
                            trailing: Text(
                              _formatDate(entry.timestamp),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const TherapyJournalScreen(),
                                ),
                              );
                            },
                          ),
                        )).toList(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Error handling
              if (wellnessProvider.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          wellnessProvider.errorMessage!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: wellnessProvider.clearError,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _addMoodEntry(MoodType mood, int intensity) {
    final authProvider = context.read<AuthProvider>();
    final wellnessProvider = context.read<WellnessDashboardProvider>();
    
    if (authProvider.isAuthenticated) {
      final entry = MoodEntry(
        userId: authProvider.user!.uid,
        mood: mood,
        intensity: intensity,
        notes: 'Quick mood check',
      );
      
      wellnessProvider.addMoodEntry(entry);
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mood logged: ${mood.toString().split('.').last}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _AIChatPage extends StatelessWidget {
  const _AIChatPage();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: AIChatInterface(),
      ),
    );
  }
}

class _CommunityPage extends StatelessWidget {
  const _CommunityPage();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: CommunityInterface(),
      ),
    );
  }
}

class _LearningPage extends StatelessWidget {
  const _LearningPage();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: LearningCenterInterface(),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) {
    return _SectionScaffold(
      title: 'Profile & Journal',
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userProfile;
          
          return Column(
            children: [
              // User Info Card
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user?.fullName ?? 'User'),
                  subtitle: Text(user?.email ?? ''),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => authProvider.signOut(),
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Journal Card
              Card(
                child: ListTile(
                  leading: Icon(Icons.book_outlined, color: AppColors.primary),
                  title: const Text('Therapy Journal'),
                  subtitle: const Text('Secure, encrypted personal journaling'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TherapyJournalScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              
              // Settings Card
              Card(
                child: ListTile(
                  leading: Icon(Icons.settings_outlined, color: AppColors.primary),
                  title: const Text('Settings'),
                  subtitle: const Text('Privacy, security, and preferences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
