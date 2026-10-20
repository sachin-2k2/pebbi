/// Abstract interface for scheduling and managing local notification reminders.
///
/// Follows AGENTS.md §2 (isolated behind repository/service interface,
/// mock now, real implementation backed by flutter_local_notifications).
abstract interface class NotificationScheduler {
  /// Requests notification permission from the host operating system.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestPermission();

  /// Schedules repeating weekly reminders for the specified [hour], [minute], and [weekdays].
  ///
  /// [weekdays] contains ISO-8601 day numbers (1 = Monday, ..., 7 = Sunday).
  Future<void> scheduleWeeklyReminders({
    required int hour,
    required int minute,
    required Set<int> weekdays,
    required String title,
    required String body,
  });

  /// Cancels all previously scheduled reminders.
  Future<void> cancelAllReminders();
}
