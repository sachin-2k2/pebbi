import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Bottom safety disclaimer footer for the emergency show screen.
///
/// Follows AGENTS.md §3 (<150 lines).
class ShowScreenDisclaimer extends StatelessWidget {
  const ShowScreenDisclaimer({
    super.key,
    required this.disclaimerText,
    this.ttsNotice,
  });

  final String disclaimerText;
  final String? ttsNotice;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ttsNotice != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              ttsNotice!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.emergencyLabelRed,
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          disclaimerText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            fontSize: 12.0,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

