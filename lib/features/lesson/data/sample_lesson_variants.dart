import '../domain/exercise.dart';
import '../domain/lesson_set.dart';
import '../domain/match_pair_item.dart';
import '../domain/phrase_token.dart';
import '../domain/picture_option.dart';

/// Test variants for curriculum lessons (redo rounds, RTL Arabic, long phrases).
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract final class SampleLessonVariants {
  /// Arabic (RTL) lesson testing text direction and layout mirroring.
  static LessonSet arabicLesson() {
    return const LessonSet(
      id: 'lesson_arabic_sample',
      stopId: 'arabic_1',
      title: 'التحيات',
      items: [
        NewPhraseCardExercise(
          id: 'ar_item_1',
          phrase: 'مَرْحَبًا',
          tokens: [
            PhraseToken(id: 'ar_tok_1', text: 'مَرْحَبًا', meaning: 'Hello'),
          ],
          meaning: 'Hello',
          picture: '👋',
          registerTag: 'casual',
          phraseKindTag: 'New phrase',
          tipText: 'التحية الأساسية في اللغة العربية.',
          audioText: 'مرحبا',
          audioLocale: 'ar-SA',
          correctAnswerText: 'مَرْحَبًا',
        ),
        PickPictureExercise(
          id: 'ar_item_2',
          prompt: 'Hello',
          audioText: 'مرحبا',
          audioLocale: 'ar-SA',
          options: [
            PictureOption(
              id: 'ar_opt_1',
              imageRef: '👋',
              spokenLabel: 'Waving hand',
            ),
            PictureOption(
              id: 'ar_opt_2',
              imageRef: '🌙',
              spokenLabel: 'Crescent moon',
            ),
          ],
          correctOptionId: 'ar_opt_1',
          correctAnswerText: 'مَرْحَبًا',
          feedbackSuccessText: '“مَرْحَبًا” تعني Hello',
          explanationText: 'مرحبا كلمة تحية عامة.',
        ),
      ],
    );
  }

  /// Very long phrase variant testing 200% text scale and wrap resilience.
  static LessonSet longPhraseLesson() {
    return const LessonSet(
      id: 'lesson_long_phrase',
      stopId: 'long_1',
      title: 'Long Expressions',
      items: [
        NewPhraseCardExercise(
          id: 'long_item_1',
          phrase:
              'Buenos días a todos y bienvenidos a nuestra hermosa ciudad costera',
          tokens: [
            PhraseToken(id: 'lt_1', text: 'Buenos', meaning: 'Good'),
            PhraseToken(id: 'lt_2', text: 'días', meaning: 'days'),
            PhraseToken(id: 'lt_3', text: 'a', meaning: 'to'),
            PhraseToken(id: 'lt_4', text: 'todos', meaning: 'everyone'),
          ],
          meaning:
              'Good morning everyone and welcome to our beautiful coastal city with plenty of sun and sea',
          picture: '🌅',
          registerTag: 'polite',
          tipText:
              'A very long descriptive sentence demonstrating multi-line wrapping.',
          audioText: 'Buenos días a todos',
          audioLocale: 'es-ES',
        ),
        MatchPairsExercise(
          id: 'long_item_2',
          prompt: 'Match the pairs',
          pairs: [
            MatchPairItem(
              id: 'lp_1',
              targetText: 'Mucho gusto en conocerle señorita',
              meaningText: 'Pleased to meet you miss on this fine day',
            ),
            MatchPairItem(
              id: 'lp_2',
              targetText: 'Hasta luego y que tenga un excelente día',
              meaningText: 'See you later and have an excellent day ahead',
            ),
          ],
          displayMeaningIds: ['lp_2', 'lp_1'],
          correctAnswerText: 'Matched',
          feedbackSuccessText: 'Matched!',
          explanationText: 'Long matching pairs.',
        ),
      ],
    );
  }

  /// Arabic (RTL) speaking exercise variant.
  static LessonSet arabicSpeakLesson() {
    return const LessonSet(
      id: 'lesson_arabic_speak',
      stopId: 'arabic_speak_1',
      title: 'التحيات الشفوية',
      items: [
        SpeakExercise(
          id: 'ar_speak_1',
          prompt: 'تحدث بصوت عالٍ',
          phrase: 'مَرْحَبًا، كَيْفَ حَالُكَ؟',
          meaning: 'Hello, how are you?',
          audioText: 'مرحبا كيف حالك',
          audioLocale: 'ar-SA',
          sttLocale: 'ar-SA',
          correctAnswerText: 'مَرْحَبًا، كَيْفَ حَالُكَ؟',
          feedbackSuccessText: 'أحسنت!',
          explanationText: 'قل "مَرْحَبًا، كَيْفَ حَالُكَ؟" بوضوح.',
        ),
      ],
    );
  }

  /// Japanese (CJK) speaking exercise variant.
  static LessonSet japaneseSpeakLesson() {
    return const LessonSet(
      id: 'lesson_japanese_speak',
      stopId: 'japanese_speak_1',
      title: 'あいさつ',
      items: [
        SpeakExercise(
          id: 'ja_speak_1',
          prompt: '声に出して言ってみよう',
          phrase: 'こんにちは、元気ですか？',
          meaning: 'Hello, how are you?',
          helperLine: 'Konnichiwa, genki desu ka?',
          audioText: 'こんにちは、元気ですか？',
          audioLocale: 'ja-JP',
          sttLocale: 'ja-JP',
          correctAnswerText: 'こんにちは、元気ですか？',
          feedbackSuccessText: '素晴らしい！',
          explanationText: '「こんにちは、元気ですか？」とはっきり発音してください。',
        ),
      ],
    );
  }
}
