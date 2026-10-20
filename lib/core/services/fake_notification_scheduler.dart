import 'notification_scheduler.dart';

/// In-memory fake scheduler for tests, preview, and unsupported environments.
class FakeNotificationScheduler implements NotificationScheduler {
  FakeNotificationScheduler({this.permissionGrantedResult = true});

  /// Configurable simulated permission result.
  bool permissionGrantedResult;

  /// In-memory record of scheduled reminders.
  final List<Map<String, dynamic>> scheduledReminders = [];

  bool wasPermissionRequested = false;
  bool wereRemindersCancelled = false;

  @override
  Future<bool> requestPermission() async {
    wasPermissionRequested = true;
    return permissionGrantedResult;
  }

  @override
  Future<void> scheduleWeeklyReminders({
    required int hour,
    required int minute,
    required Set<int> weekdays,
    required String title,
    required String body,
  }) async {
    scheduledReminders.add({
      'hour': hour,
      'minute': minute,
      'weekdays': weekdays,
      'title': title,
      'body': body,
    });
  }

  @override
  Future<void> cancelAllReminders() async {
    wereRemindersCancelled = true;
    scheduledReminders.clear();
  }
}
