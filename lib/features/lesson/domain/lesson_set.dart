import 'exercise.dart';

/// An ordered set of items comprising a curriculum lesson.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonSet {
  const LessonSet({
    required this.id,
    required this.stopId,
    required this.title,
    required this.items,
  });

  /// Unique identifier of the lesson set.
  final String id;

  /// Identifier of the curriculum stop (e.g. '1').
  final String stopId;

  /// Human-readable title of the lesson (e.g. "Say hello").
  final String title;

  /// Ordered list of items (teach cards, exercises, and speaking placeholder).
  final List<Exercise> items;
}
