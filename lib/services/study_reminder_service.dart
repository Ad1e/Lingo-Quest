import 'package:shared_preferences/shared_preferences.dart';
import 'package:language_learning_app/services/local_notifications_service.dart';
import 'package:language_learning_app/providers/notification_preference_provider.dart';
import 'dart:developer' as developer;

/// Study reminder service
/// Manages scheduling and tracking of daily study reminders
class StudyReminderService {
  static final StudyReminderService _instance =
      StudyReminderService._internal();

  final LocalNotificationsService _notificationsService =
      LocalNotificationsService();

  factory StudyReminderService() {
    return _instance;
  }

  StudyReminderService._internal();

  /// Initialize study reminders
  Future<void> initialize() async {
    try {
      developer.log('Study reminder service initialized');
    } catch (e) {
      developer.log('Error initializing study reminder service: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Schedule daily study reminder
  Future<void> scheduleDailyReminder({
    required String userId,
    required int hour,
    required int minute,
  }) async {
    try {
      await _notificationsService.scheduleDailyNotification(
        title: '⏰ Time to Study',
        body: "You haven't studied yet today. Keep your streak alive!",
        time: TimeOfDay(hour: hour, minute: minute),
        payloadType: 'study_reminder',
        notificationId: _getReminderId(userId),
      );

      developer.log(
        'Daily reminder scheduled for $userId at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      developer.log('Error scheduling daily reminder: $e',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// Cancel daily study reminder
  Future<void> cancelDailyReminder(String userId) async {
    try {
      await _notificationsService.cancelNotification(_getReminderId(userId));
      developer.log('Daily reminder cancelled for user $userId');
    } catch (e) {
      developer.log('Error cancelling daily reminder: $e', error: e);
      rethrow;
    }
  }

  /// Record that reminder was shown (to check if user studied after reminder)
  Future<void> recordReminderShown(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_reminder_shown_$userId', today);
      developer.log('Reminder recorded for user $userId on $today');
    } catch (e) {
      developer.log('Error recording reminder: $e', error: e);
    }
  }

  /// Check if reminder was shown today and user hasn't studied
  Future<bool> shouldShowReminderToday({
    required String userId,
    required bool userStudiedToday,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastReminder = prefs.getString('last_reminder_shown_$userId');

      // Show reminder if not shown today and user hasn't studied
      return lastReminder != today && !userStudiedToday;
    } catch (e) {
      developer.log('Error checking reminder status: $e', error: e);
      return false;
    }
  }

  /// Mark that user studied today
  Future<void> recordStudyToday(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_study_date_$userId', today);
      developer.log('Study recorded for user $userId on $today');
    } catch (e) {
      developer.log('Error recording study: $e', error: e);
    }
  }

  /// Check if user studied today
  Future<bool> userStudiedToday(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastStudy = prefs.getString('last_study_date_$userId');
      return lastStudy == today;
    } catch (e) {
      developer.log('Error checking if user studied today: $e', error: e);
      return false;
    }
  }

  /// Get unique reminder notification ID for user
  int _getReminderId(String userId) {
    // Generate a consistent ID based on user ID
    return userId.hashCode % 2147483647; // Keep it within int range
  }

  /// Schedule friend challenge notification
  Future<void> scheduleFriendChallengeNotification({
    required String friendName,
    required String challengeType,
  }) async {
    try {
      await _notificationsService.showNotification(
        title: '🎯 New Challenge from $friendName',
        body: '$friendName challenged you to a $challengeType challenge!',
        payloadType: 'friend_challenge',
        notificationId: DateTime.now().millisecondsSinceEpoch.toInt() % 2147483647,
      );

      developer.log(
        'Friend challenge notification sent for $challengeType from $friendName',
      );
    } catch (e) {
      developer.log('Error scheduling friend challenge notification: $e',
          error: e);
      rethrow;
    }
  }

  /// Schedule leaderboard reset notification
  Future<void> scheduleLeaderboardResetNotification() async {
    try {
      await _notificationsService.showNotification(
        title: '🏆 Leaderboard Reset',
        body: 'The weekly leaderboard has been reset. Compete for the top position!',
        payloadType: 'leaderboard_reset',
        notificationId: DateTime.now().millisecondsSinceEpoch.toInt() % 2147483647,
      );

      developer.log('Leaderboard reset notification sent');
    } catch (e) {
      developer.log('Error scheduling leaderboard reset notification: $e',
          error: e);
      rethrow;
    }
  }

  /// Schedule achievement unlock notification
  Future<void> scheduleAchievementNotification({
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    try {
      await _notificationsService.showNotification(
        title: '🏅 Achievement Unlocked: $achievementTitle',
        body: achievementDescription,
        payloadType: 'achievement_unlock',
        notificationId: DateTime.now().millisecondsSinceEpoch.toInt() % 2147483647,
      );

      developer.log('Achievement notification sent: $achievementTitle');
    } catch (e) {
      developer.log('Error scheduling achievement notification: $e', error: e);
      rethrow;
    }
  }

  /// Check and schedule due notifications
  Future<void> checkAndScheduleDueNotifications({
    required String userId,
    required NotificationPreferences prefs,
    required bool userStudiedToday,
  }) async {
    try {
      if (!prefs.enableDailyReminder) {
        return;
      }

      final shouldShow = await shouldShowReminderToday(
        userId: userId,
        userStudiedToday: userStudiedToday,
      );

      if (shouldShow) {
        await recordReminderShown(userId);
        await _notificationsService.showNotification(
          title: '⏰ Time to Study',
          body: "You haven't studied yet today. Keep your streak alive!",
          payloadType: 'study_reminder',
        );
        developer.log('Study reminder notification shown for user $userId');
      }
    } catch (e) {
      developer.log('Error checking due notifications: $e', error: e);
    }
  }
}

/// TimeOfDay class for scheduling
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
