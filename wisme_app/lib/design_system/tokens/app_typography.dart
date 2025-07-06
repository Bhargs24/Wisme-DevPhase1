import 'package:flutter/material.dart';

/// Design tokens for typography - the single source of truth for all text styles
/// UI/UX developers: Modify these values to change the entire app's typography
class AppTypography {
  AppTypography._(); // Prevent instantiation

  // === FONT CONFIGURATION ===
  /// Primary font family - change this to use different fonts
  static const String primaryFont = 'Inter';
  static const String secondaryFont = 'SF Pro Display';
  static const String monoFont = 'SF Mono';

  // === FONT WEIGHTS ===
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // === DISPLAY STYLES ===
  /// Large display text - hero sections, main headlines
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 57,
    fontWeight: bold,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 45,
    fontWeight: bold,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 36,
    fontWeight: semiBold,
    height: 1.22,
  );

  // === HEADLINE STYLES ===
  /// Headlines for sections, pages
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: semiBold,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: semiBold,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.33,
  );

  // === TITLE STYLES ===
  /// Titles for cards, components
  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // === LABEL STYLES ===
  /// Labels for buttons, form fields
  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: semiBold,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // === BODY STYLES ===
  /// Body text for content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // === CUSTOM STYLES ===
  /// Button text
  static const TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// Caption text
  static const TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
  );

  /// Overline text
  static const TextStyle overline = TextStyle(
    fontFamily: primaryFont,
    fontSize: 10,
    fontWeight: semiBold,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // === SPECIALIZED STYLES ===
  /// Code/monospace text
  static const TextStyle code = TextStyle(
    fontFamily: monoFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
  );

  /// Numeric display
  static const TextStyle numeric = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // === COMPLETE TEXT THEME ===
  /// Material Design 3 text theme
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );

  // === UTILITY METHODS ===
  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply custom weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply custom size to any text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Create responsive text style based on screen size
  static TextStyle responsive(BuildContext context, TextStyle baseStyle, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scale = 1.0;

    if (screenWidth < 600) {
      scale = mobileScale ?? 0.9;
    } else if (screenWidth < 1200) {
      scale = tabletScale ?? 1.0;
    } else {
      scale = desktopScale ?? 1.1;
    }

    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * scale,
    );
  }
}

