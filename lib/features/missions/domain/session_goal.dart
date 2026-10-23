/// Domain model for an active goal/objective during a role-play mission.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class SessionGoal {
  const SessionGoal({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  final String id;
  final String text;
  final bool isDone;

  SessionGoal copyWith({
    String? id,
    String? text,
    bool? isDone,
  }) {
    return SessionGoal(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionGoal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          isDone == other.isDone;

  @override
  int get hashCode => Object.hash(id, text, isDone);
}
