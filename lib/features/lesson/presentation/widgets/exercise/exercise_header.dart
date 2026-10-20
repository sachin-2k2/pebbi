import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import 'exercise_progress_bar.dart';

/// Top header for exercises:
/// circular X close button + animated mint progress bar + "current/total" counter.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// 48dp touch target, RTL mirroring, accessible counter semantics.
class ExerciseHeader extends StatelessWidget {
  const ExerciseHeader({
    super.key,
    required this.currentNumber,
    required this.totalNumber,
    required this.progress,
    required this.onClose,
  });

  final int currentNumber;
  final int totalNumber;
  final double progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final counterColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: AppStrings.closeExerciseSemantics,
            child: Material(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              shape: CircleBorder(
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                  width: 1.0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onClose,
                child: const SizedBox(
                  width: AppSpacing.minTouchTarget,
                  height: AppSpacing.minTouchTarget,
                  child: Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: ExerciseProgressBar(progress: progress)),
          const SizedBox(width: AppSpacing.md),
          Semantics(
            excludeSemantics: true,
            label: AppStrings.questionProgressSemantics(
              currentNumber,
              totalNumber,
            ),
            child: Text(
              '$currentNumber/$totalNumber',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: counterColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
