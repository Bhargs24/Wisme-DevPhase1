import 'package:flutter/material.dart';
import '../../UI/screens/home_screen.dart' as ui_screens;
import '../../UI/screens/dashboard_screen.dart' as ui_screens;
import '../../UI/screens/profile_screen.dart';
import '../../UI/screens/settings_screen.dart';
import '../../UI/screens/onboarding_screen.dart';
import '../../routes.dart';

/// Simplified router that only includes existing screens
class SimpleAppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Use the existing routes.dart for most routing
    final existingRoute = AppRoutes.generateRoute(settings);
    if (existingRoute != null) {
      return existingRoute;
    }

    // Handle additional routes here if needed
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const ui_screens.HomeScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('Route "${settings.name}" not found'),
            ),
          ),
        );
    }
  }
}
