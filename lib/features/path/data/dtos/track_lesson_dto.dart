import '../../domain/path_node.dart';

/// Tolerant DTO for an individual lesson within a track.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class TrackLessonDto {
  const TrackLessonDto({
    required this.lessonId,
    required this.lessonNumber,
    required this.level,
    this.levelOrder,
    required this.title,
    this.icon,
    this.xpReward = 10,
    this.status = 'not_started',
    this.locked = true,
  });

  final String lessonId;
  final int lessonNumber;
  final String level;
  final int? levelOrder;
  final String title;
  final String? icon;
  final int xpReward;
  final String status;
  final bool locked;

  factory TrackLessonDto.fromJson(Map<String, dynamic> json) {
    return TrackLessonDto(
      lessonId: json['lesson_id']?.toString() ?? '',
      lessonNumber: (json['lesson_number'] as num?)?.toInt() ?? 1,
      level: json['level']?.toString() ?? 'starter',
      levelOrder: (json['level_order'] as num?)?.toInt(),
      title: json['title']?.toString() ?? 'Lesson',
      icon: json['icon']?.toString(),
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 10,
      status: json['status']?.toString() ?? 'not_started',
      locked: json['locked'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'lesson_id': lessonId,
    'lesson_number': lessonNumber,
    'level': level,
    if (levelOrder != null) 'level_order': levelOrder,
    'title': title,
    if (icon != null) 'icon': icon,
    'xp_reward': xpReward,
    'status': status,
    'locked': locked,
  };

  /// Converts this DTO to a domain [LessonStopNode].
  LessonStopNode toDomainNode({required int totalInUnit}) {
    final isDone = status == 'complete';
    final isCurrent = !locked && !isDone;

    return LessonStopNode(
      id: lessonId,
      title: title,
      state: isDone
          ? NodeState.done
          : (isCurrent ? NodeState.current : NodeState.locked),
      lockReason: locked ? LockReason.progress : LockReason.none,
      starsEarned: isDone ? 3 : 0,
      stopNumber: levelOrder ?? lessonNumber,
      totalStopsInUnit: totalInUnit,
    );
  }
}
