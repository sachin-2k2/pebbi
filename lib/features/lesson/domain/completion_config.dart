/// Configuration parameters for lesson completion display and mock calculations.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class CompletionConfig {
  // Placeholder star thresholds used exclusively by mock/client logic.
  // Real calculation rules and weightings are owned by the backend team.
  // TODO(question: backend team owns star award algorithm and thresholds).
  static const double star3MinAccuracy = 0.90;
  static const double star2MinAccuracy = 0.60;

  // Maximum number of learned phrase rows displayed before collapsing into "+N more".
  // TODO(question: confirm maximum row count with product/design team).
  static const int maxLearnedPhrasesDisplayed = 3;

  // Motion timings
  static const Duration starPopDuration = Duration(milliseconds: 260);
  static const Duration starStaggerDelay = Duration(milliseconds: 90);
  static const Duration mascotBounceDuration = Duration(milliseconds: 350);
}
