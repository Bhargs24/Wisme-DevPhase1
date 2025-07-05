import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App routes enumeration
enum AppRoute {
  splash('/'),
  onboarding('/onboarding'),
  login('/login'),
  register('/register'),
  forgotPassword('/forgot-password'),
  
  // Main app routes
  home('/home'),
  dashboard('/dashboard'),
  profile('/profile'),
  settings('/settings'),
  
  // Learning routes
  lessons('/lessons'),
  lessonDetail('/lessons/:lessonId'),
  learningSession('/learning-session/:sessionId'),
  learningProgress('/learning-progress'),
  learningPath('/learning-path/:pathId'),
  
  // Coach routes
  coach('/coach'),
  coachChat('/coach/chat/:coachId'),
  coachHistory('/coach/history'),
  
  // Audio routes
  audioLibrary('/audio'),
  audioPlayer('/audio/player/:audioId'),
  audioGenerator('/audio/generator'),
  
  // Content routes
  curriculum('/curriculum'),
  contentItem('/content/:contentId'),
  
  // Analytics routes
  analytics('/analytics'),
  insights('/insights'),
  
  // Subscription routes
  subscription('/subscription'),
  billing('/billing'),
  
  // Error routes
  notFound('/404'),
  error('/error'),
}

/// Route configuration
class AppRoutes {
  static final _navigatorKey = GlobalKey<NavigatorState>();
  
  /// Get navigator key
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  /// Get current context
  static BuildContext? get context => _navigatorKey.currentContext;
  
  /// Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path,
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main app routes with shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            name: AppRoute.home.name,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoute.dashboard.path,
            name: AppRoute.dashboard.name,
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Learning routes
          GoRoute(
            path: AppRoute.lessons.path,
            name: AppRoute.lessons.name,
            builder: (context, state) => const LessonsScreen(),
            routes: [
              GoRoute(
                path: '/:lessonId',
                name: AppRoute.lessonDetail.name,
                builder: (context, state) => LessonDetailScreen(
                  lessonId: state.pathParameters['lessonId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoute.learningSession.path,
            name: AppRoute.learningSession.name,
            builder: (context, state) => LearningSessionScreen(
              sessionId: state.pathParameters['sessionId']!,
            ),
          ),
          GoRoute(
            path: AppRoute.learningProgress.path,
            name: AppRoute.learningProgress.name,
            builder: (context, state) => const LearningProgressScreen(),
          ),
          GoRoute(
            path: AppRoute.learningPath.path,
            name: AppRoute.learningPath.name,
            builder: (context, state) => LearningPathScreen(
              pathId: state.pathParameters['pathId']!,
            ),
          ),
          
          // Coach routes
          GoRoute(
            path: AppRoute.coach.path,
            name: AppRoute.coach.name,
            builder: (context, state) => const CoachScreen(),
            routes: [
              GoRoute(
                path: '/chat/:coachId',
                name: AppRoute.coachChat.name,
                builder: (context, state) => CoachChatScreen(
                  coachId: state.pathParameters['coachId']!,
                ),
              ),
              GoRoute(
                path: '/history',
                name: AppRoute.coachHistory.name,
                builder: (context, state) => const CoachHistoryScreen(),
              ),
            ],
          ),
          
          // Audio routes
          GoRoute(
            path: AppRoute.audioLibrary.path,
            name: AppRoute.audioLibrary.name,
            builder: (context, state) => const AudioLibraryScreen(),
            routes: [
              GoRoute(
                path: '/player/:audioId',
                name: AppRoute.audioPlayer.name,
                builder: (context, state) => AudioPlayerScreen(
                  audioId: state.pathParameters['audioId']!,
                ),
              ),
              GoRoute(
                path: '/generator',
                name: AppRoute.audioGenerator.name,
                builder: (context, state) => const AudioGeneratorScreen(),
              ),
            ],
          ),
          
          // Content routes
          GoRoute(
            path: AppRoute.curriculum.path,
            name: AppRoute.curriculum.name,
            builder: (context, state) => const CurriculumScreen(),
          ),
          GoRoute(
            path: AppRoute.contentItem.path,
            name: AppRoute.contentItem.name,
            builder: (context, state) => ContentItemScreen(
              contentId: state.pathParameters['contentId']!,
            ),
          ),
          
          // Analytics routes
          GoRoute(
            path: AppRoute.analytics.path,
            name: AppRoute.analytics.name,
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: AppRoute.insights.path,
            name: AppRoute.insights.name,
            builder: (context, state) => const InsightsScreen(),
          ),
          
          // Profile and settings
          GoRoute(
            path: AppRoute.profile.path,
            name: AppRoute.profile.name,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            name: AppRoute.settings.name,
            builder: (context, state) => const SettingsScreen(),
          ),
          
          // Subscription routes
          GoRoute(
            path: AppRoute.subscription.path,
            name: AppRoute.subscription.name,
            builder: (context, state) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: AppRoute.billing.path,
            name: AppRoute.billing.name,
            builder: (context, state) => const BillingScreen(),
          ),
        ],
      ),
      
      // Error routes
      GoRoute(
        path: AppRoute.notFound.path,
        name: AppRoute.notFound.name,
        builder: (context, state) => const NotFoundScreen(),
      ),
      GoRoute(
        path: AppRoute.error.path,
        name: AppRoute.error.name,
        builder: (context, state) => ErrorScreen(
          error: state.extra as String?,
        ),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error?.toString(),
    ),
  );
}

/// Navigation service for programmatic navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();
  
