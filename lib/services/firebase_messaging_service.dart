import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:language_learning_app/services/local_notifications_service.dart';
import 'dart:developer' as developer;

/// Firebase Cloud Messaging service
/// Handles FCM initialization, token management, and message receiving
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    try {
      // Request permissions for iOS
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carryForward: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        developer.log('FCM: User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        developer.log('FCM: User granted provisional notification permission');
      } else {
        developer.log('FCM: User declined or has not yet granted permission');
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      developer.log('FCM Token: $_fcmToken');

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        developer.log('FCM Token Refreshed: $newToken');
        _saveFcmTokenToFirestore(newToken);
      });

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle messages when app is terminated/background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle background message (must be top-level)
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      developer.log('FCM initialized successfully');
    } catch (e) {
      developer.log('FCM initialization error: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Handle messages received in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log('Foreground message received: ${message.data}');

    // Show local notification
    await LocalNotificationsService().showNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      payloadType: _getPayloadType(message.data),
    );
  }

  /// Handle message tap when app is in background
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    developer.log('Message opened from background: ${message.data}');
    _handleNotificationTap(message.data);
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'friend_challenge':
        // Navigate to friend challenge screen
        developer.log('Opening friend challenge');
        break;
      case 'leaderboard_reset':
        // Navigate to leaderboard
        developer.log('Opening leaderboard');
        break;
      case 'achievement_unlock':
        // Navigate to achievements
        developer.log('Opening achievements');
        break;
      default:
        developer.log('Unknown notification type: $type');
    }
  }

  /// Get payload type from message data
  String _getPayloadType(Map<String, dynamic> data) {
    return data['type'] as String? ?? 'general';
  }

  /// Save FCM token to Firestore
  Future<void> _saveFcmTokenToFirestore(String token) async {
    try {
      // TODO: Implement saving token to Firestore
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .update({'fcmToken': token});
    } catch (e) {
      developer.log('Error saving FCM token: $e', error: e);
    }
  }

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log('Subscribed to topic: $topic');
    } catch (e) {
      developer.log('Error subscribing to topic: $e', error: e);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log('Unsubscribed from topic: $topic');
    } catch (e) {
      developer.log('Error unsubscribing from topic: $e', error: e);
    }
  }

  /// Send test notification (for development)
  Future<void> sendTestNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    // This would call a Firebase Cloud Function in production
    developer.log('Test notification - Title: $title, Body: $body, Type: $type');
  }
}

/// Background message handler (must be top-level function)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Handling FCM message in background: ${message.data}');

  // Show local notification for background messages
  await LocalNotificationsService().showNotification(
    title: message.notification?.title ?? 'New Message',
    body: message.notification?.body ?? '',
    payloadType: message.data['type'] as String? ?? 'general',
  );
}
