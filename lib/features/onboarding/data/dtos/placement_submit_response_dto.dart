import '../../domain/placement_submission_result.dart';
import '../mapping/level_mapper.dart';

/// Tolerant DTO for `POST /api/placement/submit` response.
class PlacementSubmitResponseDto {
  const PlacementSubmitResponseDto({
    required this.score,
    required this.total,
    required this.scorePct,
    required this.level,
    this.identity,
    this.emoji,
    this.message,
    this.estimatedNote,
  });

  final int score;
  final int total;
  final int scorePct;
  final String level;
  final String? identity;
  final String? emoji;
  final String? message;
  final String? estimatedNote;

  factory PlacementSubmitResponseDto.fromJson(Map<String, dynamic> json) {
    return PlacementSubmitResponseDto(
      score: (json['score'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 8,
      scorePct: (json['score_pct'] as num?)?.toInt() ?? 0,
      level: json['level']?.toString() ?? 'starter',
      identity: json['identity']?.toString(),
      emoji: json['emoji']?.toString(),
      message: json['message']?.toString(),
      estimatedNote: json['estimated_note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'total': total,
    'score_pct': scorePct,
    'level': level,
    if (identity != null) 'identity': identity,
    if (emoji != null) 'emoji': emoji,
    if (message != null) 'message': message,
    if (estimatedNote != null) 'estimated_note': estimatedNote,
  };

  PlacementSubmissionResult toDomain() {
    return PlacementSubmissionResult(
      score: score,
      total: total,
      scorePct: scorePct,
      level: LevelMapper.fromApi(level),
      estimatedNote: estimatedNote,
      identity: identity,
      emoji: emoji,
      message: message,
    );
  }
}
