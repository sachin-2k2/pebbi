import 'calendar_day_state.dart';

/// Represents a single cell in the 28-day rolling streak calendar.
///
/// Follows AGENTS.md §2.2: Pure Dart domain model with zero Flutter imports.
class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.dayNumber,
    required this.state,
    this.isToday = false,
  });

  final DateTime date;
  final int dayNumber;
  final CalendarDayState state;
  final bool isToday;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDay &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          dayNumber == other.dayNumber &&
          state == other.state &&
          isToday == other.isToday;

  @override
  int get hashCode =>
      date.hashCode ^ dayNumber.hashCode ^ state.hashCode ^ isToday.hashCode;
}
