import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/fake_speech_recognizer_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/lesson_repository.dart';
import 'package:peddi/features/lesson/domain/lesson_set.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:peddi/features/lesson/presentation/screens/exercise_screen.dart';
import 'package:peddi/l10n/app_strings.dart';

class _NoOpTtsService implements TextToSpeechService {
  @override
  Future<bool> speak(String text, {required String locale, double? speechRate}) async => true;

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
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

  const targetSizes = [
    Size(360, 640), // Small Android phone
    Size(390, 844), // iPhone
    Size(430, 932), // Large phone
    Size(800, 1280), // Android tablet, portrait
    Size(1280, 800), // Android tablet, landscape
    Size(1024, 1366), // iPad Pro, portrait
    Size(700, 900), // Split-screen / foldable
  ];

  Widget buildTestWidget({
    required Size size,
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    final fakeRecognizer = FakeSpeechRecognizerService();
    final fakeTts = _NoOpTtsService();

    return ProviderScope(
      overrides: [
        lessonRepositoryProvider.overrideWithValue(
          _FakeLessonRepository(sampleLesson),
        ),
        speechRecognizerServiceProvider.overrideWithValue(fakeRecognizer),
        textToSpeechServiceProvider.overrideWithValue(fakeTts),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const ExerciseScreen(stopId: 'stop_test'),
        ),
      ),
    );
  }

  group('SpeakExercise Responsive Layouts', () {
    for (final size in targetSizes) {
      testWidgets('renders cleanly on ${size.width}x${size.height} at scale 1.0',
          (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildTestWidget(size: size, textScale: 1.0));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders cleanly on ${size.width}x${size.height} at scale 2.0 (large text)',
          (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(buildTestWidget(size: size, textScale: 2.0));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('renders dark mode cleanly without overflow', (tester) async {
      const size = Size(390, 844);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(size: size, themeMode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Screen B (Self-Check) without overflow at 360x640 scale 2.0',
        (tester) async {
      const size = Size(360, 640);
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(size: size, textScale: 2.0));
      await tester.pumpAndSettle();

      // Navigate to Screen B (scroll to link in small viewport with large text)
      await tester.scrollUntilVisible(
        find.text(AppStrings.speakRatherNotAction),
        100.0,
      );
      await tester.tap(find.text(AppStrings.speakRatherNotAction));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
