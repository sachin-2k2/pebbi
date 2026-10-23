import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
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
    final palette = context.palette;
    final counterColor = palette.textMuted;

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
              color: palette.surface,
              shape: CircleBorder(
                side: BorderSide(
                  color: palette.outline,
                  width: 1.0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onClose,
                child: SizedBox(
                  width: AppSpacing.minTouchTarget,
                  height: AppSpacing.minTouchTarget,
                  child: Icon(
                    Icons.close,
                    color: palette.textPrimary,
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
