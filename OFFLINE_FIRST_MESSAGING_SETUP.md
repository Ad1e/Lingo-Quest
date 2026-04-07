# Offline-First Notification System Setup Guide

## Overview

This guide covers setting up:
- **Firebase Cloud Messaging (FCM)** for push notifications
- **flutter_local_notifications** for local notifications and daily reminders
- **Offline mode** with local Drift database
- **Connectivity detection** with real-time banner
- **Offline queue** for syncing writes when online

## 📋 Prerequisites

### Dependencies Installation

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.x.x
  firebase_messaging: ^14.x.x
  flutter_local_notifications: ^17.x.x
  timezone: ^0.x.x
  shared_preferences: ^2.x.x
  connectivity_plus: ^5.x.x
  flutter_riverpod: ^2.x.x
  lottie: ^2.x.x
  drift: ^2.x.x
  sqlite3_flutter_libs: ^0.x.x
  
dev_dependencies:
  drift_dev: ^2.x.x
  build_runner: ^2.x.x
```

## 🔧 Setup Steps

### Step 1: Firebase Configuration

#### Android Setup

1. Download `google-services.json` from Firebase Console
2. Place in `android/app/`
3. Add to `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

4. Add to `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.x.x'
}
```

#### iOS Setup

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to Xcode project (`Runner` folder)
3. Enable Push Notifications capability
4. Add to `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

### Step 2: Local Notifications Setup

#### Android Setup

Add notification channels to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="lingoquest_channel" />
```

#### iOS Setup

Add to `ios/Runner/GeneratedPluginRegistrant.m` (auto-generated, no manual action needed).

### Step 3: Connectivity Setup

Add internet permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

For iOS, no additional setup needed.

### Step 4: Main App Initialization

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/firebase_config.dart';
import 'services/app_initialization_service.dart';
import 'views/widgets/offline_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize all services
  final initService = AppInitializationService();
  await initService.initializeAllServices();
  
  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'LingoQuest',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('LingoQuest')),
      body: Stack(
        children: [
          // Your main content here
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome to LingoQuest!'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to flashcard screen
                  },
                  child: const Text('Start Studying'),
                ),
              ],
            ),
          ),
          
          // Offline banner
          const OfflineBanner(),
        ],
      ),
    );
  }
}
```

## 🎯 Usage Examples

### Example 1: Schedule Daily Study Reminder

```dart
import 'package:language_learning_app/services/app_initialization_service.dart';
import 'package:language_learning_app/services/study_reminder_service.dart';

// In your settings screen or user preferences
Future<void> setStudyReminderTime(String userId, int hour, int minute) async {
  final initService = AppInitializationService();
  await initService.studyReminderService.scheduleDailyReminder(
    userId: userId,
    hour: hour,
    minute: minute,
  );
}
```

### Example 2: Award XP and Handle Offline

```dart
import 'package:language_learning_app/services/offline_queue_service.dart';
import 'package:language_learning_app/services/app_initialization_service.dart';

