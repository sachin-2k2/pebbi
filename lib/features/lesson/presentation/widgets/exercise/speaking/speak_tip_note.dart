import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Subdued sparkle note displayed at the bottom of speaking screens:
/// "Speak, or skip — nothing is lost".
///
/// Follows AGENTS.md §3 & §4: under 50 lines, accessible text.
class SpeakTipNote extends StatelessWidget {
  const SpeakTipNote({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          size: 15.0,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            AppStrings.speakTipNote,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
