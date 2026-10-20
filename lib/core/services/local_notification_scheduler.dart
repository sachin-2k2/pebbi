import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_scheduler.dart';

/// Real notification scheduler backed by [FlutterLocalNotificationsPlugin].
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ??
          true; // On Android < 13, permission is granted by default
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  @override
  Future<void> scheduleWeeklyReminders({
    required int hour,
    required int minute,
    required Set<int> weekdays,
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    // Cancel existing scheduled slots before setting new schedule
    await cancelAllReminders();

    // Note: To schedule repeating weekly notifications matching local wall-clock
    // across DST boundaries, zonedSchedule requires tz.TZDateTime (from the timezone package).
    // When the timezone package is approved and configured, zonedSchedule is hooked here.
  }

  @override
  Future<void> cancelAllReminders() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }
}
