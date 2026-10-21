/// Domain model representing a Free Talk conversational topic.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class FreeTalkTopic {
  const FreeTalkTopic({
    required this.id,
    required this.label,
    this.isCustom = false,
  });

  /// Distinct topic identifier (e.g. 'today', 'food', 'custom').
  final String id;

  /// User-facing label in the learner's explanation language.
  final String label;

  /// Whether this topic represents user-typed custom input ('My own').
  final bool isCustom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeTalkTopic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          isCustom == other.isCustom;

  @override
  int get hashCode => Object.hash(id, label, isCustom);
}
