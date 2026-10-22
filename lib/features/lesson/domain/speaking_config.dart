/// Pure domain configuration for speaking exercises and matching thresholds.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract final class SpeakingConfig {
  /// Minimum normalized token / character similarity required for a match (0.0 to 1.0).
  /// TODO(question): Confirm authoritative scoring ownership (client vs backend).
  static const double similarityThreshold = 0.80;

  /// Maximum duration to record speech before automatically timing out.
  /// TODO(question): Confirm listening duration limits per language.
  static const Duration maxListeningDuration = Duration(seconds: 10);

  /// Silence duration after speech before speech recognition finalizes.
  /// TODO(question): Confirm silence timeout with product.
  static const Duration silenceTimeout = Duration(seconds: 3);

  /// Credit awarded on full speech recognition match.
  static const double fullCreditValue = 1.0;

  /// Credit awarded when learner confirms "I said it ✓" via self-check.
  static const double halfCreditValue = 0.5;

  /// Credit awarded when learner skips the speaking exercise.
  static const double zeroCreditValue = 0.0;

  /// Whether diacritic accents are ignored during matching (e.g. estás vs estas).
  static const bool ignoreAccents = true;
}
