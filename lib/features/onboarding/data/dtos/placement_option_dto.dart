import '../../domain/placement_question.dart';

/// Tolerant DTO for a placement question option.
class PlacementOptionDto {
  const PlacementOptionDto({
    required this.emoji,
    required this.label,
    required this.isCorrect,
    this.pebbiCorrect = '',
    this.pebbiWrong = '',
    this.funFact,
  });

  final String emoji;
  final String label;
  final bool isCorrect;
  final String pebbiCorrect;
  final String pebbiWrong;
  final String? funFact;

  factory PlacementOptionDto.fromJson(Map<String, dynamic> json) {
    return PlacementOptionDto(
      emoji: json['emoji']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      pebbiCorrect: json['pebbi_correct']?.toString() ?? '',
      pebbiWrong: json['pebbi_wrong']?.toString() ?? '',
      funFact: json['fun_fact']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'label': label,
    'is_correct': isCorrect,
    'pebbi_correct': pebbiCorrect,
    'pebbi_wrong': pebbiWrong,
    if (funFact != null) 'fun_fact': funFact,
  };

  PlacementOption toDomain() => PlacementOption(
    emoji: emoji,
    label: label,
    isCorrect: isCorrect,
    pebbiCorrect: pebbiCorrect,
    pebbiWrong: pebbiWrong,
    funFact: funFact,
  );
}
