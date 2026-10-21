import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Soft grey-lavender informational note card describing future practice room additions.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and WCAG AA contrast.
class PracticeComingSoonNote extends StatelessWidget {
  const PracticeComingSoonNote({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkNoteCardBackground
        : AppColors.noteCardBackground;
    final border = isDark
        ? AppColors.darkNoteCardBorder
        : AppColors.noteCardBorder;
    final textColor = isDark
        ? AppColors.darkNoteCardText
        : AppColors.noteCardText;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Text(
        AppStrings.practiceComingSoonNote,
        style: TextStyle(
          color: textColor,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}
