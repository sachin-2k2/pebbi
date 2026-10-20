import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_feedback_service.dart';
import '../../domain/answer_checker.dart';
import '../../domain/exercise.dart';
import '../../domain/exercise_repository.dart';
import '../../domain/exercise_result.dart';
import 'exercise_session_state.dart';

/// StateNotifier managing exercise lifecycle, selections, checking, hints, and redo rounds.
///
/// Follows AGENTS.md §2.3: autoDispose notifier resetting when leaving screen,
/// encapsulates pure business rules and session state.
class ExerciseSessionNotifier extends StateNotifier<ExerciseSessionState> {
  ExerciseSessionNotifier({
    required this.repository,
    required this.answerChecker,
    required this.audioFeedback,
  }) : super(const ExerciseSessionState());

  final ExerciseRepository repository;
  final AnswerChecker answerChecker;
  final AudioFeedbackService audioFeedback;

  /// Loads the placement set for [targetLanguageCode].
  Future<void> loadPlacement(String targetLanguageCode) async {
    state = state.copyWith(isLoading: true);
    final exerciseSet = await repository.loadPlacementSet(targetLanguageCode);
    state = ExerciseSessionState(
      mainExercises: exerciseSet.exercises,
      currentMainIndex: 0,
      isLoading: false,
    );
  }

  /// Selects an option by [id].
  void selectOption(String id) {
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }
    if (state.removedOptionIds.contains(id)) {
      return;
    }

    state = state.copyWith(
      selectedOptionId: id,
      status: ExerciseStatus.selected,
    );
  }

  /// Uses a hint to eliminate one wrong distractor option.
  void useHint() {
    if (!state.canUseHint) return;

    final exercise = state.currentExercise;
    if (exercise is! SingleChoiceExercise) return;
    final singleChoice = exercise as SingleChoiceExercise;

    final candidates = singleChoice.optionIds.where((id) {
      final isCorrect = id == singleChoice.correctOptionId;
      final isSelected = id == state.selectedOptionId;
      final isRemoved = state.removedOptionIds.contains(id);
      return !isCorrect && !isSelected && !isRemoved;
    }).toList();

    if (candidates.isEmpty) return;

    final optionToRemoveId = candidates.first;
    final updatedRemoved = Set<String>.from(state.removedOptionIds)
      ..add(optionToRemoveId);

    state = state.copyWith(
      removedOptionIds: updatedRemoved,
      hintsUsed: state.hintsUsed + 1,
    );
  }

  /// Places a word tile into the answer area for sentence building.
  void placeTile(String tileId) {
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }
    if (state.placedTileIds.contains(tileId)) return;
    final updated = [...state.placedTileIds, tileId];
    state = state.copyWith(
      placedTileIds: updated,
      status: ExerciseStatus.selected,
    );
  }

  /// Removes a word tile from the answer area, returning it to the word bank.
  void removeTile(String tileId) {
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }
    if (!state.placedTileIds.contains(tileId)) return;
    final updated = state.placedTileIds.where((id) => id != tileId).toList();
    state = state.copyWith(
      placedTileIds: updated,
      status: updated.isEmpty ? ExerciseStatus.idle : ExerciseStatus.selected,
    );
  }

  /// Resets placed word tiles back to the bank.
  void resetSentence() {
    if (state.status == ExerciseStatus.checked ||
        state.status == ExerciseStatus.completed) {
      return;
    }
    state = state.copyWith(
      placedTileIds: const [],
      status: ExerciseStatus.idle,
    );
  }

  /// Checks the learner's answer and presents feedback.
  Future<void> checkAnswer() async {
    if (!state.canCheck) return;

    final exercise = state.currentExercise;
    if (exercise == null) return;

    final bool isCorrect;
    final String recordedAnswer;

    if (exercise is BuildSentenceExercise) {
      isCorrect = answerChecker.isSentenceCorrect(
        exercise,
        state.placedTileIds,
      );
      recordedAnswer = state.placedTileIds.join(',');
    } else {
      final selectedId = state.selectedOptionId ?? '';
      isCorrect = answerChecker.isCorrect(exercise, selectedId);
      recordedAnswer = selectedId;
    }

    // Record or update result
    final existingResult = state.results[exercise.id];
    final updatedResult = existingResult != null
        ? existingResult.copyWith(
            attempts: existingResult.attempts + 1,
            selectedOptionId: recordedAnswer,
          )
        : ExerciseResult(
            exerciseId: exercise.id,
            isFirstTryCorrect: isCorrect,
            hintsUsed: state.hintsUsed,
            attempts: 1,
            selectedOptionId: recordedAnswer,
          );

    final updatedResults = Map<String, ExerciseResult>.from(state.results)
      ..[exercise.id] = updatedResult;

    // Update redo queue if wrong and in main round
    var updatedRedo = List<Exercise>.from(state.redoQueue);
    if (!isCorrect && !state.isRedoRound) {
      updatedRedo.add(exercise);
    }

    state = state.copyWith(
      status: ExerciseStatus.checked,
      feedbackKind: isCorrect ? FeedbackKind.correct : FeedbackKind.wrong,
      results: updatedResults,
      redoQueue: updatedRedo,
    );

    if (isCorrect) {
      await audioFeedback.playSuccess();
    } else {
      await audioFeedback.playWrong();
    }
  }

  /// Advances to the next question, enters the redo queue, or completes.
  void next() {
    if (state.status != ExerciseStatus.checked) return;

    if (!state.isRedoRound) {
      // Main round
      if (state.currentMainIndex + 1 < state.mainExercises.length) {
        state = state.copyWith(
          currentMainIndex: state.currentMainIndex + 1,
          selectedOptionId: null,
          placedTileIds: const [],
          status: ExerciseStatus.idle,
          feedbackKind: null,
          removedOptionIds: const {},
          hintsUsed: 0,
        );
        return;
      }

      // Check if redo round is needed
      if (state.redoQueue.isNotEmpty) {
        state = state.copyWith(
          isRedoRound: true,
          currentRedoIndex: 0,
          selectedOptionId: null,
          placedTileIds: const [],
          status: ExerciseStatus.idle,
          feedbackKind: null,
          removedOptionIds: const {},
          hintsUsed: 0,
        );
        return;
      }

      // All done!
      state = state.copyWith(status: ExerciseStatus.completed);
    } else {
      // Redo round
      if (state.currentRedoIndex + 1 < state.redoQueue.length) {
        state = state.copyWith(
          currentRedoIndex: state.currentRedoIndex + 1,
          selectedOptionId: null,
          placedTileIds: const [],
          status: ExerciseStatus.idle,
          feedbackKind: null,
          removedOptionIds: const {},
          hintsUsed: 0,
        );
        return;
      }

      // Redo round finished
      state = state.copyWith(status: ExerciseStatus.completed);
    }
  }
}
