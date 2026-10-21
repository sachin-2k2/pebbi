import '../../onboarding/domain/age_band.dart';

/// Child safety guardrails for the Invite card and referral sharing.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class InviteSafetyRules {
  /// Whether the invite card should be displayed for the given [ageBand].
  static bool shouldShowInvite(AgeBand ageBand) {
    return true;
  }

  /// Whether the user can trigger external invite sharing.
  static bool canShareInvite(AgeBand? ageBand) {
    if (ageBand == AgeBand.child) return false;
    return true;
  }
}
