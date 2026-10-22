import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Text row indicating additional phrases learned beyond the initial preview.
///
/// Follows AGENTS.md §3 & §4: under 50 lines, build under 25 lines.
class MoreLearnedLine extends StatelessWidget {
  const MoreLearnedLine({super.key, required this.extraCount});

  final int extraCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextMuted : const Color(0xFF524F6B);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Center(
        child: Text(
          AppStrings.moreLearnedPhrasesCount(extraCount),
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
