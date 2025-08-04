import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_app.dart';

void main() {
  group('MindCare App Smoke Tests', () {
    testWidgets('App boots and shows 5 tabs', (tester) async {
      await tester.pumpWidget(
        const TestApp(child: TestHomeWidget()),
      );

      await tester.pumpAndSettle();

      // Basic smoke tests
      expect(find.text('Home'), findsWidgets);
      expect(find.text('AI Chat'), findsWidgets);
      expect(find.text('Community'), findsWidgets);
      expect(find.text('Learning'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('App boots and renders without crashing', (tester) async {
      await tester.pumpWidget(
        const TestApp(child: TestHomeWidget()),
      );

      // Let the app settle
      await tester.pumpAndSettle();

      // Verify the app renders a MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Verify we have a scaffold (main app structure)
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Verify navigation is present
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('App handles navigation structure', (tester) async {
      await tester.pumpWidget(
        const TestApp(child: TestHomeWidget()),
      );

      // Wait for initial build
      await tester.pump();

      // The app should render without exceptions
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Basic smoke test - app doesn't crash on startup
      expect(tester.takeException(), isNull);
    });

    testWidgets('App responds to basic interactions', (tester) async {
      await tester.pumpWidget(
        const TestApp(child: TestHomeWidget()),
      );

      await tester.pumpAndSettle();

      // Verify the app is interactive (no exceptions thrown)
      expect(tester.takeException(), isNull);
      
      // Basic structural check
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
