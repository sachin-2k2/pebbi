import 'package:flutter/material.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_typography.dart';
import 'package:peddi/l10n/app_strings.dart';

/// Small centered note with amber star icon indicating estimated lesson duration.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// high contrast gold icon (#D97706 > 3:1), muted text (#6E6A8A > 5:1 against white).
class FirstLessonNote extends StatelessWidget {
  const FirstLessonNote({super.key, this.estimatedMinutes = 3});

  final int estimatedMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final starColor = isDark ? AppColors.starGold : AppColors.goldDepth;

    final noteText = AppStrings.firstLessonDurationNote(estimatedMinutes);

    return Semantics(
      label: noteText,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.star_border_rounded,
                size: 16.0,
                color: starColor,
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 2.0),
            Flexible(
              child: Text(
                noteText,
                style: AppTypography.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
