import 'path_node.dart';

/// Pure domain model representing a course unit containing path nodes.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
class Unit {
  const Unit({
    required this.id,
    required this.unitNumber,
    required this.title,
    required this.trackId,
    this.isFree = true,
    required this.nodes,
  });

  final String id;
  final int unitNumber;
  final String title;
  final String trackId;
  final bool isFree;
  final List<PathNode> nodes;

  int get stopsDone => nodes.where((n) => n.isDone).length;
  int get totalStops => nodes.length;

  int get lessonStopsDone =>
      nodes.whereType<LessonStopNode>().where((n) => n.isDone).length;

  int get totalLessonStops => nodes.whereType<LessonStopNode>().length;

  double get progress => totalLessonStops > 0
      ? (lessonStopsDone / totalLessonStops).clamp(0.0, 1.0)
      : 0.0;

  bool get isFreeUnit => isFree;
  bool get isLocked => nodes.isNotEmpty && nodes.every((n) => n.isLocked);
  bool get isCompleted => nodes.isNotEmpty && nodes.every((n) => n.isDone);
}
