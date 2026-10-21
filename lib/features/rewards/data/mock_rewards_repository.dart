import 'dart:async';
import '../domain/badge_item.dart';
import '../domain/badge_status.dart';
import '../domain/calendar_day.dart';
import '../domain/calendar_day_state.dart';
import '../domain/daily_goal_info.dart';
import '../domain/quest_item.dart';
import '../domain/rewards_repository.dart';
import '../domain/rewards_summary.dart';

/// In-memory mock repository providing faithful screenshot and edge-case states.
///
/// Follows AGENTS.md §2.2 & §6 (per-user isolation).
class MockRewardsRepository implements RewardsRepository {
  MockRewardsRepository({RewardsSummary? initialSummary}) {
    if (initialSummary != null) {
      _defaultSummary = initialSummary;
    }
  }

  RewardsSummary _defaultSummary = createScreenshotDefault();
  final Map<String, RewardsSummary> _userSummaries = {};
  final _controller = StreamController<RewardsSummary>.broadcast();

  /// Default state matching design screenshots (rewards_1.png, rewards_2.png, rewards_3.png).
  static RewardsSummary createScreenshotDefault({
    String targetLanguage = 'Spanish',
  }) {
    // Generate 28 rolling calendar days ending Oct 21
    final calendar = <CalendarDay>[];
    // Row 1: Sept 24 - 30
    for (int day = 24; day <= 30; day++) {
      calendar.add(
        CalendarDay(
          date: DateTime(2026, 9, day),
          dayNumber: day,
          state: CalendarDayState.none,
        ),
      );
    }
    // Row 2: Oct 1 - 7
    for (int day = 1; day <= 7; day++) {
      calendar.add(
        CalendarDay(
          date: DateTime(2026, 10, day),
          dayNumber: day,
          state: CalendarDayState.none,
        ),
      );
    }
    // Row 3: Oct 8 - 14
    for (int day = 8; day <= 14; day++) {
      calendar.add(
        CalendarDay(
          date: DateTime(2026, 10, day),
          dayNumber: day,
          state: CalendarDayState.none,
        ),
      );
    }
    // Row 4: Oct 15 - 21 (Day 20 is active, Day 21 is today)
    for (int day = 15; day <= 21; day++) {
      final state = day == 20 ? CalendarDayState.active : CalendarDayState.none;
      calendar.add(
        CalendarDay(
          date: DateTime(2026, 10, day),
          dayNumber: day,
          state: state,
          isToday: day == 21,
        ),
      );
    }

    return RewardsSummary(
      targetLanguage: targetLanguage,
      level: 1,
      outfitName: "Pebbi's little scarf",
      starsInLevel: 0,
      starsForNextLevel: 40,
      totalStars: 0,
      stopsDone: 0,
      phrasesMet: 0,
      dailyGoal: const DailyGoalInfo(
        title: 'Daily goal: 1 lesson',
        doneCount: 0,
        targetCount: 1,
        isDone: false,
        reminderHour: 19,
        reminderMinute: 0,
        isReminderEnabled: true,
      ),
      streakDays: 1,
      activeDaysCount: 1,
      freezesReady: 2,
      calendar: calendar,
      quests: const [
        QuestItem(
          id: 'q1',
          emoji: '🎧',
          label: 'Practise one lesson today',
          current: 0,
          target: 1,
          isDone: false,
        ),
        QuestItem(
          id: 'q2',
          emoji: '🛍️',
          label: 'Finish a real-life mission',
          current: 0,
          target: 1,
          isDone: false,
        ),
        QuestItem(
          id: 'q3',
          emoji: '🔄',
          label: 'Get 10 phrases to strong',
          current: 0,
          target: 10,
          isDone: false,
        ),
        QuestItem(
          id: 'q4',
          emoji: '🔥',
          label: 'Three days in a row',
          current: 1,
          target: 3,
          isDone: false,
        ),
      ],
      chestMessage:
          'Finish all four and the weekly chest opens with a sticker inside.',
      isChestReady: false,
      badges: const [
        BadgeItem(
          id: 'b1',
          emoji: '👋',
          name: 'First hello',
          howToEarn: 'Finish your first stop',
          status: BadgeStatus.locked,
          targetProgress: null,
        ),
        BadgeItem(
          id: 'b2',
          emoji: '⭐',
          name: '10 stars',
          howToEarn: 'Earn 10 stars on your path',
          status: BadgeStatus.locked,
          currentProgress: 0,
          targetProgress: 10,
        ),
        BadgeItem(
          id: 'b3',
          emoji: '🔄',
          name: 'Review hero',
          howToEarn: 'Review 20 phrases',
          status: BadgeStatus.locked,
          currentProgress: 0,
          targetProgress: 20,
        ),
        BadgeItem(
          id: 'b4',
          emoji: '💬',
          name: 'Conversation starter',
          howToEarn: 'Start your first mission chat',
          status: BadgeStatus.locked,
          targetProgress: null,
        ),
        BadgeItem(
          id: 'b5',
          emoji: '☕',
          name: 'Café regular',
          howToEarn: 'Complete the coffee shop scene',
          status: BadgeStatus.locked,
          targetProgress: null,
        ),
        BadgeItem(
          id: 'b6',
          emoji: '🎙️',
          name: 'Voice starter',
          howToEarn: 'Speak 5 phrases aloud',
          status: BadgeStatus.locked,
          currentProgress: 0,
          targetProgress: 5,
        ),
        BadgeItem(
          id: 'b7',
          emoji: '💧',
          name: 'Three days running',
          howToEarn: 'Reach a 3-day streak',
          status: BadgeStatus.inProgress,
          currentProgress: 1,
          targetProgress: 3,
        ),
        BadgeItem(
          id: 'b8',
          emoji: '🏅',
          name: 'Week of fire',
          howToEarn: 'Reach a 7-day streak',
          status: BadgeStatus.inProgress,
          currentProgress: 1,
          targetProgress: 7,
        ),
        BadgeItem(
          id: 'b9',
          emoji: '🎭',
          name: 'Scene stealer',
          howToEarn: 'Finish 5 missions',
          status: BadgeStatus.locked,
          currentProgress: 0,
          targetProgress: 5,
        ),
        BadgeItem(
          id: 'b10',
          emoji: '📝',
          name: 'Script explorer',
          howToEarn: 'Explore 10 script notes',
          status: BadgeStatus.locked,
          currentProgress: 0,
          targetProgress: 10,
        ),
        BadgeItem(
          id: 'b11',
          emoji: '🌐',
          name: 'Polyglot heart',
          howToEarn: 'Learn in two languages',
          status: BadgeStatus.locked,
          currentProgress: 0,
          targetProgress: 2,
        ),
        BadgeItem(
          id: 'b12',
          emoji: '🌟',
          name: 'Fifty stars',
          howToEarn: 'Earn 50 stars on your path',
          status: BadgeStatus.locked,
          currentProgress: 0,
          targetProgress: 50,
        ),
      ],
      stickerCount: 0,
    );
  }

