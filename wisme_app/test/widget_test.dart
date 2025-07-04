// Basic Flutter widget test for Wisme app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wisme_app/app.dart';
import 'package:wisme_app/providers/user_provider.dart';
import 'package:wisme_app/providers/voice_provider.dart';
import 'package:wisme_app/providers/lesson_provider.dart';
import 'package:wisme_app/providers/audio_provider.dart';
import 'package:wisme_app/services/auth_services.dart';
import 'package:wisme_app/services/firestore_service.dart';
import 'package:wisme_app/services/storage_service.dart';
import 'package:wisme_app/services/gpt_service.dart';
import 'package:wisme_app/services/tts_service.dart';

void main() {
  testWidgets('Wisme app smoke test', (WidgetTester tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>(create: (_) => StorageService()),
          Provider<FirestoreService>(create: (_) => FirestoreService()),
          Provider<AuthService>(create: (_) => AuthService()),
          Provider<GPTService>(create: (_) => GPTService()),
          Provider<TTSService>(create: (_) => TTSService()),
          Provider<SharedPreferences>.value(value: prefs),
          ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider(
              authService: context.read<AuthService>(),
              prefs: prefs,
            ),
          ),
          ChangeNotifierProvider<VoiceProvider>(
            create: (context) => VoiceProvider(
              ttsService: context.read<TTSService>(),
              prefs: prefs,
            ),
          ),
          ChangeNotifierProvider<LessonProvider>(
            create: (context) => LessonProvider(
              storageService: context.read<StorageService>(),
              firestoreService: context.read<FirestoreService>(),
              gptService: context.read<GPTService>(),
            ),
          ),
          ChangeNotifierProvider<AudioProvider>(
            create: (context) => AudioProvider(),
          ),
        ],
        child: const WismeApp(),
      ),
    );

    // Verify that the app loads without crashing
    await tester.pump();
    
    // Should show either login or home screen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
