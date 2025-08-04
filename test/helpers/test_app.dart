import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindcare/providers/auth_provider.dart';
import 'package:mindcare/providers/learning_provider.dart';
import 'package:mindcare/providers/wellness_dashboard_provider.dart';
import 'package:mindcare/providers/therapy_journal_provider.dart';
import 'package:mindcare/providers/ai_therapy_provider.dart';
import 'package:mindcare/providers/community_provider.dart';
import 'package:mindcare/providers/therapy_provider.dart';

/// A test wrapper app that provides all necessary providers without Firebase dependencies
class TestApp extends StatelessWidget {
  final Widget child;

  const TestApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => WellnessDashboardProvider()),
        ChangeNotifierProvider(create: (_) => TherapyJournalProvider()),
        ChangeNotifierProvider(create: (_) => AITherapyProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => TherapyProvider()),
      ],
      child: MaterialApp(
        title: 'MindCare Test',
        home: child,
      ),
    );
  }
}

/// Simple test home widget for basic UI testing
class TestHomeWidget extends StatelessWidget {
  const TestHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MindCare Test')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home'),
            Text('AI Chat'),
            Text('Community'),
            Text('Learning'),
            Text('Profile'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'AI Chat'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Learning'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}