import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fake_notification_scheduler.dart';
import 'notification_scheduler.dart';

/// Global provider for the [NotificationScheduler].
///
/// In tests or mock mode, can be overridden with a [FakeNotificationScheduler].
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  // Uses fake scheduler by default until native notification channels are configured in main
  return FakeNotificationScheduler();
});
