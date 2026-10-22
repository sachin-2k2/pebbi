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
