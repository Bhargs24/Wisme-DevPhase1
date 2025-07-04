import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Will be enabled when Firebase is configured
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'providers/audio_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/user_provider.dart';
import 'providers/voice_provider.dart';
import 'providers/coach_provider.dart';
import 'services/auth_services.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/gpt_service.dart';
import 'services/tts_service.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Skip Firebase initialization for now - will be enabled later
  try {
    // Only try to initialize Firebase if configuration exists
    // This will be uncommented when you set up Firebase
    // await Firebase.initializeApp();
    logger.w('Firebase not configured - running in offline mode');
    logger.i('Note: Authentication and cloud features will show errors but app will still work');
  } catch (e) {
    logger.e('Firebase initialization failed: $e');
    logger.i('Note: Some features requiring Firebase will be disabled');
  }

  runApp(
    MultiProvider(
      providers: [
        // Services - original code, will handle Firebase gracefully
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<GPTService>(create: (_) => GPTService()),
        Provider<TTSService>(create: (_) => TTSService()),
        Provider<SharedPreferences>.value(value: prefs),
        
        // State providers
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
            firestoreService: context.read<FirestoreService>(),
            gptService: context.read<GPTService>(),
            ttsService: context.read<TTSService>(),
          ),
        ),
        ChangeNotifierProvider<AudioProvider>(
          create: (context) => AudioProvider(
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
        ChangeNotifierProvider<CoachProvider>(
          create: (context) => CoachProvider(),
        ),
      ],
      child: const WismeApp(),
    ),
  );
}
