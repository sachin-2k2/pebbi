import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_feedback_service.dart';
import '../../data/mock_exercise_repository.dart';
import '../../domain/answer_checker.dart';
import '../../domain/exercise_repository.dart';
import 'exercise_session_notifier.dart';
import 'exercise_session_state.dart';

/// Provider for [ExerciseRepository].
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return const MockExerciseRepository();
});

/// Provider for [AnswerChecker].
final answerCheckerProvider = Provider<AnswerChecker>((ref) {
  return const StandardAnswerChecker();
});

/// AutoDispose provider managing interactive exercise sessions.
final exerciseSessionProvider =
    StateNotifierProvider.autoDispose<
      ExerciseSessionNotifier,
      ExerciseSessionState
    >((ref) {
      final repository = ref.watch(exerciseRepositoryProvider);
      final answerChecker = ref.watch(answerCheckerProvider);
      final audioFeedback = ref.watch(audioFeedbackServiceProvider);

      return ExerciseSessionNotifier(
        repository: repository,
        answerChecker: answerChecker,
        audioFeedback: audioFeedback,
      );
    });
