import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';
import '../../user_manager.dart';

/// Social login buttons widget
class WismeSocialLoginButtons extends StatelessWidget {
  const WismeSocialLoginButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "or"
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: WismeSpacing.md),
              child: Text(
                'or',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: WismeSpacing.md),

        // Google sign in
        WismeSecondaryButton(
          text: 'Continue with Google',
          icon: const Icon(Icons.g_mobiledata),
          onPressed: () async {
            try {
              final userManager = UserManager();
              final result = await userManager.signInWithGoogle();
              if (result.isSuccess) {
                // Handle successful login
              } else {
                // Handle error
              }
            } catch (e) {
              // Handle error
            }
          },
        ),
        const SizedBox(height: WismeSpacing.sm),

        // Apple sign in (if on iOS)
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          WismeSecondaryButton(
            text: 'Continue with Apple',
            icon: const Icon(Icons.apple),
            onPressed: () async {
              try {
                final userManager = UserManager();
                final result = await userManager.signInWithApple();
                if (result.isSuccess) {
                  // Handle successful login
                } else {
                  // Handle error
                }
              } catch (e) {
                // Handle error
              }
            },
          ),
          const SizedBox(height: WismeSpacing.sm),
        ],
      ],
    );
  }
}

/// User profile avatar widget
class WismeUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const WismeUserAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.radius = 30,
    this.onTap,
    this.showEditIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget avatar = WismeAvatar(
      imageUrl: imageUrl,
      name: name,
      radius: radius,
      onTap: onTap,
    );

    if (showEditIcon) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: radius * 0.4,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }
}

/// Progress card widget
class WismeProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  const WismeProgressCard({
    Key? key,
    required this.title,
    required this.progress,
    this.subtitle,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WismeCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24),
                const SizedBox(width: WismeSpacing.sm),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: WismeSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: WismeSpacing.sm),
          WismeProgressIndicator(
            progress: progress,
            showPercentage: false,
          ),
        ],
      ),
    );
  }
}

/// Achievement badge widget
class WismeAchievementBadge extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const WismeAchievementBadge({
    Key? key,
    required this.title,
    required this.icon,
    this.color,
    this.isUnlocked = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeColor = isUnlocked 
      ? (color ?? Theme.of(context).colorScheme.primary)
      : Theme.of(context).colorScheme.outline;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: badgeColor, width: 2),
            ),
            child: Icon(
              icon,
              color: badgeColor,
              size: 28,
            ),
          ),
          const SizedBox(height: WismeSpacing.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isUnlocked 
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Stats card widget
class WismeStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const WismeStatsCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WismeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          const SizedBox(height: WismeSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color ?? Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: WismeSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
