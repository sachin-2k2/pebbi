import '../../../onboarding/domain/placement_question.dart';
import '../../domain/exercise.dart';
import '../../domain/exercise_mode.dart';
import '../../domain/exercise_set.dart';
import '../../domain/picture_option.dart';

/// Pure domain mapper converting [PlacementQuestionSet] from the placement API
/// into an [ExerciseSet] composed of [PickPictureExercise]s.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract final class PlacementExerciseMapper {
  /// Converts [questionSet] into an [ExerciseSet] for placement testing.
  static ExerciseSet toExerciseSet({
    required PlacementQuestionSet questionSet,
    required String targetLanguageCode,
    required String nativeLanguageCode,
  }) {
    final exercises = <Exercise>[];
    final locale = resolveAudioLocale(targetLanguageCode);

    for (final q in questionSet.sortedValidQuestions) {
      final options = <PictureOption>[];
      String? correctId;

      for (var i = 0; i < q.options.length; i++) {
        final opt = q.options[i];
        final id = 'opt_${q.id}_$i';
        options.add(
          PictureOption(id: id, imageRef: opt.emoji, spokenLabel: opt.label),
        );
        if (opt.isCorrect) {
          correctId = id;
        }
      }

      correctId ??= options.isNotEmpty ? options.first.id : '';

      final correctOption = q.options.firstWhere(
        (o) => o.isCorrect,
        orElse: () => q.options.first,
      );

      final prompt = q.targetPhrase.trim().isNotEmpty
          ? q.targetPhrase.trim()
          : cleanPromptText(q.questionText, correctOption.label);

      final audioText = cleanAudioText(
        q.targetPhrase.trim().isNotEmpty
            ? q.targetPhrase.trim()
            : correctOption.label,
      );

      final cleanCorrectLabel = correctOption.label
          .replaceAll(
            RegExp(
              r'\s*[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
              unicode: true,
            ),
            '',
          )
          .trim();

      final meaning = (cleanCorrectLabel != q.targetPhrase)
          ? cleanCorrectLabel
          : cleanPromptText(q.questionText, cleanCorrectLabel);

      final feedbackSuccess = (q.targetPhrase.isNotEmpty && meaning.isNotEmpty)
          ? '“${q.targetPhrase}” means $meaning'
          : (q.pebbiCorrect ?? 'Nice one!');

      final explanation = q.funFact ?? correctOption.funFact ?? '';

      exercises.add(
        PickPictureExercise(
          id: q.id,
          prompt: prompt,
          audioText: audioText,
          audioLocale: locale,
          explanationText: explanation,
          correctAnswerText: prompt,
          feedbackSuccessText: feedbackSuccess,
          praisePhrase: q.targetPhrase,
          options: options,
          correctOptionId: correctId,
        ),
      );
    }

    return ExerciseSet(
      id: 'placement_set_${nativeLanguageCode}_$targetLanguageCode',
      title: 'Placement Quick Check',
      mode: ExerciseMode.placement,
      exercises: exercises,
    );
  }

  /// Extracts the readable prompt text beneath "Pick the picture".
  static String cleanPromptText(String questionText, String fallback) {
    if (questionText.trim().isEmpty) return fallback;

    // If the question is in the format: Which one means 'Good morning'? -> extract Good morning
    final quoteMatch = RegExp(
      r"['\u2018\u2019\u201c\u201d](.*?)['\u2018\u2019\u201c\u201d]",
    ).firstMatch(questionText);
    if (quoteMatch != null && quoteMatch.group(1)!.trim().isNotEmpty) {
      return quoteMatch.group(1)!.trim();
    }

    // Strip trailing/leading emojis
    final cleaned = questionText
        .replaceAll(
          RegExp(
            r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
            unicode: true,
          ),
          '',
        )
        .trim();

    if (cleaned.endsWith('!')) {
      return cleaned.substring(0, cleaned.length - 1).trim();
    }
    return cleaned.isNotEmpty ? cleaned : fallback;
  }

  /// Resolves the BCP 47 locale code for TTS synthesis.
  static String resolveAudioLocale(String languageCode) {
    switch (languageCode.toLowerCase().trim()) {
      case 'ml':
        return 'ml-IN';
      case 'es':
        return 'es-ES';
      case 'fr':
        return 'fr-FR';
      case 'de':
        return 'de-DE';
      case 'ja':
        return 'ja-JP';
      case 'ar':
        return 'ar-SA';
      case 'en':
      default:
        return 'en-US';
    }
  }

  /// Cleans [text] for audio TTS synthesis:
  /// - Strips emoji symbols (e.g. 👋, 🙏)
  /// - Strips parenthesized or bracketed transliterations (e.g. "(Namaskaram)")
  ///   which causes the TTS engine to read both the target script and the transliteration,
  ///   sounding like the phrase is spoken twice.
  static String cleanAudioText(String text) {
    if (text.trim().isEmpty) return text;

    final withoutEmojis = text.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      ),
      '',
    );

    final withoutParens = withoutEmojis
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '')
        .trim();

    if (withoutParens.isNotEmpty) {
      return withoutParens;
    }

    final stripped = withoutEmojis
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim();

    return stripped.isNotEmpty ? stripped : text.trim();
  }
}
