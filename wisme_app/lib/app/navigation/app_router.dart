import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../../UI/screens/onboarding_screen.dart';
import '../../UI/screens/home_screen.dart';
import '../../UI/screens/dashboard_screen.dart';
import '../../UI/screens/login_screen.dart';
import '../../UI/screens/profile_screen.dart';
import '../../UI/screens/lesson_screen.dart';
import '../../UI/screens/coach_selection_screen.dart';
import '../../UI/screens/topic_selection_screen.dart';
import '../../UI/screens/settings_screen.dart';

/// App route names
class AppRoutes {
  // Authentication routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  
  // Onboarding routes
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String assessment = '/assessment';
  
  // Main app routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  
  // Learning routes
  static const String learning = '/learning';
  static const String lesson = '/lesson';
  static const String lessonDetail = '/lesson-detail';
  static const String learningPath = '/learning-path';
  static const String practiceMode = '/practice-mode';
  static const String quiz = '/quiz';
  static const String results = '/results';
  
  // Content routes
  static const String content = '/content';
  static const String contentLibrary = '/content-library';
  static const String topicExplorer = '/topic-explorer';
  static const String contentGeneration = '/content-generation';
  
  // Coach routes
  static const String coach = '/coach';
  static const String coachChat = '/coach-chat';
  static const String coachSelection = '/coach-selection';
  static const String coachProfile = '/coach-profile';
  
  // Audio routes
  static const String audioPlayer = '/audio-player';
  static const String audioLibrary = '/audio-library';
  static const String audioGeneration = '/audio-generation';
  
  // Analytics routes
  static const String analytics = '/analytics';
  static const String progress = '/progress';
  static const String achievements = '/achievements';
  static const String insights = '/insights';
  
  // User routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String preferences = '/preferences';
}

/// App router configuration
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Authentication routes
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);
      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);
      case AppRoutes.register:
        return _buildRoute(const RegisterScreen(), settings);
      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case AppRoutes.emailVerification:
        return _buildRoute(const EmailVerificationScreen(), settings);
      
      // Onboarding routes
      case AppRoutes.welcome:
        return _buildRoute(const OnboardingScreen(), settings);
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case AppRoutes.assessment:
        return _buildRoute(const AssessmentScreen(), settings);
      
      // Main app routes
      case AppRoutes.home:
        return _buildRoute(const HomeScreen(), settings);
      case AppRoutes.dashboard:
        return _buildRoute(const DashboardScreen(), settings);
      
      // Learning routes
      case AppRoutes.learning:
        return _buildRoute(const LearningHomeScreen(), settings);
      case AppRoutes.lesson:
        return _buildRoute(const LessonScreen(), settings);
      case AppRoutes.lessonDetail:
        final lessonId = settings.arguments as String?;
        return _buildRoute(LessonDetailScreen(lessonId: lessonId), settings);
      case AppRoutes.learningPath:
        return _buildRoute(const LearningPathScreen(), settings);
      case AppRoutes.practiceMode:
        return _buildRoute(const PracticeModeScreen(), settings);
      case AppRoutes.quiz:
        return _buildRoute(const QuizScreen(), settings);
      case AppRoutes.results:
        return _buildRoute(const ResultsScreen(), settings);
      
      // Content routes
      case AppRoutes.content:
        return _buildRoute(const ContentHomeScreen(), settings);
      case AppRoutes.contentLibrary:
        return _buildRoute(const ContentLibraryScreen(), settings);
      case AppRoutes.topicExplorer:
        return _buildRoute(const TopicExplorerScreen(), settings);
      case AppRoutes.contentGeneration:
        return _buildRoute(const ContentGenerationScreen(), settings);
      
      // Coach routes
      case AppRoutes.coach:
        return _buildRoute(const CoachHomeScreen(), settings);
      case AppRoutes.coachChat:
        final coachId = settings.arguments as String?;
        return _buildRoute(CoachChatScreen(coachId: coachId), settings);
      case AppRoutes.coachSelection:
        return _buildRoute(const CoachSelectionScreen(), settings);
      case AppRoutes.coachProfile:
        final coachId = settings.arguments as String?;
        return _buildRoute(CoachProfileScreen(coachId: coachId), settings);
      
      // Audio routes
      case AppRoutes.audioPlayer:
        final audioFile = settings.arguments;
        return _buildRoute(AudioPlayerScreen(audioFile: audioFile), settings);
      case AppRoutes.audioLibrary:
        return _buildRoute(const AudioLibraryScreen(), settings);
      case AppRoutes.audioGeneration:
        return _buildRoute(const AudioGenerationScreen(), settings);
      
      // Analytics routes
      case AppRoutes.analytics:
        return _buildRoute(const AnalyticsHomeScreen(), settings);
      case AppRoutes.progress:
        return _buildRoute(const ProgressScreen(), settings);
      case AppRoutes.achievements:
        return _buildRoute(const AchievementsScreen(), settings);
      case AppRoutes.insights:
        return _buildRoute(const InsightsScreen(), settings);
      
      // User routes
      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen(), settings);
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);
      case AppRoutes.subscription:
        return _buildRoute(const SubscriptionScreen(), settings);
      case AppRoutes.preferences:
        return _buildRoute(const PreferencesScreen(), settings);
      
      default:
        return _buildRoute(const NotFoundScreen(), settings);
    }
  }

  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

/// Navigation helper methods
class AppNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to a named route
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  static Future<T?> pushReplacementNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed<T?, T>(routeName, arguments: arguments);
  }

  /// Clear stack and navigate to a named route
  static Future<T?> pushNamedAndClearStack<T>(String routeName, {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop<T>([T? result]) {
    navigator!.pop<T>(result);
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  static bool canPop() {
    return navigator!.canPop();
  }
}

/// 404 Not Found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('The requested page could not be found.'),
          ],
        ),
      ),
    );
  }
}
