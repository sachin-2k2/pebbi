/// Represents an individual quest row on the Rewards screen.
///
/// Follows AGENTS.md §2.2: Pure Dart domain model with zero Flutter imports.
class QuestItem {
  const QuestItem({
    required this.id,
    required this.emoji,
    required this.label,
    required this.current,
    required this.target,
    required this.isDone,
  });

  final String id;
  final String emoji;
  final String label;
  final int current;
  final int target;
  final bool isDone;

  double get progressRatio =>
      target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          label == other.label &&
          current == other.current &&
          target == other.target &&
          isDone == other.isDone;

  @override
  int get hashCode =>
      id.hashCode ^
      emoji.hashCode ^
      label.hashCode ^
      current.hashCode ^
      target.hashCode ^
      isDone.hashCode;
}
