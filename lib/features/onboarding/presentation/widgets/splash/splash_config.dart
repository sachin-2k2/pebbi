/// Configuration tokens and constants for the Splash screen.
///
/// Follows AGENTS.md §2, §3 (< 150 lines), §4, and User Rules 1–7.
abstract final class SplashConfig {
  /// Logical size in dp for the central logo tile.
  /// Fixed across all devices, windows, and text scales.
  /// TODO(question): 96dp is a placeholder chosen per spec; designer to confirm.
  static const double tileLogicalSize = 96.0;

  /// Default flag: whether to show full decorative splash on every cold start
  /// or only on the first-ever launch.
  /// TODO(question): Client to decide production default.
  static const bool splashArtOnEveryLaunchDefault = true;

  /// Key in non-user SharedPreferences storing whether splash art has been seen.
  static const String hasSeenSplashArtPrefKey = 'has_seen_splash_art';

  /// Total budget for entrance animation: 900 ms.
  static const Duration entranceDuration = Duration(milliseconds: 900);

  /// Minimum display time when full decorative art is displayed.
  /// Matches entrance duration so no half-built splash is displayed on fast startup.
  static const Duration minDisplayTimeWithArt = Duration(milliseconds: 900);

  /// Minimum display time when splash art is disabled (0 ms).
  static const Duration minDisplayTimeWithoutArt = Duration.zero;

  /// Reserved maximum width for the tagline to prevent layout shifts.
  static const double taglineReservedWidth = 220.0;

  /// Size of the loading dashes.
  static const double dashWidth = 18.0;
  static const double dashHeight = 4.0;
  static const double dashSpacing = 6.0;
}

/// Entrance animation phase offsets within the 900ms budget.
abstract final class SplashAnimationConfig {
  // 0 to 350 ms: Gradient cross-fades over solid background
  static const double gradientFadeStart = 0.0;
  static const double gradientFadeEnd = 350.0 / 900.0;

  // 150 to 550 ms: Wordmark and tagline fade in and slide up 8dp
  static const double wordmarkFadeStart = 150.0 / 900.0;
  static const double wordmarkFadeEnd = 550.0 / 900.0;

  // 300 to 750 ms: Floating items and greetings fade in
  static const double decorationsFadeStart = 300.0 / 900.0;
  static const double decorationsFadeEnd = 750.0 / 900.0;

  // 450 to 900 ms: Loading dashes begin pulsing
  static const double dashesFadeStart = 450.0 / 900.0;
  static const double dashesFadeEnd = 1.0;
}
