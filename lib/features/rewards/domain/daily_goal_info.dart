/// Status and reminder details for the user's daily learning goal.
///
/// Follows AGENTS.md §2.2: Pure Dart domain model with zero Flutter imports.
class DailyGoalInfo {
  const DailyGoalInfo({
    required this.title,
    required this.doneCount,
    required this.targetCount,
    required this.isDone,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.isReminderEnabled = true,
  });

  final String title;
  final int doneCount;
  final int targetCount;
  final bool isDone;
  final int reminderHour;
  final int reminderMinute;
  final bool isReminderEnabled;

  double get progressRatio =>
      targetCount > 0 ? (doneCount / targetCount).clamp(0.0, 1.0) : 0.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyGoalInfo &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          doneCount == other.doneCount &&
          targetCount == other.targetCount &&
          isDone == other.isDone &&
          reminderHour == other.reminderHour &&
          reminderMinute == other.reminderMinute &&
          isReminderEnabled == other.isReminderEnabled;

  @override
  int get hashCode =>
      title.hashCode ^
      doneCount.hashCode ^
      targetCount.hashCode ^
      isDone.hashCode ^
      reminderHour.hashCode ^
      reminderMinute.hashCode ^
      isReminderEnabled.hashCode;
}
