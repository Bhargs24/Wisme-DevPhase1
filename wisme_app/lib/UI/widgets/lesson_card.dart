import '../../core/exports.dart';
class LessonCard extends StatelessWidget {
  final ContentBlock lesson;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onMorePressed;
  final bool showPlayButton;
  final bool showFavoriteButton;
  final bool showMoreButton;
  final bool isCompact;
  final bool showProgress;
  final double? progressValue;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
    this.onLongPress,
    this.onPlayPressed,
    this.onFavoritePressed,
    this.onMorePressed,
    this.showPlayButton = true,
    this.showFavoriteButton = false,
    this.showMoreButton = false,
    this.isCompact = false,
    this.showProgress = false,
    this.progressValue,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: isCompact ? _buildCompactLayout(context) : _buildFullLayout(context),
        ),
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        _buildContent(context),
        if (showProgress && progressValue != null) ...[
          const SizedBox(height: 8),
          _buildProgressBar(context),
        ],
        const SizedBox(height: 8),
        _buildFooter(context),
        if (lesson.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTags(context),
        ],
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildDurationChip(context),
        if (showPlayButton && onPlayPressed != null) ...[
          const SizedBox(width: 8),
          _buildPlayButton(),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            lesson.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildDurationChip(context),
        if (showMoreButton && onMorePressed != null) ...[
          const SizedBox(width: 8),
          _buildMoreButton(),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      lesson.title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(progressValue! * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: AppColors.disabled,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.topic,
          size: AppSizing.iconXS,
          color: AppColors.textSecondary,
        ),
        AppSpacing.horizontalSpaceXS,
        Text(
          lesson.title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        AppSpacing.horizontalSpaceM,
        Icon(
          Icons.record_voice_over,
          size: AppSizing.iconXS,
          color: AppColors.textSecondary,
        ),
        AppSpacing.horizontalSpaceXS,
        Text(
          _getVoiceDisplayName('default'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        if (lesson.playCount > 0) ...[
          Icon(
            Icons.play_circle_outline,
            size: AppSizing.iconXS,
            color: AppColors.textSecondary,
          ),
          AppSpacing.horizontalSpaceXS,
          Text(
            '${lesson.playCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          AppSpacing.horizontalSpaceS,
        ],
        if (showPlayButton && onPlayPressed != null) _buildPlayButton(),
        if (showFavoriteButton && onFavoritePressed != null) ...[
          AppSpacing.horizontalSpaceS,
          _buildFavoriteButton(),
        ],
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.xs,
      children: lesson.tags.take(3).map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs / 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizing.radiusM),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: Text(
            '#$tag',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationChip(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizing.radiusS),
      ),
      child: Text(
        "${lesson.duration.inMinutes} min",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPlayPressed,
        icon: const Icon(Icons.play_arrow),
        iconSize: 18,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      onPressed: onFavoritePressed,
      icon: const Icon(Icons.favorite_border),
      iconSize: 20,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildMoreButton() {
    return IconButton(
      onPressed: onMorePressed,
      icon: const Icon(Icons.more_vert),
      iconSize: 20,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
      ),
    );
  }

  String _getVoiceDisplayName(String voiceId) {
    // Map voice IDs to display names
    final voiceNames = {
      'zen_coach': 'Zen',
      'startup_buddy': 'Startup',
      'science_guide': 'Science',
      'default': 'Default',
      'motivational': 'Motivational',
      'storyteller': 'Story',
    };
    return voiceNames[voiceId] ?? voiceId;
  }
}

