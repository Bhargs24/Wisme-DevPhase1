import 'package:flutter/material.dart';

/// Design tokens for spacing, sizing, and layout - single source of truth
/// UI/UX developers: Modify these values to change spacing throughout the app
class AppSpacing {
  AppSpacing._(); // Prevent instantiation

  // === BASE SPACING SCALE ===
  /// Extra small spacing - 4px
  static const double xs = 4.0;
  /// Small spacing - 8px
  static const double s = 8.0;
  /// Medium spacing - 16px
  static const double m = 16.0;
  /// Large spacing - 24px
  static const double l = 24.0;
  /// Extra large spacing - 32px
  static const double xl = 32.0;
  /// Extra extra large spacing - 48px
  static const double xxl = 48.0;
  /// Extra extra extra large spacing - 64px
  static const double xxxl = 64.0;

  // === SEMANTIC SPACING ===
  /// Page padding
  static const EdgeInsets pagePadding = EdgeInsets.all(m);
  static const EdgeInsets pageHorizontalPadding = EdgeInsets.symmetric(horizontal: m);
  static const EdgeInsets pageVerticalPadding = EdgeInsets.symmetric(vertical: m);

  /// Card spacing
  static const EdgeInsets cardPadding = EdgeInsets.all(m);
  static const EdgeInsets cardMargin = EdgeInsets.all(s);

  // === BUTTON SPACING ===
  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: l, vertical: s);
  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(horizontal: m, vertical: xs);
  static const EdgeInsets buttonLargePadding = EdgeInsets.symmetric(horizontal: xl, vertical: m);

  /// Input field spacing
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: m, vertical: s);
  static const EdgeInsets inputMargin = EdgeInsets.symmetric(vertical: s);

  /// List item spacing
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: m, vertical: s);
  static const EdgeInsets listItemMargin = EdgeInsets.symmetric(vertical: xs);

  // === COMPONENT SPACING ===
  /// Spacing between elements in a row
  static const double rowSpacing = s;
  /// Spacing between elements in a column
  static const double columnSpacing = s;
  /// Spacing for chips and tags
  static const double chipSpacing = xs;
  /// Spacing for form fields
  static const double formFieldSpacing = m;

  // === LAYOUT SPACING ===
  /// Safe area padding
  static const double safeAreaPadding = m;
  /// Header height
  static const double headerHeight = 56.0;
  /// Bottom navigation height
  static const double bottomNavHeight = 60.0;
  /// Floating action button margin
  static const double fabMargin = m;

  // === RESPONSIVE BREAKPOINTS ===
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;
  static const double desktopBreakpoint = 1800.0;

  // === UTILITY METHODS ===
  /// Get responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.all(s);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.all(m);
    } else {
      return const EdgeInsets.all(l);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: m);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: xl);
    } else {
      return const EdgeInsets.symmetric(horizontal: xxxl);
    }
  }

  /// Get spacing between widgets
  static Widget verticalSpacing(double height) => SizedBox(height: height);
  static Widget horizontalSpacing(double width) => SizedBox(width: width);
  
  /// Common vertical spacings
  static Widget get verticalSpaceXS => const SizedBox(height: xs);
  static Widget get verticalSpaceS => const SizedBox(height: s);
  static Widget get verticalSpaceM => const SizedBox(height: m);
  static Widget get verticalSpaceL => const SizedBox(height: l);
  static Widget get verticalSpaceXL => const SizedBox(height: xl);
  
  /// Common horizontal spacings
  static Widget get horizontalSpaceXS => const SizedBox(width: xs);
  static Widget get horizontalSpaceS => const SizedBox(width: s);
  static Widget get horizontalSpaceM => const SizedBox(width: m);
  static Widget get horizontalSpaceL => const SizedBox(width: l);
  static Widget get horizontalSpaceXL => const SizedBox(width: xl);
}

/// Design tokens for sizing - button heights, icon sizes, etc.
class AppSizing {
  AppSizing._();

  // === BUTTON HEIGHTS ===
  static const double buttonSmallHeight = 32.0;
  static const double buttonMediumHeight = 40.0;
  static const double buttonLargeHeight = 48.0;

  // === ICON SIZES ===
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // === AVATAR SIZES ===
  static const double avatarS = 24.0;
  static const double avatarM = 32.0;
  static const double avatarL = 48.0;
  static const double avatarXL = 64.0;

  // === COMPONENT SIZES ===
  static const double inputMinHeight = 48.0;
  static const double cardMinHeight = 80.0;
  static const double listItemMinHeight = 56.0;
  static const double chipHeight = 32.0;
  static const double tabHeight = 48.0;
  static const double bottomSheetHeaderHeight = 56.0;

  // === BORDER RADIUS ===
  static const double radiusXS = 2.0;
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 999.0;

  // === ELEVATION/SHADOWS ===
  static const double elevationNone = 0.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  // === UTILITY METHODS ===
  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < AppSpacing.mobileBreakpoint) {
      return mobile ?? iconS;
    } else if (screenWidth < AppSpacing.tabletBreakpoint) {
      return tablet ?? iconM;
    } else {
      return desktop ?? iconL;
    }
  }

  /// Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < AppSpacing.mobileBreakpoint) {
      return buttonMediumHeight;
    } else {
      return buttonLargeHeight;
    }
  }
}

