import '../../core/exports.dart';
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

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
  final Color? backgroundColor;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: backgroundColor,
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
  final double? width;
  final IconData? icon;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
      ),
    );
  }
}


