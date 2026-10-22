/// Audio playback rate constants for spoken exercises.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class AudioPlaybackRates {
  /// Standard conversational speech playback rate.
  static const double normal = 0.45;

  /// Deliberate, articulated slower speech playback rate.
  static const double slow = 0.25;
}
