import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/session_goal.dart';
import 'goal_chip.dart';

/// Top horizontal strip rendering active conversation goals.
///
/// Follows AGENTS.md §4:
/// - Displays all active session goals horizontally with touch-friendly scrolling
class GoalsStrip extends StatelessWidget {
  const GoalsStrip({super.key, required this.goals});

  final List<SessionGoal> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs + 2.0,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < goals.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              GoalChip(
                goal: goals[i],
                index: i + 1,
                total: goals.length,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
