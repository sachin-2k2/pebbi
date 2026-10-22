import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Text line showing the count and accuracy of first-try answers in the lesson.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, build under 30 lines.
class FirstTryLine extends StatelessWidget {
  const FirstTryLine({
    super.key,
    required this.correctCount,
    required this.scoredCount,
  });

  final int correctCount;
  final int scoredCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextMuted
        : const Color(0xFF524F6B); // WCAG AA compliant (> 5.5:1)

    return Text(
      AppStrings.firstTryCountLine(correctCount, scoredCount),
      style: AppTypography.caption.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 13.0,
      ),
      textAlign: TextAlign.center,
    );
  }
}
