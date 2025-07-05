import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../../UI/screens/onboarding_screen.dart';
import '../../UI/screens/home_screen.dart' as ui_screens;
import '../../UI/screens/dashboard_screen.dart' as ui_screens;
import '../../UI/screens/login_screen.dart';
import '../../UI/screens/profile_screen.dart';
import '../../UI/screens/settings_screen.dart';

/// App route names
class AppRoutes {
  // Core routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Simple app router for navigation
class AppRouter {
  static const String initialRoute = AppRoutes.splash;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Route generator
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);
      
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      
      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);
      
      case AppRoutes.home:
        return _buildRoute(const ui_screens.HomeScreen(), settings);
      
      case AppRoutes.dashboard:
        return _buildRoute(const ui_screens.DashboardScreen(), settings);
      
      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen(), settings);
      
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);
      
      default:
        return _buildRoute(
          const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings,
        );
    }
  }

  /// Build material page route
  static MaterialPageRoute<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: (context) => page,
      settings: settings,
    );
  }

  /// Navigation helpers
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
    return navigator!.pop<T>(result);
  }

  /// Check if can pop
  static bool canPop() {
    return navigator!.canPop();
  }
}
