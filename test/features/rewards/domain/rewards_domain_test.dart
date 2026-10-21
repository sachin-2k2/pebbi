import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/rewards/domain/badge_item.dart';
import 'package:peddi/features/rewards/domain/badge_status.dart';
import 'package:peddi/features/rewards/domain/calendar_day.dart';
import 'package:peddi/features/rewards/domain/calendar_day_state.dart';
import 'package:peddi/features/rewards/domain/daily_goal_info.dart';
import 'package:peddi/features/rewards/domain/quest_item.dart';
import 'package:peddi/features/rewards/domain/rewards_safety_rules.dart';
import 'package:peddi/features/rewards/domain/rewards_summary.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('Rewards Domain & Formatting Logic Tests', () {
    test('Plural and formatting helpers for streaks and freezes', () {
      expect(AppStrings.rewardsStreakTitle(1), '1 day streak');
      expect(AppStrings.rewardsStreakTitle(8), '8 days streak');

      expect(
        AppStrings.rewardsStreakSubtitle(1, 2),
        '1 active day · 2 freezes ready',
      );
      expect(
        AppStrings.rewardsStreakSubtitle(8, 1),
        '8 active days · 1 freeze ready',
      );
      expect(
        AppStrings.rewardsStreakSubtitle(0, 0),
        '0 active days · 0 freezes ready',
      );
    });

    test('Level caption formatting and max-level thresholds', () {
      expect(AppStrings.rewardsLevelCaption(1), 'Level 1');
      expect(AppStrings.rewardsNextLevelCaption(2, 40), 'Level 2 at 40 stars');
      expect(AppStrings.rewardsTopLevel, 'Top level');

      const regularSummary = RewardsSummary(
        targetLanguage: 'Spanish',
        level: 1,
        outfitName: "Pebbi's little scarf",
        starsInLevel: 10,
        starsForNextLevel: 40,
        totalStars: 10,
        stopsDone: 1,
        phrasesMet: 5,
        dailyGoal: DailyGoalInfo(
          title: 'Daily goal: 1 lesson',
          doneCount: 0,
          targetCount: 1,
          isDone: false,
        ),
        streakDays: 1,
        activeDaysCount: 1,
        freezesReady: 2,
        calendar: [],
        quests: [],
        chestMessage: 'Chest note',
        isChestReady: false,
        badges: [],
        stickerCount: 0,
      );
      expect(regularSummary.isMaxLevel, isFalse);
      expect(regularSummary.levelProgressRatio, 0.25);

      const maxLevelSummary = RewardsSummary(
        targetLanguage: 'Spanish',
        level: 8,
        outfitName: 'Crown & Cape',
        starsInLevel: 240,
        starsForNextLevel: null,
        totalStars: 240,
        stopsDone: 50,
        phrasesMet: 120,
        dailyGoal: DailyGoalInfo(
          title: 'Daily goal: 1 lesson',
          doneCount: 1,
          targetCount: 1,
          isDone: true,
        ),
        streakDays: 30,
        activeDaysCount: 30,
        freezesReady: 2,
        calendar: [],
        quests: [],
        chestMessage: 'Chest note',
        isChestReady: false,
        badges: [],
        stickerCount: 12,
      );
      expect(maxLevelSummary.isMaxLevel, isTrue);
      expect(maxLevelSummary.levelProgressRatio, 1.0);
    });

    test('Badge progress bar visibility strictly follows targetProgress', () {
      const firstHello = BadgeItem(
        id: 'b1',
        emoji: '👋',
        name: 'First hello',
        howToEarn: 'Finish stop',
        status: BadgeStatus.locked,
        targetProgress: null,
      );
      expect(firstHello.hasProgressBar, isFalse);
      expect(firstHello.progressRatio, 0.0);

      const tenStars = BadgeItem(
        id: 'b2',
        emoji: '⭐',
        name: '10 stars',
        howToEarn: 'Earn stars',
        status: BadgeStatus.locked,
        currentProgress: 0,
        targetProgress: 10,
      );
      expect(tenStars.hasProgressBar, isTrue);
      expect(tenStars.progressRatio, 0.0);

      const threeDaysRunning = BadgeItem(
        id: 'b7',
        emoji: '💧',
        name: 'Three days running',
        howToEarn: 'Reach streak',
        status: BadgeStatus.inProgress,
        currentProgress: 1,
        targetProgress: 3,
      );
      expect(threeDaysRunning.hasProgressBar, isTrue);
      expect(threeDaysRunning.progressRatio, closeTo(0.333, 0.01));

      const earnedTenStars = BadgeItem(
        id: 'b2',
        emoji: '⭐',
        name: '10 stars',
        howToEarn: 'Earn stars',
        status: BadgeStatus.earned,
        currentProgress: 10,
        targetProgress: 10,
      );
      expect(earnedTenStars.hasProgressBar, isFalse);
    });

    test('QuestItem progress ratio and completion evaluation', () {
      const q1 = QuestItem(
        id: 'q1',
        emoji: '🎧',
        label: 'Practise one lesson',
        current: 0,
        target: 1,
        isDone: false,
      );
      expect(q1.progressRatio, 0.0);
      expect(q1.isDone, isFalse);

      const q4 = QuestItem(
        id: 'q4',
        emoji: '🔥',
        label: 'Three days in a row',
        current: 1,
        target: 3,
        isDone: false,
      );
      expect(q4.progressRatio, closeTo(0.333, 0.01));
    });

    test('CalendarDay equality and state validation', () {
      final day1 = CalendarDay(
        date: DateTime(2026, 10, 20),
        dayNumber: 20,
        state: CalendarDayState.active,
        isToday: false,
      );
      final day2 = CalendarDay(
        date: DateTime(2026, 10, 20),
        dayNumber: 20,
        state: CalendarDayState.active,
        isToday: false,
      );
      expect(day1, equals(day2));
    });

    test('RewardsSafetyRules checks age bands', () {
      expect(
        RewardsSafetyRules.shouldShowRewardsPressureElements(AgeBand.child),
        isTrue,
      );
      expect(
        RewardsSafetyRules.shouldShowRewardsPressureElements(AgeBand.adult),
        isTrue,
      );
      expect(RewardsSafetyRules.shouldShowInvite(AgeBand.child), isFalse);
      expect(RewardsSafetyRules.shouldShowInvite(AgeBand.adult), isTrue);
    });
  });
}
