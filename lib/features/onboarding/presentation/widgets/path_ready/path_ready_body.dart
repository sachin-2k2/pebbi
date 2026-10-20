import 'package:flutter/material.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_typography.dart';
import 'package:peddi/features/onboarding/domain/path_ready_state.dart';
import 'package:peddi/l10n/app_strings.dart';
import 'first_lesson_note.dart';
import 'path_ready_ring.dart';
import 'readiness_checklist.dart';

/// Scrollable body for Onboarding Setup Step 11: Path Ready ("Your path is ready").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// flexible sizing, clamped hero ring, no fixed heights.
class PathReadyBody extends StatelessWidget {
  const PathReadyBody({
    super.key,
    required this.state,
    this.reduceMotion = false,
    this.onRetry,
  });

  final PathReadyState state;
  final bool reduceMotion;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            AppStrings.pathReadyTitle,
            textAlign: TextAlign.center,
            style: AppTypography.screenTitle.copyWith(color: titleColor),
          ),
        ),
        PathReadyRing(progress: state.progress),
        const SizedBox(height: AppSpacing.xs),
        ReadinessChecklist(
          tasks: state.tasks,
          reduceMotion: reduceMotion,
          onRetry: onRetry,
        ),
        const SizedBox(height: AppSpacing.md),
        FirstLessonNote(
          estimatedMinutes: state.firstLessonInfo.estimatedMinutes,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
