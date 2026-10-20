import 'picture_option_dto.dart';
import 'text_option_dto.dart';
import 'word_tile_dto.dart';

/// Data Transfer Object representing an exercise payload from the API.
class ExerciseDto {
  const ExerciseDto({
    required this.id,
    required this.type,
    required this.prompt,
    required this.audioText,
    required this.audioLocale,
    required this.explanationText,
    required this.correctAnswerText,
    required this.feedbackSuccessText,
    this.options = const [],
    this.textOptions = const [],
    this.tiles = const [],
    this.acceptedAnswers = const [],
    this.distractorTileIds = const [],
    this.correctOptionId,
    this.phrase,
    this.helperLine,
    this.praisePhrase,
  });

  final String id;
  final String type;
  final String prompt;
  final String audioText;
  final String audioLocale;
  final String explanationText;
  final String correctAnswerText;
  final String feedbackSuccessText;
  final List<PictureOptionDto> options;
  final List<TextOptionDto> textOptions;
  final List<WordTileDto> tiles;
  final List<List<String>> acceptedAnswers;
  final List<String> distractorTileIds;
  final String? correctOptionId;
  final String? phrase;
  final String? helperLine;
  final String? praisePhrase;

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      id: json['id'] as String,
      type: json['type'] as String,
      prompt: json['prompt'] as String,
      audioText: json['audio_text'] as String,
      audioLocale: json['audio_locale'] as String,
      explanationText: json['explanation_text'] as String,
      correctAnswerText: json['correct_answer_text'] as String,
      feedbackSuccessText: json['feedback_success_text'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => PictureOptionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      textOptions:
          (json['text_options'] as List<dynamic>?)
              ?.map((e) => TextOptionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tiles:
          (json['tiles'] as List<dynamic>?)
              ?.map((e) => WordTileDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      acceptedAnswers:
          (json['accepted_answers'] as List<dynamic>?)
              ?.map(
                (inner) =>
                    (inner as List<dynamic>).map((e) => e as String).toList(),
              )
              .toList() ??
          const [],
      distractorTileIds:
          (json['distractor_tile_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctOptionId: json['correct_option_id'] as String?,
      phrase: json['phrase'] as String?,
      helperLine: json['helper_line'] as String?,
      praisePhrase: json['praise_phrase'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'prompt': prompt,
    'audio_text': audioText,
    'audio_locale': audioLocale,
    'explanation_text': explanationText,
    'correct_answer_text': correctAnswerText,
    'feedback_success_text': feedbackSuccessText,
    'options': options.map((e) => e.toJson()).toList(),
    'text_options': textOptions.map((e) => e.toJson()).toList(),
    'tiles': tiles.map((e) => e.toJson()).toList(),
    'accepted_answers': acceptedAnswers,
    'distractor_tile_ids': distractorTileIds,
    'correct_option_id': correctOptionId,
    if (phrase != null) 'phrase': phrase,
    if (helperLine != null) 'helper_line': helperLine,
    if (praisePhrase != null) 'praise_phrase': praisePhrase,
  };
}
