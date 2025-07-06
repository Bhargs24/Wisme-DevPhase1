import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized text styles for consistent typography
/// All text styles follow Material Design 3 guidelines
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  /// Base font family (can be customized)
  static const String _fontFamily = 'Inter';

  /// Complete text theme for the app
  static const TextTheme textTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      fontFamily: _fontFamily,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFamily: _fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      fontFamily: _fontFamily,
    ),
  );

  // Custom text styles for specific use cases
  
  /// App bar title style
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    fontFamily: _fontFamily,
  );

  /// Button text style
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
  );

  /// Lesson card title style
  static const TextStyle lessonTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );

  /// Lesson card subtitle style
  static const TextStyle lessonSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );

  /// Voice chip style
  static const TextStyle voiceChip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    fontFamily: _fontFamily,
  );

  /// Tag chip style
  static const TextStyle tagChip = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    fontFamily: _fontFamily,
  );

  /// Hint text style
  static const TextStyle hintText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );

  /// Error text style
  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
    fontFamily: _fontFamily,
  );

  /// Success text style
  static const TextStyle successText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.success,
    fontFamily: _fontFamily,
  );

  /// Caption style for small labels
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );

  /// Overline style for category labels
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
    letterSpacing: 1.5,
  );
}

/// Helper extension for applying text styles with context
extension TextStyleExtension on TextStyle {
  /// Apply primary color
  TextStyle get primary => copyWith(color: AppColors.primary);
  
  /// Apply secondary color
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);
  
  /// Apply error color
  TextStyle get error => copyWith(color: AppColors.error);
  
  /// Apply success color
  TextStyle get success => copyWith(color: AppColors.success);
  
  /// Apply bold weight
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  
  /// Apply semi-bold weight
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  
  /// Apply medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
}

