import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/daily_goal_info.dart';
import 'goal_ring.dart';
import 'level_progress_bar.dart';

/// Card showing the user's daily goal status, reminder line, and level progress bar.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.1.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.goal,
    required this.level,
    required this.starsInLevel,
    required this.starsForNextLevel,
    required this.levelProgressRatio,
  });

  final DailyGoalInfo goal;
  final int level;
  final int starsInLevel;
  final int? starsForNextLevel;
  final double levelProgressRatio;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    final formattedHour = goal.reminderHour.toString().padLeft(2, '0');
    final formattedMinute = goal.reminderMinute.toString().padLeft(2, '0');
    final formattedTime = '$formattedHour:$formattedMinute';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border, width: 1.0),
        boxShadow: isDark ? null : AppSpacing.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GoalRing(
                progress: goal.progressRatio,
                isDone: goal.isDone,
                doneCount: goal.doneCount,
                targetCount: goal.targetCount,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      goal.title,
                      style: AppTypography.cardTitle.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      goal.isDone
                          ? AppStrings.rewardsDailyGoalDone
                          : AppStrings.rewardsDailyGoalMissed,
                      style: AppTypography.caption.copyWith(
                        color: subtitleColor,
                        fontSize: 12.5,
                        height: 1.25,
                      ),
                    ),
                    if (goal.isReminderEnabled) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        AppStrings.rewardsReminderSet(formattedTime),
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.darkChipPurpleText
                              : AppColors.linkPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LevelProgressBar(
            level: level,
            starsInLevel: starsInLevel,
            starsForNextLevel: starsForNextLevel,
            progressRatio: levelProgressRatio,
          ),
        ],
      ),
    );
  }
}
