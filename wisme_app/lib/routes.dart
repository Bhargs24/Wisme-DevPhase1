import 'package:flutter/material.dart';
import 'UI/screens/login_screen.dart';
import 'UI/screens/onboarding_screen.dart';
import 'UI/screens/topic_selection_screen.dart';
import 'UI/screens/topic_screen.dart';
import 'UI/screens/voice_settings_screen.dart';
import 'UI/screens/profile_screen.dart';
import 'UI/screens/lesson_screen.dart';
import 'UI/screens/component_showcase_screen.dart';
import 'UI/screens/showcase_screen.dart';
import 'UI/screens/topic_analysis_screen.dart';
import 'UI/screens/knowledge_level_screen.dart';
import 'UI/screens/coach_selection_screen.dart';
import 'UI/screens/coach_naming_screen.dart';
import 'UI/screens/journey_planning_screen.dart';
import 'UI/screens/enhanced_audio_player_screen.dart';
import 'UI/screens/social_leaderboard_screen.dart';
import 'UI/screens/achievements_gallery_screen.dart';
import 'UI/screens/advanced_settings_screen.dart';
import 'UI/screens/search_screen.dart';
import 'UI/screens/settings_screen.dart';
import 'UI/screens/dashboard_screen.dart';
import 'UI/screens/learning_stats_screen.dart';
import 'UI/screens/content_library_screen.dart';
import 'UI/screens/offline_learning_screen.dart';
import 'UI/screens/learning_data_screen.dart';
import 'UI/screens/downloads_screen.dart';
import 'UI/screens/favorites_screen.dart';
import 'UI/screens/learning_history_screen.dart';
import 'UI/screens/help_support_screen.dart';
import 'UI/screens/privacy_policy_screen.dart';
import 'UI/screens/terms_of_service_screen.dart';
import 'UI/widgets/auth_wrapper.dart';
import 'models/lesson_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String topicSelection = '/topic-selection';
  static const String topicAnalysis = '/topic-analysis';
  static const String knowledgeLevel = '/knowledge-level';
  static const String coachSelection = '/coach-selection';
  static const String coachNaming = '/coach-naming';
  static const String avatarGallery = '/avatar-gallery';
  static const String journeyPlanning = '/journey-planning';
  static const String audioPlayer = '/audio-player';
  static const String topic = '/topic';
  static const String lesson = '/lesson';
  static const String voiceSettings = '/voice-settings';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String componentShowcase = '/component-showcase';
  static const String featureShowcase = '/feature-showcase';
  // New premium screens
  static const String dashboard = '/dashboard';
  static const String learningStats = '/learning-stats';
  static const String learningData = '/learning-data';
  static const String downloads = '/downloads';
  static const String favorites = '/favorites';
  static const String learningHistory = '/learning-history';
  static const String helpSupport = '/help-support';
  static const String contentLibrary = '/content-library';
  static const String offlineLearning = '/offline-learning';
  static const String socialLeaderboard = '/social-leaderboard';
  static const String achievementsGallery = '/achievements-gallery';
  static const String advancedSettings = '/advanced-settings';
  static const String enhancedAudioPlayer = '/enhanced-audio-player';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const AuthWrapper(),
      login: (context) => const LoginScreen(),
      onboarding: (context) => const OnboardingScreen(),
      topic: (context) => const TopicScreen(),
      voiceSettings: (context) => const VoiceSettingsScreen(),
      profile: (context) => const ProfileScreen(),
      componentShowcase: (context) => const ComponentShowcaseScreen(),
      featureShowcase: (context) => const ShowcaseScreen(),
      search: (context) => const SearchScreen(),
      settings: (context) => const SettingsScreen(),
      // New premium screens
      dashboard: (context) => const DashboardScreen(),
      learningStats: (context) => const LearningStatsScreen(),
      learningData: (context) => const LearningDataScreen(),
      downloads: (context) => const DownloadsScreen(),
      favorites: (context) => const FavoritesScreen(),
      learningHistory: (context) => const LearningHistoryScreen(),
      helpSupport: (context) => const HelpSupportScreen(),
      contentLibrary: (context) => const ContentLibraryScreen(),
      offlineLearning: (context) => const OfflineLearningScreen(),
      socialLeaderboard: (context) => const SocialLeaderboardScreen(),
      achievementsGallery: (context) => const AchievementsGalleryScreen(),
      advancedSettings: (context) => const AdvancedSettingsScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),
      termsOfService: (context) => const TermsOfServiceScreen(),
    };
  }

  // Route generator for dynamic routes with parameters
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case topicSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        final query = args?['query'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => TopicSelectionScreen(searchQuery: query),
        );
      case topicAnalysis:
        final args = settings.arguments as Map<String, dynamic>?;
        final searchQuery = args?['searchQuery'] as String? ?? args?['topic'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => TopicAnalysisScreen(searchQuery: searchQuery),
        );
      case knowledgeLevel:
        final args = settings.arguments as Map<String, dynamic>?;
        final topic = args?['topic'] as String? ?? '';
        final category = args?['category'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => KnowledgeLevelScreen(topic: topic, category: category),
        );
      case coachSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        final topic = args?['topic'] as String? ?? '';
        final category = args?['category'] as String? ?? '';
        final knowledgeLevel = args?['knowledgeLevel'] as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => CoachSelectionScreen(
            topic: topic,
            category: category,
            knowledgeLevel: knowledgeLevel,
          ),
        );
      case coachNaming:
        final args = settings.arguments as Map<String, dynamic>?;
        final topic = args?['topic'] as String? ?? '';
        final category = args?['category'] as String? ?? '';
        final knowledgeLevel = args?['knowledgeLevel'] as String? ?? '';
        final coachId = args?['coachId'] as String? ?? '';
        final coachData = args?['coachData'] as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => CoachNamingScreen(
            topic: topic,
            category: category,
            knowledgeLevel: knowledgeLevel,
            coachId: coachId,
            coachData: coachData,
          ),
        );
      case journeyPlanning:
        final args = settings.arguments as Map<String, dynamic>?;
        final topic = args?['topic'] as String? ?? '';
        final category = args?['category'] as String? ?? '';
        final knowledgeLevel = args?['knowledgeLevel'] as String? ?? '';
        final coachData = args?['coachData'] as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => JourneyPlanningScreen(
            topic: topic,
            category: category,
            knowledgeLevel: knowledgeLevel,
            coachData: coachData,
          ),
        );
      case audioPlayer:
        final args = settings.arguments as Map<String, dynamic>?;
        final lessonId = args?['lessonId'] as String? ?? '';
        final lessonData = args?['lessonData'] as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => EnhancedAudioPlayerScreen(
            lessonId: lessonId,
            lessonData: lessonData,
          ),
        );
      case enhancedAudioPlayer:
        final args = settings.arguments as Map<String, dynamic>?;
        final lessonId = args?['lessonId'] as String? ?? '';
        final lessonData = args?['lessonData'] as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => EnhancedAudioPlayerScreen(
            lessonId: lessonId,
            lessonData: lessonData,
          ),
        );
      case socialLeaderboard:
        return MaterialPageRoute(
          builder: (context) => const SocialLeaderboardScreen(),
        );
      case achievementsGallery:
        return MaterialPageRoute(
          builder: (context) => const AchievementsGalleryScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        );
      case 'advanced-settings':
        return MaterialPageRoute(
          builder: (context) => const AdvancedSettingsScreen(),
        );
      case lesson:
        final args = settings.arguments as Map<String, dynamic>?;
        final lessonData = args?['lesson'] as ContentBlock?;
        final lessonId = args?['lessonId'] as String? ?? '';
        
        if (lessonData != null) {
          return MaterialPageRoute(
            builder: (context) => LessonScreen(lesson: lessonData),
          );
        } else {
          // Create a fallback lesson if only ID is provided
          final fallbackLesson = ContentBlock(
            id: lessonId,
            category: 'General',
            topic: 'Learning',
            contentType: 'lesson',
            difficulty: 'beginner',
            title: 'Lesson',
            script: 'Loading lesson...',
            duration: const Duration(minutes: 10),
            createdAt: DateTime.now(),
          );
          return MaterialPageRoute(
            builder: (context) => LessonScreen(lesson: fallbackLesson),
          );
        }
      default:
        return null;
    }
  }
}
