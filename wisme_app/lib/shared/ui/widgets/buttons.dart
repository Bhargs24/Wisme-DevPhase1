import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Primary action button - Main CTAs
class WismePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;

  const WismePrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: WismeSpacing.lg,
          vertical: WismeSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WismeRadius.md),
        ),
      ),
      child: isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: WismeSpacing.sm),
                Text(text),
              ],
            )
          : Text(text),
    );

    return isFullWidth
      ? SizedBox(width: double.infinity, child: button)
      : button;
  }
}

/// Secondary action button - Alternative actions
class WismeSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;

  const WismeSecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: WismeSpacing.lg,
          vertical: WismeSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WismeRadius.md),
        ),
      ),
      child: isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: WismeSpacing.sm),
                Text(text),
              ],
            )
          : Text(text),
    );

    return isFullWidth
      ? SizedBox(width: double.infinity, child: button)
      : button;
  }
}

/// Text button - Subtle actions
class WismeTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  const WismeTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: WismeSpacing.sm),
                Text(text),
              ],
            )
          : Text(text),
    );
  }
}

/// Icon button with proper theming
class WismeIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;

  const WismeIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// Floating Action Button
class WismeFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isExtended;
  final String? label;

  const WismeFAB({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isExtended = false,
    this.label,
  }) : super(key: key);

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
