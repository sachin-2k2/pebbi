import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/lesson/data/dtos/check_answer_dto.dart';
import 'package:peddi/features/lesson/data/mock_exercise_repository.dart';
import 'package:peddi/features/lesson/data/mock_lesson_repository.dart';
import 'package:peddi/features/lesson/data/mock_progress_repository.dart';
import 'package:peddi/features/lesson/domain/answer_checker.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/lesson_set.dart';
import 'package:peddi/features/lesson/domain/text_option.dart';
import 'package:peddi/features/lesson/presentation/providers/exercise_session_notifier.dart';
import 'package:peddi/features/lesson/presentation/providers/exercise_session_state.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_providers.dart';
import 'package:peddi/features/lesson/presentation/screens/exercise_screen.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/answer_option_card.dart';
import 'package:peddi/features/lesson/presentation/widgets/exercise/feedback_panel.dart';

class _FakeCheckLessonRepository extends MockLessonRepository {
  String? lastLessonId;
  String? lastQuestionId;
  String? lastChosenAnswer;
  CheckAnswerResponseDto? responseToReturn;

  @override
  Future<LessonSet> loadLesson(
    String stopId, {
    String? nativeLanguage,
    String? learningLanguage,
  }) async {
    return const LessonSet(
      id: 'daily-starter-1',
      stopId: 'daily-starter-1',
      title: 'Say Hello',
      items: [
        ChooseMeaningExercise(
          id: 'q_greeting_1',
          prompt: 'What does this mean?',
          phrase: 'Buenos días',
          audioText: 'Buenos días',
          audioLocale: 'es-ES',
          hint: 'Topic: Morning Greetings',
          explanationText: 'Standard polite morning greeting',
          correctAnswerText: 'Good morning',
          feedbackSuccessText: '¡Excelente! 🎉',
          correctOptionId: 'Good morning',
          options: [
            TextOption(id: 'Good morning', text: 'Good morning'),
            TextOption(id: 'Good evening', text: 'Good evening'),
            TextOption(id: 'Goodbye', text: 'Goodbye'),
          ],
        ),
      ],
    );
  }

  @override
  Future<CheckAnswerResponseDto?> checkAnswer({
    required String lessonId,
    required String questionId,
    required String chosenAnswer,
  }) async {
    lastLessonId = lessonId;
    lastQuestionId = questionId;
    lastChosenAnswer = chosenAnswer;
    return responseToReturn;
  }
}

