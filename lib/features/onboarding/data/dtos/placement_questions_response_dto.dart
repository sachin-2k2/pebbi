import '../../domain/placement_question.dart';
import '../mapping/level_mapper.dart';
import 'placement_question_dto.dart';

/// Tolerant DTO for `GET /api/placement/questions` response.
class PlacementQuestionsResponseDto {
  const PlacementQuestionsResponseDto({
    required this.available,
    this.total,
    this.questions = const [],
    this.message,
    this.defaultLevel,
  });

  final bool available;
  final int? total;
  final List<PlacementQuestionDto> questions;
  final String? message;
  final String? defaultLevel;

  factory PlacementQuestionsResponseDto.fromJson(Map<String, dynamic> json) {
    final questionsList = json['questions'];
    final parsedQuestions = <PlacementQuestionDto>[];

    if (questionsList is List) {
      for (final q in questionsList) {
        if (q is Map<String, dynamic>) {
          parsedQuestions.add(PlacementQuestionDto.fromJson(q));
        } else if (q is Map) {
          parsedQuestions.add(
            PlacementQuestionDto.fromJson(Map<String, dynamic>.from(q)),
          );
        }
      }
    }

    return PlacementQuestionsResponseDto(
      available: json['available'] as bool? ?? false,
      total: (json['total'] as num?)?.toInt(),
      questions: List.unmodifiable(parsedQuestions),
      message: json['message']?.toString(),
      defaultLevel: json['default_level']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'available': available,
    if (total != null) 'total': total,
    'questions': questions.map((q) => q.toJson()).toList(),
    if (message != null) 'message': message,
    if (defaultLevel != null) 'default_level': defaultLevel,
  };

  PlacementQuestionSet toDomain() {
    return PlacementQuestionSet(
      isAvailable: available,
      total: total ?? questions.length,
      questions: questions.map((q) => q.toDomain()).toList(),
      unavailableMessage: message,
      defaultLevel: LevelMapper.fromApi(defaultLevel),
    );
  }
}
