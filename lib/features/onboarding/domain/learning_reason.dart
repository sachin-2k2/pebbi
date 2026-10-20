/// Immutable domain model representing an option in "Why are you learning?".
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LearningReason {
  const LearningReason({
    required this.id,
    required this.label,
    required this.iconEmoji,
  });

  /// Stable identifier (e.g. 'travel', 'work', 'interview').
  final String id;

  /// User-facing display label (e.g. 'Travel', 'Work and career').
  final String label;

  /// Emoji glyph representing the reason (e.g. '🧳', '💼').
  final String iconEmoji;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningReason &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          iconEmoji == other.iconEmoji;

  @override
  int get hashCode => Object.hash(id, label, iconEmoji);
}