class _NoOpTts implements TextToSpeechService {
  @override
  Future<bool> speak(
    String text, {
    required String locale,
    double? speechRate,
    VoidCallback? onCompletion,
  }) async =>
      true;

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

void main() {
  group('POST /api/lessons/{lesson_id}/check Integration & UI Tests', () {
    test('ExerciseSessionNotifier calls checkAnswer and updates state with server feedback', () async {
      final repo = _FakeCheckLessonRepository();
      repo.responseToReturn = const CheckAnswerResponseDto(
        questionId: 'q_greeting_1',
        isCorrect: true,
        correctAnswer: 'Good morning',
        chosenAnswer: 'Good morning',
        pointsEarned: 1,
      );

      final notifier = ExerciseSessionNotifier(
        repository: const MockExerciseRepository(),
        lessonRepository: repo,
        progressRepository: MockProgressRepository(),
        answerChecker: const StandardAnswerChecker(),
        audioFeedback: FakeAudioFeedbackService(),
      );

      await notifier.loadLesson('daily-starter-1');
      expect(notifier.state.currentExercise?.id, equals('q_greeting_1'));

      notifier.selectOption('Good morning');
      expect(notifier.state.selectedOptionId, equals('Good morning'));

      await notifier.checkAnswer();

      expect(repo.lastLessonId, equals('daily-starter-1'));
      expect(repo.lastQuestionId, equals('q_greeting_1'));
      expect(repo.lastChosenAnswer, equals('Good morning'));

      final state = notifier.state;
      expect(state.status, equals(ExerciseStatus.checked));
      expect(state.feedbackKind, equals(FeedbackKind.correct));
      expect(state.revealedCorrectAnswer, equals('Good morning'));
      expect(state.earnedPoints, equals(1));
      expect(state.lastCheckResult?.isCorrect, isTrue);
    });

    test('Wrong answer from server updates state, reveals correct answer, and queues redo', () async {
      final repo = _FakeCheckLessonRepository();
      repo.responseToReturn = const CheckAnswerResponseDto(
        questionId: 'q_greeting_1',
        isCorrect: false,
        correctAnswer: 'Good morning',
        chosenAnswer: 'Goodbye',
        pointsEarned: 0,
      );

      final notifier = ExerciseSessionNotifier(
        repository: const MockExerciseRepository(),
        lessonRepository: repo,
        progressRepository: MockProgressRepository(),
        answerChecker: const StandardAnswerChecker(),
        audioFeedback: FakeAudioFeedbackService(),
      );

      await notifier.loadLesson('daily-starter-1');
      notifier.selectOption('Goodbye');
      await notifier.checkAnswer();

      final state = notifier.state;
      expect(state.status, equals(ExerciseStatus.checked));
      expect(state.feedbackKind, equals(FeedbackKind.wrong));
      expect(state.revealedCorrectAnswer, equals('Good morning'));
      expect(state.earnedPoints, equals(0));
      expect(state.redoQueue.length, equals(1));
    });

    testWidgets('UI highlights chosen wrong answer in red ❌ and correct answer in green ✅',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeCheckLessonRepository();
      repo.responseToReturn = const CheckAnswerResponseDto(
        questionId: 'q_greeting_1',
        isCorrect: false,
        correctAnswer: 'Good morning',
        chosenAnswer: 'Goodbye',
        pointsEarned: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lessonRepositoryProvider.overrideWithValue(repo),
            textToSpeechServiceProvider.overrideWithValue(_NoOpTts()),
          ],
          child: const MaterialApp(
            home: ExerciseScreen(stopId: 'daily-starter-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify question loaded
      expect(find.text('What does this mean?'), findsOneWidget);
      expect(find.text('Buenos días'), findsOneWidget);

      // Tap wrong answer 'Goodbye'
      await tester.ensureVisible(find.text('Goodbye'));
      await tester.tap(find.text('Goodbye'));
      await tester.pumpAndSettle();

      // Tap Check
      await tester.ensureVisible(find.text('Check'));
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Verify API was called
      expect(repo.lastChosenAnswer, equals('Goodbye'));

      // Verify FeedbackPanel displayed with authoritative server answer
      expect(find.byType(FeedbackPanel), findsOneWidget);
      expect(find.textContaining('Good morning'), findsWidgets);

      // Verify checkmark icon (✅) and cancel icon (❌)
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

      // Verify AnswerOptionCard states
      final optionCards = tester.widgetList<AnswerOptionCard>(find.byType(AnswerOptionCard)).toList();
      final goodMorningCard = optionCards.firstWhere((c) => c.option.text == 'Good morning');
      final goodbyeCard = optionCards.firstWhere((c) => c.option.text == 'Goodbye');

      expect(goodMorningCard.isCorrectAnswer, isTrue);
      expect(goodMorningCard.isWrongAnswer, isFalse);

      expect(goodbyeCard.isSelected, isTrue);
      expect(goodbyeCard.isWrongAnswer, isTrue);
      expect(goodbyeCard.isCorrectAnswer, isFalse);
    });

    testWidgets('Tapping "Why?" displays the backend explanation in WhySheet modal',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const serverExplanation =
          '"Buenos días" translates to "Good morning". Used as a polite greeting before noon.';

      final repo = _FakeCheckLessonRepository();
      repo.responseToReturn = const CheckAnswerResponseDto(
        questionId: 'q_greeting_1',
        isCorrect: false,
        correctAnswer: 'Good morning',
        chosenAnswer: 'Goodbye',
        pointsEarned: 0,
        explanation: serverExplanation,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lessonRepositoryProvider.overrideWithValue(repo),
            textToSpeechServiceProvider.overrideWithValue(_NoOpTts()),
          ],
          child: const MaterialApp(
            home: ExerciseScreen(stopId: 'daily-starter-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap wrong answer and Check
      await tester.tap(find.text('Goodbye'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Tap "Why?"
      expect(find.text('Why?'), findsOneWidget);
      await tester.tap(find.text('Why?'));
      await tester.pumpAndSettle();

      // Verify WhySheet displays the server's explanation
      expect(find.text('Why this answer'), findsOneWidget);
      expect(find.text(serverExplanation), findsOneWidget);
    });

    testWidgets('Tapping "Hint" displays the pre-answer clue context', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = _FakeCheckLessonRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lessonRepositoryProvider.overrideWithValue(repo),
            textToSpeechServiceProvider.overrideWithValue(_NoOpTts()),
          ],
          child: const MaterialApp(
            home: ExerciseScreen(stopId: 'daily-starter-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Before tapping hint, clue is not shown
      expect(find.text('Topic: Morning Greetings'), findsNothing);

      // Tap Hint button
      expect(find.text('Hint'), findsOneWidget);
      await tester.tap(find.text('Hint'));
      await tester.pumpAndSettle();

      // Verify clue is now shown
      expect(find.text('Topic: Morning Greetings'), findsOneWidget);
    });
  });
}
