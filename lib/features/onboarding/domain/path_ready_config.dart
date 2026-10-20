/// Named timing and threshold configuration constants for the Path Ready step.
///
/// Follows AGENTS.md §2.2 & §3.3: named constants in config files; no magic numbers.
abstract final class PathReadyConfig {
  /// Total estimated duration for path readiness animation sequence (~2.4 seconds).
  static const Duration totalPreparationDuration = Duration(milliseconds: 2400);

  /// Interval between preparation update ticks in mock service.
  static const Duration tickInterval = Duration(milliseconds: 80);

  /// Progress thresholds at which each readiness task ticks to done.
  static const double task1Threshold = 0.33; // Audio ready
  static const double task2Threshold = 0.66; // Sticker book started
  static const double task3Threshold = 1.00; // Speaking practice unlocked

  /// Ring sizing tokens (clamped between min and max responsive boundaries).
  static const double ringStrokeWidth = 13.0;
  static const double minRingDiameter = 140.0;
  static const double maxRingDiameter = 200.0;

  /// Default fallback first lesson metadata.
  static const int defaultFirstLessonNumber = 1;
  static const int defaultFirstLessonMinutes = 3;

  /// Onboarding step index.
  static const int stepNumber = 11;
}
