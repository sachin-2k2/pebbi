import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/fake_speech_recognizer_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/lesson_repository.dart';
import 'package:peddi/features/lesson/domain/lesson_set.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:peddi/features/lesson/presentation/screens/exercise_screen.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/feedback_panel.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/speaking/level_dots.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/speaking/mic_button.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/speaking/self_check_body.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/speaking/speak_body.dart';
import 'package:peddi/features/settings/domain/app_settings.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

class _FakeTtsService implements TextToSpeechService {
  String? lastSpokenText;
  String? lastLocale;
  int speakCount = 0;
  int stopCount = 0;

  @override
  Future<bool> speak(String text, {required String locale, double? speechRate}) async {
    lastSpokenText = text;
    lastLocale = locale;
    speakCount++;
    return true;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }

  @override
  void dispose() {}
}


class _FakeAppSettingsNotifier extends AppSettingsNotifier {
  _FakeAppSettingsNotifier(AppSettings initial) {
    state = initial;
  }
}

class _FakeCurrentUserNotifier extends CurrentUserNotifier {
  _FakeCurrentUserNotifier(UserProfile? initial)
      : super(MockProfileRepository(), initial);
}

UserProfile _createTestProfile(String id, {AgeBand ageBand = AgeBand.adult}) {
  return UserProfile(
    userId: id,
    ageBand: ageBand,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: const {'travel'},
    dailyGoalId: 'regular',
    reminderTime: const ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: const {1, 2, 3, 4, 5},
    remindersEnabled: true,
    accentId: 'purple',
    plan: 'free',
  );
}

class _FakeLessonRepository implements LessonRepository {
  _FakeLessonRepository(this.lesson);
  final LessonSet lesson;
  @override
  Future<LessonSet> loadLesson(String stopId) async => lesson;
}

void main() {
  const sampleSpeakExercise = SpeakExercise(
    id: 'speak_item_test',
    prompt: 'Say it out loud',
    phrase: 'Muy bien, gracias',
    meaning: "I'm well, thank you",
    audioText: 'Muy bien, gracias',
    audioLocale: 'es-ES',
    sttLocale: 'es-ES',
    correctAnswerText: 'Muy bien, gracias',
    feedbackSuccessText: "“Muy bien, gracias” means I'm well, thank you",
  );

  final sampleLesson = const LessonSet(
    id: 'lesson_test',
    stopId: 'stop_test',
    title: 'Test Lesson',
    items: [sampleSpeakExercise],
  );

  Widget createSubject({
    required FakeSpeechRecognizerService recognizer,
    required _FakeTtsService tts,
    AppSettings settings = const AppSettings(),
    UserProfile? user,
  }) {
    return ProviderScope(
      overrides: [
        lessonRepositoryProvider.overrideWithValue(
          _FakeLessonRepository(sampleLesson),
        ),
        speechRecognizerServiceProvider.overrideWithValue(recognizer),
        textToSpeechServiceProvider.overrideWithValue(tts),
        appSettingsProvider.overrideWith(
          (ref) => _FakeAppSettingsNotifier(settings),
        ),
        currentUserProvider.overrideWith(
          (ref) => _FakeCurrentUserNotifier(user),
        ),
      ],
      child: const MaterialApp(
        home: ExerciseScreen(stopId: 'stop_test'),
      ),
    );
  }

  group('SpeakExercise & SelfCheck UI Flow', () {
    late FakeSpeechRecognizerService fakeRecognizer;
    late _FakeTtsService fakeTts;

    setUp(() {
      fakeRecognizer = FakeSpeechRecognizerService();
      fakeTts = _FakeTtsService();
    });

    testWidgets('renders Screen A with phrase card, dots, mic, and tip note',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SpeakBody), findsOneWidget);
      expect(find.text('Muy bien, gracias'), findsOneWidget);
      expect(find.text("I'm well, thank you"), findsOneWidget);
      expect(find.text(AppStrings.hearIt), findsOneWidget);
      expect(find.byType(LevelDots), findsOneWidget);
      expect(find.byType(MicButton), findsOneWidget);
      expect(find.text(AppStrings.speakTapMicPrompt), findsOneWidget);
      expect(find.text(AppStrings.speakRatherNotAction), findsOneWidget);
      expect(find.text(AppStrings.speakTipNote), findsOneWidget);
    });

    testWidgets('tapping Hear It speaks the phrase audio', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.hearIt));
      await tester.pump();

      expect(fakeTts.speakCount, equals(1));
      expect(fakeTts.lastSpokenText, equals('Muy bien, gracias'));
      expect(fakeTts.lastLocale, equals('es-ES'));
    });

    testWidgets('tapping mic starts listening and matched speech awards credit',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
      ));
      await tester.pumpAndSettle();

      // Tap mic
      await tester.tap(find.byType(MicButton));
      await tester.pump();

      expect(fakeRecognizer.isListening, isTrue);

      // Simulate recognized speech
      fakeRecognizer.simulateSpeech('Muy bien gracias');
      await tester.pumpAndSettle();

      // FeedbackPanel appears
      expect(find.byType(FeedbackPanel), findsOneWidget);
      expect(find.text(AppStrings.continueExercise), findsOneWidget);
    });

    testWidgets('tapping "rather not speak" transitions to Screen B (Self-Check)',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.speakRatherNotAction));
      await tester.pumpAndSettle();

      expect(find.byType(SelfCheckBody), findsOneWidget);
      expect(find.text(AppStrings.selfCheckTitle), findsOneWidget);
      expect(find.text(AppStrings.selfCheckSubUserChose), findsOneWidget);
      expect(find.text('Hear it again'), findsOneWidget);
      expect(
        find.text('${AppStrings.selfCheckSaidItAction}  ${AppStrings.selfCheckHalfCreditLabel}'),
        findsOneWidget,
      );
      expect(find.text(AppStrings.selfCheckSkipAction), findsOneWidget);
    });

    testWidgets('on Screen B: "Hear it again" plays TTS', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.speakRatherNotAction));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hear it again'));
      await tester.pump();

      expect(fakeTts.speakCount, equals(1));
      expect(fakeTts.lastSpokenText, equals('Muy bien, gracias'));
    });

    testWidgets('on Screen B: "I said it ✓" awards half credit and triggers FeedbackPanel',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.speakRatherNotAction));
      await tester.pumpAndSettle();

      await tester.tap(find.text(
        '${AppStrings.selfCheckSaidItAction}  ${AppStrings.selfCheckHalfCreditLabel}',
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackPanel), findsOneWidget);
    });

    testWidgets('on Screen B: "Skip for now" skips without penalty and finishes',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.speakRatherNotAction));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.selfCheckSkipAction));
      await tester.pumpAndSettle();

      // Since it's the last item in the set, session finishes
      expect(find.byType(FeedbackPanel), findsNothing);
    });

    testWidgets('speaking disabled in Settings automatically opens Screen B',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
        settings: const AppSettings(speakingPracticeEnabled: false),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SelfCheckBody), findsOneWidget);
      expect(find.text(AppStrings.selfCheckSubSettingOff), findsOneWidget);
    });

    testWidgets('child safety policy automatically opens Screen B',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createSubject(
        recognizer: fakeRecognizer,
        tts: fakeTts,
        user: _createTestProfile('u_child', ageBand: AgeBand.child),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SelfCheckBody), findsOneWidget);
      expect(find.text(AppStrings.selfCheckSubPolicy), findsOneWidget);
    });
  });
}
