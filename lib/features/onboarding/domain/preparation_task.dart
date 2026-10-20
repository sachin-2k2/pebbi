/// Lifecycle status for an onboarding path readiness preparation task.
enum TaskStatus { pending, done, failed, unavailable }

/// Pure Dart domain model representing a single setup preparation requirement.
///
/// Follows AGENTS.md §2.2: Pure Dart with zero Flutter imports.
class PreparationTask {
  const PreparationTask({
    required this.id,
    required this.label,
    required this.emoji,
    this.status = TaskStatus.pending,
    this.isBlocking = true,
    this.errorMessage,
  });

  /// Creates default initial preparation tasks.
  static List<PreparationTask> defaultInitialTasks({
    String? unavailableTaskId,
  }) {
    return [
      PreparationTask(
        id: 'audio',
        label: 'Headphones on — audio is ready',
        emoji: '🎧',
        status: unavailableTaskId == 'audio'
            ? TaskStatus.unavailable
            : TaskStatus.pending,
      ),
      PreparationTask(
        id: 'sticker',
        label: 'Sticker book started',
        emoji: '👋',
        status: unavailableTaskId == 'sticker'
            ? TaskStatus.unavailable
            : TaskStatus.pending,
      ),
      PreparationTask(
        id: 'speaking',
        label: 'Speaking practice unlocked',
        emoji: '🎙️',
        status: unavailableTaskId == 'speaking'
            ? TaskStatus.unavailable
            : TaskStatus.pending,
      ),
    ];
  }

  /// Unique task identifier (e.g. 'audio', 'sticker', 'speaking').
  final String id;

  /// User-facing label description.
  final String label;

  /// Leading emoji icon character.
  final String emoji;

  /// Current task progress status.
  final TaskStatus status;

  /// Whether failure of this task blocks the "Start lesson" primary action.
  final bool isBlocking;

  /// Optional error message if the task failed.
  final String? errorMessage;

  bool get isDone => status == TaskStatus.done;
  bool get isFailed => status == TaskStatus.failed;
  bool get isUnavailable => status == TaskStatus.unavailable;

  PreparationTask copyWith({
    String? id,
    String? label,
    String? emoji,
    TaskStatus? status,
    bool? isBlocking,
    String? errorMessage,
  }) {
    return PreparationTask(
      id: id ?? this.id,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      status: status ?? this.status,
      isBlocking: isBlocking ?? this.isBlocking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreparationTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          emoji == other.emoji &&
          status == other.status &&
          isBlocking == other.isBlocking &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      Object.hash(id, label, emoji, status, isBlocking, errorMessage);
}
