import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Will be enabled when Firebase is configured
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'services/app_initialization_service.dart';
import 'providers/audio_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/user_provider.dart';
import 'providers/voice_provider.dart';
import 'providers/coach_provider.dart';
import 'providers/settings_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/gpt_service.dart';
import 'services/tts_service.dart';
import 'services/content_matching_service.dart';
import 'services/cache_service.dart';

final logger = Logger();

void main() async {
  // Use comprehensive production-ready initialization
  await AppInitializationService.initialize();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Log configuration status for deployment verification
  logger.i('� App Configuration Status:');
  logger.i('  - OpenAI configured: ${AppConfig.openAIApiKey.isNotEmpty}');
  logger.i('  - ElevenLabs configured: ${AppConfig.elevenLabsApiKey.isNotEmpty}');
  logger.i('  - Environment: ${EnvironmentConfig.environment}');
  logger.i('  - Production ready: ${AppConfig.isConfiguredForProduction}');
  
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
        // Core infrastructure services  
        Provider<SharedPreferences>.value(value: prefs),
        Provider<CacheService>(create: (_) => CacheService()),
        
        // Core business services
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<GPTService>(create: (_) => GPTService()),
        Provider<TTSService>(create: (_) => TTSService()),
        
        // Content matching service
        Provider<ContentMatchingService>(
          create: (context) => ContentMatchingService(
            firestoreService: context.read<FirestoreService>(),
            gptService: context.read<GPTService>(),
          ),
        ),
        
        // Settings provider
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefs: prefs),
        ),
        
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
            cacheService: context.read<CacheService>(),
          ),
        ),
        ChangeNotifierProvider<LessonProvider>(
          create: (context) => LessonProvider(
            firestoreService: context.read<FirestoreService>(),
            gptService: context.read<GPTService>(),
            ttsService: context.read<TTSService>(),
            contentMatchingService: context.read<ContentMatchingService>(),
            cacheService: context.read<CacheService>(),
          ),
        ),
        ChangeNotifierProvider<AudioProvider>(
          create: (context) => AudioProvider(
            firestoreService: context.read<FirestoreService>(),
            cacheService: context.read<CacheService>(),
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
