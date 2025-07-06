import 'package:flutter/material.dart';
import 'UI/screens/home_screen.dart';
import 'UI/screens/profile_screen.dart';
import 'UI/screens/onboarding_screen.dart';
import 'UI/screens/lesson_screen.dart';
import 'UI/screens/topic_selection_screen.dart';
import 'UI/screens/coach_selection_screen.dart';
import 'UI/screens/settings_screen.dart';
import 'UI/screens/search_screen.dart';
import 'UI/screens/dashboard_screen.dart';
import 'UI/screens/learning_stats_screen.dart';
import 'UI/screens/learning_data_screen.dart';
import 'UI/screens/downloads_screen.dart';
import 'UI/screens/favorites_screen.dart';
import 'UI/screens/learning_history_screen.dart';
import 'UI/screens/help_support_screen.dart';
import 'UI/screens/content_library_screen.dart';
import 'UI/screens/social_leaderboard_screen.dart';
import 'UI/screens/achievements_gallery_screen.dart';
import 'UI/screens/advanced_settings_screen.dart';
import 'UI/screens/voice_settings_screen.dart';
import 'UI/screens/topic_analysis_screen.dart';
import 'UI/screens/coach_naming_screen.dart';
import 'UI/screens/analytics_screen.dart';
import 'UI/screens/enhanced_audio_player_screen.dart';
import 'UI/screens/topic_screen.dart';
import 'UI/screens/terms_of_service_screen.dart';
import 'UI/screens/splash_screen.dart';
import 'UI/screens/privacy_policy_screen.dart';
import 'UI/screens/component_showcase_screen.dart';
import 'UI/screens/login_screen.dart';
import 'UI/screens/knowledge_level_screen.dart';
import 'models/content_block.dart';

class AppRoutes {
  // Route names
  static const String home = '/home';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String lesson = '/lesson';
  static const String topicSelection = '/topic-selection';
  static const String coachSelection = '/coach-selection';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String dashboard = '/dashboard';
  static const String learningStats = '/learning-stats';
  static const String learningData = '/learning-data';
  static const String downloads = '/downloads';
  static const String favorites = '/favorites';
  static const String learningHistory = '/learning-history';
  static const String helpSupport = '/help-support';
  static const String contentLibrary = '/content-library';
  static const String socialLeaderboard = '/social-leaderboard';
  static const String achievementsGallery = '/achievements-gallery';
  static const String advancedSettings = '/advanced-settings';
  static const String voiceSettings = '/voice-settings';
  static const String topicAnalysis = '/topic-analysis';
  static const String coachNaming = '/coach-naming';
  static const String analytics = '/analytics';
  static const String enhancedAudioPlayer = '/enhanced-audio-player';
  static const String topic = '/topic';
  static const String termsOfService = '/terms-of-service';
  static const String splash = '/splash';
  static const String privacyPolicy = '/privacy-policy';
  static const String componentShowcase = '/component-showcase';
  static const String login = '/login';
  static const String knowledgeLevel = '/knowledge-level';
  
  // Route mappings (basic implementation)
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    onboarding: (context) => const OnboardingScreen(),
    settings: (context) => const SettingsScreen(),
    search: (context) => const SearchScreen(),
    dashboard: (context) => const DashboardScreen(),
    learningStats: (context) => const LearningStatsScreen(),
    learningData: (context) => const LearningDataScreen(),
    downloads: (context) => const DownloadsScreen(),
    favorites: (context) => const FavoritesScreen(),
    learningHistory: (context) => const LearningHistoryScreen(),
    helpSupport: (context) => const HelpSupportScreen(),
    contentLibrary: (context) => const ContentLibraryScreen(),
    socialLeaderboard: (context) => const SocialLeaderboardScreen(),
    achievementsGallery: (context) => const AchievementsGalleryScreen(),
    advancedSettings: (context) => const AdvancedSettingsScreen(),
    voiceSettings: (context) => const VoiceSettingsScreen(),
    analytics: (context) => const AnalyticsScreen(),
    componentShowcase: (context) => const ComponentShowcaseScreen(),
    privacyPolicy: (context) => const PrivacyPolicyScreen(),
    termsOfService: (context) => const TermsOfServiceScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
  };
  
  // Generate route method
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    
    // Handle parameterized routes
    switch (settings.name) {
      case lesson:
        final lesson = settings.arguments as ContentBlock?;
        return MaterialPageRoute(
          builder: (context) => LessonScreen(lesson: lesson!),
          settings: settings,
        );
      case topicSelection:
        final searchQuery = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => TopicSelectionScreen(searchQuery: searchQuery),
          settings: settings,
        );
      case coachSelection:
        final args = settings.arguments as Map<String, String>? ?? {};
        return MaterialPageRoute(
          builder: (context) => CoachSelectionScreen(
            topic: args['topic'] ?? '',
            category: args['category'] ?? '',
            knowledgeLevel: args['knowledgeLevel'] ?? '',
          ),
          settings: settings,
        );
      case topicAnalysis:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => TopicAnalysisScreen(
            searchQuery: args['searchQuery'] ?? '',
          ),
          settings: settings,
        );
      case coachNaming:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => CoachNamingScreen(
            topic: args['topic'] ?? '',
            category: args['category'] ?? '',
            knowledgeLevel: args['knowledgeLevel'] ?? '',
            coachId: args['coachId'] ?? '',
            coachData: args['coachData'] ?? {},
          ),
          settings: settings,
        );
      case enhancedAudioPlayer:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => EnhancedAudioPlayerScreen(
            lessonId: args['lessonId'] ?? '',
            lessonData: args['lessonData'],
          ),
          settings: settings,
        );
      case topic:
        return MaterialPageRoute(
          builder: (context) => const TopicScreen(),
          settings: settings,
        );
      case knowledgeLevel:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => KnowledgeLevelScreen(
            topic: args['topic'] ?? '',
            category: args['category'] ?? '',
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
