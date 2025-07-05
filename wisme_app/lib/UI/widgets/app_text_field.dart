import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// Highly customizable input field component
/// Supports various input types, validation, and styling options
class AppTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsets? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final bool autofocus;
  final List<String>? autofillHints;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding,
    this.border,
    this.fillColor,
    this.autofocus = false,
    this.autofillHints,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initialValue,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: _obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        contentPadding: widget.contentPadding ?? AppDimensions.inputPadding,
        filled: true,
        fillColor: widget.fillColor ?? AppColors.surface,
        border: widget.border ?? _getDefaultBorder(),
        enabledBorder: _getDefaultBorder(),
        focusedBorder: _getDefaultBorder(focused: true),
        errorBorder: _getDefaultBorder(error: true),
        focusedErrorBorder: _getDefaultBorder(error: true, focused: true),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  OutlineInputBorder _getDefaultBorder({bool focused = false, bool error = false}) {
    Color borderColor = AppColors.border;
    double borderWidth = 1.0;

    if (error) {
      borderColor = AppColors.error;
      borderWidth = focused ? 2.0 : 1.0;
    } else if (focused) {
      borderColor = AppColors.primary;
      borderWidth = 2.0;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }
}

/// Search input field with built-in search functionality
class AppSearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppSearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: hintText ?? 'Search...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _buildSuffixIcon(),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
    );
  }

  Widget? _buildSuffixIcon() {
    if (controller?.text.isNotEmpty == true) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller?.clear();
          onClear?.call();
        },
      );
    }
    return null;
  }
}

/// Password input field with strength indicator
class AppPasswordField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showStrengthIndicator;

  const AppPasswordField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.showStrengthIndicator = false,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  PasswordStrength _strength = PasswordStrength.weak;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          labelText: widget.labelText ?? 'Password',
          hintText: widget.hintText,
          controller: widget.controller,
          obscureText: true,
          validator: widget.validator,
          onChanged: (value) {
            if (widget.showStrengthIndicator) {
              setState(() {
                _strength = _calculatePasswordStrength(value);
              });
            }
            widget.onChanged?.call(value);
          },
        ),
        if (widget.showStrengthIndicator) ...[
          const SizedBox(height: AppDimensions.spaceS),
          _buildStrengthIndicator(),
        ],
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildStrengthBar(0)),
            const SizedBox(width: 4),
            Expanded(child: _buildStrengthBar(1)),
            const SizedBox(width: 4),
            Expanded(child: _buildStrengthBar(2)),
            const SizedBox(width: 4),
            Expanded(child: _buildStrengthBar(3)),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        Text(
          _getStrengthText(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _getStrengthColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthBar(int index) {
    final isActive = index < _strength.index + 1;
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? _getStrengthColor() : AppColors.disabled,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.fair;
    
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int score = 0;
    if (hasUpper) score++;
    if (hasLower) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;
    
    if (password.length >= 12 && score >= 3) return PasswordStrength.strong;
    if (password.length >= 10 && score >= 2) return PasswordStrength.good;
    if (score >= 2) return PasswordStrength.fair;
    
    return PasswordStrength.weak;
  }

  Color _getStrengthColor() {
    switch (_strength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.fair:
        return AppColors.warning;
      case PasswordStrength.good:
        return AppColors.info;
      case PasswordStrength.strong:
        return AppColors.success;
    }
  }

  String _getStrengthText() {
    switch (_strength) {
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.fair:
        return 'Fair password';
      case PasswordStrength.good:
        return 'Good password';
      case PasswordStrength.strong:
        return 'Strong password';
    }
  }
}

enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
}
