import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../user/manager_factory.dart';
import '../utils/logger.dart';
import '../routes.dart';

/// Production-grade Wisme app with new architecture
class WismeAppV2 extends StatefulWidget {
  const WismeAppV2({super.key});

  @override
  State<WismeAppV2> createState() => _WismeAppV2State();
}

class _WismeAppV2State extends State<WismeAppV2> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppLogger.info('✅ WismeAppV2: App started with new architecture');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.info('📱 WismeAppV2: App resumed');
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        AppLogger.info('📱 WismeAppV2: App paused');
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        AppLogger.info('📱 WismeAppV2: App detached');
        _handleAppDetached();
        break;
      default:
        break;
    }
  }

  void _handleAppResumed() {
    // Handle app resume logic
    try {
      // Refresh auth state if needed
      if (managers.isInitialized) {
        // The auth service will automatically handle state changes
      }
    } catch (e) {
      AppLogger.error('❌ WismeAppV2: Error handling app resume: $e');
    }
  }

  void _handleAppPaused() {
    // Handle app pause logic
    try {
      // Save any pending data or state
      if (managers.isInitialized) {
        // Any cleanup or state saving can be done here
      }
    } catch (e) {
      AppLogger.error('❌ WismeAppV2: Error handling app pause: $e');
    }
  }

  void _handleAppDetached() {
    // Handle app termination
    try {
      if (managers.isInitialized) {
        // Clean shutdown of services
        AppLogger.info('📱 WismeAppV2: Performing clean shutdown...');
      }
    } catch (e) {
      AppLogger.error('❌ WismeAppV2: Error during app detach: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisme - Smart Learning Assistant',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      
      // Theme configuration
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      
      // Routes
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
      
      // Global app configuration
      builder: (context, child) {
        return _AppWrapper(child: child);
      },
    );
  }

  /// Build light theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      
      // Primary colors
      primarySwatch: _createMaterialColor(AppColors.primary),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      
      // Text themes
      textTheme: _buildTextTheme(Brightness.light),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Build dark theme
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      
      // Text themes
      textTheme: _buildTextTheme(Brightness.dark),
    );
  }

  /// Build text theme
  TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light 
        ? AppColors.onBackground 
        : Colors.white;
    
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: textColor),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: textColor),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: textColor),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: textColor),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: textColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: textColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: textColor),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: textColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: textColor),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: textColor),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: textColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: textColor),
    );
  }

  /// Create material color from Color
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

/// App wrapper for global functionality
class _AppWrapper extends StatelessWidget {
  final Widget? child;

  const _AppWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          // Set up global error handling
          FlutterError.onError = (FlutterErrorDetails details) {
            AppLogger.error('❌ Flutter Error: ${details.exception}');
            AppLogger.error('❌ Stack Trace: ${details.stack}');
          };

          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Navigation service for global navigation access
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  static BuildContext? get context => navigatorKey.currentContext;
  
  /// Navigate to a named route
  static Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// Replace current route with a named route
  static Future<T?> navigateToReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigator!.pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
  }
  
  /// Clear stack and navigate to a named route
  static Future<T?> navigateToAndClearStack<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// Go back
  static void goBack<T extends Object?>([T? result]) {
    navigator!.pop<T>(result);
  }
  
  /// Check if can go back
  static bool canGoBack() {
    return navigator!.canPop();
  }
}
