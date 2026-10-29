/// Request and response DTOs for `POST /api/lessons/{lesson_id}/check`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class CheckAnswerRequestDto {
  const CheckAnswerRequestDto({
    required this.questionId,
    required this.chosenAnswer,
  });

  final String questionId;
  final String chosenAnswer;

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'chosen_answer': chosenAnswer,
      };
}

class CheckAnswerResponseDto {
  const CheckAnswerResponseDto({
    required this.questionId,
    required this.isCorrect,
    required this.correctAnswer,
    required this.chosenAnswer,
    this.pointsEarned = 0,
  });

  final String questionId;
  final bool isCorrect;
  final String correctAnswer;
  final String chosenAnswer;
  final int pointsEarned;

  factory CheckAnswerResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckAnswerResponseDto(
      questionId: json['question_id']?.toString() ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      correctAnswer: json['correct_answer']?.toString() ?? '',
      chosenAnswer: json['chosen_answer']?.toString() ?? '',
      pointsEarned: (json['points_earned'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'is_correct': isCorrect,
        'correct_answer': correctAnswer,
        'chosen_answer': chosenAnswer,
        'points_earned': pointsEarned,
      };
}
