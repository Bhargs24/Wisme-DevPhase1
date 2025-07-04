import 'package:flutter/material.dart';
import 'UI/screens/app_launcher_screen.dart';
import 'UI/screens/onboarding_screen.dart';
import 'UI/screens/welcome_back_screen.dart';
import 'UI/screens/home_screen.dart';
import 'UI/screens/login_screen.dart';
import 'UI/screens/topic_screen.dart';
import 'UI/screens/voice_settings_screen.dart';
import 'UI/screens/profile_screen.dart';
import 'UI/screens/showcase_screen.dart';

class AppRoutes {
  static const String launcher = '/';
  static const String onboarding = '/onboarding';
  static const String welcomeBack = '/welcome-back';
  static const String home = '/home';
  static const String login = '/login';
  static const String topic = '/topic';
  static const String voiceSettings = '/voice-settings';
  static const String profile = '/profile';
  static const String componentShowcase = '/component-showcase';

  static Map<String, WidgetBuilder> get routes {
    return {
      launcher: (context) => const AppLauncherScreen(),
      onboarding: (context) => const OnboardingScreen(),
      welcomeBack: (context) => const WelcomeBackScreen(),
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      topic: (context) => const TopicScreen(),
      voiceSettings: (context) => const VoiceSettingsScreen(),
      profile: (context) => const ProfileScreen(),
      componentShowcase: (context) => const ComponentShowcaseScreen(),
    };
  }
}
