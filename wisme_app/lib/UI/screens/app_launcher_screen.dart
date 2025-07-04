import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

/// Smart launcher that routes users based on their state
class AppLauncherScreen extends StatefulWidget {
  const AppLauncherScreen({super.key});

  @override
  State<AppLauncherScreen> createState() => _AppLauncherScreenState();
}

class _AppLauncherScreenState extends State<AppLauncherScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Give a brief moment for providers to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final userProvider = context.read<UserProvider>();
    
    // Check if user has seen onboarding
    final hasSeenOnboarding = userProvider.hasSeenOnboarding;
    
    // Check if user is logged in
    final isLoggedIn = userProvider.isLoggedIn;
    
    if (!hasSeenOnboarding) {
      // First time user - show onboarding
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else if (isLoggedIn) {
      // Returning user - go to home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User has seen onboarding but not logged in - show gentle login prompt
      Navigator.of(context).pushReplacementNamed('/welcome-back');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // Primary
              Color(0xFF8B5CF6), // Purple
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Icon(
                Icons.psychology,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Wisme',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'AI-Powered Microlearning',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
