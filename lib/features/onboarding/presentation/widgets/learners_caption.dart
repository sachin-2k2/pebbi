import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Formats a raw integer learners count into a compact locale string (e.g. "42M learners").
///
/// Follows AGENTS.md §3: under 100 lines, no hardcoded strings or numbers in the UI.
class LearnersCaption extends StatelessWidget {
  const LearnersCaption({
    super.key,
    required this.count,
    this.color = AppColors.textMuted,
  });

  final int count;
  final Color color;

  static String formatCompact(int number) {
    if (number >= 1000000) {
      final millions = number / 1000000.0;
      final formatted = millions % 1 == 0
          ? millions.toInt().toString()
          : millions.toStringAsFixed(1);
      return '${formatted}M';
    } else if (number >= 1000) {
      final thousands = number / 1000.0;
      final formatted = thousands % 1 == 0
          ? thousands.toInt().toString()
          : thousands.toStringAsFixed(1);
      return '${formatted}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final compact = formatCompact(count);
    return Text(
      AppStrings.learnersCountFormatted(compact),
      style: AppTypography.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
