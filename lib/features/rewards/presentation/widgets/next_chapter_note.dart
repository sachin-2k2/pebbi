import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Small muted footnote regarding upcoming skill map and certificates.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines).
class NextChapterNote extends StatelessWidget {
  const NextChapterNote({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Text(
      AppStrings.rewardsNextChapterNote,
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(
        color: subtitleColor,
        fontSize: 12.0,
        height: 1.35,
      ),
    );
  }
}
