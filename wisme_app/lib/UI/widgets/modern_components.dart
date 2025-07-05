import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ModernButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
