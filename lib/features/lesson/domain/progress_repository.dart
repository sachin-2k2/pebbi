import 'lesson_completion.dart';
import 'lesson_result.dart';

/// Repository interface for saving lesson progress and queuing offline sync events.
///
/// Follows AGENTS.md §2.1, §2.2 & §5: Pure Dart, zero Flutter imports.
/// Reads from local storage and queues unsynced progress events in an outbox.
abstract interface class ProgressRepository {
  /// Saves the completed [result] under the given [userId].
  Future<void> saveLessonProgress({
    required String userId,
    required LessonResult result,
  });

  /// Records lesson completion for [stopId] and [userId], returning the display-ready [LessonCompletion].
  ///
  /// Guarantees idempotency via [clientEventId].
  Future<LessonCompletion> completeLesson({
    required String userId,
    required String stopId,
    required LessonResult result,
    String? clientEventId,
  });

  /// Retrieves the cached [LessonCompletion] for [stopId] and [userId], if previously completed.
  Future<LessonCompletion?> getLessonCompletion({
    required String userId,
    required String stopId,
  });

  /// Fetches cached lesson results for [userId].
  Future<List<LessonResult>> getLessonHistory({required String userId});

  /// Returns whether a specific lesson stop has been completed by [userId].
  Future<bool> isStopCompleted({
    required String userId,
    required String stopId,
  });

  /// Clears in-memory cache for user isolation.
  void clearCache();
}
