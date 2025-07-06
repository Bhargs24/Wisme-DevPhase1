import 'package:flutter/material.dart';

/// Central color palette for the Wisme app
/// Easily customizable - change any color here to theme the entire app
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFFFF9800);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color overlay = Color(0x80000000);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // UI element colors
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  
  // Audio player specific colors
  static const Color audioProgress = Color(0xFF2196F3);
  static const Color audioBackground = Color(0xFFF5F5F5);
  static const Color audioControl = Color(0xFF2196F3);
  
  // Voice selection colors
  static const Color voiceSelected = Color(0xFF2196F3);
  static const Color voiceAvailable = Color(0xFF4CAF50);
  static const Color voiceUnavailable = Color(0xFF757575);
  
  // Gradient definitions for easy theming
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, Color(0xFFFAFAFA)],
  );
}

