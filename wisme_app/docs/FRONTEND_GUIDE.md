# 🎨 Wisme Frontend Guide

*Complete guide to Flutter UI development, design patterns, and best practices for the Wisme platform*

---

## 🎯 Frontend Architecture Overview

### 🏗️ UI Architecture Principles

- **🎨 Design System First**: Consistent, reusable components with centralized theming
- **📱 Mobile-First**: Optimized for mobile with responsive web and desktop support
- **♿ Accessibility Built-In**: WCAG compliant with screen reader and keyboard support
- **⚡ Performance Optimized**: Efficient rendering and smooth animations
- **🧱 Component-Driven**: Atomic design with maximum reusability
- **🔄 State Management**: Clean separation of UI and business logic

### 📊 Frontend Stack

```
┌─────────────────────────────────────────────────┐
│                Flutter UI Layer                 │
├─────────────────────────────────────────────────┤
│  Screens  │  Widgets  │  Components │  Themes   │
├─────────────────────────────────────────────────┤
│           State Management (Provider)           │
├─────────────────────────────────────────────────┤
│    Navigation │   Animations │   Gestures       │
├─────────────────────────────────────────────────┤
│              Platform Channels                  │
└─────────────────────────────────────────────────┘
```

---

## 📁 UI Directory Structure

```
lib/UI/
├── 🖥️ screens/                    # Full-screen views
│   ├── onboarding/               # App introduction flow
│   │   ├── welcome_screen.dart
│   │   ├── feature_showcase_screen.dart
│   │   ├── knowledge_selection_screen.dart
│   │   ├── coach_selection_screen.dart
│   │   └── journey_planning_screen.dart
│   ├── auth/                     # Authentication screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── verify_email_screen.dart
│   ├── dashboard/                # Main app screens
│   │   ├── home_screen.dart
│   │   ├── learning_dashboard.dart
│   │   ├── progress_screen.dart
│   │   └── recommendations_screen.dart
│   ├── lessons/                  # Learning content screens
│   │   ├── lesson_list_screen.dart
│   │   ├── lesson_detail_screen.dart
│   │   ├── audio_player_screen.dart
│   │   └── quiz_screen.dart
│   ├── profile/                  # User profile screens
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── achievements_screen.dart
│   │   └── learning_stats_screen.dart
│   ├── social/                   # Social features
│   │   ├── leaderboard_screen.dart
│   │   ├── friends_screen.dart
│   │   └── challenges_screen.dart
│   ├── content/                  # Content management
│   │   ├── library_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── downloads_screen.dart
│   │   └── search_screen.dart
│   └── settings/                 # App configuration
│       ├── settings_screen.dart
│       ├── privacy_screen.dart
│       ├── audio_settings_screen.dart
│       └── advanced_settings_screen.dart
├── 🧱 widgets/                    # Reusable UI components
│   ├── common/                   # Generic widgets
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   ├── forms/
│   │   ├── loading/
│   │   └── navigation/
│   ├── audio/                    # Audio-specific widgets
│   │   ├── audio_player_widget.dart
│   │   ├── waveform_widget.dart
│   │   ├── playback_controls.dart
│   │   └── audio_visualizer.dart
│   ├── learning/                 # Learning-specific widgets
│   │   ├── lesson_card.dart
│   │   ├── progress_indicator.dart
│   │   ├── quiz_widget.dart
│   │   └── achievement_badge.dart
│   ├── coach/                    # AI coach widgets
│   │   ├── coach_avatar.dart
│   │   ├── coach_message.dart
│   │   └── personality_selector.dart
│   └── social/                   # Social widgets
│       ├── leaderboard_item.dart
│       ├── friend_tile.dart
│       └── challenge_card.dart
└── 🎨 themes/                     # Theming and styling
    ├── app_theme.dart            # Main theme configuration
    ├── light_theme.dart          # Light mode theme
    ├── dark_theme.dart           # Dark mode theme
    ├── color_schemes.dart        # Color system
    ├── typography.dart           # Text styles
    └── component_themes.dart     # Component-specific themes
```

---

## 🎨 Design System Implementation

### 🎯 Color System

