/// Represents an answered question in the placement quiz.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class PlacementAnswer {
  const PlacementAnswer({required this.questionId, required this.chosenEmoji});

  final String questionId;
  final String chosenEmoji;

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'chosen_emoji': chosenEmoji,
  };
}
