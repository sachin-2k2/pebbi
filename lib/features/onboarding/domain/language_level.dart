/// Proficiency levels for language placement.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum LanguageLevel {
  little(id: 'little', label: 'Little'),
  knowABit(id: 'know_a_bit', label: 'Know a bit'),
  expert(id: 'expert', label: 'Expert');

  const LanguageLevel({required this.id, required this.label});

  final String id;
  final String label;

  /// Returns [LanguageLevel] matching [id], or null if not found.
  static LanguageLevel? fromId(String id) {
    for (final level in values) {
      if (level.id == id) return level;
    }
    return null;
  }
}
