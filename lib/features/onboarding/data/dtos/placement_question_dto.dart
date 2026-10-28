import '../../domain/placement_question.dart';
import 'placement_option_dto.dart';

/// Tolerant DTO for a placement question item.
class PlacementQuestionDto {
  const PlacementQuestionDto({
    required this.id,
    required this.sortOrder,
    this.difficulty,
    required this.questionText,
    required this.targetPhrase,
    required this.options,
    this.funFact,
    this.pebbiCorrect,
    this.pebbiWrong,
    this.pebbiWarning,
  });

  final String id;
  final int sortOrder;
  final String? difficulty;
  final String questionText;
  final String targetPhrase;
  final List<PlacementOptionDto> options;
  final String? funFact;
  final String? pebbiCorrect;
  final String? pebbiWrong;
  final String? pebbiWarning;

  factory PlacementQuestionDto.fromJson(Map<String, dynamic> json) {
    final optsList = json['options'];
    final parsedOptions = <PlacementOptionDto>[];

    if (optsList is List) {
      for (final opt in optsList) {
        if (opt is Map<String, dynamic>) {
          parsedOptions.add(PlacementOptionDto.fromJson(opt));
        } else if (opt is Map) {
          parsedOptions.add(
            PlacementOptionDto.fromJson(Map<String, dynamic>.from(opt)),
          );
        }
      }
    }

    return PlacementQuestionDto(
      id: json['id']?.toString() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString(),
      questionText:
          json['prompt']?.toString() ?? json['question_text']?.toString() ?? '',
      targetPhrase: json['target_phrase']?.toString() ?? '',
      options: List.unmodifiable(parsedOptions),
      funFact: json['fun_fact']?.toString(),
      pebbiCorrect: json['pebbi_correct']?.toString(),
      pebbiWrong: json['pebbi_wrong']?.toString(),
      pebbiWarning: json['pebbi_warning']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sort_order': sortOrder,
    if (difficulty != null) 'difficulty': difficulty,
    'question_text': questionText,
    'target_phrase': targetPhrase,
    'options': options.map((o) => o.toJson()).toList(),
    if (funFact != null) 'fun_fact': funFact,
    if (pebbiCorrect != null) 'pebbi_correct': pebbiCorrect,
    if (pebbiWrong != null) 'pebbi_wrong': pebbiWrong,
    if (pebbiWarning != null) 'pebbi_warning': pebbiWarning,
  };

  PlacementQuestion toDomain() => PlacementQuestion(
    id: id,
    sortOrder: sortOrder,
    difficulty: difficulty,
    questionText: questionText,
    targetPhrase: targetPhrase,
    options: options.map((o) => o.toDomain()).toList(),
    funFact: funFact,
    pebbiCorrect: pebbiCorrect,
    pebbiWrong: pebbiWrong,
    pebbiWarning: pebbiWarning,
  );
}
