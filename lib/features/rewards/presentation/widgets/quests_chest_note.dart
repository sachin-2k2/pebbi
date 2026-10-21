import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Footnote explaining the weekly chest condition.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines).
class QuestsChestNote extends StatelessWidget {
  const QuestsChestNote({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Text(
      message ?? AppStrings.rewardsChestNote,
      style: AppTypography.caption.copyWith(
        color: subtitleColor,
        fontSize: 12.0,
        height: 1.3,
      ),
    );
  }
}
