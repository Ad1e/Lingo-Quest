import 'package:flutter/material.dart';
import 'package:language_learning_app/services/firebase_messaging_service.dart';
import 'package:language_learning_app/services/local_notifications_service.dart';
import 'package:language_learning_app/services/connectivity_service.dart';
import 'package:language_learning_app/services/study_reminder_service.dart';
import 'dart:developer' as developer;

/// App initialization service
/// Initializes all services on app startup
class AppInitializationService {
  static final AppInitializationService _instance =
      AppInitializationService._internal();

  late FirebaseMessagingService _fcmService;
  late LocalNotificationsService _localNotificationsService;
  late ConnectivityService _connectivityService;
  late StudyReminderService _studyReminderService;

  bool _isInitialized = false;

  factory AppInitializationService() {
    return _instance;
  }

  AppInitializationService._internal();

  /// Get the Firebase Messaging Service instance
  FirebaseMessagingService get fcmService => _fcmService;

  /// Get the Local Notifications Service instance
  LocalNotificationsService get localNotificationsService =>
      _localNotificationsService;

  /// Get the Connectivity Service instance
  ConnectivityService get connectivityService => _connectivityService;

  /// Get the Study Reminder Service instance
  StudyReminderService get studyReminderService => _studyReminderService;

  /// Check if services are initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all services
  Future<void> initializeAllServices() async {
    if (_isInitialized) {
      developer.log('Services already initialized');
      return;
    }

    try {
      developer.log('Starting app initialization...');

      // Initialize services (order matters)
      _fcmService = FirebaseMessagingService();
      _localNotificationsService = LocalNotificationsService();
      _connectivityService = ConnectivityService();
      _studyReminderService = StudyReminderService();

      // Initialize each service
      developer.log('Initializing Firebase Cloud Messaging...');
      await _fcmService.initialize();

      developer.log('Initializing Local Notifications...');
      await _localNotificationsService.initialize();

      developer.log('Initializing Connectivity Monitoring...');
      await _connectivityService.initialize();

      developer.log('Initializing Study Reminder Service...');
      await _studyReminderService.initialize();

      _isInitialized = true;
      developer.log('✅ All services initialized successfully');
    } catch (e) {
      developer.log('❌ Error during app initialization: $e',
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// Dispose all services
  Future<void> disposeAllServices() async {
    try {
      developer.log('Disposing services...');
      _connectivityService.dispose();
      _isInitialized = false;
      developer.log('✅ All services disposed');
    } catch (e) {
      developer.log('Error disposing services: $e', error: e);
    }
  }

  /// Get initialization status
  Future<Map<String, bool>> getInitializationStatus() async {
    return {
      'fcm_initialized': _fcmService != null,
      'notifications_initialized': _localNotificationsService != null,
      'connectivity_initialized': _connectivityService != null,
      'study_reminder_initialized': _studyReminderService != null,
      'all_initialized': _isInitialized,
    };
  }
}
