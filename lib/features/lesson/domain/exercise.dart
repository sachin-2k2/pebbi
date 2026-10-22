import 'audio_playback_rates.dart';
import 'match_pair_item.dart';
import 'phrase_token.dart';
import 'picture_option.dart';
import 'text_option.dart';
import 'word_tile_item.dart';

/// Base sealed class for all interactive exercises and lesson items in Pebbi.
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

  /// Human-readable prompt displayed to the learner.
  final String prompt;

  /// Native phrase to synthesize via TTS (e.g. "Hola").
  final String audioText;

  /// BCP 47 locale code for TTS synthesis (e.g. "es-ES").
  final String audioLocale;

  /// Detailed grammatical/cultural explanation shown in the "Why?" sheet.
  final String explanationText;

  /// Text representation of the correct answer.
  final String correctAnswerText;

  /// Success message shown in feedback panel.
  final String feedbackSuccessText;

  /// Optional phrase in target language praised upon first-try success.
  final String? praisePhrase;
}

/// Common interface for exercises presenting a single selectable correct option.
abstract interface class SingleChoiceExercise {
  /// List of all candidate option IDs.
  List<String> get optionIds;

  /// ID of the single correct option.
  String get correctOptionId;
}

/// "New phrase" teach card introducing a phrase before exercises begin.
class NewPhraseCardExercise extends Exercise {
  const NewPhraseCardExercise({
    required super.id,
    required this.phrase,
    required this.tokens,
    required this.meaning,
    required this.picture,
    required this.registerTag,
    this.phraseKindTag = 'New phrase',
    required this.tipText,
    required super.audioText,
    required super.audioLocale,
    this.slowAudioRate = AudioPlaybackRates.slow,
    super.explanationText = '',
    super.correctAnswerText = '',
    super.feedbackSuccessText = '',
    super.praisePhrase,
  }) : super(prompt: phrase);

  /// Target language phrase (e.g. "Hola", "Buenos días").
  final String phrase;

  /// Tokens split from data (never split on whitespace in code).
  final List<PhraseToken> tokens;

  /// Native translated meaning (e.g. "Hello", "Good morning").
  final String meaning;

  /// Visual representation (emoji or asset path e.g. '👋', '🌅').
  final String picture;

  /// Register descriptor (e.g. 'casual', 'polite').
  final String registerTag;

  /// Tag identifying the card kind (e.g. 'New phrase').
  final String phraseKindTag;

  /// Pedagogical tip displayed in the Pebbi speech bubble.
  final String tipText;

  /// Playback rate for slow speed audio.
  final double slowAudioRate;
}

/// "Match the pairs" exercise with two equal columns of target phrases and meanings.
class MatchPairsExercise extends Exercise {
  const MatchPairsExercise({
    required super.id,
    required super.prompt,
    required this.pairs,
    required this.displayMeaningIds,
    super.audioText = '',
    super.audioLocale = 'es-ES',
    required super.explanationText,
    required super.correctAnswerText,
    required super.feedbackSuccessText,
    super.praisePhrase,
  });

  /// The list of matching pairs.
  final List<MatchPairItem> pairs;

  /// Shuffled order of pair IDs for the right-hand (meaning) column.
  final List<String> displayMeaningIds;
}

/// "Tap what you hear" exercise with large halo audio button and target-language text cards.
class ListenChooseExercise extends Exercise implements SingleChoiceExercise {
  const ListenChooseExercise({
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

  /// Text choices presented to the learner in the target language.
  final List<TextOption> options;

  @override
  final String correctOptionId;

  @override
  List<String> get optionIds => options.map((opt) => opt.id).toList();

  TextOption? get correctOption {
    for (final opt in options) {
      if (opt.id == correctOptionId) return opt;
    }
    return null;
  }
}

/// "Choose the reply" exercise presenting a speaker dialogue bubble and target replies.
class ChooseReplyExercise extends Exercise implements SingleChoiceExercise {
  const ChooseReplyExercise({
    required super.id,
    required super.prompt,
    required this.speakerEmoji,
    required this.promptLine,
    required super.audioText,
    required super.audioLocale,
    required super.explanationText,
    required super.correctAnswerText,
    required super.feedbackSuccessText,
    super.praisePhrase,
    required this.options,
    required this.correctOptionId,
  });

  /// Emoji representing the speaker character (e.g. '🧔').
  final String speakerEmoji;

  /// Dialogue line in target language (e.g. "¿Cómo estás?").
  final String promptLine;

  /// Candidate reply options in the target language.
  final List<TextOption> options;

  @override
  final String correctOptionId;

  @override
  List<String> get optionIds => options.map((opt) => opt.id).toList();

  TextOption? get correctOption {
    for (final opt in options) {
      if (opt.id == correctOptionId) return opt;
    }
    return null;
  }
}

/// Placeholder for Item 12 (Speaking exercise) to be built in Part 2.
class SpeakingPlaceholderExercise extends Exercise {
  const SpeakingPlaceholderExercise({
    required super.id,
    super.prompt = 'Say it out loud',
    this.placeholderMessage = 'Speaking exercise\n(coming next)',
    super.audioText = '',
    super.audioLocale = 'es-ES',
    super.explanationText = '',
    super.correctAnswerText = '',
    super.feedbackSuccessText = '',
    super.praisePhrase,
  });

  final String placeholderMessage;
}

/// "Say it out loud" exercise where the learner speaks the phrase into the microphone.
class SpeakExercise extends Exercise {
  const SpeakExercise({
    required super.id,
    super.prompt = 'Say it out loud',
    required this.phrase,
    required this.meaning,
    required super.audioText,
    required super.audioLocale,
    this.sttLocale = 'es-ES',
    this.helperLine,
    super.explanationText = '',
    super.correctAnswerText = '',
    super.feedbackSuccessText = 'Nice one!',
    super.praisePhrase,
  });

  /// Target phrase in the learning language to speak aloud.
  final String phrase;

  /// Meaning in the explanation language.
  final String meaning;

  /// Speech recognition locale tag (e.g. 'es-ES', 'es-MX', 'ja-JP').
  final String sttLocale;

  /// Optional transliteration or pronunciation guide.
  final String? helperLine;
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

  @override
  final String correctOptionId;

  @override
  List<String> get optionIds => options.map((opt) => opt.id).toList();

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

  @override
  final String correctOptionId;

  @override
  List<String> get optionIds => options.map((opt) => opt.id).toList();

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

  /// List of accepted tile ID sequences.
  final List<List<String>> acceptedAnswers;

  /// IDs of distractor tiles not part of the primary solution.
  final List<String> distractorTileIds;
}
