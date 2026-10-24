/// Configuration tokens and constants for the Splash screen.
///
/// Follows AGENTS.md §2, §3 (< 150 lines), §4, and User Rules 1–8.
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

  /// Hold duration after the entrance controller finishes (placeholder 300 ms).
  /// TODO(question): Designer to confirm hold time before exit.
  static const Duration holdDurationWithArt = Duration(milliseconds: 300);

  /// Short minimum display time when Reduce Motion is active or splash art is disabled.
  /// Prevents 1-2 frame flash flicker (placeholder 300 ms).
  /// TODO(question): Designer to confirm short display time.
  static const Duration minDisplayTimeShort = Duration(milliseconds: 300);

  /// Hard limit safety timeout after which startup aborts and shows error UI with Retry.
  /// TODO(question): Client to confirm 8s hard limit.
  static const Duration startupTimeout = Duration(seconds: 8);

  /// Delay for accessibility announcement "Starting Pebbi".
  static const Duration accessibilityAnnouncementDelay = Duration(seconds: 3);

  /// Duration for each dash highlight step (placeholder 200 ms).
  static const Duration dashStepDuration = Duration(milliseconds: 200);

  /// Duration for the smooth color cross-fade between dashes (80 ms).
  static const Duration dashFadeDuration = Duration(milliseconds: 80);

  /// Total duration for one full cycle of the 3 loading dashes.
  static Duration get dashCycleDuration => dashStepDuration * 3;

  /// Reserved maximum width for the tagline to prevent layout shifts.
  static const double taglineReservedWidth = 220.0;

  /// Size of the loading dashes.
  static const double dashWidth = 18.0;
  static const double dashHeight = 4.0;
  static const double dashSpacing = 6.0;

  /// Debug-only flag for splash timing logs (compiled out in release).
  static const bool enableSplashTimingLogs = true;
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

  // 0 to 200 ms: Loading dashes fade in with the first gradient fade
  static const double dashesFadeStart = 0.0;
  static const double dashesFadeEnd = 200.0 / 900.0;
}
