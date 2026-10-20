import '../../../l10n/app_strings.dart';

/// Supported daily learning goal identifiers.
enum DailyGoalId {
  casual('casual'),
  regular('regular'),
  serious('serious'),
  intense('intense');

  const DailyGoalId(this.id);
  final String id;
}

/// Central definition and source of truth for daily learning goals.
///
/// Follows AGENTS.md §2 (pure Dart domain model, zero Flutter UI dependencies)
/// and §7.3 (reused across onboarding step 7 and Settings "Goal and reminders").
class DailyGoalInfo {
  const DailyGoalInfo({
    required this.id,
    required this.minutes,
    required this.emoji,
    this.isOpenEnded = false,
  });

  /// Stable string identifier for persistence ('casual', 'regular', 'serious', 'intense').
  final DailyGoalId id;

  /// Goal duration in minutes per day.
  final int minutes;

  /// Emoji representation for visual cue.
  final String emoji;

  /// Whether the goal represents an open-ended target (e.g. "20+ min a day").
  final bool isOpenEnded;

  /// Localized name of this goal tier.
  String get name => switch (id) {
    DailyGoalId.casual => AppStrings.dailyGoalCasual,
    DailyGoalId.regular => AppStrings.dailyGoalRegular,
    DailyGoalId.serious => AppStrings.dailyGoalSerious,
    DailyGoalId.intense => AppStrings.dailyGoalIntense,
  };

  /// Localized short caption formatted with ICU parameters (e.g. "10 min a day", "20+ min a day").
  String get caption =>
      AppStrings.dailyGoalMinutesCaption(minutes, isOpenEnded: isOpenEnded);

  /// Localized Settings chip format (e.g. "Regular · 10 min a day").
  String get settingsChipLabel =>
      AppStrings.dailyGoalSettingsChip(name, minutes, isOpenEnded: isOpenEnded);

  /// Predefined catalog of the 4 standard daily goal options.
  static const List<DailyGoalInfo> allGoals = [
    DailyGoalInfo(
      id: DailyGoalId.casual,
      minutes: 5,
      emoji: '🌱',
      isOpenEnded: false,
    ),
    DailyGoalInfo(
      id: DailyGoalId.regular,
      minutes: 10,
      emoji: '🌿',
      isOpenEnded: false,
    ),
    DailyGoalInfo(
      id: DailyGoalId.serious,
      minutes: 15,
      emoji: '🌲',
      isOpenEnded: false,
    ),
    DailyGoalInfo(
      id: DailyGoalId.intense,
      minutes: 20,
      emoji: '⛰️',
      isOpenEnded: true,
    ),
  ];

  /// Finds the goal info for a given [DailyGoalId], defaulting to [DailyGoalId.regular].
  static DailyGoalInfo forId(DailyGoalId id) {
    return allGoals.firstWhere(
      (goal) => goal.id == id,
      orElse: () => allGoals[1],
    );
  }

  /// Finds the goal info for a stable [idStr], defaulting to 'regular'.
  static DailyGoalInfo forStringId(String idStr) {
    return allGoals.firstWhere(
      (goal) => goal.id.id == idStr,
      orElse: () => allGoals[1],
    );
  }
}
