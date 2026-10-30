/// DTO for a vocabulary phrase returned in `GET /api/lessons/{lesson_id}`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonPhraseDto {
  const LessonPhraseDto({
    required this.position,
    required this.phraseId,
    required this.targetText,
    required this.translation,
    this.tags = const [],
    this.imageEmoji,
    this.distractors = const [],
  });

  final int position;
  final String phraseId;
  final String targetText;
  final String translation;
  final List<String> tags;
  final String? imageEmoji;
  final List<String> distractors;

  factory LessonPhraseDto.fromJson(Map<String, dynamic> json) {
    return LessonPhraseDto(
      position: (json['position'] as num?)?.toInt() ?? 1,
      phraseId: json['phrase_id']?.toString() ?? '',
      targetText: json['target_text']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
      tags:
          (json['tags'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
      imageEmoji: json['image_emoji']?.toString(),
      distractors:
          (json['distractors'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'position': position,
    'phrase_id': phraseId,
    'target_text': targetText,
    'translation': translation,
    'tags': tags,
    if (imageEmoji != null) 'image_emoji': imageEmoji,
    'distractors': distractors,
  };
}
