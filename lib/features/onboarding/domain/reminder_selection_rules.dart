import 'weekday.dart';

/// Pure domain selection and validation rules for daily reminders.
///
/// Follows AGENTS.md §2: zero Flutter UI dependencies.
abstract final class ReminderSelectionRules {
  /// Default preselected weekday numbers (all 7 days).
  static const Set<int> defaultWeekdayNumbers = Weekday.allDayNumbers;

  /// Toggles the selection state of a weekday.
  ///
  /// Returns a new set containing [dayNumber] if it wasn't selected,
  /// or omitting it if it was already selected.
  static Set<int> toggleWeekday(Set<int> currentDays, int dayNumber) {
    final updated = Set<int>.from(currentDays);
    if (updated.contains(dayNumber)) {
      updated.remove(dayNumber);
    } else {
      updated.add(dayNumber);
    }
    return updated;
  }

  /// Whether reminders are considered actively enabled.
  ///
  /// If zero days are selected, reminders are treated as turned off.
  static bool areRemindersEnabled(Set<int> selectedDays) {
    return selectedDays.isNotEmpty;
  }
}
