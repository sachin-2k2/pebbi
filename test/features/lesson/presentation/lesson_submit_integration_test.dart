import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/star_row.dart';
import 'package:peddi/core/services/audio_feedback_service.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/lesson/data/dtos/submit_lesson_dto.dart';
import 'package:peddi/features/lesson/data/mock_exercise_repository.dart';
import 'package:peddi/features/lesson/data/mock_lesson_repository.dart';
import 'package:peddi/features/lesson/data/mock_progress_repository.dart';
import 'package:peddi/features/lesson/domain/answer_checker.dart';
import 'package:peddi/features/lesson/domain/exercise.dart';
import 'package:peddi/features/lesson/domain/lesson_completion.dart';
import 'package:peddi/features/lesson/domain/lesson_set.dart';
import 'package:peddi/features/lesson/domain/text_option.dart';
import 'package:peddi/features/lesson/presentation/providers/exercise_session_notifier.dart';
import 'package:peddi/features/lesson/presentation/providers/exercise_session_state.dart';
import 'package:peddi/features/lesson/presentation/providers/lesson_completion_provider.dart';
import 'package:peddi/features/lesson/presentation/screens/lesson_complete_screen.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';

class _RecordingLessonRepository extends MockLessonRepository {
  List<SubmitLessonAnswerItemDto>? lastSubmittedAnswers;
  String? lastLessonId;
  SubmitLessonResponseDto? responseToReturn;

  @override
  Future<SubmitLessonResponseDto?> submitLesson({
    required String lessonId,
    required List<SubmitLessonAnswerItemDto> answers,
  }) async {
    lastLessonId = lessonId;
    lastSubmittedAnswers = answers;
    return responseToReturn ??
        SubmitLessonResponseDto(
          passed: true,
          score: answers.length,
          total: answers.length,
          scorePct: 100,
          xpAwarded: 10,
          nextLessonId: 'daily-starter-2',
          pebbiSays: '¡Perfecto! 🎉 You scored ${answers.length}/${answers.length}! Keep going!',
        );
  }
}

