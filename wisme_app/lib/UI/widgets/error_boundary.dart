import '../../core/exports.dart';
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Creates an error display widget
  static Widget createErrorWidget({
    required String title,
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onRetry != null) ...[
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                if (onGoHome != null) const SizedBox(width: 16),
              ],
              if (onGoHome != null)
                OutlinedButton.icon(
                  onPressed: onGoHome,
                  icon: const Icon(Icons.home),
                  label: const Text('Go Home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Network error display
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkError({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary.createErrorWidget(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// Generic error display
class GenericError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const GenericError({
    super.key,
    this.message,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary.createErrorWidget(
      title: 'Something Went Wrong',
      message: message ?? 'An unexpected error occurred. Please try again.',
      onRetry: onRetry,
      onGoHome: onGoHome,
    );
  }
}

/// Loading error display
class LoadingError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const LoadingError({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary.createErrorWidget(
      title: 'Failed to Load',
      message: message ?? 'Unable to load content. Please try again.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }
}

/// Not found error display
class NotFoundError extends StatelessWidget {
  final String? message;
  final VoidCallback? onGoHome;

  const NotFoundError({super.key, this.message, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary.createErrorWidget(
      title: 'Content Not Found',
      message: message ?? 'The content you\'re looking for could not be found.',
      icon: Icons.search_off,
      onGoHome: onGoHome,
    );
  }
}


