/// Individual correction item displayed in the post-mission debrief.
class DebriefCorrection {
  const DebriefCorrection({
    required this.userSaid,
    required this.betterWay,
    required this.explanation,
  });

  final String userSaid;
  final String betterWay;
  final String explanation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebriefCorrection &&
          runtimeType == other.runtimeType &&
          userSaid == other.userSaid &&
          betterWay == other.betterWay &&
          explanation == other.explanation;

  @override
  int get hashCode => Object.hash(userSaid, betterWay, explanation);
}

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
    this.praise,
    this.corrections = const [],
    this.vocabularyRecap = const [],
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
  final String? praise;
  final List<DebriefCorrection> corrections;
  final List<String> vocabularyRecap;

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
          totalGoals == other.totalGoals &&
          praise == other.praise;

  @override
  int get hashCode =>
      Object.hash(sessionId, missionId, turnsCount, totalGoals, praise);
}
