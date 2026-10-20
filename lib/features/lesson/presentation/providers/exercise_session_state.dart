import '../../domain/exercise.dart';
import '../../domain/exercise_result.dart';

/// Lifecycle status of an exercise within the session state machine.
enum ExerciseStatus {
  /// Initial idle state where no option has been chosen; Check is disabled.
  idle,

  /// An option is selected; Check is enabled and selection can be changed.
  selected,

  /// Answer has been checked; options are locked and feedback panel is displayed.
  checked,

  /// All exercises in the set (including any redo round) are completed.
  completed,
}

/// Type of feedback shown in the bottom sliding panel.
enum FeedbackKind { correct, wrong }

/// Immutable state for an interactive exercise session.
///
/// Follows AGENTS.md §2.3: session state managed in Riverpod, autoDispose,
/// with pure Dart state representations.
class ExerciseSessionState {
  const ExerciseSessionState({
    this.mainExercises = const [],
    this.currentMainIndex = 0,
    this.redoQueue = const [],
    this.currentRedoIndex = 0,
    this.isRedoRound = false,
    this.status = ExerciseStatus.idle,
    this.selectedOptionId,
    this.feedbackKind,
    this.removedOptionIds = const {},
    this.hintsUsed = 0,
    this.results = const {},
    this.isLoading = false,
    this.placedTileIds = const [],
  });

  final List<Exercise> mainExercises;
  final int currentMainIndex;
  final List<Exercise> redoQueue;
  final int currentRedoIndex;
  final bool isRedoRound;
  final ExerciseStatus status;
  final String? selectedOptionId;
  final FeedbackKind? feedbackKind;
  final Set<String> removedOptionIds;
  final int hintsUsed;
  final Map<String, ExerciseResult> results;
  final bool isLoading;
  final List<String> placedTileIds;

  /// Returns the currently active exercise.
  Exercise? get currentExercise {
    if (isRedoRound) {
      if (currentRedoIndex >= 0 && currentRedoIndex < redoQueue.length) {
        return redoQueue[currentRedoIndex];
      }
      return null;
    }
    if (currentMainIndex >= 0 && currentMainIndex < mainExercises.length) {
      return mainExercises[currentMainIndex];
    }
    return null;
  }

  /// 1-indexed counter number for display (e.g. 1 of 8).
  int get displayCurrentNumber {
    if (isRedoRound) {
      return currentRedoIndex + 1;
    }
    return currentMainIndex + 1;
  }

  /// Total count for counter display.
  int get displayTotalNumber {
    if (isRedoRound) {
      return redoQueue.length;
    }
    return mainExercises.length;
  }

  /// Progress fraction for progress bar (clamped 0.0 to 1.0).
  double get progressFraction {
    if (mainExercises.isEmpty) return 0.0;
    if (isRedoRound) {
      if (redoQueue.isEmpty) return 1.0;
      return (currentRedoIndex / redoQueue.length).clamp(0.0, 1.0);
    }
    return (currentMainIndex / mainExercises.length).clamp(0.0, 1.0);
  }

  /// Whether the Check button can be tapped.
  bool get canCheck {
    if (status == ExerciseStatus.checked ||
        status == ExerciseStatus.completed) {
      return false;
    }
    final exercise = currentExercise;
    if (exercise is BuildSentenceExercise) {
      return placedTileIds.isNotEmpty;
    }
    return status == ExerciseStatus.selected && selectedOptionId != null;
  }

  /// Whether a hint can be used.
  bool get canUseHint {
    if (status == ExerciseStatus.checked ||
        status == ExerciseStatus.completed) {
      return false;
    }
    final exercise = currentExercise;
    if (exercise is SingleChoiceExercise) {
      final singleChoice = exercise as SingleChoiceExercise;
      final activeOptions = singleChoice.optionIds
          .where((id) => !removedOptionIds.contains(id))
          .length;
      return activeOptions > 2;
    }
    return false;
  }

  ExerciseSessionState copyWith({
    List<Exercise>? mainExercises,
    int? currentMainIndex,
    List<Exercise>? redoQueue,
    int? currentRedoIndex,
    bool? isRedoRound,
    ExerciseStatus? status,
    String? selectedOptionId,
    FeedbackKind? feedbackKind,
    Set<String>? removedOptionIds,
    int? hintsUsed,
    Map<String, ExerciseResult>? results,
    bool? isLoading,
    List<String>? placedTileIds,
  }) {
    return ExerciseSessionState(
      mainExercises: mainExercises ?? this.mainExercises,
      currentMainIndex: currentMainIndex ?? this.currentMainIndex,
      redoQueue: redoQueue ?? this.redoQueue,
      currentRedoIndex: currentRedoIndex ?? this.currentRedoIndex,
      isRedoRound: isRedoRound ?? this.isRedoRound,
      status: status ?? this.status,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      feedbackKind: feedbackKind ?? this.feedbackKind,
      removedOptionIds: removedOptionIds ?? this.removedOptionIds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      placedTileIds: placedTileIds ?? this.placedTileIds,
    );
  }
}
