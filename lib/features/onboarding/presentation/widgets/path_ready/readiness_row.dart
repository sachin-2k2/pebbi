import 'package:flutter/material.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/core/theme/app_spacing.dart';
import 'package:peddi/core/theme/app_typography.dart';
import 'package:peddi/features/onboarding/domain/preparation_task.dart';
import 'package:peddi/l10n/app_strings.dart';
import 'animated_check.dart';

/// Single white card row displaying a readiness preparation task and its status.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// high contrast colors, accessible semantics, responsive text wrapping.
class ReadinessRow extends StatelessWidget {
  const ReadinessRow({
    super.key,
    required this.task,
    this.reduceMotion = false,
    this.onRetry,
  });

  final PreparationTask task;
  final bool reduceMotion;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;

    final labelColor = switch (task.status) {
      TaskStatus.done =>
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      TaskStatus.failed => AppColors.error,
      TaskStatus.pending || TaskStatus.unavailable =>
        isDark ? AppColors.darkTextMuted : AppColors.textMuted,
    };

    final statusText = switch (task.status) {
      TaskStatus.done => AppStrings.taskStatusDone,
      TaskStatus.pending => AppStrings.taskStatusPending,
      TaskStatus.failed => AppStrings.taskStatusFailed,
      TaskStatus.unavailable => AppStrings.taskStatusUnavailable,
    };

    return Semantics(
      label: AppStrings.readinessRowSemantics(
        label: task.label,
        statusText: statusText,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2.0),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2.0,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: border, width: 1.0),
          boxShadow: isDark ? null : AppSpacing.cardShadow,
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Text(task.emoji, style: const TextStyle(fontSize: 20.0)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                task.label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: task.isDone ? FontWeight.w700 : FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildTrailing(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (task.isFailed && onRetry != null) {
      return TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          AppStrings.retryAction,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.brandPurple,
          ),
        ),
      );
    }

    if (task.isUnavailable) {
      return Text(
        AppStrings.taskStatusUnavailable,
        style: AppTypography.caption.copyWith(color: AppColors.textMuted),
      );
    }

    return AnimatedCheck(isDone: task.isDone, reduceMotion: reduceMotion);
  }
}
