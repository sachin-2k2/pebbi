/// Domain models representing the immutable results of completing a lesson.
///
/// Follows AGENTS.md §2.2: Pure Dart domain models with zero Flutter imports.
library;

/// Single phrase learned or practiced during a lesson.
class LearnedPhrase {
  const LearnedPhrase({
    required this.id,
    required this.emoji,
    required this.text,
    required this.meaning,
    required this.audioText,
    required this.audioLocale,
    this.helperLine,
    this.isRtl = false,
  });

  final String id;
  final String emoji;
  final String text;
  final String meaning;
  final String audioText;
  final String audioLocale;
  final String? helperLine;
  final bool isRtl;
}

/// Status of the daily goal on lesson completion.
enum DailyGoalStatus {
  /// Goal requirement fulfilled today ("Goal done!").
  done,

  /// In progress toward today's goal (e.g. "1 of 2 lessons left").
  inProgress,

  /// No goal configured or tile silenced.
  none,
}

/// Daily goal achievement data.
class DailyGoalCompletion {
  const DailyGoalCompletion({
    required this.status,
    this.progressText,
  });

  final DailyGoalStatus status;

  /// Progress text for [DailyGoalStatus.inProgress] (e.g. "1 of 2 lessons left").
  final String? progressText;

  bool get isDone => status == DailyGoalStatus.done;
  bool get isInProgress => status == DailyGoalStatus.inProgress;
}

/// Aggregated, display-ready lesson completion record returned by the backend / repository.
///
/// All fields are provided by the backend / repository; the UI never computes
/// stars, streaks, or badge awards.
class LessonCompletion {
  const LessonCompletion({
    required this.stopId,
    required this.starsEarned,
    required this.scoredCount,
    required this.firstTryCorrectCount,
    required this.learnedPhrases,
    this.streakDays,
    required this.dailyGoal,
    this.nextStopId,
    this.unitCompleted = false,
    this.newBadgeIds = const [],
    this.newStickerIds = const [],
    this.levelUp,
  });

  /// The completed lesson stop ID.
  final String stopId;

  /// Star rating earned (0 to 3).
  final int starsEarned;

  /// Total count of scored items in the lesson.
  final int scoredCount;

  /// Count of scored items answered correctly on first try.
  final int firstTryCorrectCount;

  /// Phrases introduced or practiced in this lesson.
  final List<LearnedPhrase> learnedPhrases;

  /// Current active daily streak in days, or null if unassigned/silenced.
  final int? streakDays;

  /// Daily goal achievement state and progress text.
  final DailyGoalCompletion dailyGoal;

  /// ID of the next unlocked path node, if any.
  final String? nextStopId;

  /// Whether completing this stop also finished the entire unit.
  final bool unitCompleted;

  /// Newly earned badge IDs (ignored by completion UI, consumed by Rewards later).
  final List<String> newBadgeIds;

  /// Newly unlocked sticker IDs.
  final List<String> newStickerIds;

  /// Level-up milestone reached (e.g. "Level 2: Polyglot Explorer"), if any.
  final String? levelUp;
}
