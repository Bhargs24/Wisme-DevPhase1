import 'package:flutter/material.dart';

/// Centralized spacing and dimensions for consistent UI
/// Change these values to adjust spacing throughout the entire app
class AppDimensions {
  // Base spacing unit - all other spacings are multiples of this
  static const double baseSpacing = 8.0;
  
  // Standard spacing values
  static const double spaceXS = baseSpacing * 0.5; // 4
  static const double spaceS = baseSpacing; // 8
  static const double spaceM = baseSpacing * 2; // 16
  static const double spaceL = baseSpacing * 3; // 24
  static const double spaceXL = baseSpacing * 4; // 32
  static const double spaceXXL = baseSpacing * 6; // 48
  
  // Padding values
  static const EdgeInsets paddingXS = EdgeInsets.all(spaceXS);
  static const EdgeInsets paddingS = EdgeInsets.all(spaceS);
  static const EdgeInsets paddingM = EdgeInsets.all(spaceM);
  static const EdgeInsets paddingL = EdgeInsets.all(spaceL);
  static const EdgeInsets paddingXL = EdgeInsets.all(spaceXL);
  
  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(spaceM);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: spaceM);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: spaceM);
  
  // Card dimensions
  static const EdgeInsets cardPadding = EdgeInsets.all(spaceM);
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: spaceS * 1.5);
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  
  // Button dimensions
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spaceL,
    vertical: spaceS * 1.5,
  );
  static const double buttonBorderRadius = 12.0;
  static const double buttonElevation = 0.0;
  static const double buttonHeight = 48.0;
  
  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;
  
  // Avatar sizes
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXL = 96.0;
  
  // Input field dimensions
  static const EdgeInsets inputPadding = EdgeInsets.all(spaceM);
  static const double inputBorderRadius = 12.0;
  static const double inputHeight = 56.0;
  
  // Audio player dimensions
  static const double audioPlayerHeight = 120.0;
  static const EdgeInsets audioPlayerPadding = EdgeInsets.all(spaceL);
  static const double audioButtonSize = 72.0;
  static const double audioSliderHeight = 4.0;
  
  // Voice selector dimensions
  static const EdgeInsets voiceChipPadding = EdgeInsets.symmetric(
    horizontal: spaceS * 1.5,
    vertical: spaceXS,
  );
  static const double voiceChipBorderRadius = 20.0;
  
  // AppBar dimensions
  static const double appBarElevation = 0.0;
  static const double appBarHeight = kToolbarHeight;
  
  // Bottom sheet dimensions
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(spaceM);
  static const double bottomSheetBorderRadius = 20.0;
  
  // Dialog dimensions
  static const EdgeInsets dialogPadding = EdgeInsets.all(spaceL);
  static const double dialogBorderRadius = 16.0;
  
  // List item dimensions
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: spaceM,
    vertical: spaceS,
  );
  static const double listItemHeight = 72.0;
  
  // Screen breakpoints for responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  // Helper methods for responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = spaceM,
    double tablet = spaceL,
    double desktop = spaceXL,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= desktopBreakpoint) return desktop;
    if (screenWidth >= tabletBreakpoint) return tablet;
    return mobile;
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final spacing = getResponsiveSpacing(context);
    return EdgeInsets.all(spacing);
  }
  
  // Screen size helpers
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  // Safe area helpers
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

