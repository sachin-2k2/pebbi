/// DTO for the user's past progress on a lesson stop.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonUserProgressDto {
  const LessonUserProgressDto({
    this.status = 'not_started',
    this.score,
    this.xpEarned = 0,
    this.attempts = 0,
    this.completedAt,
    this.nextLessonId,
  });

  final String status;
  final int? score;
  final int xpEarned;
  final int attempts;
  final String? completedAt;
  final String? nextLessonId;

  factory LessonUserProgressDto.fromJson(Map<String, dynamic> json) {
    return LessonUserProgressDto(
      status: json['status']?.toString() ?? 'not_started',
      score: (json['score'] as num?)?.toInt(),
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      completedAt: json['completed_at']?.toString(),
      nextLessonId: json['next_lesson_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    if (score != null) 'score': score,
    'xp_earned': xpEarned,
    'attempts': attempts,
    if (completedAt != null) 'completed_at': completedAt,
    if (nextLessonId != null) 'next_lesson_id': nextLessonId,
  };
}
