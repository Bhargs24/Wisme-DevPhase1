import 'package:flutter/material.dart';
import '../../shared/ui/widgets/widgets.dart';
import '../../shared/ui/theme/app_theme.dart';
import '../../analytics/analytics_manager.dart';
import '../navigation/app_router.dart';
import '../navigation/main_navigation.dart';

/// Splash screen - App entry point
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Start animations
      _animationController.forward();
      
      // Initialize app (minimum 2 seconds for splash)
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        _performAppInitialization(),
      ]);

      // Navigate based on authentication state
      await _navigateToNextScreen();
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      // Navigate to error screen or retry
      await _navigateToNextScreen();
    }
  }

  Future<void> _performAppInitialization() async {
    // App managers are already initialized in WismeApp
    // This is for any splash-specific initialization
    try {
      await AnalyticsManager().trackEvent(
        eventType: 'system',
        eventName: 'app_launch',
        properties: {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Theme.of(context).platform.name,
        },
      );
    } catch (e) {
      debugPrint('Analytics tracking error: $e');
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      // For now, go to welcome screen until user management is fully set up
      AppNavigation.pushReplacementNamed(AppRoutes.welcome);
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback to welcome screen
      AppNavigation.pushReplacementNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(WismeRadius.xl),
                        boxShadow: WismeShadows.lg,
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 64,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: WismeSpacing.xl),
                    
                    // App name
                    Text(
                      'Wisme',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: WismeSpacing.sm),
                    
                    // Tagline
                    Text(
                      'AI-Powered Learning Platform',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: WismeSpacing.xl * 2),
                    
                    // Loading indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Authentication wrapper - Determines app flow based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For now, always show splash screen that navigates to welcome
    // This will be enhanced when user authentication is fully implemented
    return const SplashScreen();
  }
}

/// Home screen - Main dashboard after authentication
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}

/// Dashboard screen - Overview of user progress and recommendations
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
      ),
      body: const WismeLoadingIndicator(
        message: 'Loading dashboard...',
      ),
    );
  }
}

/// Placeholder screens for navigation
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Wisme!'),
            const SizedBox(height: 20),
            WismePrimaryButton(
              text: 'Get Started',
              onPressed: () {
                AppNavigation.pushNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingFlowScreen extends StatelessWidget {
  const OnboardingFlowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(
          message: 'Setting up your learning journey...',
        ),
      ),
    );
  }
}