```dart
// lib/constants/app_colors.dart
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6366F1);           // Indigo
  static const Color primaryVariant = Color(0xFF4F46E5);     // Indigo Dark
  static const Color secondary = Color(0xFF06B6D4);          // Cyan
  static const Color secondaryVariant = Color(0xFF0891B2);   // Cyan Dark
  
  // Accent Colors
  static const Color accent = Color(0xFFF59E0B);             // Amber
  static const Color success = Color(0xFF10B981);            // Emerald
  static const Color warning = Color(0xFFF59E0B);            // Amber
  static const Color error = Color(0xFFEF4444);              // Red
  static const Color info = Color(0xFF3B82F6);               // Blue
  
  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);         // Light Gray
  static const Color surface = Color(0xFFFFFFFF);            // White
  static const Color surfaceVariant = Color(0xFFF5F5F5);     // Very Light Gray
  
  // Text Colors
  static const Color onPrimary = Color(0xFFFFFFFF);          // White
  static const Color onSecondary = Color(0xFFFFFFFF);        // White
  static const Color onBackground = Color(0xFF1F2937);       // Dark Gray
  static const Color onSurface = Color(0xFF374151);          // Medium Gray
  static const Color onSurfaceVariant = Color(0xFF6B7280);   // Light Gray
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF111827);     // Very Dark Gray
  static const Color surfaceDark = Color(0xFF1F2937);        // Dark Gray
  static const Color onBackgroundDark = Color(0xFFF9FAFB);   // Very Light Gray
  static const Color onSurfaceDark = Color(0xFFE5E7EB);      // Light Gray
  
  // Semantic Colors
  static const Color lessonComplete = Color(0xFF10B981);     // Green
  static const Color lessonInProgress = Color(0xFF3B82F6);   // Blue
  static const Color lessonLocked = Color(0xFF9CA3AF);       // Gray
  
  // Audio Player Colors
  static const Color audioProgress = Color(0xFF6366F1);      // Indigo
  static const Color audioBackground = Color(0xFFF3F4F6);    // Light Gray
  static const Color waveformActive = Color(0xFF6366F1);     // Indigo
  static const Color waveformInactive = Color(0xFFD1D5DB);   // Gray
}
```

### 📝 Typography System

```dart
// lib/constants/app_text_styles.dart
class AppTextStyles {
  // Font Family
  static const String primaryFont = 'Inter';
  static const String secondaryFont = 'Roboto';
  
  // Display Styles (Large Text)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  
  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  // Special Styles
  static const TextStyle buttonText = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.25,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: primaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
  );
}
```

### 📏 Spacing System

```dart
// lib/constants/app_spacing.dart
class AppSpacing {
  // Base spacing unit (8dp)
  static const double base = 8.0;
  
  // Spacing Scale
  static const double xs = base * 0.5;    // 4dp
  static const double sm = base;          // 8dp
  static const double md = base * 2;      // 16dp
  static const double lg = base * 3;      // 24dp
  static const double xl = base * 4;      // 32dp
  static const double xxl = base * 6;     // 48dp
  static const double xxxl = base * 8;    // 64dp
  
  // Semantic Spacing
  static const double elementPadding = md;
  static const double screenPadding = lg;
  static const double sectionSpacing = xl;
  static const double componentSpacing = md;
  
  // Layout Spacing
  static const double cardPadding = md;
  static const double listItemPadding = md;
  static const double buttonPadding = md;
  static const double inputPadding = md;
}
```

---

## 🧱 Component Development

### 🎯 Atomic Design Principles

**Atoms** - Basic building blocks:
```dart
// lib/UI/widgets/common/buttons/wisme_button.dart
class WismeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final Widget? icon;
  
  const WismeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(context),
        child: isLoading
            ? _buildLoadingIndicator()
            : _buildButtonContent(),
      ),
    );
  }
  
  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        );
      case ButtonType.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: _getPadding(),
        );
    }
  }
  
  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }
  
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          type == ButtonType.primary ? AppColors.onPrimary : AppColors.primary,
        ),
      ),
    );
  }
  
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.buttonText),
        ],
      );
    }
    return Text(text, style: AppTextStyles.buttonText);
  }
}

enum ButtonType { primary, secondary, text }
enum ButtonSize { small, medium, large }
```

