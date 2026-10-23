import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/mission_goal.dart';
import 'goal_circle.dart';

/// Full-width rounded white card displaying a single mission rehearsal goal.
///
/// Follows AGENTS.md §3 & §8:
/// - Display-only row (not interactive toggles)
/// - Comprehensive list semantics: "Goal X of Y: ... Not done yet."
class GoalRow extends StatelessWidget {
  const GoalRow({
    super.key,
    required this.goal,
    required this.index,
    required this.total,
  });

  final MissionGoal goal;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      container: true,
      label: AppStrings.goalListSemantics(index, total, goal.text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2.0,
        ),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: palette.outline, width: 1.0),
          boxShadow: palette.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const GoalCircle(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                goal.text,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
