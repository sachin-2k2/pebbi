import 'first_lesson_info.dart';
import 'preparation_task.dart';

/// Progress snapshot emitted during course path preparation.
class PathPreparationProgress {
  const PathPreparationProgress({
    required this.progress,
    required this.tasks,
    required this.isComplete,
  });

  final double progress;
  final List<PreparationTask> tasks;
  final bool isComplete;
}

/// Service interface responsible for preparing the learner's initial course assets,
/// downloading unit packs, verifying audio cache, and unlocking starter features.
///
/// Follows AGENTS.md §2.2: Pure Dart interface with zero Flutter imports.
abstract interface class PathPreparationService {
  /// Emits progress snapshots and task updates as preparation work proceeds.
  Stream<PathPreparationProgress> startPreparation({bool reduceMotion = false});

  /// Fetches metadata for the user's initial path stop.
  Future<FirstLessonInfo> getFirstLessonInfo();
}
