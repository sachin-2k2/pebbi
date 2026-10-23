/// Represents a single learning objective/goal within a role-play mission scene.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class MissionGoal {
  const MissionGoal({required this.id, required this.text});

  /// Stable unique goal identifier (e.g. 'order_drink').
  final String id;

  /// Localized or translated goal instruction (e.g. 'Order a drink').
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissionGoal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => Object.hash(id, text);
}
