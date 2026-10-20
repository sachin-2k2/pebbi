import 'daily_goal_info.dart';

/// Selection logic and rules for daily learning goals.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
abstract final class DailyGoalSelectionRules {
  /// Default preselected goal identifier.
  ///
  /// TODO(question): Confirm with client whether 'regular' (10 min/day) should be
  /// preselected by default or require an explicit user selection before enabling Continue.
  static const String defaultGoalId = 'regular';

  /// Selects [newGoalId].
  ///
  /// If [newGoalId] matches [currentGoalId], returns [currentGoalId] unchanged (tapping
  /// the already selected card is a no-op).
  static String select({
    required String currentGoalId,
    required String newGoalId,
  }) {
    if (currentGoalId == newGoalId) {
      return currentGoalId;
    }
    // Verify that newGoalId corresponds to a known goal
    final goal = DailyGoalInfo.forStringId(newGoalId);
    return goal.id.id;
  }
}
