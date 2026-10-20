import '../../../features/onboarding/domain/age_band.dart';

/// Domain rules for user registration eligibility and age band safety.
///
/// Follows AGENTS.md §2.2: Pure Dart domain logic with zero Flutter imports.
abstract final class RegistrationRules {
  /// Evaluates whether an account can be created for the given [ageBand].
  ///
  /// Currently returns true for all age bands.
  /// TODO(question): What are the legal requirements (COPPA, GDPR-K) for child accounts?
  /// Does a child account require verifiable parental consent, or is direct registration
  /// blocked in favour of a guest/managed child profile?
  static bool canRegister(AgeBand? ageBand) {
    return true;
  }

  /// Lists special registration requirements (e.g. parental consent email) for the given [ageBand].
  ///
  /// Currently empty.
  /// TODO(question): What extra data is collected for children (e.g., parent's email)?
  /// Are children allowed to use Google Sign-In?
  static List<String> registrationRequirements(AgeBand? ageBand) {
    return const [];
  }
}
