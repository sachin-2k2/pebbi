import 'lesson_set.dart';

/// Repository interface for loading curriculum lessons.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class LessonRepository {
  /// Loads the [LessonSet] associated with the given curriculum [stopId].
  Future<LessonSet> loadLesson(String stopId);
}
