/// Pure business rules for selecting reasons in Onboarding Step 5.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
abstract final class ReasonSelectionRules {
  /// Maximum number of learning reasons a user can pick.
  static const int maxSelections = 3;

  /// Checks if [id] can be selected without exceeding the maximum limit.
  static bool canSelect(Set<String> current, String id) {
    return current.contains(id) || current.length < maxSelections;
  }

  /// Toggles selection of [id].
  ///
  /// - If [id] is already selected, it is removed.
  /// - If [id] is not selected and fewer than [maxSelections] are chosen, it is added.
  /// - If [id] is not selected and [maxSelections] are already chosen, [current] is returned unchanged.
  static Set<String> toggle(Set<String> current, String id) {
    if (current.contains(id)) {
      final updated = Set<String>.from(current);
      updated.remove(id);
      return Set.unmodifiable(updated);
    }

    if (current.length < maxSelections) {
      final updated = Set<String>.from(current);
      updated.add(id);
      return Set.unmodifiable(updated);
    }

    // 4th selection rejected
    return current;
  }
}
