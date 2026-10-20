/// Status of a mission for a specific learner user.
enum MissionStatus { newMission, inProgress, done }

/// Domain model representing a role-play mission scene summary.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class MissionSummary {
  const MissionSummary({
    required this.id,
    required this.categoryIds,
    required this.title,
    required this.characterName,
    required this.characterRole,
    required this.durationMinutes,
    required int difficulty,
    required this.emoji,
    this.status = MissionStatus.newMission,
    this.isPremium = false,
  }) : difficulty = difficulty < 1 ? 1 : (difficulty > 3 ? 3 : difficulty);

  /// Unique identifier (e.g. 'order_coffee').
  final String id;

  /// IDs of the categories this mission belongs to (e.g. ['everyday']).
  final List<String> categoryIds;

  /// Display title of the mission scene.
  final String title;

  /// Counterpart AI character name (e.g. 'Lucía').
  final String characterName;

  /// Counterpart AI character role (e.g. 'barista').
  final String characterRole;

  /// Estimated duration in minutes.
  final int durationMinutes;

  /// Difficulty level rating (strictly 1 to 3).
  final int difficulty;

  /// Visual icon emoji representing the scene.
  final String emoji;

  /// Per-user completion state.
  final MissionStatus status;

  /// Whether this mission requires a Premium subscription.
  final bool isPremium;

  MissionSummary copyWith({
    String? id,
    List<String>? categoryIds,
    String? title,
    String? characterName,
    String? characterRole,
    int? durationMinutes,
    int? difficulty,
    String? emoji,
    MissionStatus? status,
    bool? isPremium,
  }) {
    return MissionSummary(
      id: id ?? this.id,
      categoryIds: categoryIds ?? this.categoryIds,
      title: title ?? this.title,
      characterName: characterName ?? this.characterName,
      characterRole: characterRole ?? this.characterRole,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      emoji: emoji ?? this.emoji,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          characterName == other.characterName &&
          characterRole == other.characterRole &&
          durationMinutes == other.durationMinutes &&
          difficulty == other.difficulty &&
          emoji == other.emoji &&
          status == other.status &&
          isPremium == other.isPremium;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    characterName,
    characterRole,
    durationMinutes,
    difficulty,
    emoji,
    status,
    isPremium,
  );
}
