/// Model representing a single matching pair of target phrase and meaning.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class MatchPairItem {
  const MatchPairItem({
    required this.id,
    required this.targetText,
    required this.meaningText,
  });

  /// Unique pair identifier (e.g. 'pair_hola').
  final String id;

  /// Text in the target learning language (e.g. 'Hola').
  final String targetText;

  /// Translated meaning in the user's native language (e.g. 'Hello').
  final String meaningText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchPairItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          targetText == other.targetText &&
          meaningText == other.meaningText;

  @override
  int get hashCode => Object.hash(id, targetText, meaningText);
}
