import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard card component
class WismeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? color;

  const WismeCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: elevation,
      color: color,
      margin: margin ?? const EdgeInsets.all(WismeSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WismeRadius.lg),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(WismeSpacing.md),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WismeRadius.lg),
        child: card,
      );
    }

    return card;
  }
}

/// Container with consistent styling
class WismeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final BoxShadow? shadow;

  const WismeContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.shadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? WismeRadius.md),
        border: border,
        boxShadow: shadow != null ? [shadow!] : WismeShadows.sm,
      ),
      child: child,
    );
  }
}

/// Section with title
class WismeSection extends StatelessWidget {
  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const WismeSection({
    Key? key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(WismeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: WismeSpacing.xs),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: WismeSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// List tile with consistent styling
class WismeListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const WismeListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(
        horizontal: WismeSpacing.md,
        vertical: WismeSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WismeRadius.md),
      ),
    );
  }
}

/// Divider with consistent spacing
class WismeDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final Color? color;

  const WismeDivider({
    Key? key,
    this.height,
    this.thickness,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? WismeSpacing.md,
      thickness: thickness,
      color: color,
    );
  }
}

/// Spacer with predefined sizes
class WismeSpacer extends StatelessWidget {
  final WismeSpacingSize size;
  final bool isVertical;

  const WismeSpacer({
    Key? key,
    this.size = WismeSpacingSize.medium,
    this.isVertical = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = switch (size) {
      WismeSpacingSize.extraSmall => WismeSpacing.xs,
      WismeSpacingSize.small => WismeSpacing.sm,
      WismeSpacingSize.medium => WismeSpacing.md,
      WismeSpacingSize.large => WismeSpacing.lg,
      WismeSpacingSize.extraLarge => WismeSpacing.xl,
    };

    return SizedBox(
      width: isVertical ? null : spacing,
      height: isVertical ? spacing : null,
    );
  }
}

enum WismeSpacingSize {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
}
