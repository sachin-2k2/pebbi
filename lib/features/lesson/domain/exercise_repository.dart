import 'exercise_set.dart';

/// Repository interface providing exercise sets for placement checks and lessons.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
/// Hides data source details (mock, local cache, or remote API).
abstract interface class ExerciseRepository {
  /// Loads the placement quick check question set for [targetLanguageCode].
  Future<ExerciseSet> loadPlacementSet(String targetLanguageCode);

  /// Loads an exercise set for a specific curriculum lesson on the path.
  Future<ExerciseSet> loadLessonSet(String lessonId);
}
