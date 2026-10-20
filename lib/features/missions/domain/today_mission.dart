import 'mission_summary.dart';

/// Domain model representing today's featured role-play mission.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class TodayMission {
  const TodayMission({
    required this.mission,
    this.isCompleted = false,
    this.reason,
    this.date,
  });

  /// The underlying mission summary.
  final MissionSummary mission;

  /// Whether the user has completed today's featured mission.
  final bool isCompleted;

  /// Optional contextual reason or tag (e.g. 'Daily highlight').
  final String? reason;

  /// Date for which this is the daily mission.
  final DateTime? date;

  TodayMission copyWith({
    MissionSummary? mission,
    bool? isCompleted,
    String? reason,
    DateTime? date,
  }) {
    return TodayMission(
      mission: mission ?? this.mission,
      isCompleted: isCompleted ?? this.isCompleted,
      reason: reason ?? this.reason,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayMission &&
          runtimeType == other.runtimeType &&
          mission == other.mission &&
          isCompleted == other.isCompleted &&
          reason == other.reason &&
          date == other.date;

  @override
  int get hashCode => Object.hash(mission, isCompleted, reason, date);
}
