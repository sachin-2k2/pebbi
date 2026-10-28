import '../../domain/reminder_time.dart';

/// Formatter and parser for reminder times in 24-hour `"HH:mm"` format.
///
/// Follows TUTOTOCO-BACKEND-APIS.md §2:
/// - Request payload format: `"19:00"`.
abstract final class ReminderTimeMapper {
  static String toApi(ReminderTime? time) {
    return (time ?? ReminderTime.defaultTime).to24HourString();
  }

  static ReminderTime fromApi(String? apiValue) {
    if (apiValue == null) return ReminderTime.defaultTime;
    return ReminderTime.parse(apiValue);
  }
}
