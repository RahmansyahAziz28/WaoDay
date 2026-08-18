import 'package:flutter/material.dart';

import '../theme.dart';

/// Visual style of an [AppButton].
enum AppButtonVariant { primary, outlined, danger, text }

/// Standard button used across the app so loading and disabled states
/// stay consistent without every screen re-implementing them.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  bool get _isFilled => variant == AppButtonVariant.primary || variant == AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;
    final spinnerColor = _isFilled ? Colors.white : AppColors.primary;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(spinnerColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(onPressed: disabled ? null : onPressed, child: child);
        break;
      case AppButtonVariant.outlined:
        button = OutlinedButton(onPressed: disabled ? null : onPressed, child: child);
        break;
      case AppButtonVariant.danger:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: disabled ? null : onPressed,
          child: child,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(onPressed: disabled ? null : onPressed, child: child);
        break;
    }

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