Future<void> recordFlashcardStudy(String userId, String cardId) async {
  try {
    final initService = AppInitializationService();
    
    // Record study locally first
    await recordStudyLocally(userId, cardId);
    
    // Award XP
    await awardXp(userId, 5);
    
    // If online, sync to Firestore
    if (initService.connectivityService.isOnline) {
      await syncToFirestore(userId);
    } else {
      // Queue for later
      await OfflineQueueService().addOperation(
        OfflineOperationType.recordFlashcardStudy,
        {
          'userId': userId,
          'cardId': cardId,
          'xp': 5,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  } catch (e) {
    print('Error recording flashcard study: $e');
  }
}
```

### Example 3: Send Friend Challenge Notification

```dart
import 'package:language_learning_app/services/app_initialization_service.dart';

Future<void> sendFriendChallengeNotification(
  String friendName,
  String challengeType,
) async {
  final initService = AppInitializationService();
  await initService.studyReminderService
      .scheduleFriendChallengeNotification(
    friendName: friendName,
    challengeType: challengeType,
  );
}
```

### Example 4: Sync Offline Queue When Online

```dart
import 'package:language_learning_app/services/offline_queue_service.dart';
import 'package:language_learning_app/services/app_initialization_service.dart';

// Call this when app detects connectivity change to online
Future<void> syncOfflineQueue(String userId) async {
  final queueService = OfflineQueueService();
  final initService = AppInitializationService();
  
  if (!initService.connectivityService.isOnline) {
    return; // Only sync when online
  }
  
  await queueService.processQueue(
    processor: (operation) async {
      try {
        switch (operation.type) {
          case OfflineOperationType.addXp:
            await _syncXpOperation(operation);
            return true;
          case OfflineOperationType.recordFlashcardStudy:
            await _syncFlashcardOperation(operation);
            return true;
          case OfflineOperationType.updateStreak:
            await _syncStreakOperation(operation);
            return true;
          case OfflineOperationType.unlockAchievement:
            await _syncAchievementOperation(operation);
            return true;
          case OfflineOperationType.updateUserProfile:
            await _syncProfileOperation(operation);
            return true;
        }
      } catch (e) {
        print('Error syncing operation: $e');
        return false;
      }
    },
  );
}
```

### Example 5: Listen to Connectivity Changes

```dart
import 'package:language_learning_app/providers/connectivity_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class MyConnectivityListener extends ConsumerStatefulWidget {
  final Widget child;

  const MyConnectivityListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<MyConnectivityListener> createState() =>
      _MyConnectivityListenerState();
}

class _MyConnectivityListenerState
    extends ConsumerState<MyConnectivityListener> {
  @override
  void initState() {
    super.initState();
    // Listen for connectivity changes
    ref.listen(connectivityStateProvider, (previous, next) {
      next.whenData((state) {
        if (state.toString().contains('online')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Back online!')),
          );
          // Trigger queue sync
          _syncQueue();
        } else if (state.toString().contains('offline')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are offline')),
          );
        }
      });
    });
  }

  Future<void> _syncQueue() async {
    // Sync offline queue
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

### Example 6: Use Offline Banner in App

```dart
import 'package:language_learning_app/views/widgets/offline_banner.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;

  const MyScaffold({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Title')),
      body: Column(
        children: [
          // Offline banner at top
          const OfflineBanner(),
          
          // Your main content
          Expanded(child: body),
        ],
      ),
    );
  }
}
```

## 📱 Testing

### Test Periodic Notifications

```dart
// In your debug screen
ElevatedButton(
  onPressed: () async {
    final initService = AppInitializationService();
    await initService.studyReminderService
        .scheduleAchievementNotification(
      achievementTitle: 'Test Achievement',
      achievementDescription: 'This is a test notification',
    );
  },
  child: const Text('Test Notification'),
)
```

### Simulate Offline Mode

```dart
// Disable network in device settings or use Flight Mode
// The app will automatically show the offline banner and queue operations
```

### Check Notification Permissions

```dart
final prefs = await NotificationPermissions.request();
print('Notifications enabled: ${prefs.isGranted}');
```

## 🗄️ Drift Database Integration (Planned)

When Drift is set up, the offline queue will persist to:

```
database/
  offline_queue_database.dart
  migrations/
    001_create_offline_queue.dart
```

Tables:
- `offline_operations` - Stores queued write operations
- `study_sessions` - Cached flashcard study log
- `xp_events` - Cached XP changes
- `streak_data` - Cached streak information

## 🔐 Security Considerations

1. **FCM Token Management**: Tokens are stored securely in Firestore with user ID
2. **Offline Data**: Local data is unencrypted on device (consider encryption)
3. **Queue Validation**: All queued operations are validated before syncing
4. **Rate Limiting**: Implement rate limiting on notification endpoints

## 🐛 Troubleshooting

### Notifications Not Showing

- Check notification permissions in app settings
- Verify notification channels are created (Android)
- Check FCM token is saved to Firestore
- Test with debug console

### Offline Queue Not Syncing

- Verify connectivity service is detecting online state
- Check Firestore rules allow writes
- Check operation data format matches expected schema
- Check for network timeout issues

### Daily Reminder Not Triggering

- Check user's preferred time
- Verify notification permission is granted
- Verify device time is correct
- Check notification is not in do-not-disturb mode

## 📚 File Reference

### Services
- `lib/services/firebase_messaging_service.dart` - FCM setup
- `lib/services/local_notifications_service.dart` - Local notifications
- `lib/services/connectivity_service.dart` - Connectivity detection
- `lib/services/offline_queue_service.dart` - Offline write queueing
- `lib/services/study_reminder_service.dart` - Daily reminders
- `lib/services/app_initialization_service.dart` - App initialization

### Providers
- `lib/providers/notification_preference_provider.dart` - Notification settings
- `lib/providers/connectivity_provider.dart` - Connectivity state

### Widgets
- `lib/views/widgets/offline_banner.dart` - Offline UI components

## 🎯 Next Steps

1. ✅ Set up Firebase Cloud Messaging in console
2. ✅ Configure push notification certificates (iOS)
3. ✅ Implement Drift database for offline persistence
4. ✅ Add syncing logic in app lifecycle
5. ✅ Test offline → online transition
6. ✅ Monitor FCM delivery rates
7. ✅ Set up daily reminder scheduling from user preferences

## 📞 Support

For issues with:
- **FCM**: Check Firebase console > Cloud Messaging
- **Local Notifications**: Check app notification settings
- **Connectivity**: Check device network status
- **Offline Queue**: Check Drift database logs

---

**Last Updated**: April 7, 2026
**Status**: Ready for Integration ✅
