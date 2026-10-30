/// DTO for an assessment question in `GET /api/lessons/{lesson_id}`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonQuestionDto {
  const LessonQuestionDto({
    required this.questionId,
    required this.questionType,
    this.phraseId,
    this.answerChoices = const [],
    this.hint,
    this.points = 1,
    this.order = 1,
  });

  final String questionId;
  final String questionType;
  final String? phraseId;
  final List<String> answerChoices;
  final String? hint;
  final int points;
  final int order;

  factory LessonQuestionDto.fromJson(Map<String, dynamic> json) {
    return LessonQuestionDto(
      questionId: json['question_id']?.toString() ?? '',
      questionType: json['question_type']?.toString() ?? 'pick_meaning',
      phraseId: json['phrase_id']?.toString(),
      answerChoices:
          (json['answer_choices'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
      hint: json['hint']?.toString(),
      points: (json['points'] as num?)?.toInt() ?? 1,
      order: (json['order'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'question_type': questionType,
    if (phraseId != null) 'phrase_id': phraseId,
    'answer_choices': answerChoices,
    if (hint != null) 'hint': hint,
    'points': points,
    'order': order,
  };
}
