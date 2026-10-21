import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/rewards_summary.dart';
import 'daily_goal_card.dart';
import 'progress_header.dart';
import 'quests_card.dart';
import 'stat_tile_row.dart';
import 'streak_calendar_card.dart';
import 'streak_card.dart';

/// Primary pane hosting progress header, stats, daily goal, streak, calendar, and quests.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.3.
class RewardsLeftPane extends StatelessWidget {
  const RewardsLeftPane({
    super.key,
    required this.summary,
    required this.onSettingsPressed,
    required this.onCalendarPressed,
    required this.calendarKey,
  });

  final RewardsSummary summary;
  final VoidCallback onSettingsPressed;
  final VoidCallback onCalendarPressed;
  final GlobalKey calendarKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressHeader(
          targetLanguage: summary.targetLanguage,
          level: summary.level,
          outfitName: summary.outfitName,
          onSettingsPressed: onSettingsPressed,
        ),
        const SizedBox(height: AppSpacing.md),
        StatTileRow(
          stopsDone: summary.stopsDone,
          phrasesMet: summary.phrasesMet,
          stars: summary.totalStars,
        ),
        const SizedBox(height: AppSpacing.md),
        DailyGoalCard(
          goal: summary.dailyGoal,
          level: summary.level,
          starsInLevel: summary.starsInLevel,
          starsForNextLevel: summary.starsForNextLevel,
          levelProgressRatio: summary.levelProgressRatio,
        ),
        const SizedBox(height: AppSpacing.md),
        StreakCard(
          streakDays: summary.streakDays,
          activeDaysCount: summary.activeDaysCount,
          freezesReady: summary.freezesReady,
          onCalendarPressed: onCalendarPressed,
        ),
        const SizedBox(height: AppSpacing.md),
        KeyedSubtree(
          key: calendarKey,
          child: StreakCalendarCard(
            days: summary.calendar,
            activeDaysCount: summary.activeDaysCount,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        QuestsCard(
          quests: summary.quests,
          completedCount: summary.completedQuestsCount,
          chestMessage: summary.chestMessage,
        ),
      ],
    );
  }
}
