import '../domain/lesson_result.dart';
import '../domain/progress_repository.dart';

/// In-memory mock implementation of [ProgressRepository].
///
/// Follows AGENTS.md §2.1, §5 & §6: user isolation, outbox queue, offline-first.
class MockProgressRepository implements ProgressRepository {
  MockProgressRepository();

  /// Results stored per userId.
  final Map<String, List<LessonResult>> _userResults = {};

  /// Outbox sync queue for offline changes.
  final List<({String userId, LessonResult result, DateTime queuedAt})>
  _outbox = [];

  List<({String userId, LessonResult result, DateTime queuedAt})> get outbox =>
      List.unmodifiable(_outbox);

  @override
  Future<void> saveLessonProgress({
    required String userId,
    required LessonResult result,
  }) async {
    final list = _userResults.putIfAbsent(userId, () => []);
    list.add(result);

    // Queue in local outbox for sync
    _outbox.add((userId: userId, result: result, queuedAt: DateTime.now()));
  }

  @override
  Future<List<LessonResult>> getLessonHistory({required String userId}) async {
    return List.unmodifiable(_userResults[userId] ?? const []);
  }

  @override
  Future<bool> isStopCompleted({
    required String userId,
    required String stopId,
  }) async {
    final results = _userResults[userId];
    if (results == null) return false;
    return results.any((r) => r.stopId == stopId);
  }

  @override
  void clearCache() {
    _userResults.clear();
    _outbox.clear();
  }
}
