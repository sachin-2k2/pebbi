/// Detailed result recorded per exercise during a session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class ExerciseResult {
  const ExerciseResult({
    required this.exerciseId,
    required this.isFirstTryCorrect,
    required this.hintsUsed,
    required this.attempts,
    this.selectedOptionId,
  });

  final String exerciseId;

  /// Whether the user answered correctly on the very first try without errors.
  final bool isFirstTryCorrect;

  /// Total count of hints invoked for this question.
  final int hintsUsed;

  /// Total number of check attempts made on this question.
  final int attempts;

  /// The final selected option ID.
  final String? selectedOptionId;

  ExerciseResult copyWith({
    String? exerciseId,
    bool? isFirstTryCorrect,
    int? hintsUsed,
    int? attempts,
    String? selectedOptionId,
  }) {
    return ExerciseResult(
      exerciseId: exerciseId ?? this.exerciseId,
      isFirstTryCorrect: isFirstTryCorrect ?? this.isFirstTryCorrect,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      attempts: attempts ?? this.attempts,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    );
  }
}
