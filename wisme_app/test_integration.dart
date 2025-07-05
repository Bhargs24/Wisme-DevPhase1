import 'package:flutter/material.dart';
import 'lib/providers/user_provider.dart';
import 'lib/providers/lesson_provider.dart';
import 'lib/providers/coach_provider.dart';
import 'lib/providers/settings_provider.dart';
import 'lib/services/auth_services.dart';
import 'lib/services/firestore_service.dart';
import 'lib/services/gpt_service.dart';
import 'lib/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration test to verify all major components can be instantiated
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Initialize services
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final gptService = GPTService();
    final ttsService = TTSService();
    
    // Initialize providers
    final userProvider = UserProvider(
      authService: authService,
      prefs: prefs,
    );
    final lessonProvider = LessonProvider(
      firestoreService: firestoreService,
      gptService: gptService,
      ttsService: ttsService,
    );
    final coachProvider = CoachProvider();
    final settingsProvider = SettingsProvider(prefs: prefs);
    
    // Test app creation (comment out to avoid actually running)
    // final app = MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider<UserProvider>.value(value: userProvider),
    //     ChangeNotifierProvider<LessonProvider>.value(value: lessonProvider),
    //     ChangeNotifierProvider<CoachProvider>.value(value: coachProvider),
    //     ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
    //   ],
    //   child: const WismeApp(),
    // );
    
    print('✅ All providers and services initialized successfully');
    print('✅ AuthService: ${authService.runtimeType}');
    print('✅ UserProvider: ${userProvider.runtimeType}');
    print('✅ LessonProvider: ${lessonProvider.runtimeType}');
    print('✅ CoachProvider: ${coachProvider.runtimeType}');
    print('✅ SettingsProvider: ${settingsProvider.runtimeType}');
    print('✅ Integration test passed');
    
  } catch (e) {
    print('❌ Integration test failed: $e');
  }
}
