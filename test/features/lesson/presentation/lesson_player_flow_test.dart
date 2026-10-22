import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/fake_speech_recognizer_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/theme/app_theme.dart';
import 'package:peddi/features/lesson/domain/audio_playback_rates.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:peddi/features/lesson/presentation/screens/exercise_screen.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/audio_play_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/check_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/exercise_bottom_bar.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/exercise_header.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/feedback_panel.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/hint_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/listen/cant_listen_link.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/match/match_card.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/new_phrase/phrase_card.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/new_phrase/speed_buttons.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/picture_option_card.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/sentence/word_tile.dart';
import 'package:peddi/features/review/data/mock_phrase_repository.dart';
import 'package:peddi/features/review/presentation/providers/review_provider.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  group('Lesson Player Flow & Item Visual States', () {
    late FakeSpeechService fakeSpeech;
    late FakeAudioFeedbackService fakeAudio;
    late FakeSpeechRecognizerService fakeRecognizer;
    late MockPhraseRepository mockPhraseRepo;

    setUp(() {
      fakeSpeech = FakeSpeechService();
      fakeAudio = FakeAudioFeedbackService();
      fakeRecognizer = FakeSpeechRecognizerService();
      mockPhraseRepo = MockPhraseRepository();
    });

    Widget createScreen({
      String stopId = '1',
      bool autoplay = false,
      VoidCallback? onCompleted,
    }) {
      return ProviderScope(
        overrides: [
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
          audioFeedbackServiceProvider.overrideWithValue(fakeAudio),
          speechRecognizerServiceProvider.overrideWithValue(fakeRecognizer),
          phraseRepositoryProvider.overrideWithValue(mockPhraseRepo),
          appSettingsProvider.overrideWith(
            (ref) => _FakeAppSettingsNotifier(AppSettings(autoplay: autoplay)),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: ExerciseScreen(stopId: stopId, onCompleted: onCompleted),
        ),
      );
    }

    testWidgets(
      'Item 1 & 2: New Phrase Cards layout, speed buttons, and token saving',
      (tester) async {
        await tester.pumpWidget(createScreen(autoplay: false));
        await tester.pumpAndSettle();

        // Header counter shows 1/12
        expect(find.byType(ExerciseHeader), findsOneWidget);
        expect(find.text('1/12'), findsOneWidget);

        // Tags: "New phrase" and "casual"
        expect(find.text(AppStrings.newPhraseTag), findsOneWidget);
        expect(find.text(AppStrings.casualRegisterTag), findsOneWidget);

        // Card content: emoji 👋, phrase "Hola", meaning "Hello"
        expect(find.byType(PhraseCard), findsOneWidget);
        expect(find.text('👋'), findsOneWidget);
        expect(find.text('Hola'), findsOneWidget);
        expect(find.text('Hello'), findsOneWidget);

        // Speed buttons: Normal and Slow
        expect(find.byType(SpeedButtons), findsOneWidget);
        await tester.tap(find.text('🔊 ${AppStrings.speedNormal}'));
        await tester.pump();
        expect(fakeSpeech.lastSpokenText, equals('Hola'));
        expect(fakeSpeech.lastSpeechRate, equals(AudioPlaybackRates.normal));

        await tester.tap(find.text('🐢 ${AppStrings.speedSlow}'));
        await tester.pump();
        expect(fakeSpeech.lastSpokenText, equals('Hola'));
        expect(fakeSpeech.lastSpeechRate, equals(AudioPlaybackRates.slow));

        // Token saving tap
        expect(find.byIcon(Icons.star_rounded), findsNothing);
        await tester.tap(find.text('Hola'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.star_rounded), findsOneWidget);

        // Bottom bar: gotIt mode
        expect(find.byType(ExerciseBottomBar), findsOneWidget);
        expect(find.text(AppStrings.gotIt), findsOneWidget);
        expect(find.byType(HintButton), findsNothing);

        // Tap "Got it" advances to Item 2
        await tester.tap(find.text(AppStrings.gotIt));
        await tester.pumpAndSettle();

        // Item 2: counter 2/12, polite tag, 🌅, Buenos días, Good morning
        expect(find.text('2/12'), findsOneWidget);
        expect(find.text(AppStrings.politeRegisterTag), findsOneWidget);
        expect(find.text('🌅'), findsOneWidget);
        expect(find.text('Buenos'), findsOneWidget);
        expect(find.text('días'), findsOneWidget);
        expect(find.text('Good morning'), findsOneWidget);
      },
    );

    testWidgets('Autoplay plays speech only when setting enabled', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen(autoplay: true));
      await tester.pumpAndSettle();

      // Autoplay triggered on mount
      expect(fakeSpeech.lastSpokenText, equals('Hola'));
      expect(fakeSpeech.lastSpeechRate, equals(AudioPlaybackRates.normal));
    });

    testWidgets('Item 5: Pick the picture (Hello -> waving hand)', (
      tester,
    ) async {
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Advance through Items 1-4 (Got it)
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text(AppStrings.gotIt));
        await tester.pumpAndSettle();
      }

      // Now at Item 5 (Pick the picture)
      expect(find.text('5/12'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(PictureOptionCard), findsNWidgets(4));

      // Select waving hand 👋
      await tester.tap(find.text('👋'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckButton), findsOneWidget);

      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackPanel), findsOneWidget);
      expect(find.text('“Hola” means Hello'), findsOneWidget);

      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
    });

    testWidgets('Item 6 & 7: What does this mean & streak line in Item 7', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Skip to Item 6
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text(AppStrings.gotIt));
        await tester.pumpAndSettle();
      }
      // Answer Item 5
      await tester.tap(find.text('👋'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Item 6: What does this mean? (Hola) with AudioPlayButton halo
      expect(find.text('6/12'), findsOneWidget);
      expect(find.text(AppStrings.whatDoesThisMean), findsOneWidget);
      expect(find.byType(AudioPlayButton), findsOneWidget);

      // Select "Hello"
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();

      // Item 6 correct: streak is 2, shows "✨ 2 in a row!"
      expect(find.text('✨ ${AppStrings.streakInARow(2)}'), findsOneWidget);
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Item 7: Pick the picture (Good morning -> sunrise 🌅)
      expect(find.text('7/12'), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
      await tester.tap(find.text('🌅'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();

      // Item 7 correct: streak is 3, shows "✨ 3 in a row!" exactly as in screenshot 5
      expect(find.text('✨ ${AppStrings.streakInARow(3)}'), findsOneWidget);
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'Item 8: Match the pairs works in both tap orders & handles mistakes',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(createScreen());
        await tester.pumpAndSettle();

        // Jump to Item 8
        for (int i = 0; i < 4; i++) {
          await tester.tap(find.text(AppStrings.gotIt));
          await tester.pumpAndSettle();
        }
        // Q5
        await tester.tap(find.text('👋'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // Q6
        await tester.tap(find.text('Hello'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();
        // Q7
        await tester.tap(find.text('🌅'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.check));
        await tester.pumpAndSettle();
        await tester.tap(find.text(AppStrings.continueExercise));
        await tester.pumpAndSettle();

        // Now at Item 8 (Match the pairs)
        expect(find.text('8/12'), findsOneWidget);
        expect(find.text(AppStrings.matchPairsTitle), findsOneWidget);
        expect(find.text('0 of 3 matched'), findsOneWidget);
        expect(find.byType(MatchCard), findsNWidgets(6));

        // Test Mismatch: tap "Hola" then "Good morning"
        await tester.tap(find.text('Hola'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Good morning'));
        await tester.pumpAndSettle();
        // Selection cleared, still 0 of 3 matched
        expect(find.text('0 of 3 matched'), findsOneWidget);

        // Test Match 1: Target then meaning (Hola -> Hello)
        await tester.tap(find.text('Hola'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hello'));
        await tester.pumpAndSettle();
        expect(find.text('1 of 3 matched'), findsOneWidget);

        // Test Match 2: Meaning then target (Good afternoon -> Buenas tardes)
        await tester.tap(find.text('Good afternoon'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buenas tardes'));
        await tester.pumpAndSettle();
        expect(find.text('2 of 3 matched'), findsOneWidget);

        // Test Match 3: Buenos días -> Good morning
        await tester.tap(find.text('Buenos días'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Good morning'));
        await tester.pumpAndSettle();

        // All pairs matched! Shows FeedbackPanel
        expect(find.byType(FeedbackPanel), findsOneWidget);
        expect(find.text('All pairs matched!'), findsOneWidget);
      },
    );

    testWidgets('Item 9: Tap what you hear & Can\'t listen now skip link', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(createScreen());
      await tester.pumpAndSettle();

      // Fast forward to Item 9
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text(AppStrings.gotIt));
        await tester.pumpAndSettle();
      }
      // Item 5
      await tester.tap(find.text('👋'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // Item 6
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // Item 7
      await tester.tap(find.text('🌅'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Item 8 (Match)
      await tester.tap(find.text('Hola'));
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buenos días'));
      await tester.tap(find.text('Good morning'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buenas tardes'));
      await tester.tap(find.text('Good afternoon'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // Now at Item 9
      expect(find.text('9/12'), findsOneWidget);
      expect(find.text(AppStrings.tapWhatYouHearTitle), findsOneWidget);
      expect(find.byType(AudioPlayButton), findsOneWidget);
      expect(find.byType(CantListenLink), findsOneWidget);

      // Tapping "Can't listen now" skips without penalty to Item 10
      await tester.tap(find.text(AppStrings.cantListenNow));
      await tester.pumpAndSettle();

      // Now at Item 10 (Build the sentence)
      expect(find.text('10/12'), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.byType(WordTile), findsNWidgets(3));
    });

    testWidgets('Full 12-item flow completes with Speaking item & Self-Check', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      bool completed = false;
      await tester.pumpWidget(
        createScreen(onCompleted: () => completed = true),
      );
      await tester.pumpAndSettle();

      // 1-4
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text(AppStrings.gotIt));
        await tester.pumpAndSettle();
      }
      // 5: 👋
      await tester.tap(find.text('👋'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // 6: Hello
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // 7: 🌅
      await tester.tap(find.text('🌅'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // 8: Match pairs
      await tester.tap(find.text('Hola'));
      await tester.tap(find.text('Hello'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buenos días'));
      await tester.tap(find.text('Good morning'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buenas tardes'));
      await tester.tap(find.text('Good afternoon'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // 9: Tap what you hear -> Hola
      await tester.tap(find.text('Hola'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // 10: Build sentence -> Buenos + días
      await tester.tap(find.text('Buenos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('días'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();
      // 11: Choose the reply -> Muy bien, gracias
      expect(find.text('11/12'), findsOneWidget);
      expect(find.text('¿Cómo estás?'), findsOneWidget);
      await tester.tap(find.text('Muy bien, gracias'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      // 12: Speaking item (Say it out loud)
      expect(find.text('12/12'), findsOneWidget);
      expect(find.text('Muy bien, gracias'), findsOneWidget);
      expect(find.text(AppStrings.speakTapMicPrompt), findsOneWidget);

      // Tap rather not speak -> goes to Self-Check (Screen B)
      await tester.tap(find.text(AppStrings.speakRatherNotAction));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.selfCheckTitle), findsOneWidget);

      // Tap "I said it ✓" awards credit and reveals feedback panel
      await tester.tap(find.text(
        '${AppStrings.selfCheckSaidItAction}  ${AppStrings.selfCheckHalfCreditLabel}',
      ));
      await tester.pumpAndSettle();

      // Tap Continue finishes lesson
      await tester.tap(find.text(AppStrings.continueExercise));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });
  });
}

class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(AppSettings initial) {
    state = initial;
  }
}
