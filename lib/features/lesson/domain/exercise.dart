import 'picture_option.dart';
import 'text_option.dart';
import 'word_tile_item.dart';

/// Base sealed class for all interactive exercises in Pebbi.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
sealed class Exercise {
  const Exercise({
    required this.id,
    required this.prompt,
    required this.audioText,
    required this.audioLocale,
    required this.explanationText,
    required this.correctAnswerText,
    required this.feedbackSuccessText,
    this.praisePhrase,
  });

  /// Unique identifier of the exercise.
  final String id;

  /// Human-readable prompt displayed to the learner (e.g. "A ticket to Madrid, please").
  final String prompt;

  /// Native phrase to synthesize via TTS (e.g. "Un billete a Madrid, por favor").
  final String audioText;

  /// BCP 47 locale code for TTS synthesis (e.g. "es-ES").
  final String audioLocale;

  /// Detailed grammatical/cultural explanation shown in the "Why?" sheet.
  final String explanationText;

  /// Text representation of the correct answer (e.g. "Un billete a Madrid, por favor" or "Buenos días").
  final String correctAnswerText;

  /// Success message (e.g. "“Un billete a Madrid, por favor” means A ticket to Madrid, please").
  final String feedbackSuccessText;

  /// Optional phrase in target language praised upon first-try success (e.g. "Soy de México").
  final String? praisePhrase;
}

/// Common interface for exercises presenting a single selectable correct option.
abstract interface class SingleChoiceExercise {
  /// List of all candidate option IDs.
  List<String> get optionIds;

  /// ID of the single correct option.
  String get correctOptionId;
}

/// "Pick the picture" exercise type where the learner chooses one picture card from a grid.
class PickPictureExercise extends Exercise implements SingleChoiceExercise {
  const PickPictureExercise({
    required super.id,
    required super.prompt,
    required super.audioText,
    required super.audioLocale,
    required super.explanationText,
    required super.correctAnswerText,
    required super.feedbackSuccessText,
    super.praisePhrase,
    required this.options,
    required this.correctOptionId,
  });

  /// Visual options presented to the learner (typically 4 in a 2x2 grid).
  final List<PictureOption> options;

  /// ID of the correct [PictureOption].
  @override
  final String correctOptionId;

  @override
  List<String> get optionIds => options.map((opt) => opt.id).toList();

  /// Returns the correct [PictureOption] or null if not found.
  PictureOption? get correctOption {
    for (final opt in options) {
      if (opt.id == correctOptionId) return opt;
    }
    return null;
  }
}

/// "What does this mean?" exercise type where the learner hears a target phrase
/// and picks its meaning from 3 text choices.
class ChooseMeaningExercise extends Exercise implements SingleChoiceExercise {
  const ChooseMeaningExercise({
    required super.id,
    required super.prompt,
    required super.audioText,
    required super.audioLocale,
    required super.explanationText,
    required super.correctAnswerText,
    required super.feedbackSuccessText,
    super.praisePhrase,
    required this.phrase,
    this.helperLine,
    required this.options,
    required this.correctOptionId,
  });

  /// The phrase in the target language (e.g. "Soy de México").
  final String phrase;

  /// Optional transliteration, pinyin, or romaji line displayed beneath [phrase].
  final String? helperLine;

  /// Text choices presented to the learner.
  final List<TextOption> options;

  /// ID of the correct [TextOption].
  @override
  final String correctOptionId;

  @override
  List<String> get optionIds => options.map((opt) => opt.id).toList();

  /// Returns the correct [TextOption] or null if not found.
  TextOption? get correctOption {
    for (final opt in options) {
      if (opt.id == correctOptionId) return opt;
    }
    return null;
  }
}

/// "Build the sentence" exercise where the learner arranges word tiles in order.
class BuildSentenceExercise extends Exercise {
  const BuildSentenceExercise({
    required super.id,
    required super.prompt,
    required super.audioText,
    required super.audioLocale,
    required super.explanationText,
    required super.correctAnswerText,
    required super.feedbackSuccessText,
    super.praisePhrase,
    required this.tiles,
    required this.acceptedAnswers,
    this.distractorTileIds = const [],
  });

  /// All available word tiles displayed in the word bank.
  final List<WordTileItem> tiles;

  /// List of accepted tile ID sequences. Each sequence is a list of tile IDs in order.
  final List<List<String>> acceptedAnswers;

  /// IDs of distractor tiles not part of the primary solution.
  final List<String> distractorTileIds;
}
