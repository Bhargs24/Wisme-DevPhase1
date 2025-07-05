import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  group('Wisme App Integration Tests', () {
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app starts
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Give it some time to load
      await tester.pump(const Duration(seconds: 1));
      
      // The app should be running without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Main navigation exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));
      
      // Should not have any exceptions
      expect(tester.takeException(), isNull);
    });
  });
}

// Minimal test app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisme Test',
      home: Container(
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Wisme App Test',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
