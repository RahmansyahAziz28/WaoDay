import 'package:flutter/material.dart';

/// Standard content card used across list and detail screens.
///
/// Wraps [Card] with the app's default padding and, when [onTap] or
/// [onLongPress] is provided, an internal ripple so cards act as tappable
/// list rows without nested MouseRegion conflicts.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (onTap == null && onLongPress == null) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
