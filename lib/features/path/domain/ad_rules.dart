import '../../onboarding/domain/age_band.dart';

/// Pure domain rules governing advertisement eligibility and child-safety compliance.
///
/// Follows AGENTS.md §2.2: Pure Dart rules with zero Flutter imports.
class AdRules {
  const AdRules();

  /// Determines whether an advertisement banner should be shown to the user.
  ///
  /// Rules:
  /// - Premium learners never see ads.
  /// - Children (`AgeBand.child`) must never see commercial ads under COPPA/GDPR-K.
  /// - Offline users cannot fetch/view ads (ad banner hidden to avoid blank space).
  ///
  /// TODO(question: backend/legal team alignment on contextual child-safe promo messages).
  static bool shouldShowAds({
    required AgeBand ageBand,
    required bool isPremium,
    required bool isOnline,
  }) {
    if (isPremium) return false;
    if (ageBand == AgeBand.child) return false;
    if (!isOnline) return false;
    return true;
  }
}
