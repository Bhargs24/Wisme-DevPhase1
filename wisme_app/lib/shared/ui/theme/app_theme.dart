import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App theme configuration
class WismeTheme {
  /// Light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: WismeColors.lightColorScheme,
    appBarTheme: _lightAppBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    textButtonTheme: _textButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cardTheme,
    chipTheme: _chipTheme,
    bottomNavigationBarTheme: _bottomNavigationBarTheme,
    navigationRailTheme: _navigationRailTheme,
    tabBarTheme: _tabBarTheme,
    dialogTheme: _dialogTheme,
    snackBarTheme: _snackBarTheme,
    textTheme: WismeTextStyles.textTheme,
    fontFamily: WismeTextStyles.fontFamily,
  );
  
  /// Dark theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: WismeColors.darkColorScheme,
    appBarTheme: _darkAppBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    textButtonTheme: _textButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cardTheme,
    chipTheme: _chipTheme,
    bottomNavigationBarTheme: _bottomNavigationBarTheme,
    navigationRailTheme: _navigationRailTheme,
    tabBarTheme: _tabBarTheme,
    dialogTheme: _dialogTheme,
    snackBarTheme: _snackBarTheme,
    textTheme: WismeTextStyles.textTheme,
    fontFamily: WismeTextStyles.fontFamily,
  );
  
  // Component themes
  static const _lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );
  
  static const _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
  
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
  
  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  static final _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: const EdgeInsets.all(16),
  );
  
  static final _cardTheme = CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );
  
  static final _chipTheme = ChipThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );
  
  static const _bottomNavigationBarTheme = BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );
  
  static const _navigationRailTheme = NavigationRailThemeData(
    elevation: 4,
  );
  
  static const _tabBarTheme = TabBarTheme(
    indicatorSize: TabBarIndicatorSize.label,
  );
  
  static final _dialogTheme = DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );
  
  static final _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

/// App colors
class WismeColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryGreen = Color(0xFF059669);
  static const Color primaryOrange = Color(0xFFEA580C);
  static const Color primaryRed = Color(0xFFDC2626);
  
  // Neutral colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  
  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Light color scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCECFF),
    onPrimaryContainer: Color(0xFF001D35),
    secondary: primaryPurple,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE9DDFF),
    onSecondaryContainer: Color(0xFF21005D),
    tertiary: primaryGreen,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFA6F3DD),
    onTertiaryContainer: Color(0xFF002114),
    error: error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    outline: neutral400,
    background: neutral50,
    onBackground: neutral900,
    surface: Colors.white,
    onSurface: neutral900,
    surfaceVariant: neutral100,
    onSurfaceVariant: neutral700,
    inverseSurface: neutral800,
    onInverseSurface: neutral100,
    inversePrimary: Color(0xFFB1C5FF),
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: primaryBlue,
  );
  
  // Dark color scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB1C5FF),
    onPrimary: Color(0xFF002E69),
    primaryContainer: Color(0xFF004494),
    onPrimaryContainer: Color(0xFFDCECFF),
    secondary: Color(0xFFCFBCFF),
    onSecondary: Color(0xFF371E73),
    secondaryContainer: Color(0xFF4F378B),
    onSecondaryContainer: Color(0xFFE9DDFF),
    tertiary: Color(0xFF89D6C1),
    onTertiary: Color(0xFF003729),
    tertiaryContainer: Color(0xFF00513E),
    onTertiaryContainer: Color(0xFFA6F3DD),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    outline: neutral500,
    background: Color(0xFF0F0F0F),
    onBackground: neutral100,
    surface: neutral900,
    onSurface: neutral100,
    surfaceVariant: neutral800,
    onSurfaceVariant: neutral300,
    inverseSurface: neutral100,
    onInverseSurface: neutral800,
    inversePrimary: primaryBlue,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Color(0xFFB1C5FF),
  );
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, primaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App text styles
class WismeTextStyles {
  static const String fontFamily = 'Inter';
  
  // Text theme
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
  );
  
  // Custom text styles
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.25,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.3,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
}

/// App spacing constants
class WismeSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Semantic spacing
  static const double tiny = xs;
  static const double small = sm;
  static const double medium = md;
  static const double large = lg;
  static const double huge = xl;
  static const double massive = xxl;
}

/// App border radius constants
class WismeRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
  
  // Border radius widgets
  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}

/// App shadows
class WismeShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];
  
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];
  
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
  ];
}

/// Theme extensions
extension WismeThemeExtension on ThemeData {
  /// Get primary gradient
  LinearGradient get primaryGradient => WismeColors.primaryGradient;
  
  /// Get success gradient
  LinearGradient get successGradient => WismeColors.successGradient;
  
  /// Get warning gradient
  LinearGradient get warningGradient => WismeColors.warningGradient;
  
  /// Get error gradient
  LinearGradient get errorGradient => WismeColors.errorGradient;
}

extension WismeColorExtension on ColorScheme {
  /// Get success color
  Color get success => WismeColors.success;
  
  /// Get warning color
  Color get warning => WismeColors.warning;
  
  /// Get info color
  Color get info => WismeColors.info;
}
