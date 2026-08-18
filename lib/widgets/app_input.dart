import 'package:flutter/material.dart';

/// A labeled text field with a consistent look across every form in the
/// app (label above the field, optional leading icon, error text, and an
/// optional trailing widget for things like a password-visibility toggle).
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.suffix,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final Widget? suffix;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 22) : null,
            suffixIcon: suffix,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
