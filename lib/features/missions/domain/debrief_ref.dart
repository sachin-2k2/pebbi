/// Immutable reference passed to the debrief route upon finishing a role-play session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class DebriefRef {
  const DebriefRef({
    required this.sessionId,
    required this.missionId,
    required this.turnsCount,
    required this.completedGoalIds,
    required this.totalGoals,
    this.characterName,
    this.characterRole,
    this.completedGoalTexts = const [],
    this.starsEarned = 25,
    this.xpEarned = 20,
  });

  final String sessionId;
  final String missionId;
  final int turnsCount;
  final List<String> completedGoalIds;
  final int totalGoals;
  final String? characterName;
  final String? characterRole;
  final List<String> completedGoalTexts;
  final int starsEarned;
  final int xpEarned;

  double get completionRatio => totalGoals == 0
      ? 0.0
      : (completedGoalIds.length / totalGoals).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebriefRef &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          missionId == other.missionId &&
          turnsCount == other.turnsCount &&
          totalGoals == other.totalGoals;

  @override
  int get hashCode => Object.hash(sessionId, missionId, turnsCount, totalGoals);
}
