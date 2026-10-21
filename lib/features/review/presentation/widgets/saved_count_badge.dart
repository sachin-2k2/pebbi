import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';

/// Small muted count badge displaying "{count} saved" with WCAG AA compliance.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines).
class SavedCountBadge extends StatelessWidget {
  const SavedCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMutedDarker;

    return Text(
      AppStrings.phrasebookSavedCount(count),
      style: TextStyle(
        color: textColor,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