**Molecules** - Combinations of atoms:
```dart
// lib/UI/widgets/learning/lesson_card.dart
class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;
  final bool showProgress;
  
  const LessonCard({
    super.key,
    required this.lesson,
    this.onTap,
    this.showProgress = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.sm),
              _buildContent(),
              if (showProgress) ...[
                const SizedBox(height: AppSpacing.md),
                _buildProgressIndicator(),
              ],
              const SizedBox(height: AppSpacing.sm),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        _buildLessonIcon(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: AppTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                lesson.category,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _buildDurationChip(),
      ],
    );
  }
  
  Widget _buildLessonIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getLessonStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getLessonStatusIcon(),
        color: _getLessonStatusColor(),
        size: 20,
      ),
    );
  }
  
  Widget _buildContent() {
    return Text(
      lesson.description,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '${(lesson.progress * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: lesson.progress,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDuration(lesson.duration),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.star,
              size: 14,
              color: AppColors.accent,
            ),
            const SizedBox(width: 4),
            Text(
              lesson.rating.toStringAsFixed(1),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDurationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDuration(lesson.duration),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Color _getLessonStatusColor() {
    switch (lesson.status) {
      case LessonStatus.completed:
        return AppColors.lessonComplete;
      case LessonStatus.inProgress:
        return AppColors.lessonInProgress;
      case LessonStatus.locked:
        return AppColors.lessonLocked;
      default:
        return AppColors.primary;
    }
  }
  
  IconData _getLessonStatusIcon() {
    switch (lesson.status) {
      case LessonStatus.completed:
        return Icons.check_circle;
      case LessonStatus.inProgress:
        return Icons.play_circle;
      case LessonStatus.locked:
        return Icons.lock;
      default:
        return Icons.circle;
    }
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = duration.inHours;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }
}
```

**Organisms** - Complex UI sections:
```dart
// lib/UI/widgets/audio/audio_player_widget.dart
class AudioPlayerWidget extends StatefulWidget {
  final AudioTrack track;
  final bool showPlaylist;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  
  const AudioPlayerWidget({
    super.key,
    required this.track,
    this.showPlaylist = false,
    this.onNext,
    this.onPrevious,
  });
  
  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveformController;
  late AnimationController _playButtonController;
  late AudioPlayer _audioPlayer;
  
  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _audioPlayer = AudioPlayer();
    _initializeAudio();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildTrackInfo(),
            const SizedBox(height: AppSpacing.lg),
            _buildWaveform(),
            const SizedBox(height: AppSpacing.lg),
            _buildProgressBar(),
            const SizedBox(height: AppSpacing.lg),
            _buildControls(),
            if (widget.showPlaylist) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildPlaylistSection(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrackInfo() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.track.coverImage != null
              ? Image.network(
                  widget.track.coverImage!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.music_note,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.track.title,
                style: AppTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.track.artist ?? 'Wisme AI',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // Add to favorites functionality
          },
          icon: const Icon(Icons.favorite_border),
          color: AppColors.onSurfaceVariant,
        ),
      ],
    );
  }
  
  Widget _buildWaveform() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return AnimatedBuilder(
          animation: _waveformController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 80),
              painter: WaveformPainter(
                waveformData: widget.track.waveformData,
                progress: audioProvider.position.inMilliseconds /
                    audioProvider.duration.inMilliseconds,
                isPlaying: audioProvider.isPlaying,
                animationProgress: _waveformController.value,
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildProgressBar() {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceVariant,
                thumbColor: AppColors.primary,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: audioProvider.position.inMilliseconds.toDouble(),
                min: 0,
                max: audioProvider.duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  audioProvider.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(audioProvider.position),
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    _formatDuration(audioProvider.duration),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: widget.onPrevious,
          icon: const Icon(Icons.skip_previous),
          iconSize: 32,
          color: AppColors.onSurface,
        ),
        IconButton(
          onPressed: () {
            // Rewind 15 seconds
            context.read<AudioProvider>().seekRelative(const Duration(seconds: -15));
          },
          icon: const Icon(Icons.replay_15),
          iconSize: 28,
          color: AppColors.onSurfaceVariant,
        ),
        Consumer<AudioProvider>(
          builder: (context, audioProvider, child) {
            return AnimatedBuilder(
              animation: _playButtonController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_playButtonController.value * 0.1),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        _playButtonController.forward().then((_) {
                          _playButtonController.reverse();
                        });
                        audioProvider.togglePlayPause();
                      },
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.onPrimary,
                        size: 32,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        IconButton(
          onPressed: () {
            // Fast forward 15 seconds
            context.read<AudioProvider>().seekRelative(const Duration(seconds: 15));
          },
          icon: const Icon(Icons.forward_15),
          iconSize: 28,
          color: AppColors.onSurfaceVariant,
        ),
        IconButton(
          onPressed: widget.onNext,
          icon: const Icon(Icons.skip_next),
          iconSize: 32,
          color: AppColors.onSurface,
        ),
      ],
    );
  }
  
  // Additional widget building methods...
  
  @override
  void dispose() {
    _waveformController.dispose();
    _playButtonController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
```

