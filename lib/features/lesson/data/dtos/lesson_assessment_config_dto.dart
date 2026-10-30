/// DTO for assessment rules in `GET /api/lessons/{lesson_id}`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonAssessmentConfigDto {
  const LessonAssessmentConfigDto({
    this.totalQuestions = 6,
    this.passScore = 4,
    this.includeSpeakAttempt = false,
  });

  final int totalQuestions;
  final int passScore;
  final bool includeSpeakAttempt;

  factory LessonAssessmentConfigDto.fromJson(Map<String, dynamic> json) {
    return LessonAssessmentConfigDto(
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 6,
      passScore: (json['pass_score'] as num?)?.toInt() ?? 4,
      includeSpeakAttempt: json['include_speak_attempt'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_questions': totalQuestions,
    'pass_score': passScore,
    'include_speak_attempt': includeSpeakAttempt,
  };
}
