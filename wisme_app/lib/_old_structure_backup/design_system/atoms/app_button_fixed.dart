import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

/// Ultra-flexible button component - the foundation for all buttons
/// UI/UX developers: This is your main button component, highly customizable
class AppButton extends StatelessWidget {
  // === CONTENT ===
  final String? text;
  final Widget? child;
  final IconData? icon;
  final IconData? trailingIcon;

  // === BEHAVIOR ===
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isLoading;
  final bool isEnabled;

  // === STYLING ===
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Color? customColor;
  final Color? customBackgroundColor;
  final Color? customTextColor;
  final EdgeInsets? customPadding;
  final BorderRadius? customBorderRadius;
  final double? customElevation;
  final Border? customBorder;
  final List<BoxShadow>? customShadow;
  final Gradient? customGradient;

  // === LAYOUT ===
  final bool isFullWidth;
  final double? customWidth;
  final double? customHeight;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const AppButton({
    super.key,
    this.text,
    this.child,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.onLongPress,
    this.isLoading = false,
    this.isEnabled = true,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.customColor,
    this.customBackgroundColor,
    this.customTextColor,
    this.customPadding,
    this.customBorderRadius,
    this.customElevation,
    this.customBorder,
    this.customShadow,
    this.customGradient,
    this.isFullWidth = true,
    this.customWidth,
    this.customHeight,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = _buildButtonByVariant(context, theme);

    // Apply custom width constraints
    if (customWidth != null || isFullWidth) {
      button = SizedBox(
        width: isFullWidth ? double.infinity : customWidth,
        height: customHeight ?? _getHeight(),
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonByVariant(BuildContext context, ThemeData theme) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildElevatedButton(context, theme);
      case AppButtonVariant.secondary:
        return _buildOutlinedButton(context, theme);
      case AppButtonVariant.ghost:
        return _buildTextButton(context, theme);
      case AppButtonVariant.danger:
        return _buildDangerButton(context, theme);
      case AppButtonVariant.custom:
        return _buildCustomButton(context, theme);
    }
  }

  Widget _buildElevatedButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: customBackgroundColor ?? customColor ?? theme.colorScheme.primary,
        foregroundColor: customTextColor ?? theme.colorScheme.onPrimary,
        elevation: customElevation ?? 2.0,
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? BorderRadius.circular(8.0),
          side: customBorder?.top ?? BorderSide.none,
        ),
        minimumSize: Size(0, customHeight ?? _getHeight()),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, ThemeData theme) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: OutlinedButton.styleFrom(
        foregroundColor: customTextColor ?? customColor ?? theme.colorScheme.primary,
        side: BorderSide(
          color: customColor ?? theme.colorScheme.primary,
          width: customBorder?.top.width ?? 1,
        ),
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? BorderRadius.circular(8.0),
        ),
        minimumSize: Size(0, customHeight ?? _getHeight()),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildTextButton(BuildContext context, ThemeData theme) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: TextButton.styleFrom(
        foregroundColor: customTextColor ?? customColor ?? theme.colorScheme.primary,
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? BorderRadius.circular(8.0),
        ),
        minimumSize: Size(0, customHeight ?? _getHeight()),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildDangerButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: customBackgroundColor ?? AppColors.error,
        foregroundColor: customTextColor ?? AppColors.textOnPrimary,
        elevation: customElevation ?? 2.0,
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? BorderRadius.circular(8.0),
        ),
        minimumSize: Size(0, customHeight ?? _getHeight()),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildCustomButton(BuildContext context, ThemeData theme) {
    return Container(
      width: customWidth,
      height: customHeight ?? _getHeight(),
      decoration: BoxDecoration(
        color: customBackgroundColor,
        gradient: customGradient,
        borderRadius: customBorderRadius ?? BorderRadius.circular(8.0),
        border: customBorder,
        boxShadow: customShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          onLongPress: onLongPress,
          borderRadius: customBorderRadius ?? BorderRadius.circular(8.0),
          child: Container(
            padding: customPadding ?? _getPadding(),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            customTextColor ?? AppColors.textOnPrimary,
          ),
        ),
      );
    }

    final content = child ?? Text(text!);

    if (icon != null || trailingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (icon != null) ...[
            Icon(icon, size: _getIconSize()),
            const SizedBox(width: 8),
          ],
          Flexible(child: content),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: _getIconSize()),
          ],
        ],
      );
    }

    return content;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 32.0;
      case AppButtonSize.medium:
        return 40.0;
      case AppButtonSize.large:
        return 48.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 4);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 8);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 20.0;
      case AppButtonSize.large:
        return 24.0;
    }
  }
}

/// Button variant types
enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
  custom,
}

/// Button size types
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Specialized button variants for common use cases

/// Icon-only button
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.color,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = AppButton(
      icon: icon,
      text: '',
      onPressed: onPressed,
      variant: AppButtonVariant.custom,
      size: size,
      customColor: color,
      customBackgroundColor: backgroundColor,
      isFullWidth: false,
      customWidth: _getSize(),
      customHeight: _getSize(),
      customBorderRadius: BorderRadius.circular(999),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  double _getSize() {
    switch (size) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 40;
      case AppButtonSize.large:
        return 48;
    }
  }
}

/// Floating action button variant
class AppFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isExtended;
  final String? label;

  const AppFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isExtended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
