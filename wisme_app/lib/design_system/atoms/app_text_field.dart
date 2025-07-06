import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';

/// Ultra-flexible text input component
/// UI/UX developers: This is your main input component, highly customizable
class AppTextField extends StatefulWidget {
  // === CONTENT ===
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;

  // === BEHAVIOR ===
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;

  // === VALIDATION ===
  final String? Function(String?)? validator;
  final bool isRequired;
  final String? requiredMessage;

  // === CALLBACKS ===
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final FocusNode? focusNode;

  // === STYLING ===
  final AppTextFieldVariant variant;
  final AppTextFieldSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsets? contentPadding;
  final InputBorder? border;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.validator,
    this.isRequired = false,
    this.requiredMessage,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.focusNode,
    this.variant = AppTextFieldVariant.outlined,
    this.size = AppTextFieldSize.medium,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding,
    this.border,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      _errorText = widget.errorText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          _buildLabel(context, theme),
          const SizedBox(height: 8),
        ],
        _buildTextField(context, theme),
        if (widget.helperText != null || _errorText != null) ...[
          const SizedBox(height: 4),
          _buildHelperText(context, theme),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context, ThemeData theme) {
    return RichText(
      text: TextSpan(
        text: widget.labelText,
        style: widget.labelStyle ?? theme.inputDecorationTheme.labelStyle ??
            theme.textTheme.bodyMedium,
        children: [
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, ThemeData theme) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: _obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      style: widget.textStyle ?? _getTextStyle(theme),
      validator: _buildValidator(),
      onChanged: (value) {
        if (_errorText != null) {
          setState(() {
            _errorText = null;
          });
        }
        widget.onChanged?.call(value);
      },
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      decoration: _buildInputDecoration(context, theme),
    );
  }

  Widget _buildHelperText(BuildContext context, ThemeData theme) {
    final text = _errorText ?? widget.helperText;
    final isError = _errorText != null;
    
    return Text(
      text!,
      style: widget.errorStyle ??
          theme.textTheme.bodySmall?.copyWith(
            color: isError 
                ? theme.colorScheme.error 
                : theme.colorScheme.onSurfaceVariant,
          ),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, ThemeData theme) {
    return InputDecoration(
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      contentPadding: widget.contentPadding ?? _getContentPadding(),
      filled: widget.variant == AppTextFieldVariant.filled,
      fillColor: widget.fillColor ?? _getFillColor(theme),
      border: widget.border ?? _getBorder(theme),
      enabledBorder: _getBorder(theme),
      focusedBorder: _getBorder(theme, focused: true),
      errorBorder: _getBorder(theme, error: true),
      focusedErrorBorder: _getBorder(theme, error: true, focused: true),
      errorText: _errorText,
      hintStyle: widget.hintStyle ?? theme.inputDecorationTheme.hintStyle,
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

  String? Function(String?)? _buildValidator() {
    if (widget.validator == null && !widget.isRequired) return null;
    
    return (value) {
      // Check required validation first
      if (widget.isRequired && (value == null || value.trim().isEmpty)) {
        return widget.requiredMessage ?? 'This field is required';
      }
      
      // Run custom validator
      return widget.validator?.call(value);
    };
  }

  TextStyle _getTextStyle(ThemeData theme) {
    switch (widget.size) {
      case AppTextFieldSize.small:
        return theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12);
      case AppTextFieldSize.medium:
        return theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
      case AppTextFieldSize.large:
        return theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    }
  }

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case AppTextFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppTextFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppTextFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  Color _getFillColor(ThemeData theme) {
    if (widget.variant == AppTextFieldVariant.filled) {
      return theme.colorScheme.surfaceContainerHighest;
    }
    return Colors.transparent;
  }

  InputBorder _getBorder(ThemeData theme, {bool focused = false, bool error = false}) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);
    
    Color borderColor;
    double borderWidth = 1;
    
    if (error) {
      borderColor = widget.errorBorderColor ?? theme.colorScheme.error;
      borderWidth = focused ? 2 : 1;
    } else if (focused) {
      borderColor = widget.focusedBorderColor ?? theme.colorScheme.primary;
      borderWidth = 2;
    } else {
      borderColor = widget.borderColor ?? theme.colorScheme.outline;
    }

    switch (widget.variant) {
      case AppTextFieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        );
      case AppTextFieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        );
      case AppTextFieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        );
    }
  }
}

/// Text field variant types
enum AppTextFieldVariant {
  outlined,
  underlined,
  filled,
}

/// Text field size types
enum AppTextFieldSize {
  small,
  medium,
  large,
}

/// Specialized text field variants

/// Search input field
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
      suffixIcon: _buildClearButton(),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
    );
  }

  Widget? _buildClearButton() {
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
  final bool isRequired;

  const AppPasswordField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.showStrengthIndicator = false,
    this.isRequired = false,
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
          isRequired: widget.isRequired,
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
          const SizedBox(height: 8),
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
        const SizedBox(height: 4),
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

