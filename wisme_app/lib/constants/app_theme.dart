import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Centralized theme configuration for maximum flexibility
/// Supports light/dark themes and easy customization
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      
      // Typography
      textTheme: AppTextStyles.textTheme,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.background,
      
      // Cards
      cardTheme: CardTheme(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        ),
        color: AppColors.surface,
        margin: AppDimensions.cardMargin,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: AppDimensions.buttonElevation,
          padding: AppDimensions.buttonPadding,
          minimumSize: Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: AppDimensions.buttonPadding,
          minimumSize: Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppDimensions.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppDimensions.inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      
      // Icon button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.disabled,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.voiceChipBorderRadius),
        ),
      ),
    );
  }

  /// Dark theme configuration (for future implementation)
  static ThemeData get darkTheme {
    // For now, return light theme. Can be expanded later for dark mode
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[900],
      cardTheme: lightTheme.cardTheme.copyWith(
        color: Colors.grey[800],
      ),
    );
  }

  /// Light color scheme
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.textOnPrimary,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onError: AppColors.textOnPrimary,
  );
}

/// Extension for easy theme access in widgets
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

