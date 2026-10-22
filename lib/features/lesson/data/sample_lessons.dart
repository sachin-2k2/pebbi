import '../domain/exercise.dart';
import '../domain/lesson_set.dart';
import '../domain/match_pair_item.dart';
import '../domain/phrase_token.dart';
import '../domain/picture_option.dart';
import '../domain/text_option.dart';
import '../domain/word_tile_item.dart';

/// Static factory providing realistic sample curriculum lessons.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract final class SampleLessons {
  /// Standard 12-item "Say hello" curriculum lesson (Stop 1).
  static LessonSet sayHelloLesson() {
    return const LessonSet(
      id: 'lesson_say_hello',
      stopId: '1',
      title: 'Say hello',
      items: [
        // Items 1-4: New phrase cards
        NewPhraseCardExercise(
          id: 'item_1',
          phrase: 'Hola',
          tokens: [
            PhraseToken(id: 'token_hola', text: 'Hola', meaning: 'Hello'),
          ],
          meaning: 'Hello',
          picture: '👋',
          registerTag: 'casual',
          phraseKindTag: 'New phrase',
          tipText: "Learn it before you're tested on it — take your time.",
          audioText: 'Hola',
          audioLocale: 'es-ES',
          correctAnswerText: 'Hola',
        ),
        NewPhraseCardExercise(
          id: 'item_2',
          phrase: 'Buenos días',
          tokens: [
            PhraseToken(id: 'token_buenos', text: 'Buenos', meaning: 'Good'),
            PhraseToken(id: 'token_dias', text: 'días', meaning: 'morning'),
          ],
          meaning: 'Good morning',
          picture: '🌅',
          registerTag: 'polite',
          phraseKindTag: 'New phrase',
          tipText: "Learn it before you're tested on it — take your time.",
          audioText: 'Buenos días',
          audioLocale: 'es-ES',
          correctAnswerText: 'Buenos días',
        ),
        NewPhraseCardExercise(
          id: 'item_3',
          phrase: 'Buenas tardes',
          tokens: [
            PhraseToken(id: 'token_buenas', text: 'Buenas', meaning: 'Good'),
            PhraseToken(
              id: 'token_tardes',
              text: 'tardes',
              meaning: 'afternoon',
            ),
          ],
          meaning: 'Good afternoon',
          picture: '🌇',
          registerTag: 'polite',
          phraseKindTag: 'New phrase',
          tipText: "Learn it before you're tested on it — take your time.",
          audioText: 'Buenas tardes',
          audioLocale: 'es-ES',
          correctAnswerText: 'Buenas tardes',
        ),
        NewPhraseCardExercise(
          id: 'item_4',
          phrase: 'Muy bien, gracias',
          tokens: [
            PhraseToken(id: 'token_muy', text: 'Muy', meaning: 'Very'),
            PhraseToken(id: 'token_bien', text: 'bien', meaning: 'well'),
            PhraseToken(
              id: 'token_gracias',
              text: 'gracias',
              meaning: 'thanks',
            ),
          ],
          meaning: "I'm well, thank you",
          picture: '😊',
          registerTag: 'polite',
          phraseKindTag: 'New phrase',
          tipText: "Learn it before you're tested on it — take your time.",
          audioText: 'Muy bien, gracias',
          audioLocale: 'es-ES',
          correctAnswerText: 'Muy bien, gracias',
        ),
        // Item 5: Pick the picture (Hello -> waving hand)
        // TODO(question): Distractor ambiguity between person raising hand 🙋 and waving hand 👋.
        PickPictureExercise(
          id: 'item_5',
          prompt: 'Hello',
          audioText: 'Hola',
          audioLocale: 'es-ES',
          options: [
            PictureOption(
              id: 'opt_raise',
              imageRef: '🙋',
              spokenLabel: 'Person raising hand',
            ),
            PictureOption(
              id: 'opt_wave',
              imageRef: '👋',
              spokenLabel: 'Waving hand',
            ),
            PictureOption(
              id: 'opt_smile',
              imageRef: '😊',
              spokenLabel: 'Smiling face',
            ),
            PictureOption(id: 'opt_sun', imageRef: '☀️', spokenLabel: 'Sun'),
          ],
          correctOptionId: 'opt_wave',
          correctAnswerText: 'Hola',
          feedbackSuccessText: '“Hola” means Hello',
          explanationText:
              '“Hola” is a friendly, universal greeting used at any time.',
        ),
        // Item 6: What does this mean? (Hola -> Hello)
        ChooseMeaningExercise(
          id: 'item_6',
          prompt: 'What does this mean?',
          phrase: 'Hola',
          audioText: 'Hola',
          audioLocale: 'es-ES',
          options: [
            TextOption(id: 'opt_platform', text: 'Platform five'),
            TextOption(id: 'opt_nice', text: 'Nice to meet you'),
            TextOption(id: 'opt_hello', text: 'Hello'),
          ],
          correctOptionId: 'opt_hello',
          correctAnswerText: 'Hello',
          feedbackSuccessText: '“Hola” means Hello',
          explanationText: '“Hola” translates to Hello in English.',
        ),
        // Item 7: Pick the picture (Good morning -> sunrise)
        // TODO(question): Distractor ambiguity between plain sun ☀️ and sunrise 🌅.
        PickPictureExercise(
          id: 'item_7',
          prompt: 'Good morning',
          audioText: 'Buenos días',
          audioLocale: 'es-ES',
          options: [
            PictureOption(
              id: 'opt_train',
              imageRef: '🚇',
              spokenLabel: 'Metro train',
            ),
            PictureOption(
              id: 'opt_wave',
              imageRef: '👋',
              spokenLabel: 'Waving hand',
            ),
            PictureOption(id: 'opt_sun', imageRef: '☀️', spokenLabel: 'Sun'),
            PictureOption(
              id: 'opt_sunrise',
              imageRef: '🌅',
              spokenLabel: 'Sunrise',
            ),
          ],
          correctOptionId: 'opt_sunrise',
          correctAnswerText: 'Buenos días',
          feedbackSuccessText: '“Buenos días” means Good morning',
          explanationText:
              '“Buenos días” is used from waking up until the afternoon.',
        ),
        // Item 8: Match the pairs
        MatchPairsExercise(
          id: 'item_8',
          prompt: 'Match the pairs',
          pairs: [
            MatchPairItem(
              id: 'pair_1',
              targetText: 'Hola',
              meaningText: 'Hello',
            ),
            MatchPairItem(
              id: 'pair_2',
              targetText: 'Buenos días',
              meaningText: 'Good morning',
            ),
            MatchPairItem(
              id: 'pair_3',
              targetText: 'Buenas tardes',
              meaningText: 'Good afternoon',
            ),
          ],
          displayMeaningIds: ['pair_3', 'pair_2', 'pair_1'],
          correctAnswerText:
              'Hola - Hello, Buenos días - Good morning, Buenas tardes - Good afternoon',
          feedbackSuccessText: 'All pairs matched!',
          explanationText:
              'Match each Spanish greeting with its English meaning.',
        ),
        // Item 9: Tap what you hear
        ListenChooseExercise(
          id: 'item_9',
          prompt: 'Tap what you hear',
          audioText: 'Hola',
          audioLocale: 'es-ES',
          options: [
            TextOption(id: 'opt_buenos', text: 'Buenos días'),
            TextOption(id: 'opt_hola', text: 'Hola'),
            TextOption(id: 'opt_derecha', text: 'A la derecha'),
          ],
          correctOptionId: 'opt_hola',
          correctAnswerText: 'Hola',
          feedbackSuccessText: '“Hola” means Hello',
          explanationText: 'You heard "Hola", meaning Hello.',
        ),
        // Item 10: Build the sentence
        BuildSentenceExercise(
          id: 'item_10',
          prompt: 'Good morning',
          audioText: 'Buenos días',
          audioLocale: 'es-ES',
          tiles: [
            WordTileItem(id: 'tile_hola', text: 'Hola'),
            WordTileItem(id: 'tile_buenos', text: 'Buenos'),
            WordTileItem(id: 'tile_dias', text: 'días'),
          ],
          acceptedAnswers: [
            ['tile_buenos', 'tile_dias'],
          ],
          distractorTileIds: ['tile_hola'],
          correctAnswerText: 'Buenos días',
          feedbackSuccessText: '“Buenos días” means Good morning',
          explanationText: '“Buenos” + “días” means "Good morning".',
        ),
        // Item 11: Choose the reply
        ChooseReplyExercise(
          id: 'item_11',
          prompt: 'Choose the reply',
          speakerEmoji: '🧔',
          promptLine: '¿Cómo estás?',
          audioText: '¿Cómo estás?',
          audioLocale: 'es-ES',
          options: [
            TextOption(id: 'opt_delicioso', text: 'Está delicioso'),
            TextOption(id: 'opt_buenos', text: 'Buenos días'),
            TextOption(id: 'opt_muybien', text: 'Muy bien, gracias'),
          ],
          correctOptionId: 'opt_muybien',
          correctAnswerText: 'Muy bien, gracias',
          feedbackSuccessText: '“¿Cómo estás?” means How are you?',
          explanationText:
              'When asked "¿Cómo estás?", answer "Muy bien, gracias".',
        ),
        // Item 12: Say it out loud (Speaking exercise)
        SpeakExercise(
          id: 'item_12',
          prompt: 'Say it out loud',
          phrase: 'Muy bien, gracias',
          meaning: "I'm well, thank you",
          audioText: 'Muy bien, gracias',
          audioLocale: 'es-ES',
          sttLocale: 'es-ES',
          correctAnswerText: 'Muy bien, gracias',
          feedbackSuccessText:
              '“Muy bien, gracias” means I\'m well, thank you',
          explanationText:
              'Say "Muy bien, gracias" clearly into your microphone.',
        ),
      ],
    );
  }
}
