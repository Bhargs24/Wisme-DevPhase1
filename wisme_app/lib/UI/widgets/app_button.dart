import '../../core/exports.dart';
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final EdgeInsets? customPadding;
  final BorderRadius? customBorderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onLongPress,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.customColor,
    this.customPadding,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildElevatedButton(context);
      case ButtonVariant.secondary:
        return _buildOutlinedButton(context);
      case ButtonVariant.ghost:
        return _buildTextButton(context);
      case ButtonVariant.danger:
        return _buildDangerButton(context);
    }
  }

  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: customColor ?? AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? 
            BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
        elevation: AppDimensions.buttonElevation,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: OutlinedButton.styleFrom(
        foregroundColor: customColor ?? AppColors.primary,
        side: BorderSide(color: customColor ?? AppColors.primary),
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? 
            BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: TextButton.styleFrom(
        foregroundColor: customColor ?? AppColors.primary,
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? 
            BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildDangerButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      onLongPress: onLongPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.textOnPrimary,
        padding: customPadding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: customBorderRadius ?? 
            BorderRadius.circular(AppDimensions.buttonBorderRadius),
        ),
        elevation: AppDimensions.buttonElevation,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppDimensions.spaceS),
          Text(text, style: _getTextStyle(context)),
        ],
      );
    }

    return Text(text, style: _getTextStyle(context));
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return AppDimensions.buttonHeight;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceM,
          vertical: AppDimensions.spaceS,
        );
      case ButtonSize.medium:
        return AppDimensions.buttonPadding;
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceXL,
          vertical: AppDimensions.spaceM,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.iconS;
      case ButtonSize.medium:
        return AppDimensions.iconM;
      case ButtonSize.large:
        return AppDimensions.iconL;
    }
  }

  TextStyle? _getTextStyle(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.medium:
        return Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.large:
        return Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }
}

enum ButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

