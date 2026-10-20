import '../../onboarding/domain/age_band.dart';

/// Business rules governing premium offer presentation and store compliance.
///
/// Follows AGENTS.md §2.2: Pure Dart domain logic with zero Flutter imports.
abstract final class PremiumRules {
  /// Determines whether the premium introductory offer setup step should be presented.
  ///
  /// Compliance considerations:
  /// - Child age bands (e.g. [AgeBand.child] or [AgeBand.teen]): Store guidelines
  ///   (Apple Kids Category, Google Designed for Families) strictly regulate direct upsells,
  ///   in-app purchases, and advertising without parental gates.
  ///   TODO(question): Confirm with client whether under-18 learners skip the offer step entirely
  ///   or require a parental gate before viewing subscription options.
  /// - Returning subscribers: Users with an active entitlement should bypass this step.
  ///   TODO(question): Confirm entitlement sync behavior during onboarding for signed-in users.
  static bool shouldShowOffer({
    AgeBand? ageBand,
    bool isAlreadyPremium = false,
  }) {
    if (isAlreadyPremium) {
      return false;
    }

    // Default policy: currently true for all age bands until legal/compliance rules are finalized.
    return true;
  }

  /// Determines whether the full paywall screen can be shown to a user in [ageBand].
  ///
  /// Store regulations (e.g. Apple Kids Category & Google Families policy) prohibit
  /// unrestricted in-app purchase prompts to children without a parental gate.
  /// TODO(question): Confirm with client and legal team whether child learners must pass
  /// an adult parental gate before viewing this paywall screen.
  static bool canShowPaywall(AgeBand? ageBand) {
    // Always true for now until client/legal team specifies parental gate flow.
    return true;
  }
}
