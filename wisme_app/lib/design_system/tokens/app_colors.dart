import 'package:flutter/material.dart';

/// Design tokens for colors - the single source of truth for all colors
/// UI/UX developers: Modify these values to change the entire app's color scheme
class AppColors {
  AppColors._(); // Prevent instantiation

  // === BRAND COLORS ===
  /// Primary brand color - used for main actions, links, etc.
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  /// Secondary brand color - used for secondary actions
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  /// Accent color - used for highlights, special elements
  static const Color accent = Color(0xFFFF9800);

  // === SEMANTIC COLORS ===
  /// Success states - confirmations, completed actions
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF047857);
  
  /// Warning states - cautions, warnings
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  
  /// Error states - errors, destructive actions
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);
  
  /// Info states - information, neutral notifications
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  // === NEUTRAL COLORS ===
  /// Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  /// Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  /// Border and divider colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFF334155);
  static const Color divider = Color(0xFFE2E8F0);
  
  /// State colors
  static const Color disabled = Color(0xFF94A3B8);
  static const Color disabledBackground = Color(0xFFF1F5F9);
  static const Color hover = Color(0xFFF8FAFC);
  static const Color focus = Color(0xFFE0E7FF);
  static const Color pressed = Color(0xFFE2E8F0);

  // === GRADIENT COLORS ===
  /// Primary gradient for special elements
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Secondary gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === OVERLAY COLORS ===
  /// Overlay colors for modals, dialogs
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color overlayDark = Color(0xB3000000);

  // === QUICK ACCESS METHODS ===
  /// Get color by name - useful for dynamic theming
  static Color getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'primary': return primary;
      case 'secondary': return secondary;
      case 'success': return success;
      case 'warning': return warning;
      case 'error': return error;
      case 'info': return info;
      default: return primary;
    }
  }

  /// Get semantic color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Generate color palette for a given base color
  static Map<int, Color> generatePalette(Color baseColor) {
    return {
      50: baseColor.withValues(alpha: 0.1),
      100: baseColor.withValues(alpha: 0.2),
      200: baseColor.withValues(alpha: 0.3),
      300: baseColor.withValues(alpha: 0.4),
      400: baseColor.withValues(alpha: 0.5),
      500: baseColor,
      600: Color.fromRGBO(
        (baseColor.r * 0.8).round(),
        (baseColor.g * 0.8).round(),
        (baseColor.b * 0.8).round(),
        1,
      ),
      700: Color.fromRGBO(
        (baseColor.r * 0.6).round(),
        (baseColor.g * 0.6).round(),
        (baseColor.b * 0.6).round(),
        1,
      ),
      800: Color.fromRGBO(
        (baseColor.r * 0.4).round(),
        (baseColor.g * 0.4).round(),
        (baseColor.b * 0.4).round(),
        1,
      ),
      900: Color.fromRGBO(
        (baseColor.r * 0.2).round(),
        (baseColor.g * 0.2).round(),
        (baseColor.b * 0.2).round(),
        1,
      ),
    };
  }
}

/// Dark theme colors - for dark mode support
class AppColorsDark {
  AppColorsDark._();

  // Override colors for dark theme
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFF334155);
  static const Color divider = Color(0xFF334155);
}
