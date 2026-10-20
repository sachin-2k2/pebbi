/// Weekday representation for daily reminder schedules.
///
/// Follows AGENTS.md §2: pure Dart domain model, values correspond to
/// standard DateTime weekday values (1 = Monday .. 7 = Sunday).
enum Weekday {
  monday(1, 'M', 'Monday'),
  tuesday(2, 'T', 'Tuesday'),
  wednesday(3, 'W', 'Wednesday'),
  thursday(4, 'T', 'Thursday'),
  friday(5, 'F', 'Friday'),
  saturday(6, 'S', 'Saturday'),
  sunday(7, 'S', 'Sunday');

  const Weekday(this.isoNumber, this.shortLetter, this.fullName);

  /// ISO-8601 weekday number (1 for Monday to 7 for Sunday).
  final int isoNumber;

  /// Single-character display letter (M, T, W, T, F, S, S).
  final String shortLetter;

  /// Full weekday name for screen reader accessibility.
  final String fullName;

  /// Canonical list of all 7 days from Monday to Sunday.
  static const List<Weekday> allDays = [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  ];

  /// Default weekday selection: all 7 days selected.
  static const Set<int> allDayNumbers = {1, 2, 3, 4, 5, 6, 7};

  /// Resolves a weekday by its ISO number (1..7).
  static Weekday forNumber(int number) {
    return allDays.firstWhere(
      (day) => day.isoNumber == number,
      orElse: () => monday,
    );
  }
}
