import 'package:flutter/material.dart';

/// App routes enumeration
enum AppRoute {
  splash,
  onboarding,
  login,
  register,
  forgotPassword,
  
  // Main app routes
  home,
  dashboard,
  profile,
  settings,
  
  // Learning routes
  lessons,
  lessonDetail,
  learningSession,
  learningProgress,
  learningPath,
  
  // Coach routes
  coach,
  coachChat,
  coachHistory,
  
  // Audio routes
  audioLibrary,
  audioPlayer,
  audioGenerator,
  
  // Content routes
  curriculum,
  contentItem,
  
  // Analytics routes
  analytics,
  insights,
  
  // Subscription routes
  subscription,
  billing,
  
  // Error routes
  notFound,
  error,
}

/// Extension to get route paths and names
extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.splash:
        return '/';
      case AppRoute.onboarding:
        return '/onboarding';
      case AppRoute.login:
        return '/login';
      case AppRoute.register:
        return '/register';
      case AppRoute.forgotPassword:
        return '/forgot-password';
      case AppRoute.home:
        return '/home';
      case AppRoute.dashboard:
        return '/dashboard';
      case AppRoute.profile:
        return '/profile';
      case AppRoute.settings:
        return '/settings';
      case AppRoute.lessons:
        return '/lessons';
      case AppRoute.lessonDetail:
        return '/lessons/detail';
      case AppRoute.learningSession:
        return '/learning-session';
      case AppRoute.learningProgress:
        return '/learning-progress';
      case AppRoute.learningPath:
        return '/learning-path';
      case AppRoute.coach:
        return '/coach';
      case AppRoute.coachChat:
        return '/coach/chat';
      case AppRoute.coachHistory:
        return '/coach/history';
      case AppRoute.audioLibrary:
        return '/audio';
      case AppRoute.audioPlayer:
        return '/audio/player';
      case AppRoute.audioGenerator:
        return '/audio/generator';
      case AppRoute.curriculum:
        return '/curriculum';
      case AppRoute.contentItem:
        return '/content';
      case AppRoute.analytics:
        return '/analytics';
      case AppRoute.insights:
        return '/insights';
      case AppRoute.subscription:
        return '/subscription';
      case AppRoute.billing:
        return '/billing';
      case AppRoute.notFound:
        return '/404';
      case AppRoute.error:
        return '/error';
    }
  }
  
  String get name => toString().split('.').last;
}

/// Route configuration using standard Flutter navigation
class AppRoutes {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  
  /// Get navigator key
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  /// Get current context
  static BuildContext? get context => _navigatorKey.currentContext;
  
  /// Route generator for named routes
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case '/onboarding':
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case '/lessons':
        return MaterialPageRoute(
          builder: (_) => const LessonsScreen(),
          settings: settings,
        );
      case '/lessons/detail':
        final lessonId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => LessonDetailScreen(lessonId: lessonId ?? ''),
          settings: settings,
        );
      case '/learning-session':
        final sessionId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => LearningSessionScreen(sessionId: sessionId ?? ''),
          settings: settings,
        );
      case '/learning-progress':
        return MaterialPageRoute(
          builder: (_) => const LearningProgressScreen(),
          settings: settings,
        );
      case '/learning-path':
        final pathId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => LearningPathScreen(pathId: pathId ?? ''),
          settings: settings,
        );
      case '/coach':
        return MaterialPageRoute(
          builder: (_) => const CoachScreen(),
          settings: settings,
        );
      case '/coach/chat':
        final coachId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CoachChatScreen(coachId: coachId ?? ''),
          settings: settings,
        );
      case '/coach/history':
        return MaterialPageRoute(
          builder: (_) => const CoachHistoryScreen(),
          settings: settings,
        );
      case '/audio':
        return MaterialPageRoute(
          builder: (_) => const AudioLibraryScreen(),
          settings: settings,
        );
      case '/audio/player':
        final audioId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AudioPlayerScreen(audioId: audioId ?? ''),
          settings: settings,
        );
      case '/audio/generator':
        return MaterialPageRoute(
          builder: (_) => const AudioGeneratorScreen(),
          settings: settings,
        );
      case '/curriculum':
        return MaterialPageRoute(
          builder: (_) => const CurriculumScreen(),
          settings: settings,
        );
      case '/content':
        final contentId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ContentItemScreen(contentId: contentId ?? ''),
          settings: settings,
        );
      case '/analytics':
        return MaterialPageRoute(
          builder: (_) => const AnalyticsScreen(),
          settings: settings,
        );
      case '/insights':
        return MaterialPageRoute(
          builder: (_) => const InsightsScreen(),
          settings: settings,
        );
      case '/subscription':
        return MaterialPageRoute(
          builder: (_) => const SubscriptionScreen(),
          settings: settings,
        );
      case '/billing':
        return MaterialPageRoute(
          builder: (_) => const BillingScreen(),
          settings: settings,
        );
      case '/404':
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
      case '/error':
        final error = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ErrorScreen(error: error),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
  
  /// Get all route names
  static List<String> get allRoutes => AppRoute.values.map((e) => e.path).toList();
}

