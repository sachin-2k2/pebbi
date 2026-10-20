import 'language_level.dart';

/// Central configuration constants for the onboarding setup flow.
///
/// Follows AGENTS.md §2.2: no magic numbers in widgets, all step counts
/// and default values are defined here.
abstract final class OnboardingConfig {
  /// Total number of setup steps (11 steps).
  static const int totalSteps = 11;

  /// Default number of questions in the placement check (prototype: 8).
  static const int placementQuestionsCount = 8;

  /// Estimated duration in minutes for the placement check (prototype: 2).
  static const int placementEstimatedMinutes = 2;

  /// Default lowest level assigned when skipping placement check.
  static const LanguageLevel defaultLowestLevel = LanguageLevel.little;

  /// Default preselected year of birth shown in the prototype.
  ///
  /// TODO(question): Confirm with client whether to preselect a default year (2002)
  /// or require the user to explicitly pick a year before enabling Continue.
  static const int defaultBirthYear = 2002;

  /// Minimum age in years allowed to be selected.
  static const int minAgeYears = 4;

  /// Maximum age in years (covers ~100 years from current year).
  static const int maxAgeYears = 100;

  /// Generates the selectable years from current year down to currentYear - [maxAgeYears].
  static List<int> generateSelectableYears({int? currentYear}) {
    final nowYear = currentYear ?? DateTime.now().year;
    final startYear = nowYear - minAgeYears;
    final endYear = nowYear - maxAgeYears;
    final years = <int>[];
    for (int y = startYear; y >= endYear; y--) {
      years.add(y);
    }
    return years;
  }
}
