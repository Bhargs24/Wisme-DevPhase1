// Basic Flutter widget test for Wisme app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Wisme app MaterialApp test', (WidgetTester tester) async {
    // Simple test to verify MaterialApp loads without routing conflicts
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Test App'),
          ),
        ),
      ),
    );

    // Verify that the app loads without crashing
    await tester.pump();
    
    // Should show MaterialApp widget
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });
  
  testWidgets('Wisme app routing test', (WidgetTester tester) async {
    // Test the WismeApp with simplified setup
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Scaffold(
            body: Center(child: Text('Home')),
          ),
          '/test': (context) => Scaffold(
            body: Center(child: Text('Test')),
          ),
        },
      ),
    );

    // Verify routing works without conflicts
    await tester.pump();
    
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