  /// Navigate to route
  void go(AppRoute route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    String path = route.path;
    
    // Replace path parameters
    if (pathParameters != null) {
      pathParameters.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }
    
    AppRoutes.router.go(path, extra: extra);
  }
  
  /// Push route
  void push(AppRoute route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    String path = route.path;
    
    // Replace path parameters
    if (pathParameters != null) {
      pathParameters.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }
    
    AppRoutes.router.push(path, extra: extra);
  }
  
  /// Pop current route
  void pop([Object? result]) {
    if (AppRoutes.router.canPop()) {
      AppRoutes.router.pop(result);
    }
  }
  
  /// Replace current route
  void replace(AppRoute route, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters, Object? extra}) {
    String path = route.path;
    
    // Replace path parameters
    if (pathParameters != null) {
      pathParameters.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });
    }
    
    AppRoutes.router.pushReplacement(path, extra: extra);
  }
  
  /// Go to lesson detail
  void goToLessonDetail(String lessonId) {
    go(AppRoute.lessonDetail, pathParameters: {'lessonId': lessonId});
  }
  
  /// Go to learning session
  void goToLearningSession(String sessionId) {
    go(AppRoute.learningSession, pathParameters: {'sessionId': sessionId});
  }
  
  /// Go to learning path
  void goToLearningPath(String pathId) {
    go(AppRoute.learningPath, pathParameters: {'pathId': pathId});
  }
  
  /// Go to coach chat
  void goToCoachChat(String coachId) {
    go(AppRoute.coachChat, pathParameters: {'coachId': coachId});
  }
  
  /// Go to audio player
  void goToAudioPlayer(String audioId) {
    go(AppRoute.audioPlayer, pathParameters: {'audioId': audioId});
  }
  
  /// Go to content item
  void goToContentItem(String contentId) {
    go(AppRoute.contentItem, pathParameters: {'contentId': contentId});
  }
  
  /// Navigate to home
  void goToHome() => go(AppRoute.home);
  
  /// Navigate to dashboard
  void goToDashboard() => go(AppRoute.dashboard);
  
  /// Navigate to profile
  void goToProfile() => go(AppRoute.profile);
  
  /// Navigate to settings
  void goToSettings() => go(AppRoute.settings);
  
  /// Navigate to login
  void goToLogin() => go(AppRoute.login);
  
  /// Navigate to register
  void goToRegister() => go(AppRoute.register);
  
  /// Navigate to onboarding
  void goToOnboarding() => go(AppRoute.onboarding);
  
  /// Get current location
  String get currentLocation => AppRoutes.router.routerDelegate.currentConfiguration.uri.toString();
  
  /// Check if can pop
  bool get canPop => AppRoutes.router.canPop();
}

/// Extension on AppRoute for convenience
extension AppRouteExtension on AppRoute {
  /// Get route path
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
        return '/lessons/:lessonId';
      case AppRoute.learningSession:
        return '/learning-session/:sessionId';
      case AppRoute.learningProgress:
        return '/learning-progress';
      case AppRoute.learningPath:
        return '/learning-path/:pathId';
      case AppRoute.coach:
        return '/coach';
      case AppRoute.coachChat:
        return '/coach/chat/:coachId';
      case AppRoute.coachHistory:
        return '/coach/history';
      case AppRoute.audioLibrary:
        return '/audio';
      case AppRoute.audioPlayer:
        return '/audio/player/:audioId';
      case AppRoute.audioGenerator:
        return '/audio/generator';
      case AppRoute.curriculum:
        return '/curriculum';
      case AppRoute.contentItem:
        return '/content/:contentId';
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
  
  /// Get route name
  String get name => toString().split('.').last;
}

/// Placeholder screens - these will be implemented in the UI layer
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Splash')));
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Onboarding')));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login')));
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Register')));
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Forgot Password')));
}

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({required this.child, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: child);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Dashboard')));
}

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Lessons')));
}

class LessonDetailScreen extends StatelessWidget {
  final String lessonId;
  const LessonDetailScreen({required this.lessonId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Lesson Detail: $lessonId')));
}

class LearningSessionScreen extends StatelessWidget {
  final String sessionId;
  const LearningSessionScreen({required this.sessionId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Learning Session: $sessionId')));
}

class LearningProgressScreen extends StatelessWidget {
  const LearningProgressScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Learning Progress')));
}

class LearningPathScreen extends StatelessWidget {
  final String pathId;
  const LearningPathScreen({required this.pathId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Learning Path: $pathId')));
}

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Coach')));
}

class CoachChatScreen extends StatelessWidget {
  final String coachId;
  const CoachChatScreen({required this.coachId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Coach Chat: $coachId')));
}

class CoachHistoryScreen extends StatelessWidget {
  const CoachHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Coach History')));
}

class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Audio Library')));
}

class AudioPlayerScreen extends StatelessWidget {
  final String audioId;
  const AudioPlayerScreen({required this.audioId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Audio Player: $audioId')));
}

class AudioGeneratorScreen extends StatelessWidget {
  const AudioGeneratorScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Audio Generator')));
}

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Curriculum')));
}

class ContentItemScreen extends StatelessWidget {
  final String contentId;
  const ContentItemScreen({required this.contentId, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Content Item: $contentId')));
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Analytics')));
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Insights')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings')));
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Subscription')));
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Billing')));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('404 - Not Found')));
}

class ErrorScreen extends StatelessWidget {
  final String? error;
  const ErrorScreen({this.error, super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Error: ${error ?? 'Unknown error'}')));
}
