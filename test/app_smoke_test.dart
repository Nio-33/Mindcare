import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindcare/main.dart' as app;

void main() {
  testWidgets('App boots and shows 5 tabs', (tester) async {
    app.main();
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('AI Chat'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
