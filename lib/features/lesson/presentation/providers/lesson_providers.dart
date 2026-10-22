import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_feedback_service.dart';
import '../../../../core/services/speech_recognizer_service.dart';
import '../../../../core/services/speech_to_text_recognizer_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../data/mock_exercise_repository.dart';
import '../../data/mock_lesson_repository.dart';
import '../../data/mock_progress_repository.dart';
import '../../domain/answer_checker.dart';
import '../../domain/exercise_repository.dart';
import '../../domain/lesson_repository.dart';
import '../../domain/progress_repository.dart';
import 'exercise_session_notifier.dart';
import 'exercise_session_state.dart';

/// Provider for [ExerciseRepository] (used for placement checks).
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return const MockExerciseRepository();
});

/// Provider for [LessonRepository] (used for curriculum lessons).
final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return const MockLessonRepository();
});

/// Provider for [ProgressRepository] (manages lesson history and offline outbox).
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final repo = MockProgressRepository();
  ref.onDispose(() => repo.clearCache());
  return repo;
});

/// Provider for [SpeechRecognizerService].
final speechRecognizerServiceProvider =
    Provider<SpeechRecognizerService>((ref) {
  final service = SpeechToTextRecognizerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for [AnswerChecker].
final answerCheckerProvider = Provider<AnswerChecker>((ref) {
  return const StandardAnswerChecker();
});

/// AutoDispose provider managing interactive exercise and lesson sessions.
///
/// Follows AGENTS.md §2.3 & §6: Watches currentUserProvider for strict user isolation.
final exerciseSessionProvider =
    StateNotifierProvider.autoDispose<
      ExerciseSessionNotifier,
      ExerciseSessionState
    >((ref) {
      final repository = ref.watch(exerciseRepositoryProvider);
      final lessonRepository = ref.watch(lessonRepositoryProvider);
      final progressRepository = ref.watch(progressRepositoryProvider);
      final phraseRepository = ref.watch(phraseRepositoryProvider);
      final currentUser = ref.watch(currentUserProvider);
      final answerChecker = ref.watch(answerCheckerProvider);
      final audioFeedback = ref.watch(audioFeedbackServiceProvider);

      return ExerciseSessionNotifier(
        repository: repository,
        lessonRepository: lessonRepository,
        progressRepository: progressRepository,
        phraseRepository: phraseRepository,
        userId: currentUser?.userId ?? 'guest_default',
        answerChecker: answerChecker,
        audioFeedback: audioFeedback,
      );
    });
