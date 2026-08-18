import 'package:flutter/material.dart';

/// Standard content card used across list and detail screens.
///
/// Wraps [Card] with the app's default padding and, when [onTap] is
/// provided, a ripple so cards can act as tappable list rows without
/// every screen re-implementing the same wrapper.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Card(child: Padding(padding: padding, child: child));
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