/// Navigation service for programmatic navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();
  
  /// Navigate to route
  void navigateTo(AppRoute route, {Object? arguments}) {
    AppRoutes.navigatorKey.currentState?.pushNamed(route.path, arguments: arguments);
  }
  
  /// Push route
  void push(AppRoute route, {Object? arguments}) {
    AppRoutes.navigatorKey.currentState?.pushNamed(route.path, arguments: arguments);
  }
  
  /// Pop current route
  void pop([Object? result]) {
    AppRoutes.navigatorKey.currentState?.pop(result);
  }
  
  /// Replace current route
  void pushReplacement(AppRoute route, {Object? arguments}) {
    AppRoutes.navigatorKey.currentState?.pushReplacementNamed(route.path, arguments: arguments);
  }
  
  /// Push and remove until
  void pushAndRemoveUntil(AppRoute route, {Object? arguments}) {
    AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route.path,
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// Go to lesson detail
  void goToLessonDetail(String lessonId) {
    navigateTo(AppRoute.lessonDetail, arguments: lessonId);
  }
  
  /// Go to learning session
  void goToLearningSession(String sessionId) {
    navigateTo(AppRoute.learningSession, arguments: sessionId);
  }
  
  /// Go to learning path
  void goToLearningPath(String pathId) {
    navigateTo(AppRoute.learningPath, arguments: pathId);
  }
  
  /// Go to coach chat
  void goToCoachChat(String coachId) {
    navigateTo(AppRoute.coachChat, arguments: coachId);
  }
  
  /// Go to audio player
  void goToAudioPlayer(String audioId) {
    navigateTo(AppRoute.audioPlayer, arguments: audioId);
  }
  
  /// Go to content item
  void goToContentItem(String contentId) {
    navigateTo(AppRoute.contentItem, arguments: contentId);
  }
  
  /// Navigate to home
  void goToHome() => navigateTo(AppRoute.home);
  
  /// Navigate to dashboard
  void goToDashboard() => navigateTo(AppRoute.dashboard);
  
  /// Navigate to profile
  void goToProfile() => navigateTo(AppRoute.profile);
  
  /// Navigate to settings
  void goToSettings() => navigateTo(AppRoute.settings);
  
  /// Navigate to login
  void goToLogin() => navigateTo(AppRoute.login);
  
  /// Navigate to register
  void goToRegister() => navigateTo(AppRoute.register);
  
  /// Navigate to onboarding
  void goToOnboarding() => navigateTo(AppRoute.onboarding);
  
  /// Check if can pop
  bool get canPop => AppRoutes.navigatorKey.currentState?.canPop() ?? false;
}

/// Placeholder screens - these will be replaced with actual UI implementations
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Splash Screen')),
  );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Onboarding Screen')),
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Login Screen')),
  );
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Register Screen')),
  );
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Forgot Password Screen')),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Home Screen')),
  );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Dashboard Screen')),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Profile Screen')),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Settings Screen')),
  );
}

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Lessons Screen')),
  );
}

class LessonDetailScreen extends StatelessWidget {
  final String lessonId;
  const LessonDetailScreen({required this.lessonId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Lesson Detail: $lessonId')),
  );
}

class LearningSessionScreen extends StatelessWidget {
  final String sessionId;
  const LearningSessionScreen({required this.sessionId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Learning Session: $sessionId')),
  );
}

class LearningProgressScreen extends StatelessWidget {
  const LearningProgressScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Learning Progress Screen')),
  );
}

class LearningPathScreen extends StatelessWidget {
  final String pathId;
  const LearningPathScreen({required this.pathId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Learning Path: $pathId')),
  );
}

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Coach Screen')),
  );
}

class CoachChatScreen extends StatelessWidget {
  final String coachId;
  const CoachChatScreen({required this.coachId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Coach Chat: $coachId')),
  );
}

class CoachHistoryScreen extends StatelessWidget {
  const CoachHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Coach History Screen')),
  );
}

class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Audio Library Screen')),
  );
}

class AudioPlayerScreen extends StatelessWidget {
  final String audioId;
  const AudioPlayerScreen({required this.audioId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Audio Player: $audioId')),
  );
}

class AudioGeneratorScreen extends StatelessWidget {
  const AudioGeneratorScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Audio Generator Screen')),
  );
}

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Curriculum Screen')),
  );
}

class ContentItemScreen extends StatelessWidget {
  final String contentId;
  const ContentItemScreen({required this.contentId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Text('Content Item: $contentId')),
  );
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Analytics Screen')),
  );
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Insights Screen')),
  );
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Subscription Screen')),
  );
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Billing Screen')),
  );
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('404 - Page Not Found')),
  );
}

class ErrorScreen extends StatelessWidget {
  final String? error;
  const ErrorScreen({this.error, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Error Screen'),
          if (error != null) Text('Error: $error'),
        ],
      ),
    ),
  );
}
