/// Path node types per AGENTS.md §5 and §7.
enum PathNodeType { lesson, review, mission, chest }

/// Progress state of a path node.
enum PathNodeStatus { locked, current, completed }

/// Pure domain model for a learning path stop (no Flutter imports per §2.2).
class PathNodeData {
  const PathNodeData({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.unitNumber = 1,
    this.starsEarned = 0,
    this.maxStars = 3,
  });

  final String id;
  final String title;
  final PathNodeType type;
  final PathNodeStatus status;
  final int unitNumber;
  final int starsEarned;
  final int maxStars;

  bool get isLocked => status == PathNodeStatus.locked;
  bool get isCurrent => status == PathNodeStatus.current;
  bool get isCompleted => status == PathNodeStatus.completed;
}
