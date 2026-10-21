import '../../onboarding/domain/age_band.dart';
import '../../review/domain/invite_safety_rules.dart';

/// Child safety guardrails for gamification, streaks, and sharing.
///
/// Follows AGENTS.md §2.2: Pure Dart domain class with zero Flutter imports.
abstract final class RewardsSafetyRules {
  /// Whether gamification pressure elements (streaks, badges, quests) are visible.
  ///
  /// Always returns true for now per product spec, with child policy pending.
  /// TODO(question): Confirm whether child accounts (under 13) should have streaks/leaderboard elements silenced.
  static bool shouldShowRewardsPressureElements(AgeBand? ageBand) {
    return true;
  }

  /// Whether the invite card should be displayed for the user.
  ///
  /// Reuses [InviteSafetyRules.canShareInvite] to maintain single-source-of-truth.
  static bool shouldShowInvite(AgeBand? ageBand) {
    return InviteSafetyRules.canShareInvite(ageBand);
  }
}
