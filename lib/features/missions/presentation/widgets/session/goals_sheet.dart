import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/session_goal.dart';

/// Modal bottom sheet / dialog displaying the full list of mission goals.
///
/// Follows AGENTS.md §3 & §4.5: Composed via AdaptiveSheet.
class GoalsSheet extends StatelessWidget {
  const GoalsSheet({super.key, required this.goals});

  final List<SessionGoal> goals;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.sessionGoalsSheetTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.sessionGoalsSheetSubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: palette.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < goals.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.isDark ? palette.surfaceVariant : palette.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(
                    color: goals[i].isDone ? palette.mint : palette.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      goals[i].isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: goals[i].isDone ? palette.mint : palette.textMuted,
                      size: 20.0,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        goals[i].text,
                        style: AppTypography.bodyMedium.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
