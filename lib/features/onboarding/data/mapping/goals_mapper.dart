/// Mapping for user learning reasons to backend `learning_goals`.
///
/// Follows API-UPDATES.md §5:
/// All 9 domain reason IDs match backend allowed values directly.
abstract final class GoalsMapper {
  static const Set<String> validGoals = {
    'travel',
    'work',
    'interview',
    'study_abroad',
    'move_abroad',
    'family',
    'exams',
    'culture',
    'just_learning',
  };

  /// Sanitizes reason IDs into a valid `learning_goals` list for registration.
  static List<String> toApi(Iterable<String>? reasonIds) {
    if (reasonIds == null || reasonIds.isEmpty) return const [];
    return reasonIds
        .where((id) => validGoals.contains(id.toLowerCase()))
        .map((id) => id.toLowerCase())
        .toList(growable: false);
  }

  /// Parses incoming `learning_goals` array from backend into domain reason IDs.
  static Set<String> fromApi(List<dynamic>? apiGoals) {
    if (apiGoals == null || apiGoals.isEmpty) return const {};
    return apiGoals
        .map((g) => g.toString().toLowerCase().trim())
        .where((g) => validGoals.contains(g))
        .toSet();
  }
}
