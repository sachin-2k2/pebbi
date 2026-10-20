import 'exercise.dart';

/// Pure Dart interface for validating exercise answers.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// Decouples client verification from potential future server-side validation.
abstract interface class AnswerChecker {
  /// Evaluates whether [selectedOptionId] is the correct answer for [exercise].
  bool isCorrect(Exercise exercise, String selectedOptionId);

  /// Evaluates whether [placedTileIds] matches an accepted answer for [exercise].
  bool isSentenceCorrect(
    BuildSentenceExercise exercise,
    List<String> placedTileIds,
  );
}

/// Standard client-side implementation of [AnswerChecker].
class StandardAnswerChecker implements AnswerChecker {
  const StandardAnswerChecker();

  @override
  bool isCorrect(Exercise exercise, String selectedOptionId) {
    if (exercise is SingleChoiceExercise) {
      final singleChoice = exercise as SingleChoiceExercise;
      return singleChoice.correctOptionId == selectedOptionId;
    }
    return false;
  }

  @override
  bool isSentenceCorrect(
    BuildSentenceExercise exercise,
    List<String> placedTileIds,
  ) {
    if (placedTileIds.isEmpty) return false;

    // Check exact tile ID sequence match.
    for (final accepted in exercise.acceptedAnswers) {
      if (accepted.length != placedTileIds.length) continue;
      var match = true;
      for (var i = 0; i < accepted.length; i++) {
        if (accepted[i] != placedTileIds[i]) {
          match = false;
          break;
        }
      }
      if (match) return true;
    }

    // Also verify by assembled text sequence (handles duplicate words gracefully).
    final tileMap = {for (final t in exercise.tiles) t.id: t.text};
    final placedText = placedTileIds.map((id) => tileMap[id] ?? '').join(' ');
    return placedText == exercise.correctAnswerText;
  }
}
