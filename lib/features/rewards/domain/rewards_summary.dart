import 'badge_item.dart';
import 'badge_status.dart';
import 'calendar_day.dart';
import 'daily_goal_info.dart';
import 'quest_item.dart';

/// Aggregated user state for the Rewards screen.
///
/// Follows AGENTS.md §2.2: Pure Dart domain model with zero Flutter imports.
class RewardsSummary {
  const RewardsSummary({
    required this.targetLanguage,
    required this.level,
    required this.outfitName,
    required this.starsInLevel,
    required this.starsForNextLevel,
    required this.totalStars,
    required this.stopsDone,
    required this.phrasesMet,
    required this.dailyGoal,
    required this.streakDays,
    required this.activeDaysCount,
    required this.freezesReady,
    required this.calendar,
    required this.quests,
    required this.chestMessage,
    required this.isChestReady,
    required this.badges,
    required this.stickerCount,
  });

  final String targetLanguage;
  final int level;
  final String outfitName;
  final int starsInLevel;
  final int? starsForNextLevel;
  final int totalStars;

  final int stopsDone;
  final int phrasesMet;

  final DailyGoalInfo dailyGoal;
  final int streakDays;
  final int activeDaysCount;
  final int freezesReady;

  final List<CalendarDay> calendar;
  final List<QuestItem> quests;
  final String chestMessage;
  final bool isChestReady;

  final List<BadgeItem> badges;
  final int stickerCount;

  bool get isMaxLevel => starsForNextLevel == null;

  double get levelProgressRatio {
    if (isMaxLevel) return 1.0;
    final next = starsForNextLevel!;
    return next > 0 ? (starsInLevel / next).clamp(0.0, 1.0) : 0.0;
  }

  int get earnedBadgesCount =>
      badges.where((b) => b.status == BadgeStatus.earned).length;

  int get completedQuestsCount => quests.where((q) => q.isDone).length;
}
