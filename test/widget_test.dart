import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';

void main() {
  group('MindCare App Widget Tests', () {
    testWidgets('App renders Material 3 shell with navigation', (WidgetTester tester) async {
      // Test the basic navigation structure
      await tester.pumpWidget(
        const TestApp(child: TestHomeWidget()),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the app boots without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Check if we can find navigation-related widgets
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Navigation bar shows all 5 tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestApp(child: TestHomeWidget()),
      );

      await tester.pumpAndSettle();

      // Check for all navigation labels
      expect(find.text('Home'), findsWidgets);
      expect(find.text('AI Chat'), findsWidgets);
      expect(find.text('Community'), findsWidgets);
      expect(find.text('Learning'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('App structure is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestApp(child: TestHomeWidget()),
      );

      await tester.pumpAndSettle();

      // Basic structural checks
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      
      // No exceptions should be thrown
      expect(tester.takeException(), isNull);
    });
  });
}
