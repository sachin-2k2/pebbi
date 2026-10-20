import 'exercise.dart';
import 'exercise_mode.dart';

/// An ordered set of exercises for a placement check or lesson stop.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class ExerciseSet {
  const ExerciseSet({
    required this.id,
    required this.title,
    required this.mode,
    required this.exercises,
  });

  final String id;
  final String title;
  final ExerciseMode mode;
  final List<Exercise> exercises;

  int get totalCount => exercises.length;

  bool get isEmpty => exercises.isEmpty;
  bool get isNotEmpty => exercises.isNotEmpty;
}
