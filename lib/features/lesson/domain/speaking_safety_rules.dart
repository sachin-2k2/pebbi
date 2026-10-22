import '../../onboarding/domain/age_band.dart';

/// Pure safety and compliance rules for speaking exercises.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract final class SpeakingSafetyRules {
  /// Evaluates whether speaking exercises are permitted for the given age band.
  ///
  /// Under COPPA (US) and GDPR-K (EU), child voice recordings may require verifiable
  /// parental consent. Currently returns true as a placeholder until legal/product policy
  /// is established.
  /// TODO(question): Confirm minor voice recording consent policy with legal counsel.
  static bool shouldAllowSpeaking(AgeBand? ageBand) {
    if (ageBand == AgeBand.child) {
      return false;
    }
    return true;
  }
}
