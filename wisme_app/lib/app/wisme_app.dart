import 'package:flutter/material.dart';
import '../shared/ui/theme/app_theme.dart';
import '../user/user_manager.dart';
import '../user/services/auth_service.dart';
import '../user/services/personalization_service.dart';
import '../user/services/gamification_service.dart';
import '../user/data/user_data_service.dart';
import '../core/core_manager.dart';
import '../analytics/analytics_manager.dart';
import '../audio/audio_manager.dart';
import '../core/navigation/app_routes.dart';

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
      
      // Create individual services (they auto-initialize in constructors)
      final authService = AuthService();
      final dataService = UserDataService();
      final personalizationService = PersonalizationService();
      final gamificationService = GamificationService();
      
      // Initialize domain managers with proper dependencies
      await Future.wait([
        UserManager(
          dataService: dataService,
          authService: authService,
          personalizationService: personalizationService,
          gamificationService: gamificationService,
        ).initialize(),
        AnalyticsManager().initialize(),
        AudioManager.instance.initialize(),
      ]);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle initialization error
      debugPrint('App initialization failed: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'Wisme',
        theme: WismeTheme.lightTheme,
        darkTheme: WismeTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Wisme',
      theme: WismeTheme.lightTheme,
      darkTheme: WismeTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: AppRoutes.navigatorKey,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoute.splash.path,
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
