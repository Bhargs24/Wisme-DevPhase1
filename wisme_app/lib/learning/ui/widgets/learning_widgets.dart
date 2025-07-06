import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';

/// Lesson card widget
class WismeLessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final String duration;
  final bool isRecommended;
  final VoidCallback? onTap;

  const WismeLessonCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.duration,
    this.isRecommended = false,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isRecommended) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: WismeSpacing.sm,
                          vertical: WismeSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(WismeRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: WismeSpacing.xs),
                            Text(
                              'Recommended',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: WismeSpacing.sm),
                    ],
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: WismeSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: WismeSpacing.xs),
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: WismeSpacing.md),
          WismeProgressIndicator(
            progress: progress,
            showPercentage: false,
          ),
        ],
      ),
    );
  }
}

/// Learning path card widget
class WismeLearningPathCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final int lessonsCount;
  final int completedLessons;
  final VoidCallback? onTap;

  const WismeLearningPathCard({
    Key? key,
    required this.title,
    required this.description,
    required this.progress,
    required this.lessonsCount,
    required this.completedLessons,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: WismeSpacing.xs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: WismeSpacing.md),
          
          // Progress stats
          Row(
            children: [
              Text(
                '$completedLessons of $lessonsCount lessons',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}% complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
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

/// Quick actions grid
class WismeQuickActionsGrid extends StatelessWidget {
  const WismeQuickActionsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: WismeSpacing.sm,
      crossAxisSpacing: WismeSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        WismeQuickActionCard(
          title: 'Practice Quiz',
          icon: Icons.quiz,
          color: Colors.blue,
          onTap: () {},
        ),
        WismeQuickActionCard(
          title: 'Flashcards',
          icon: Icons.style,
          color: Colors.purple,
          onTap: () {},
        ),
        WismeQuickActionCard(
          title: 'Audio Review',
          icon: Icons.headphones,
          color: Colors.orange,
          onTap: () {},
        ),
        WismeQuickActionCard(
          title: 'Progress Report',
          icon: Icons.analytics,
          color: Colors.green,
          onTap: () {},
        ),
      ],
    );
  }
}

/// Quick action card
class WismeQuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const WismeQuickActionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WismeCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(WismeRadius.md),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: WismeSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Lesson stat widget
class WismeLessonStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const WismeLessonStat({
    Key? key,
    required this.icon,
    required this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: statColor,
        ),
        const SizedBox(width: WismeSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: statColor,
          ),
        ),
      ],
    );
  }
}

/// Quiz option widget
class WismeQuizOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const WismeQuizOption({
    Key? key,
    required this.text,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(WismeSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(WismeRadius.md),
          color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : null,
              ),
              child: isSelected 
                ? Icon(
                    Icons.check,
                    size: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : null,
            ),
            const SizedBox(width: WismeSpacing.md),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quiz stat widget
class WismeQuizStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const WismeQuizStat({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(WismeRadius.lg),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: WismeSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
