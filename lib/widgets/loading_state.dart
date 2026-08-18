import 'package:flutter/material.dart';

import '../theme.dart';

/// Centered spinner with an optional caption, used while data is being
/// fetched or an action is in progress.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
