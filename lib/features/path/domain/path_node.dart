/// Progress state of a path node.
enum NodeState { done, current, locked }

/// Reason why a node is locked.
enum LockReason { none, progress, premium }

/// Sealed domain hierarchy representing nodes along the learning rail.
///
/// Follows AGENTS.md §2.2: Pure Dart model with zero Flutter imports.
sealed class PathNode {
  const PathNode({
    required this.id,
    required this.title,
    required this.state,
    this.lockReason = LockReason.none,
    this.starsEarned = 0,
  });

  final String id;
  final String title;
  final NodeState state;
  final LockReason lockReason;
  final int starsEarned;

  bool get isLocked => state == NodeState.locked;
  bool get isCurrent => state == NodeState.current;
  bool get isDone => state == NodeState.done;
  bool get isPremiumLocked => lockReason == LockReason.premium;
}

/// Regular lesson stop along the path.
class LessonStopNode extends PathNode {
  const LessonStopNode({
    required super.id,
    required super.title,
    required super.state,
    super.lockReason,
    super.starsEarned,
    required this.stopNumber,
    required this.totalStopsInUnit,
    this.isNext = false,
  });

  final int stopNumber;
  final int totalStopsInUnit;
  final bool isNext;
}

/// Spaced-repetition review stop along the path.
class ReviewNode extends PathNode {
  const ReviewNode({
    required super.id,
    required super.title,
    required super.state,
    super.lockReason,
    super.starsEarned,
  });
}

/// AI role-play mission stop along the path.
class MissionNode extends PathNode {
  const MissionNode({
    required super.id,
    required super.title,
    required super.state,
    super.lockReason,
    super.starsEarned,
  });
}

/// Rewarding bonus chest node along the path.
class ChestNode extends PathNode {
  const ChestNode({
    required super.id,
    required super.title,
    required super.state,
    super.lockReason,
    super.starsEarned,
    this.isOpened = false,
  });

  final bool isOpened;
}
