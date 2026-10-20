import '../../auth/domain/user_profile.dart';
import '../../onboarding/domain/age_band.dart';
import 'mission_summary.dart';

/// Result of evaluating whether a user can access a specific mission.
enum MissionAccessResult {
  /// User is allowed to play this mission.
  allowed,

  /// Mission requires an active Premium subscription.
  needsPremium,

  /// Free tier usage quota or daily limit has been reached.
  limitReached,
}

/// Pure Dart business rules governing access and child safety for missions.
///
/// Follows AGENTS.md §2.2: Zero Flutter imports.
abstract final class MissionAccessRules {
  /// Evaluates whether [user] has access to launch [mission].
  ///
  /// Premium missions require `user.isPremium == true`.
  /// TODO(question: free tier missions quota limit is unknown; currently unmetered for non-premium missions).
  static MissionAccessResult missionAccess(
    UserProfile? user,
    MissionSummary mission,
  ) {
    if (mission.isPremium && (user == null || !user.isPremium)) {
      return MissionAccessResult.needsPremium;
    }
    // Free missions are currently allowed. Limit quota hooks will be added once backend specs are provided.
    return MissionAccessResult.allowed;
  }

  /// Determines whether role-play missions should be shown for the learner's [ageBand].
  ///
  /// TODO(question: confirm whether child age band requires parental gate or restricted scenarios).
  static bool shouldShowMissions(AgeBand ageBand) {
    return true;
  }

  /// Determines whether open-ended Free Talk AI conversations are allowed for [ageBand].
  ///
  /// TODO(question: confirm child safety guardrails for unstructured conversational AI).
  static bool shouldAllowFreeTalk(AgeBand ageBand) {
    return true;
  }
}
