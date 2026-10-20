import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/daily_goal_info.dart';
import 'goal_card.dart';

/// Responsive grid of daily goal option cards with equal height per row.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, adapts columns (2 on phone, up to 4 on tablet),
/// uses IntrinsicHeight so cards dynamically stretch equally without aspect ratio overflow.
class GoalGrid extends StatelessWidget {
  const GoalGrid({
    super.key,
    required this.selectedGoalId,
    required this.onSelectGoal,
    this.spacing = AppSpacing.md,
  });

  final String selectedGoalId;
  final ValueChanged<String> onSelectGoal;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    const goals = DailyGoalInfo.allGoals;

    return Semantics(
      label: AppStrings.dailyGoalGroupSemantics,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / 160.0).floor().clamp(2, 4);
          final rows = <List<DailyGoalInfo>>[];

          for (var i = 0; i < goals.length; i += columns) {
            final end = (i + columns < goals.length)
                ? i + columns
                : goals.length;
            rows.add(goals.sublist(i, end));
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int r = 0; r < rows.length; r++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: r == rows.length - 1 ? 0 : spacing,
                  ),
                  child: _buildRow(rows[r], columns, goals.length),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(
    List<DailyGoalInfo> rowGoals,
    int columns,
    int totalGoalsCount,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < columns; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(
              child: i < rowGoals.length
                  ? GoalCard(
                      goal: rowGoals[i],
                      isSelected: selectedGoalId == rowGoals[i].id.id,
                      onTap: () => onSelectGoal(rowGoals[i].id.id),
                      index: DailyGoalInfo.allGoals.indexOf(rowGoals[i]) + 1,
                      total: totalGoalsCount,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}