class _NoOpTts implements TextToSpeechService {
  @override
  Future<bool> speak(
    String text, {
    required String locale,
    double? speechRate,
    VoidCallback? onCompletion,
  }) async => true;

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

void main() {
  group('POST /api/lessons/{lesson_id}/submit integration tests', () {
    test('ExerciseSessionNotifier builds answers and awaits submitLesson', () async {
      final repo = _RecordingLessonRepository();
      final progressRepo = MockProgressRepository();
      final audio = FakeAudioFeedbackService();

      final notifier = ExerciseSessionNotifier(
        repository: MockExerciseRepository(),
        lessonRepository: repo,
        progressRepository: progressRepo,
        userId: 'user_123',
        answerChecker: const StandardAnswerChecker(),
        audioFeedback: audio,
      );

      final lessonSet = LessonSet(
        id: 'daily-starter-1',
        stopId: 'daily-starter-1',
        title: 'Say Hello',
        items: const [
          ChooseMeaningExercise(
            id: 'q_1',
            prompt: 'What does this mean?',
            phrase: 'Hello',
            audioText: 'Hello',
            audioLocale: 'en-US',
            explanationText: 'Greeting',
            correctAnswerText: 'ഹലോ',
            feedbackSuccessText: 'Great!',
            correctOptionId: 'opt_1',
            options: [
              TextOption(id: 'opt_1', text: 'ഹലോ'),
              TextOption(id: 'opt_2', text: 'ബൈ'),
            ],
          ),
          ChooseMeaningExercise(
            id: 'q_2',
            prompt: 'What does this mean?',
            phrase: 'Good morning',
            audioText: 'Good morning',
            audioLocale: 'en-US',
            explanationText: 'Morning greeting',
            correctAnswerText: 'സുപ്രഭാതം',
            feedbackSuccessText: 'Great!',
            correctOptionId: 'opt_a',
            options: [
              TextOption(id: 'opt_a', text: 'സുപ്രഭാതം'),
              TextOption(id: 'opt_b', text: 'ശുഭരാത്രി'),
            ],
          ),
        ],
      );

      // Initialize session directly
      notifier.loadFromLessonSet(lessonSet);

      // Answer Q1
      notifier.selectOption('opt_1');
      await notifier.checkAnswer();
      await notifier.next();

      // Answer Q2
      notifier.selectOption('opt_a');
      await notifier.checkAnswer();
      await notifier.next();

      // Verify submitLesson was called with exact answers
      expect(repo.lastLessonId, equals('daily-starter-1'));
      expect(repo.lastSubmittedAnswers, isNotNull);
      expect(repo.lastSubmittedAnswers!.length, equals(2));
      expect(repo.lastSubmittedAnswers![0].questionId, equals('q_1'));
      expect(repo.lastSubmittedAnswers![0].chosenAnswer, equals('ഹലോ'));
      expect(repo.lastSubmittedAnswers![1].questionId, equals('q_2'));
      expect(repo.lastSubmittedAnswers![1].chosenAnswer, equals('സുപ്രഭാതം'));

      // Verify progressRepository cached the response with 3 stars
      final completion = await progressRepo.getLessonCompletion(
        userId: 'user_123',
        stopId: 'daily-starter-1',
      );
      expect(completion, isNotNull);
      expect(completion!.passed, isTrue);
      expect(completion.firstTryCorrectCount, equals(2));
      expect(completion.scoredCount, equals(2));
      expect(completion.xpAwarded, equals(10));
      expect(completion.nextStopId, equals('daily-starter-2'));
      expect(completion.pebbiSays, contains('¡Perfecto! 🎉'));
    });

    testWidgets('LessonCompleteScreen renders backend pebbi_says and passing stars', (
      tester,
    ) async {
      const completion = LessonCompletion(
        stopId: 'daily-starter-1',
        starsEarned: 3,
        scoredCount: 6,
        firstTryCorrectCount: 6,
        learnedPhrases: [],
        passed: true,
        xpAwarded: 10,
        pebbiSays: '¡Perfecto! 🎉 You scored 6/6! Keep going!',
        dailyGoal: DailyGoalCompletion(status: DailyGoalStatus.done),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            textToSpeechServiceProvider.overrideWithValue(_NoOpTts()),
            audioFeedbackServiceProvider.overrideWithValue(FakeAudioFeedbackService()),
            currentUserProvider.overrideWith(
              (ref) => CurrentUserNotifier(
                MockProfileRepository(),
                const UserProfile(
                  userId: 'user_123',
                  ageBand: AgeBand.adult,
                  explanationLanguageCode: 'en',
                  targetLanguageCode: 'es',
                  reasonIds: {'travel'},
                  dailyGoalId: 'regular',
                  reminderTime: ReminderTime(hour: 18, minute: 0),
                  selectedWeekdayNumbers: {1, 2, 3, 4, 5},
                  remindersEnabled: true,
                  accentId: 'purple',
                  plan: 'free',
                ),
              ),
            ),
            lessonCompletionProvider('daily-starter-1').overrideWith(
              (ref) => completion,
            ),
          ],
          child: const MaterialApp(
            home: LessonCompleteScreen(stopId: 'daily-starter-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Subtitle renders backend's pebbiSays string
      expect(find.text('¡Perfecto! 🎉 You scored 6/6! Keep going!'), findsOneWidget);
      // Renders stars and first try count
      expect(find.byType(StarRow), findsOneWidget);
      expect(find.text('6 of 6 right on the first try'), findsOneWidget);
    });
  });
}

extension _NotifierTestExt on ExerciseSessionNotifier {
  void loadFromLessonSet(LessonSet set) {
    state = ExerciseSessionState(
      mainExercises: set.items,
      currentMainIndex: 0,
      isLoading: false,
      stopId: set.stopId,
      lessonTitle: set.title,
    );
  }
}
