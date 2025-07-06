import '../../core/exports.dart';
class MicroInteractions {
  MicroInteractions._();

  /// Bouncy button animation
  static Widget bouncyButton({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _BouncyButton(
      onTap: onTap,
      scale: scale,
      duration: duration,
      child: child,
    );
  }

  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
  }) {
    return _FadeInAnimation(
      duration: duration,
      delay: delay,
      curve: curve,
      child: child,
    );
  }

  /// Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    double distance = 50.0,
  }) {
    return _SlideInAnimation(
      duration: duration,
      delay: delay,
      distance: distance,
      direction: _SlideDirection.bottom,
      child: child,
    );
  }

  /// Slide in from left animation
  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    double distance = 50.0,
  }) {
    return _SlideInAnimation(
      duration: duration,
      delay: delay,
      distance: distance,
      direction: _SlideDirection.left,
      child: child,
    );
  }

  /// Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
    double initialScale = 0.0,
    Curve curve = Curves.elasticOut,
  }) {
    return _ScaleInAnimation(
      duration: duration,
      delay: delay,
      initialScale: initialScale,
      curve: curve,
      child: child,
    );
  }

  /// Staggered list animation
  static Widget staggeredList({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _StaggeredAnimation(
      index: index,
      delay: delay,
      child: child,
    );
  }

  /// Haptic feedback helper
  static void hapticFeedback([HapticFeedbackType type = HapticFeedbackType.lightImpact]) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
    }
  }
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

/// Bouncy button implementation
class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  const _BouncyButton({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.duration,
  });

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        MicroInteractions.hapticFeedback(HapticFeedbackType.lightImpact);
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Fade in animation implementation
class _FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const _FadeInAnimation({
    required this.child,
    required this.duration,
    required this.delay,
    required this.curve,
  });

  @override
  State<_FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<_FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

enum _SlideDirection { left, right, top, bottom }

/// Slide in animation implementation
class _SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double distance;
  final _SlideDirection direction;

  const _SlideInAnimation({
    required this.child,
    required this.duration,
    required this.delay,
    required this.distance,
    required this.direction,
  });

  @override
  State<_SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<_SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Offset begin;
    switch (widget.direction) {
      case _SlideDirection.left:
        begin = Offset(-widget.distance / 100, 0);
        break;
      case _SlideDirection.right:
        begin = Offset(widget.distance / 100, 0);
        break;
      case _SlideDirection.top:
        begin = Offset(0, -widget.distance / 100);
        break;
      case _SlideDirection.bottom:
        begin = Offset(0, widget.distance / 100);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

/// Scale in animation implementation
class _ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double initialScale;
  final Curve curve;

  const _ScaleInAnimation({
    required this.child,
    required this.duration,
    required this.delay,
    required this.initialScale,
    required this.curve,
  });

  @override
  State<_ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<_ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Staggered animation implementation
class _StaggeredAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const _StaggeredAnimation({
    required this.child,
    required this.index,
    required this.delay,
  });

  @override
  State<_StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<_StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}


