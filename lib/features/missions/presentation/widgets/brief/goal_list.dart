import 'package:flutter/material.dart';
import '../../../../../core/design_system/section_label.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/mission_goal.dart';
import 'goal_row.dart';

/// Renders the "YOUR GOAL" section label and the sequential list of goal rows.
///
/// Follows AGENTS.md §3:
/// - Reuses core [SectionLabel]
/// - Under 60 lines, build under 30 lines
class GoalList extends StatelessWidget {
  const GoalList({super.key, required this.goals});

  final List<MissionGoal> goals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionLabel(text: AppStrings.yourGoalSectionLabel),
        const SizedBox(height: AppSpacing.sm),
        for (int i = 0; i < goals.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          GoalRow(goal: goals[i], index: i + 1, total: goals.length),
        ],
      ],
    );
  }
}
