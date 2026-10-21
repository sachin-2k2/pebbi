/// Visual and interaction state of a day cell in the 28-day calendar.
enum CalendarDayState {
  /// Inactive/neutral day (no lesson or mission activity recorded).
  none,

  /// Active day with completed learning activity (displays flame icon).
  active,

  /// Missed day preserved by an active freeze (displays snowflake icon).
  freezeUsed,

  /// Previously missed day restored by a 2-minute warm-up.
  repaired,
}
