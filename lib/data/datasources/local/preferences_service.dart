import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

/// User preferences service using Hive
abstract class PreferencesService {
  /// Initialize Hive
  Future<void> initialize();

  /// Theme preferences
  Future<void> setTheme(String theme); // 'light', 'dark', 'auto'
  Future<String?> getTheme();

  /// Language preferences
  Future<void> setSourceLanguage(String language);
  Future<String?> getSourceLanguage();

  Future<void> setTargetLanguage(String language);
  Future<String?> getTargetLanguage();

  /// Audio preferences
  Future<void> setAudioEnabled(bool enabled);
  Future<bool?> isAudioEnabled();

  Future<void> setAudioSpeed(double speed); // 0.5 - 2.0
  Future<double?> getAudioSpeed();

  /// Notification preferences
  Future<void> setNotificationsEnabled(bool enabled);
  Future<bool?> areNotificationsEnabled();

  Future<void> setDailyReminderTime(String time); // HH:mm format
  Future<String?> getDailyReminderTime();

  /// Study preferences
  Future<void> setCardsPerDay(int count);
  Future<int?> getCardsPerDay();

  Future<void> setDifficulty(String difficulty); // 'easy', 'medium', 'hard'
  Future<String?> getDifficulty();

  /// User data
  Future<void> setUserId(String userId);
  Future<String?> getUserId();

  Future<void> setUsername(String username);
  Future<String?> getUsername();

  /// Generic preferences
  Future<void> setPreference(String key, dynamic value);
  Future<dynamic> getPreference(String key);
  Future<void> removePreference(String key);
  Future<void> clearAllPreferences();
}

/// Implementation of PreferencesService using Hive
@Singleton(as: PreferencesService)
class HivePreferencesService implements PreferencesService {
  static const String _boxName = 'app_preferences';
  late Box<dynamic> _preferencesBox;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    _preferencesBox = await Hive.openBox<dynamic>(_boxName);
  }

  @override
  Future<void> setTheme(String theme) async {
    await _preferencesBox.put('theme', theme);
  }

  @override
  Future<String?> getTheme() async {
    return _preferencesBox.get('theme') as String? ?? 'auto';
  }

  @override
  Future<void> setSourceLanguage(String language) async {
    await _preferencesBox.put('source_language', language);
  }

  @override
  Future<String?> getSourceLanguage() async {
    return _preferencesBox.get('source_language') as String? ?? 'en';
  }

  @override
  Future<void> setTargetLanguage(String language) async {
    await _preferencesBox.put('target_language', language);
  }

  @override
  Future<String?> getTargetLanguage() async {
    return _preferencesBox.get('target_language') as String? ?? 'es';
  }

  @override
  Future<void> setAudioEnabled(bool enabled) async {
    await _preferencesBox.put('audio_enabled', enabled);
  }

  @override
  Future<bool?> isAudioEnabled() async {
    return _preferencesBox.get('audio_enabled') as bool? ?? true;
  }

  @override
  Future<void> setAudioSpeed(double speed) async {
    final clampedSpeed = speed.clamp(0.5, 2.0);
    await _preferencesBox.put('audio_speed', clampedSpeed);
  }

  @override
  Future<double?> getAudioSpeed() async {
    return (_preferencesBox.get('audio_speed') as double?) ?? 1.0;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _preferencesBox.put('notifications_enabled', enabled);
  }

  @override
  Future<bool?> areNotificationsEnabled() async {
    return _preferencesBox.get('notifications_enabled') as bool? ?? true;
  }

  @override
  Future<void> setDailyReminderTime(String time) async {
    await _preferencesBox.put('daily_reminder_time', time);
  }

  @override
  Future<String?> getDailyReminderTime() async {
    return _preferencesBox.get('daily_reminder_time') as String? ?? '08:00';
  }

  @override
  Future<void> setCardsPerDay(int count) async {
    await _preferencesBox.put('cards_per_day', count);
  }

  @override
  Future<int?> getCardsPerDay() async {
    return _preferencesBox.get('cards_per_day') as int? ?? 20;
  }

  @override
  Future<void> setDifficulty(String difficulty) async {
    await _preferencesBox.put('difficulty', difficulty);
  }

  @override
  Future<String?> getDifficulty() async {
    return _preferencesBox.get('difficulty') as String? ?? 'medium';
  }

  @override
  Future<void> setUserId(String userId) async {
    await _preferencesBox.put('user_id', userId);
  }

  @override
  Future<String?> getUserId() async {
    return _preferencesBox.get('user_id') as String?;
  }

  @override
  Future<void> setUsername(String username) async {
    await _preferencesBox.put('username', username);
  }

  @override
  Future<String?> getUsername() async {
    return _preferencesBox.get('username') as String?;
  }

  @override
  Future<void> setPreference(String key, dynamic value) async {
    await _preferencesBox.put(key, value);
  }

  @override
  Future<dynamic> getPreference(String key) async {
    return _preferencesBox.get(key);
  }

  @override
  Future<void> removePreference(String key) async {
    await _preferencesBox.delete(key);
  }

  @override
  Future<void> clearAllPreferences() async {
    await _preferencesBox.clear();
  }
}
