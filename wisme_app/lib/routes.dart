import 'package:flutter/material.dart';
import 'UI/screens/home_screen.dart';
import 'UI/screens/topic_screen.dart';
import 'UI/screens/voice_settings_screen.dart';
import 'UI/screens/profile_screen.dart';
import 'UI/screens/showcase_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String topic = '/topic';
  static const String voiceSettings = '/voice-settings';
  static const String profile = '/profile';
  static const String componentShowcase = '/component-showcase';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomeScreen(),
      topic: (context) => const TopicScreen(),
      voiceSettings: (context) => const VoiceSettingsScreen(),
      profile: (context) => const ProfileScreen(),
      componentShowcase: (context) => const ComponentShowcaseScreen(),
    };
  }
}
