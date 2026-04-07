import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:developer' as developer;

/// Local notifications service
/// Handles scheduling and displaying local notifications
class LocalNotificationsService {
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  factory LocalNotificationsService() {
    return _instance;
  }

  LocalNotificationsService._internal();

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      final DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      // Combine settings
      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      _isInitialized = true;
      developer.log('Local notifications initialized successfully');
    } catch (e) {
      developer.log('Error initializing local notifications: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payloadType,
    int notificationId = 0,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'lingoquest_channel',
        'LingoQuest Notifications',
        channelDescription: 'Notifications for LingoQuest learning app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails =
          NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payloadType,
      );

      developer.log('Notification shown: $title');
    } catch (e) {
      developer.log('Error showing notification: $e', error: e);
    }
  }

  /// Schedule notification at specific time
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payloadType,
    int notificationId = 1,
  }) async {
    try {
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'lingoquest_scheduled',
        'LingoQuest Scheduled Notifications',
        channelDescription: 'Scheduled notifications for study reminders',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails =
          NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payloadType,
      );

      developer.log(
        'Notification scheduled for ${scheduledTime.toString()}: $title',
      );
    } catch (e) {
      developer.log('Error scheduling notification: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required String title,
    required String body,
    required TimeOfDay time,
    String? payloadType,
    int notificationId = 2,
  }) async {
    try {
      // Get today's date and set the time
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'lingoquest_daily',
        'LingoQuest Daily Reminders',
        channelDescription: 'Daily study reminders',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails =
          NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payloadType,
      );

      developer.log(
        'Daily notification scheduled for ${time.format(null)}: $title',
      );
    } catch (e) {
      developer.log('Error scheduling daily notification: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Cancel notification by ID
  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(notificationId);
      developer.log('Notification cancelled: $notificationId');
    } catch (e) {
      developer.log('Error cancelling notification: $e', error: e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      developer.log('All notifications cancelled');
    } catch (e) {
      developer.log('Error cancelling all notifications: $e', error: e);
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      developer.log('Error getting pending notifications: $e', error: e);
      return [];
    }
  }

  /// Callback when local notification is tapped on iOS
  Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    developer.log('Did receive local notification: $title - $body');
    // Handle notification tap
  }

  /// Callback when notification response is received
  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    final payload = notificationResponse.payload;
    developer.log('Notification response payload: $payload');
    // Handle notification tap based on payload
  }
}

/// Helper class for time of day
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  String format(dynamic context) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
