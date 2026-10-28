import '../../domain/weekday.dart';

/// Formatter for `reminder_days` into full English day names sorted Monday-first.
///
/// Follows API-UPDATES.md §1 & §5:
/// Backend accepts full day names (`"Monday"`, `"Tuesday"`, ...) or integers 1 to 7.
/// This mapper sends full English names sorted Monday-first.
abstract final class WeekdayMapper {
  static const Map<int, String> isoToDayName = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  static final Map<String, int> dayNameToIso = {
    for (final entry in isoToDayName.entries)
      entry.value.toLowerCase(): entry.key,
  };

  /// Converts a set of ISO weekday numbers (1..7) to full day names, sorted Monday-first.
  static List<String> toApi(Set<int>? weekdayNumbers) {
    if (weekdayNumbers == null || weekdayNumbers.isEmpty) return const [];

    final sorted = weekdayNumbers.where((n) => n >= 1 && n <= 7).toList()
      ..sort();
    return sorted.map((n) => isoToDayName[n]!).toList(growable: false);
  }

  /// Parses incoming `reminder_days` list (names or integers) back to ISO weekday numbers.
  static Set<int> fromApi(List<dynamic>? apiDays) {
    if (apiDays == null || apiDays.isEmpty) return Weekday.allDayNumbers;

    final result = <int>{};
    for (final item in apiDays) {
      if (item is int && item >= 1 && item <= 7) {
        result.add(item);
      } else if (item is String) {
        final iso = dayNameToIso[item.toLowerCase().trim()];
        if (iso != null) {
          result.add(iso);
        }
      }
    }
    return result.isEmpty ? Weekday.allDayNumbers : result;
  }
}
