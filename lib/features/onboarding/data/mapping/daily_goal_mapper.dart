/// Mapping for daily commitment goal tiers.
///
/// Follows API-UPDATES.md §5:
/// Allowed values: `casual`, `regular`, `serious`, `intense` (5, 10, 15, and 20 minutes).
abstract final class DailyGoalMapper {
  static const String defaultGoal = 'regular';

  static const Set<String> validDailyGoals = {
    'casual',
    'regular',
    'serious',
    'intense',
  };

  static String toApi(String? goalId) {
    if (goalId == null || !validDailyGoals.contains(goalId.toLowerCase())) {
      return defaultGoal;
    }
    return goalId.toLowerCase();
  }

  static String fromApi(String? apiValue) {
    if (apiValue == null) return defaultGoal;
    final lower = apiValue.toLowerCase().trim();
    if (validDailyGoals.contains(lower)) return lower;
    return defaultGoal;
  }
}
