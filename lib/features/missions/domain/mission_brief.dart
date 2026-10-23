import 'mission_goal.dart';
import 'mission_summary.dart';

/// Detailed domain model for the Mission Brief screen.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class MissionBrief {
  const MissionBrief({
    required this.missionId,
    required this.emoji,
    required this.title,
    required this.characterName,
    required this.characterRole,
    this.sceneLine,
    required this.goals,
    required this.estimatedMinutes,
    required int difficulty,
    this.supportsVoice = true,
    this.supportsChat = true,
    required this.languageCode,
    this.safetyNoticeKey = 'default',
    this.isPremium = false,
    this.status = MissionStatus.newMission,
  }) : difficulty = difficulty < 1 ? 1 : (difficulty > 3 ? 3 : difficulty);

  /// Unique mission scene identifier (e.g. 'order_coffee').
  final String missionId;

  /// Emoji representation (e.g. '☕').
  final String emoji;

  /// Display title of the mission (e.g. 'Order a coffee').
  final String title;

  /// AI counterpart character name (e.g. 'Lucía').
  final String characterName;

  /// AI counterpart character role (e.g. 'barista').
  final String characterRole;

  /// Setting/context description line (e.g. 'A busy café, morning rush').
  /// Can be null or empty, in which case the scene line is hidden without gaps.
  final String? sceneLine;

  /// Sequential rehearsal objectives for this scene.
  final List<MissionGoal> goals;

  /// Estimated duration in minutes.
  final int estimatedMinutes;

  /// Difficulty rating (1 to 3).
  final int difficulty;

  /// Whether this scene supports voice audio role-play.
  final bool supportsVoice;

  /// Whether this scene supports chat text interaction.
  final bool supportsChat;

  /// Target language code for this mission (e.g. 'es').
  final String languageCode;

  /// Key identifying the safety statement to display.
  final String safetyNoticeKey;

  /// Whether access requires a Premium tier subscription.
  final bool isPremium;

  /// Current user completion status for this mission.
  final MissionStatus status;

  /// Whether the user has previously completed this mission.
  bool get isCompleted => status == MissionStatus.done;

  MissionBrief copyWith({
    String? missionId,
    String? emoji,
    String? title,
    String? characterName,
    String? characterRole,
    String? sceneLine,
    List<MissionGoal>? goals,
    int? estimatedMinutes,
    int? difficulty,
    bool? supportsVoice,
    bool? supportsChat,
    String? languageCode,
    String? safetyNoticeKey,
    bool? isPremium,
    MissionStatus? status,
  }) {
    return MissionBrief(
      missionId: missionId ?? this.missionId,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      characterName: characterName ?? this.characterName,
      characterRole: characterRole ?? this.characterRole,
      sceneLine: sceneLine ?? this.sceneLine,
      goals: goals ?? this.goals,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      supportsVoice: supportsVoice ?? this.supportsVoice,
      supportsChat: supportsChat ?? this.supportsChat,
      languageCode: languageCode ?? this.languageCode,
      safetyNoticeKey: safetyNoticeKey ?? this.safetyNoticeKey,
      isPremium: isPremium ?? this.isPremium,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionBrief &&
          runtimeType == other.runtimeType &&
          missionId == other.missionId &&
          emoji == other.emoji &&
          title == other.title &&
          characterName == other.characterName &&
          characterRole == other.characterRole &&
          sceneLine == other.sceneLine &&
          estimatedMinutes == other.estimatedMinutes &&
          difficulty == other.difficulty &&
          supportsVoice == other.supportsVoice &&
          supportsChat == other.supportsChat &&
          languageCode == other.languageCode &&
          safetyNoticeKey == other.safetyNoticeKey &&
          isPremium == other.isPremium &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    missionId,
    emoji,
    title,
    characterName,
    characterRole,
    sceneLine,
    estimatedMinutes,
    difficulty,
    supportsVoice,
    supportsChat,
    languageCode,
    safetyNoticeKey,
    isPremium,
    status,
  );
}