---

## 📱 Screen Development Patterns

### 🏗️ Screen Architecture Template

```dart
// Template for all screens
abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});
}

abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }
  
  Future<void> _initializeScreen() async {
    setState(() => _isLoading = true);
    try {
      await initializeData();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: _buildBody(),
      floatingActionButton: buildFloatingActionButton(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return buildLoadingWidget();
    }
    
    if (_errorMessage != null) {
      return buildErrorWidget(_errorMessage!);
    }
    
    return buildContent();
  }
  
  // Abstract methods to be implemented by concrete screens
  Future<void> initializeData();
  PreferredSizeWidget? buildAppBar();
  Widget buildContent();
  Widget? buildFloatingActionButton() => null;
  Widget? buildBottomNavigationBar() => null;
  
  // Default implementations
  Widget buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Something went wrong',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          WismeButton(
            text: 'Try Again',
            onPressed: () => _initializeScreen(),
          ),
        ],
      ),
    );
  }
}
```

### 🎯 Example Screen Implementation

```dart
// lib/UI/screens/lessons/lesson_list_screen.dart
class LessonListScreen extends BaseScreen {
  const LessonListScreen({super.key});
  
  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends BaseScreenState<LessonListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Lesson> _filteredLessons = [];
  
  @override
  Future<void> initializeData() async {
    await context.read<LessonProvider>().loadLessons();
    _filteredLessons = context.read<LessonProvider>().lessons;
  }
  
  @override
  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      title: const Text('Lessons'),
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => _showFilterBottomSheet(),
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: () => _showSortBottomSheet(),
          icon: const Icon(Icons.sort),
        ),
      ],
    );
  }
  
  @override
  Widget buildContent() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilters(),
        Expanded(child: _buildLessonList()),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search lessons...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterLessons('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant,
        ),
        onChanged: _filterLessons,
      ),
    );
  }
  
  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _buildFilterChip('All', true),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Beginner', false),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Intermediate', false),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Advanced', false),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('Completed', false),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Filter logic
      },
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
      ),
    );
  }
  
  Widget _buildLessonList() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (_filteredLessons.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: () => lessonProvider.refreshLessons(),
          child: ListView.builder(
            itemCount: _filteredLessons.length,
            itemBuilder: (context, index) {
              final lesson = _filteredLessons[index];
              return LessonCard(
                lesson: lesson,
                onTap: () => _navigateToLessonDetail(lesson),
                showProgress: true,
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No lessons found',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  void _filterLessons(String query) {
    final lessonProvider = context.read<LessonProvider>();
    setState(() {
      _filteredLessons = lessonProvider.lessons
          .where((lesson) =>
              lesson.title.toLowerCase().contains(query.toLowerCase()) ||
              lesson.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  
  void _navigateToLessonDetail(Lesson lesson) {
    Navigator.of(context).pushNamed(
      '/lesson-detail',
      arguments: lesson,
    );
  }
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheet(),
    );
  }
  
  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SortBottomSheet(),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

---

## 🎭 Animation & Transitions

### ✨ Smooth Page Transitions

```dart
// lib/utils/page_transitions.dart
class SlideTransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;
  
  SlideTransitionRoute({
    required this.child,
    this.direction = SlideDirection.fromRight,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = _getBeginOffset(direction);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            
            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
  
  static Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
    }
  }
}

