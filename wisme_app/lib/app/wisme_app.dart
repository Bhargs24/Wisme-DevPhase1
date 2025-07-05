import 'package:flutter/material.dart';
import '../shared/ui/theme/app_theme.dart';
import '../user/user_manager.dart';
import '../core/core_manager.dart';
import '../analytics/analytics_manager.dart';
import '../audio/audio_manager.dart';
import 'navigation/app_router.dart';
import 'screens/splash_screen.dart';

/// Main Wisme application
class WismeApp extends StatefulWidget {
  const WismeApp({Key? key}) : super(key: key);

  @override
  State<WismeApp> createState() => _WismeAppState();
}

class _WismeAppState extends State<WismeApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize core services first
      await CoreManager().initialize();
      
      // Initialize domain managers with proper dependencies
      await Future.wait([
        UserManager(
          dataService: null, // Will be created internally
          authService: null, // Will be created internally
        ).initialize(),
        AnalyticsManager().initialize(),
        AudioManager().initialize(),
        // Note: Other managers will be initialized when first accessed
      ]);

      // Track app initialization
      // await AnalyticsManager().trackEvent('app_initialized', {});

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle initialization error
      debugPrint('App initialization error: $e');
      // Could show error dialog or retry mechanism
      setState(() {
        _isInitialized = true; // Allow app to continue with limited functionality
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisme - AI Learning Platform',
      theme: WismeTheme.lightTheme,
      darkTheme: WismeTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: AppNavigation.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.splash,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (!_isInitialized) {
          return const MaterialApp(
            home: SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        }
        return child!;
      },
    );
  }
}

/// App initialization manager
class AppInitializer {
  static bool _isInitialized = false;
  
  static bool get isInitialized => _isInitialized;

  /// Initialize all app services and managers
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize in dependency order
      await CoreManager().initialize();
      
      await Future.wait([
        UserManager(
          dataService: null, // Will be created internally
          authService: null, // Will be created internally
        ).initialize(),
        AnalyticsManager().initialize(),
        AudioManager().initialize(),
        // Note: Other managers are initialized on-demand
      ]);

      _isInitialized = true;
    } catch (e) {
      debugPrint('App initialization failed: $e');
      rethrow;
    }
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _isInitialized = false;
  }
}
