/// Pure domain rules evaluating session streaks.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// A session streak is a session-only counter of consecutive first-try-correct
/// SCORED items. It resets on a wrong answer or skip. Teach cards do not count.
abstract final class SessionStreakRules {
  /// Minimum consecutive correct answers required to display the streak line.
  ///
  /// Default is 2 (e.g. screenshot 5 shows "✨ 3 in a row!").
  /// TODO(question): Confirm with product team if threshold should be 2 or 3.
  static const int streakThreshold = 2;

  /// Computes the updated streak count after an answer is checked.
  ///
  /// - If [isFirstTry] is true and [isCorrect] is true: streak increments by 1.
  /// - If [isCorrect] is false: streak resets to 0.
  /// - If not first try (e.g. in redo round): streak resets to 0.
  static int onAnswerChecked({
    required int currentStreak,
    required bool isCorrect,
    required bool isFirstTry,
  }) {
    if (isFirstTry && isCorrect) {
      return currentStreak + 1;
    }
    return 0;
  }

  /// Streak resets to 0 on explicit skip (e.g. "Can't listen now").
  static int onSkip() => 0;

  /// Returns whether the streak count meets the threshold to be displayed.
  static bool shouldShowStreak(int streak) {
    return streak >= streakThreshold;
  }
}
