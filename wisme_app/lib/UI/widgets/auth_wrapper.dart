import 'package:flutter/material.dart';

// TODO: Replace with UserManager import
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import 'main_navigation.dart';

/// Authentication wrapper that manages app flow based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return // TODO: Replace // TODO: Replace Consumer<UserProvider> with manager pattern with manager pattern(
      builder: (context, userProvider, child) {
        // Show loading screen while checking authentication
        if (userProvider.isLoading) {
          return const SplashScreen();
        }
        
        // Show onboarding if it's the first time
        if (!userProvider.hasCompletedOnboarding) {
          return const OnboardingScreen();
        }
        
        // Redirect to login if not authenticated
        if (!userProvider.isLoggedIn) {
          return const LoginScreen();
        }
        
        // Show main app if authenticated
        return const MainNavigation();
      },
    );
  }
}


