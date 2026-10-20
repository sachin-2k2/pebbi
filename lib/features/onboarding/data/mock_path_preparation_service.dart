import 'dart:async';
import '../domain/first_lesson_info.dart';
import '../domain/path_preparation_service.dart';
import '../domain/path_ready_config.dart';
import '../domain/preparation_task.dart';

/// Mock implementation of [PathPreparationService] simulating real preparation work.
///
/// Follows AGENTS.md §1 & §2: Simulates downloading unit 1 and verifying audio
/// until backend endpoints and native asset downloaders are connected.
class MockPathPreparationService implements PathPreparationService {
  const MockPathPreparationService({
    this.totalDuration = PathReadyConfig.totalPreparationDuration,
    this.tickInterval = PathReadyConfig.tickInterval,
    this.failedTaskId,
    this.unavailableTaskId,
    this.firstLesson = const FirstLessonInfo(),
  });

  final Duration totalDuration;
  final Duration tickInterval;
  final String? failedTaskId;
  final String? unavailableTaskId;
  final FirstLessonInfo firstLesson;

  static List<PreparationTask> createInitialTasks({String? unavailableTaskId}) {
    return PreparationTask.defaultInitialTasks(
      unavailableTaskId: unavailableTaskId,
    );
  }

  @override
  Stream<PathPreparationProgress> startPreparation({
    bool reduceMotion = false,
  }) {
    late final StreamController<PathPreparationProgress> controller;
    Timer? timer;

    controller = StreamController<PathPreparationProgress>(
      onListen: () {
        var tasks = createInitialTasks(unavailableTaskId: unavailableTaskId);

        // Initial 0.0 state
        controller.add(
          PathPreparationProgress(
            progress: 0.0,
            tasks: tasks,
            isComplete: false,
          ),
        );

        if (reduceMotion || totalDuration == Duration.zero) {
          tasks = _updateTasksForProgress(tasks, 1.0);
          controller.add(
            PathPreparationProgress(
              progress: 1.0,
              tasks: tasks,
              isComplete: true,
            ),
          );
          controller.close();
          return;
        }

        final totalTicks =
            (totalDuration.inMilliseconds / tickInterval.inMilliseconds)
                .round();
        final effectiveTicks = totalTicks <= 0 ? 1 : totalTicks;
        var currentTick = 0;

        timer = Timer.periodic(tickInterval, (t) {
          currentTick++;
          final currentProgress = (currentTick / effectiveTicks).clamp(
            0.0,
            1.0,
          );
          tasks = _updateTasksForProgress(tasks, currentProgress);
          final isComplete = currentProgress >= 1.0;

          if (!controller.isClosed) {
            controller.add(
              PathPreparationProgress(
                progress: currentProgress,
                tasks: tasks,
                isComplete: isComplete,
              ),
            );
          }

          if (isComplete) {
            t.cancel();
            controller.close();
          }
        });
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }

  List<PreparationTask> _updateTasksForProgress(
    List<PreparationTask> currentTasks,
    double progress,
  ) {
    return currentTasks.map((task) {
      if (task.status == TaskStatus.unavailable) return task;

      if (task.id == failedTaskId) {
        return task.copyWith(
          status: TaskStatus.failed,
          errorMessage: 'Download failed. Tap to retry.',
        );
      }

      var threshold = 1.0;
      if (task.id == 'audio') {
        threshold = PathReadyConfig.task1Threshold;
      } else if (task.id == 'sticker') {
        threshold = PathReadyConfig.task2Threshold;
      } else if (task.id == 'speaking') {
        threshold = PathReadyConfig.task3Threshold;
      }

      if (progress >= threshold) {
        return task.copyWith(status: TaskStatus.done);
      }
      return task;
    }).toList();
  }

  @override
  Future<FirstLessonInfo> getFirstLessonInfo() async {
    return firstLesson;
  }
}
