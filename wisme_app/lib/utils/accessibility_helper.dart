import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for inclusive design
class AccessibilityHelper {
  AccessibilityHelper._();

  /// Semantic wrapper for better screen reader support
  static Widget semantic({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? link,
    bool? enabled,
    bool? selected,
    bool? checked,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    String? increasedValue,
    String? decreasedValue,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      link: link,
      enabled: enabled,
      selected: selected,
      checked: checked,
      onTap: onTap,
      onLongPress: onLongPress,
      increasedValue: increasedValue,
      decreasedValue: decreasedValue,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  /// Announce text to screen reader
  static void announce(String message, [TextDirection? textDirection]) {
    SemanticsService.announce(message, textDirection ?? TextDirection.ltr);
  }

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    String? semanticLabel,
    String? tooltip,
    bool enabled = true,
  }) {
    Widget button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: child,
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return semantic(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? onPressed : null,
      child: button,
    );
  }

  /// Create accessible icon button
  static Widget accessibleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? tooltip,
    bool enabled = true,
    Color? color,
    double? size,
  }) {
    Widget button = IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip ?? semanticLabel,
    );

    return semantic(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? onPressed : null,
      child: button,
    );
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required TextEditingController controller,
    String? label,
    String? hint,
    String? semanticLabel,
    bool obscureText = false,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    VoidCallback? onTap,
  }) {
    return semantic(
      label: semanticLabel ?? label,
      hint: hint,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  /// Create accessible card
  static Widget accessibleCard({
    required Widget child,
    String? semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    bool button = false,
  }) {
    Widget card = Card(child: child);

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        child: card,
      );
    }

    return semantic(
      label: semanticLabel,
      hint: semanticHint,
      button: button || onTap != null,
      onTap: onTap,
      child: card,
    );
  }

  /// Create accessible list item
  static Widget accessibleListItem({
    required Widget child,
    String? semanticLabel,
    String? semanticValue,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    Widget item = ListTile(
      title: child,
      onTap: onTap,
      selected: selected,
    );

    return semantic(
      label: semanticLabel,
      value: semanticValue,
      button: onTap != null,
      selected: selected,
      onTap: onTap,
      child: item,
    );
  }

  /// Create accessible progress indicator
  static Widget accessibleProgress({
    required double value,
    String? semanticLabel,
    String? semanticValue,
    Color? color,
    Color? backgroundColor,
  }) {
    final percentage = (value * 100).round();
    final defaultLabel = semanticLabel ?? 'Progress';
    final defaultValue = semanticValue ?? '$percentage percent complete';

    return semantic(
      label: defaultLabel,
      value: defaultValue,
      child: LinearProgressIndicator(
        value: value,
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Create accessible slider
  static Widget accessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String? label,
    String? semanticLabel,
  }) {
    return semantic(
      label: semanticLabel ?? label ?? 'Slider',
      value: value.toString(),
      increasedValue: 'Increase',
      decreasedValue: 'Decrease',
      onIncrease: () => onChanged((value + 0.1).clamp(min, max)),
      onDecrease: () => onChanged((value - 0.1).clamp(min, max)),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
      ),
    );
  }

  /// Create accessible switch
  static Widget accessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? label,
    String? semanticLabel,
    bool enabled = true,
  }) {
    final switchWidget = Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
    );

    Widget result = switchWidget;

    if (label != null) {
      result = Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          switchWidget,
        ],
      );
    }

    return semantic(
      label: semanticLabel ?? label ?? 'Switch',
      value: value ? 'On' : 'Off',
      button: true,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      child: result,
    );
  }

  /// Create accessible checkbox
  static Widget accessibleCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    String? label,
    String? semanticLabel,
    bool enabled = true,
  }) {
    final checkbox = Checkbox(
      value: value,
      onChanged: enabled ? onChanged : null,
    );

    Widget result = checkbox;

    if (label != null) {
      result = Row(
        children: [
          checkbox,
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
        ],
      );
    }

    return semantic(
      label: semanticLabel ?? label ?? 'Checkbox',
      checked: value,
      button: true,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      child: result,
    );
  }

  /// Create accessible radio button
  static Widget accessibleRadio<T>({
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    String? label,
    String? semanticLabel,
    bool enabled = true,
  }) {
    final isSelected = value == groupValue;
    final radio = Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: enabled ? onChanged : null,
    );

    Widget result = radio;

    if (label != null) {
      result = Row(
        children: [
          radio,
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
        ],
      );
    }

    return semantic(
      label: semanticLabel ?? label ?? 'Radio button',
      selected: isSelected,
      button: true,
      enabled: enabled,
      onTap: enabled ? () => onChanged(value) : null,
      child: result,
    );
  }

  /// Create accessible header
  static Widget accessibleHeader({
    required String text,
    TextStyle? style,
    int level = 1,
  }) {
    return semantic(
      header: true,
      label: 'Heading level $level: $text',
      child: Text(
        text,
        style: style,
      ),
    );
  }

  /// Create live region for dynamic content announcements
  static Widget liveRegion({
    required Widget child,
    LiveRegionPoliteLevel politeLevel = LiveRegionPoliteLevel.polite,
  }) {
    return Semantics(
      liveRegion: true,
      child: child,
    );
  }

  /// Focus helper
  static void focusNode(FocusNode node) {
    node.requestFocus();
  }

  /// Check if screen reader is enabled
  static bool get isScreenReaderEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.accessibleNavigation;
  }

  /// Check if high contrast is enabled
  static bool get isHighContrastEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.highContrast;
  }

  /// Check if reduce animations is enabled
  static bool get isReduceAnimationsEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
  }
}

/// Politeness levels for live regions
enum LiveRegionPoliteLevel {
  polite,
  assertive,
}

