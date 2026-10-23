/// A single suggested reply card displayed in Guided support mode.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class Suggestion {
  const Suggestion({
    required this.id,
    required this.text,
    this.translation,
  });

  final String id;
  final String text;
  final String? translation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Suggestion &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          translation == other.translation;

  @override
  int get hashCode => Object.hash(id, text, translation);
}
