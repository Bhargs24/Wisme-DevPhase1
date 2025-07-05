import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Avatar widget with fallback initials
class WismeAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;

  const WismeAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
        ? Text(
            _getInitials(name),
            style: TextStyle(
              fontSize: radius * 0.7,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Badge widget for notifications
class WismeBadge extends StatelessWidget {
  final Widget child;
  final String? count;
  final bool showBadge;
  final Color? backgroundColor;

  const WismeBadge({
    Key? key,
    required this.child,
    this.count,
    this.showBadge = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showBadge) return child;

    return Badge(
      label: count != null ? Text(count!) : null,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.error,
      child: child,
    );
  }
}

/// Tag/chip widget
class WismeTag extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;

  const WismeTag({
    Key? key,
    required this.label,
    this.onTap,
    this.onDelete,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      onDeleted: onDelete,
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WismeRadius.full),
      ),
    );
  }
}

/// Rating stars widget
class WismeRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final ValueChanged<double>? onRatingUpdate;
  final bool allowHalfRating;

  const WismeRating({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24,
    this.onRatingUpdate,
    this.allowHalfRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return GestureDetector(
          onTap: onRatingUpdate != null
            ? () => onRatingUpdate!(index + 1.0)
            : null,
          child: Icon(
            _getStarIcon(index + 1),
            size: size,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int position) {
    if (rating >= position) {
      return Icons.star;
    } else if (allowHalfRating && rating >= position - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }
}

/// Expandable content widget
class WismeExpandable extends StatefulWidget {
  final Widget header;
  final Widget content;
  final bool initiallyExpanded;
  final Duration animationDuration;

  const WismeExpandable({
    Key? key,
    required this.header,
    required this.content,
    this.initiallyExpanded = false,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<WismeExpandable> createState() => _WismeExpandableState();
}

class _WismeExpandableState extends State<WismeExpandable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Row(
            children: [
              Expanded(child: widget.header),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: widget.animationDuration,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: widget.content,
        ),
      ],
    );
  }
}

/// Status indicator
class WismeStatusIndicator extends StatelessWidget {
  final String status;
  final Color? color;
  final IconData? icon;

  const WismeStatusIndicator({
    Key? key,
    required this.status,
    this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WismeSpacing.sm,
        vertical: WismeSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(WismeRadius.full),
        border: Border.all(
          color: color ?? Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: WismeSpacing.xs),
          ],
          Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
