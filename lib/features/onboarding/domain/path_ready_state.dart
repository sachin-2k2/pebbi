import 'first_lesson_info.dart';
import 'preparation_task.dart';

/// Immutable state for the Path Ready step sequence.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class PathReadyState {
  const PathReadyState({
    this.progress = 0.0,
    this.tasks = const [],
    this.firstLessonInfo = const FirstLessonInfo(),
    this.isPrepared = false,
    this.isSaving = false,
    this.saveErrorMessage,
    this.hasAnnouncedDone = false,
  });

  /// Ring progress fraction from 0.0 to 1.0.
  final double progress;

  /// Ordered checklist of preparation tasks.
  final List<PreparationTask> tasks;

  /// Information about the first lesson.
  final FirstLessonInfo firstLessonInfo;

  /// Whether all blocking preparation tasks have completed successfully.
  final bool isPrepared;

  /// Whether profile saving is in progress.
  final bool isSaving;

  /// Optional error message if saving profile fails.
  final String? saveErrorMessage;

  /// Whether the finished state announcement has fired to prevent double-announcing.
  final bool hasAnnouncedDone;

  /// Whether the learner can proceed to lesson 1.
  bool get canStartLesson => isPrepared && !isSaving;

  /// Creates the initial state with default pending tasks.
  static PathReadyState initial() {
    return PathReadyState(tasks: PreparationTask.defaultInitialTasks());
  }

  PathReadyState copyWith({
    double? progress,
    List<PreparationTask>? tasks,
    FirstLessonInfo? firstLessonInfo,
    bool? isPrepared,
    bool? isSaving,
    String? saveErrorMessage,
    bool clearSaveError = false,
    bool? hasAnnouncedDone,
  }) {
    return PathReadyState(
      progress: progress ?? this.progress,
      tasks: tasks ?? this.tasks,
      firstLessonInfo: firstLessonInfo ?? this.firstLessonInfo,
      isPrepared: isPrepared ?? this.isPrepared,
      isSaving: isSaving ?? this.isSaving,
      saveErrorMessage: clearSaveError
          ? null
          : (saveErrorMessage ?? this.saveErrorMessage),
      hasAnnouncedDone: hasAnnouncedDone ?? this.hasAnnouncedDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathReadyState &&
          runtimeType == other.runtimeType &&
          progress == other.progress &&
          firstLessonInfo == other.firstLessonInfo &&
          isPrepared == other.isPrepared &&
          isSaving == other.isSaving &&
          saveErrorMessage == other.saveErrorMessage &&
          hasAnnouncedDone == other.hasAnnouncedDone &&
          _listEquals(tasks, other.tasks);

  @override
  int get hashCode => Object.hash(
    progress,
    firstLessonInfo,
    isPrepared,
    isSaving,
    saveErrorMessage,
    hasAnnouncedDone,
    Object.hashAll(tasks),
  );

  static bool _listEquals(List<PreparationTask> a, List<PreparationTask> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