enum SlideDirection { fromRight, fromLeft, fromTop, fromBottom }
```

### 🌊 Fluid Animations

```dart
// lib/UI/widgets/common/animated_counter.dart
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? textStyle;
  
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 500),
    this.textStyle,
  });
  
  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.reset();
      _controller.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.toInt().toString(),
          style: widget.textStyle ?? AppTextStyles.headlineMedium,
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 📱 Responsive Design

### 📐 Breakpoint System

```dart
// lib/utils/responsive.dart
class Responsive {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
  
  static Widget responsive(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}
```

### 📱 Adaptive Layouts

```dart
// lib/UI/widgets/common/adaptive_layout.dart
class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Responsive.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Usage example
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }
  
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Mobile-specific layout
      ],
    );
  }
  
  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildSidebar()),
        Expanded(flex: 2, child: _buildMainContent()),
      ],
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(width: 280, child: _buildSidebar()),
        Expanded(child: _buildMainContent()),
        SizedBox(width: 320, child: _buildDetailsPanel()),
      ],
    );
  }
}
```

---

## ♿ Accessibility Implementation

### 🎯 Semantic Widgets

```dart
// lib/UI/widgets/common/accessible_button.dart
class AccessibleButton extends StatelessWidget {
  final String text;
  final String? semanticLabel;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Widget? icon;
  
  const AccessibleButton({
    super.key,
    required this.text,
    this.semanticLabel,
    this.tooltip,
    this.onPressed,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );
    
    // Add semantic labels
    button = Semantics(
      label: semanticLabel ?? text,
      hint: tooltip,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
    
    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}
```

### 📱 Screen Reader Support

```dart
// lib/utils/accessibility_announcer.dart
class AccessibilityAnnouncer {
  static void announce(String message, {bool assertive = false}) {
    SemanticsService.announce(
      message,
      assertive ? Assertiveness.assertive : Assertiveness.polite,
    );
  }
  
  static void announcePageChange(String pageName) {
    announce('Navigated to $pageName', assertive: true);
  }
  
  static void announceAction(String action) {
    announce(action, assertive: false);
  }
  
  static void announceError(String error) {
    announce('Error: $error', assertive: true);
  }
  
  static void announceSuccess(String message) {
    announce('Success: $message', assertive: false);
  }
}
```

---

## 🚀 Performance Optimization

### ⚡ Efficient Widget Building

```dart
// Use const constructors whenever possible
const Text('Static text');

// Avoid rebuilding expensive widgets
class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const SomeExpensiveOperation();
  }
}

// Use RepaintBoundary for complex animations
RepaintBoundary(
  child: AnimatedWidget(),
);

// Implement efficient list building
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListItem(item: items[index]);
  },
);

// Use AutomaticKeepAliveClientMixin for preserving state
class PreservedWidget extends StatefulWidget {
  @override
  _PreservedWidgetState createState() => _PreservedWidgetState();
}

class _PreservedWidgetState extends State<PreservedWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return YourWidget();
  }
}
```

### 🎨 Image Optimization

```dart
// lib/utils/image_cache_manager.dart
class ImageCacheManager {
  static const String _cacheKey = 'wisme_images';
  
  static Widget cachedImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      cacheManager: _getCacheManager(),
    );
  }
  
  static CacheManager _getCacheManager() {
    return CacheManager(
      Config(
        _cacheKey,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200,
      ),
    );
  }
  
  static Widget _defaultPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  static Widget _defaultErrorWidget() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.error_outline,
        color: AppColors.error,
      ),
    );
  }
}
```

This comprehensive frontend guide provides all the tools and patterns needed to build beautiful, accessible, and performant Flutter applications for the Wisme platform. Follow these guidelines to ensure consistent UI/UX and maintainable code.
