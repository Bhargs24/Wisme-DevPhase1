import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/audio_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/user_provider.dart';
import 'providers/voice_provider.dart';
import 'services/auth_services.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/gpt_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        // Services
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
            storageService: context.read<StorageService>(),
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
}
