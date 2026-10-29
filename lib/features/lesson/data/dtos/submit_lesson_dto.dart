/// Request and response DTOs for `POST /api/lessons/{lesson_id}/submit`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class SubmitLessonAnswerItemDto {
  const SubmitLessonAnswerItemDto({
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

class SubmitLessonRequestDto {
  const SubmitLessonRequestDto({
    required this.answers,
  });

  final List<SubmitLessonAnswerItemDto> answers;

  Map<String, dynamic> toJson() => {
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}

class SubmitLessonResponseDto {
  const SubmitLessonResponseDto({
    required this.passed,
    required this.score,
    required this.total,
    required this.scorePct,
    this.xpAwarded = 0,
    this.nextLessonId,
    this.pebbiSays,
  });

  final bool passed;
  final int score;
  final int total;
  final int scorePct;
  final int xpAwarded;
  final String? nextLessonId;
  final String? pebbiSays;

  factory SubmitLessonResponseDto.fromJson(Map<String, dynamic> json) {
    return SubmitLessonResponseDto(
      passed: json['passed'] as bool? ?? false,
      score: (json['score'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      scorePct: (json['score_pct'] as num?)?.toInt() ?? 0,
      xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 0,
      nextLessonId: json['next_lesson_id']?.toString(),
      pebbiSays: json['pebbi_says']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'passed': passed,
        'score': score,
        'total': total,
        'score_pct': scorePct,
        'xp_awarded': xpAwarded,
        if (nextLessonId != null) 'next_lesson_id': nextLessonId,
        if (pebbiSays != null) 'pebbi_says': pebbiSays,
      };
}
