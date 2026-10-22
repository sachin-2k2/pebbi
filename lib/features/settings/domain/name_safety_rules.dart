import '../../onboarding/domain/age_band.dart';

/// Pure Dart domain rules for learner name privacy and validation.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class NameSafetyRules {
  /// Maximum allowed length for first name inputs.
  static const int maxNameLength = 30;

  /// Whether the app may request a learner's first name given their [ageBand].
  ///
  /// Currently returns true for all age bands. Can be restricted for children
  /// under strict COPPA/GDPR-K regimes.
  static bool shouldAskForName(AgeBand ageBand) {
    return true;
  }

  /// Sanitizes raw user input: trims whitespace, removes control characters,
  /// strips emojis if any, and clamps length to [maxNameLength].
  static String sanitize(String input) {
    // Remove emoji characters and non-printable control characters
    final regex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE00}-\u{FE0F}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}]',
      unicode: true,
    );
    final cleaned = input
        .replaceAll(regex, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.length <= maxNameLength) {
      return cleaned;
    }
    return cleaned.substring(0, maxNameLength);
  }
}
