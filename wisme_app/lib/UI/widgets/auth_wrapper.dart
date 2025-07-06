import '../../core/exports.dart';
import 'main_navigation.dart';
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
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


