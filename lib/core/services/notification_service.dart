import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Notification ids used across the app
class NotificationIds {
  NotificationIds._();

  static const openSummary = 1;
  static const dailyReminder = 2;
  static const debtAlertBase = 1000;
}

/// Payloads attached to notifications so taps can be routed
class NotificationPayloads {
  NotificationPayloads._();

  static const debts = 'debts';
  static const social = 'social';
}

/// Wrapper around flutter_local_notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Called when the user taps a notification (payload is passed through)
  void Function(String? payload)? onTap;

  /// Payload of the notification that launched the app, if any
  String? launchPayload;

  static const _remindersChannel = AndroidNotificationChannel(
    'reminders',
    'Payment reminders',
    description: 'Reminders about money you owe or are owed',
    importance: Importance.high,
  );

  static const _socialChannel = AndroidNotificationChannel(
    'social',
    'Friends & groups',
    description: 'Friend requests and group invitations',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (e) {
        debugPrint('Timezone lookup failed, using UTC: $e');
      }

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) =>
            onTap?.call(response.payload),
      );

      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(_remindersChannel);
      await android?.createNotificationChannel(_socialChannel);

      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        launchPayload = launch!.notificationResponse?.payload;
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  /// Ask for permission (Android 13+ / iOS). Safe to call repeatedly.
  Future<void> requestPermission() async {
    if (!_initialized) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  NotificationDetails _details(
    AndroidNotificationChannel channel, {
    String? body,
    String? tag,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        tag: tag,
        // Long multi-line bodies (list of debts) stay readable
        styleInformation: body == null ? null : BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  Future<void> showReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details(_remindersChannel, body: body),
        payload: NotificationPayloads.debts,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Social notifications use the Firestore doc id as tag so a matching FCM
  /// push (same tag, id 0) replaces it instead of showing a duplicate.
  Future<void> showSocial({
    required String tag,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: _details(_socialChannel, body: body, tag: tag),
        payload: NotificationPayloads.social,
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Schedule (or replace) the repeating daily reminder
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: when,
        title: title,
        body: body,
        notificationDetails: _details(_remindersChannel, body: body),
        // Inexact avoids needing the SCHEDULE_EXACT_ALARM permission
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: NotificationPayloads.debts,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }
}
