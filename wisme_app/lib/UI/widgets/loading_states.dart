import '../../core/exports.dart';
class LoadingStates {
  LoadingStates._();

  /// Default circular loading indicator
  static Widget circular({
    Color? color,
    double? size,
    double? strokeWidth,
  }) {
    return Center(
      child: SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primary,
          strokeWidth: strokeWidth ?? 3.0,
        ),
      ),
    );
  }

  /// Loading with text message
  static Widget withMessage({
    required String message,
    Color? color,
    double? size,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 32,
            height: size ?? 32,
            child: CircularProgressIndicator(
              color: color ?? AppColors.primary,
              strokeWidth: 3.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Skeleton loading for cards
  static Widget skeleton({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const _ShimmerEffect(),
    );
  }

  /// List skeleton loading
  static Widget listSkeleton({
    int itemCount = 3,
    double? itemHeight,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: skeleton(height: itemHeight ?? 80),
      ),
    );
  }

  /// Card skeleton with title and subtitle
  static Widget cardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          skeleton(height: 20, width: 200),
          const SizedBox(height: 8),
          skeleton(height: 16, width: 150),
          const SizedBox(height: 12),
          skeleton(height: 40),
        ],
      ),
    );
  }

  /// Page loading with custom message
  static Widget page({
    String? message,
    IconData? icon,
  }) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 48,
                  color: AppColors.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 24),
              ],
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message ?? 'Loading...',
                style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Overlay loading (for showing over existing content)
  static Widget overlay({
    String? message,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3.0),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: AppTextStyles.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer effect for skeleton loading
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
                1.0,
              ],
              colors: [
                Colors.grey[300]!,
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}

