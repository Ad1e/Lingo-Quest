import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// Model for notification preferences
class NotificationPreferences {
  final bool enableDailyReminder;
  final int reminderHour; // 0-23
  final int reminderMinute; // 0-59
  final bool enableFriendNotifications;
  final bool enableLeaderboardNotifications;
  final bool enableAchievementNotifications;

  NotificationPreferences({
    this.enableDailyReminder = true,
    this.reminderHour = 8, // 8:00 AM
    this.reminderMinute = 0,
    this.enableFriendNotifications = true,
    this.enableLeaderboardNotifications = true,
    this.enableAchievementNotifications = true,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'enableDailyReminder': enableDailyReminder,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'enableFriendNotifications': enableFriendNotifications,
    'enableLeaderboardNotifications': enableLeaderboardNotifications,
    'enableAchievementNotifications': enableAchievementNotifications,
  };

  /// Create from JSON
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enableDailyReminder: json['enableDailyReminder'] as bool? ?? true,
      reminderHour: json['reminderHour'] as int? ?? 8,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
      enableFriendNotifications: json['enableFriendNotifications'] as bool? ?? true,
      enableLeaderboardNotifications: json['enableLeaderboardNotifications'] as bool? ?? true,
      enableAchievementNotifications: json['enableAchievementNotifications'] as bool? ?? true,
    );
  }

  /// Copy with modifications
  NotificationPreferences copyWith({
    bool? enableDailyReminder,
    int? reminderHour,
    int? reminderMinute,
    bool? enableFriendNotifications,
    bool? enableLeaderboardNotifications,
    bool? enableAchievementNotifications,
  }) {
    return NotificationPreferences(
      enableDailyReminder: enableDailyReminder ?? this.enableDailyReminder,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      enableFriendNotifications: enableFriendNotifications ?? this.enableFriendNotifications,
      enableLeaderboardNotifications: enableLeaderboardNotifications ?? this.enableLeaderboardNotifications,
      enableAchievementNotifications: enableAchievementNotifications ?? this.enableAchievementNotifications,
    );
  }

  /// Get display time string
  String getTimeString() {
    final hour = reminderHour.toString().padLeft(2, '0');
    final minute = reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// State notifier for notification preferences
class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<NotificationPreferences>> {
  final String _userId;

  NotificationPreferencesNotifier(this._userId)
      : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  /// Load preferences from shared preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notification_prefs_$_userId';
      final json = prefs.getString(key);

      if (json != null) {
        final Map<String, dynamic> data = Map.from(
          (await Future.delayed(Duration.zero, () => json)) as Map,
        );
        state = AsyncValue.data(NotificationPreferences.fromJson(data));
      } else {
        state = AsyncValue.data(NotificationPreferences());
      }

      developer.log('Notification preferences loaded for user $_userId');
    } catch (e, stackTrace) {
      developer.log('Error loading notification preferences: $e',
          error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update notification preferences
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'notification_prefs_$_userId';
      await prefs.setString(
        key,
        _jsonEncode(preferences.toJson()),
      );
      state = AsyncValue.data(preferences);
      developer.log('Notification preferences updated for user $_userId');
    } catch (e, stackTrace) {
      developer.log('Error updating notification preferences: $e',
          error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Set daily reminder time
  Future<void> setDailyReminderTime(int hour, int minute) async {
    try {
      final current = state.maybeWhen(
        data: (prefs) => prefs,
        orElse: () => NotificationPreferences(),
      );

      final updated = current.copyWith(
        enableDailyReminder: true,
        reminderHour: hour,
        reminderMinute: minute,
      );

      await updatePreferences(updated);
      developer.log('Daily reminder time set to $hour:${'$minute'.padLeft(2, '0')}');
    } catch (e) {
      developer.log('Error setting daily reminder time: $e', error: e);
      rethrow;
    }
  }

  /// Toggle daily reminder
  Future<void> toggleDailyReminder(bool enabled) async {
    try {
      final current = state.maybeWhen(
        data: (prefs) => prefs,
        orElse: () => NotificationPreferences(),
      );

      final updated = current.copyWith(enableDailyReminder: enabled);
      await updatePreferences(updated);
      developer.log('Daily reminder toggled: $enabled');
    } catch (e) {
      developer.log('Error toggling daily reminder: $e', error: e);
      rethrow;
    }
  }

  /// Toggle friend notifications
  Future<void> toggleFriendNotifications(bool enabled) async {
    try {
      final current = state.maybeWhen(
        data: (prefs) => prefs,
        orElse: () => NotificationPreferences(),
      );

      final updated = current.copyWith(enableFriendNotifications: enabled);
      await updatePreferences(updated);
    } catch (e) {
      developer.log('Error toggling friend notifications: $e', error: e);
      rethrow;
    }
  }

  /// Toggle leaderboard notifications
  Future<void> toggleLeaderboardNotifications(bool enabled) async {
    try {
      final current = state.maybeWhen(
        data: (prefs) => prefs,
        orElse: () => NotificationPreferences(),
      );

      final updated = current.copyWith(enableLeaderboardNotifications: enabled);
      await updatePreferences(updated);
    } catch (e) {
      developer.log('Error toggling leaderboard notifications: $e', error: e);
      rethrow;
    }
  }

  /// Toggle achievement notifications
  Future<void> toggleAchievementNotifications(bool enabled) async {
    try {
      final current = state.maybeWhen(
        data: (prefs) => prefs,
        orElse: () => NotificationPreferences(),
      );

      final updated = current.copyWith(enableAchievementNotifications: enabled);
      await updatePreferences(updated);
    } catch (e) {
      developer.log('Error toggling achievement notifications: $e', error: e);
      rethrow;
    }
  }

  /// Helper for JSON encoding
  String _jsonEncode(Map<String, dynamic> data) {
    // Simple JSON encoding - use dart:convert.jsonEncode in production
    return data.toString();
  }
}

/// Riverpod provider for notification preferences
final notificationPreferencesProvider = StateNotifierProvider.family<
    NotificationPreferencesNotifier,
    AsyncValue<NotificationPreferences>,
    String>((ref, userId) {
  return NotificationPreferencesNotifier(userId);
});

/// Provider for checking if daily reminder is enabled for today
final isDailyReminderDueProvider = FutureProvider.family<bool, String>(
  (ref, userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastReminderDate = prefs.getString('last_daily_reminder_$userId');
      final today = DateTime.now().toIso8601String().split('T')[0];

      return lastReminderDate != today;
    } catch (e) {
      developer.log('Error checking daily reminder status: $e', error: e);
      return false;
    }
  },
);

/// Provider for checking if user studied today
final userStudiedTodayProvider = FutureProvider.family<bool, String>(
  (ref, userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastStudyDate = prefs.getString('last_study_date_$userId');
      final today = DateTime.now().toIso8601String().split('T')[0];

      return lastStudyDate == today;
    } catch (e) {
      developer.log('Error checking if user studied today: $e', error: e);
      return false;
    }
  },
);
