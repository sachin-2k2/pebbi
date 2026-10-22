import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/lesson_completion.dart';
import 'completion_stat_tile.dart';

/// Row coordinating the streak and daily goal stat tiles.
///
/// Follows AGENTS.md §3 & §4: under 120 lines, build under 50 lines,
/// adapts to single-tile expansion, none-state collapse, and text scale > 1.3x stacking.
class CompletionStatRow extends StatelessWidget {
  const CompletionStatRow({
    super.key,
    required this.streakDays,
    required this.dailyGoal,
    this.showStreak = true,
  });

  final int? streakDays;
  final DailyGoalCompletion dailyGoal;
  final bool showStreak;

  @override
  Widget build(BuildContext context) {
    final hasStreak = showStreak && streakDays != null;
    final hasGoal = dailyGoal.status != DailyGoalStatus.none;

    if (!hasStreak && !hasGoal) return const SizedBox.shrink();

    Widget? streakWidget;
    if (hasStreak) {
      final days = streakDays!;
      streakWidget = CompletionStatTile(
        icon: Icons.local_fire_department_outlined,
        iconColor: AppColors.coral,
        title: '$days',
        label: AppStrings.dayStreakValueLabel(days),
        semanticLabel: '$days ${AppStrings.dayStreakValueLabel(days)}',
      );
    }

    Widget? goalWidget;
    if (hasGoal) {
      final isDone = dailyGoal.status == DailyGoalStatus.done;
      final title = isDone
          ? AppStrings.goalDoneTitle
          : (dailyGoal.progressText ?? AppStrings.goalDoneTitle);

      goalWidget = CompletionStatTile(
        icon: Icons.star_outline_rounded,
        iconColor: AppColors.goldStar,
        title: title,
        label: AppStrings.dailyGoalLabel,
        semanticLabel: isDone
            ? 'Daily goal done'
            : '$title ${AppStrings.dailyGoalLabel}',
      );
    }

    if (hasStreak && !hasGoal) return streakWidget!;
    if (hasGoal && !hasStreak) return goalWidget!;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final shouldStack = textScale > 1.3;

    if (shouldStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          streakWidget!,
          const SizedBox(height: AppSpacing.sm),
          goalWidget!,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: streakWidget!),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: goalWidget!),
      ],
    );
  }
}
