/// Pure Dart representation of a daily reminder wall-clock time.
///
/// Follows AGENTS.md §2: zero Flutter UI dependencies.
class ReminderTime {
  const ReminderTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour <= 23, 'Hour must be between 0 and 23'),
      assert(minute >= 0 && minute <= 59, 'Minute must be between 0 and 59');

  /// Hour in 24-hour format (0–23).
  final int hour;

  /// Minute of the hour (0–59).
  final int minute;

  /// Default reminder time shown in prototype: 7:00 PM (19:00).
  static const ReminderTime defaultTime = ReminderTime(hour: 19, minute: 0);

  /// Converts this time into a stable 24-hour string (e.g. "19:00").
  String to24HourString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Parses a 24-hour string (e.g. "19:00") into a [ReminderTime].
  static ReminderTime parse(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return defaultTime;
    final h = int.tryParse(parts[0]) ?? defaultTime.hour;
    final m = int.tryParse(parts[1]) ?? defaultTime.minute;
    return ReminderTime(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  /// Formats the time for presentation adhering to the device's 12h/24h setting.
  String formatDisplay({required bool alwaysUse24Hour}) {
    if (alwaysUse24Hour) {
      return to24HourString();
    }
    final isPm = hour >= 12;
    var displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    final h = displayHour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final period = isPm ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => to24HourString();
}