  /// State with earned badges, completed daily goal, and mid-level streak.
  static RewardsSummary createMidState({String targetLanguage = 'Spanish'}) {
    final def = createScreenshotDefault(targetLanguage: targetLanguage);
    final badges = def.badges.map((b) {
      if (b.id == 'b1' || b.id == 'b2' || b.id == 'b4') {
        return BadgeItem(
          id: b.id,
          emoji: b.emoji,
          name: b.name,
          howToEarn: b.howToEarn,
          status: BadgeStatus.earned,
          earnedAt: DateTime(2026, 10, 12),
          currentProgress: b.targetProgress,
          targetProgress: b.targetProgress,
        );
      }
      return b;
    }).toList();

    return RewardsSummary(
      targetLanguage: targetLanguage,
      level: 3,
      outfitName: 'Student cap',
      starsInLevel: 25,
      starsForNextLevel: 60,
      totalStars: 85,
      stopsDone: 14,
      phrasesMet: 28,
      dailyGoal: const DailyGoalInfo(
        title: 'Daily goal: 1 lesson',
        doneCount: 1,
        targetCount: 1,
        isDone: true,
        reminderHour: 19,
        reminderMinute: 0,
        isReminderEnabled: true,
      ),
      streakDays: 8,
      activeDaysCount: 8,
      freezesReady: 1,
      calendar: def.calendar,
      quests: def.quests.map((q) {
        if (q.id == 'q1') {
          return QuestItem(
            id: q.id,
            emoji: q.emoji,
            label: q.label,
            current: 1,
            target: 1,
            isDone: true,
          );
        }
        return q;
      }).toList(),
      chestMessage: def.chestMessage,
      isChestReady: false,
      badges: badges,
      stickerCount: 3,
    );
  }

  /// State for a user who reached maximum level (level 8).
  static RewardsSummary createMaxLevelState({
    String targetLanguage = 'Spanish',
  }) {
    final def = createScreenshotDefault(targetLanguage: targetLanguage);
    return RewardsSummary(
      targetLanguage: targetLanguage,
      level: 8,
      outfitName: 'Crown & Cape',
      starsInLevel: 240,
      starsForNextLevel: null,
      totalStars: 240,
      stopsDone: 50,
      phrasesMet: 120,
      dailyGoal: def.dailyGoal,
      streakDays: def.streakDays,
      activeDaysCount: def.activeDaysCount,
      freezesReady: def.freezesReady,
      calendar: def.calendar,
      quests: def.quests,
      chestMessage: def.chestMessage,
      isChestReady: def.isChestReady,
      badges: def.badges,
      stickerCount: 12,
    );
  }

  /// Sets state for a specific user ID.
  void setUserSummary(String userId, RewardsSummary summary) {
    _userSummaries[userId] = summary;
    _controller.add(summary);
  }

  @override
  Future<RewardsSummary> getSummary({required String userId}) async {
    return _userSummaries[userId] ?? _defaultSummary;
  }

  @override
  Stream<RewardsSummary> watchSummary({required String userId}) async* {
    yield await getSummary(userId: userId);
    yield* _controller.stream.where(
      (_) => true,
    ); // simplified broadcast for mock
  }

  void dispose() {
    _controller.close();
  }
}
