/// Configuration constants for placement quiz scoring heuristics.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
/// TODO(question): Who decides this scoring rule in production — the client or the backend API?
abstract final class PlacementScoringConfig {
  /// Minimum first-try correct answers required for [LanguageLevel.expert].
  static const int expertMinCorrect = 7;

  /// Minimum first-try correct answers required for [LanguageLevel.knowABit].
  static const int knowABitMinCorrect = 4;

  /// Maximum number of target language praise phrases displayed on result card.
  static const int maxPraisePhrases = 3;
}
