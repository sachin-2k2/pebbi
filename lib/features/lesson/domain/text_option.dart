/// Represents a selectable text answer option in an exercise.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class TextOption {
  const TextOption({required this.id, required this.text});

  /// Unique identifier of the option.
  final String id;

  /// Text displayed on the option card (e.g. "I'm from Mexico").
  final String text;
}
