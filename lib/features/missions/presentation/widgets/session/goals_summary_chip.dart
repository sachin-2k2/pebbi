import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Compact collapsed summary chip ("Goals 1 of 3  ›") opening full goals modal.
///
/// Follows AGENTS.md §4.6 & §8: 48dp minimum touch target.
class GoalsSummaryChip extends StatelessWidget {
  const GoalsSummaryChip({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.onTap,
  });

  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: 'View all goals. $completedCount of $totalCount completed.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: palette.outline, width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completedCount == totalCount
                      ? Icons.check_circle_rounded
                      : Icons.flag_rounded,
                  size: 16.0,
                  color: completedCount == totalCount ? palette.mint : palette.brand,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    AppStrings.sessionGoalsSummaryChip(completedCount, totalCount),
                    style: AppTypography.labelMedium.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
