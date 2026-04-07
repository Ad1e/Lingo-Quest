# Offline-First Notification System - Quick Reference

## 🚀 Quick Start

### 1. Initialize in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppInitializationService().initializeAllServices();
  runApp(const MyApp());
}
```

### 2. Add Offline Banner
```dart
Column(
  children: [
    const OfflineBanner(),
    Expanded(child: yourContent),
  ],
)
```

### 3. Award XP (Offline-Safe)
```dart
await progressNotifier.addXpForEvent(
  XpEventType.flashcardStudied,
  streakBonus: true,
);
```

## 📱 Services Cheat Sheet

### Get Service Instances
```dart
final initService = AppInitializationService();
final fcm = initService.fcmService;
final notifications = initService.localNotificationsService;
final connectivity = initService.connectivityService;
final reminder = initService.studyReminderService;
```

### Check Online/Offline Status
```dart
bool isOnline = connectivity.isOnline;
bool isOffline = connectivity.isOffline;
ConnectivityState state = connectivity.currentState;
```

### Schedule Daily Reminder
```dart
await reminder.scheduleDailyReminder(
  userId: userId,
  hour: 8,
  minute: 0,
);
```

### Show Notification
```dart
await notifications.showNotification(
  title: 'Title',
  body: 'Body text',
  payloadType: 'notification_type',
);
```

### Schedule One-Time Notification
```dart
await notifications.scheduleNotification(
  title: 'Title',
  body: 'Body',
  scheduledTime: DateTime.now().add(Duration(hours: 2)),
);
```

### Queue Operation When Offline
```dart
await OfflineQueueService().addOperation(
  OfflineOperationType.addXp,
  {'userId': userId, 'xp': 5},
);
```

### Process Queue When Online
```dart
await OfflineQueueService().processQueue(
  processor: (operation) async {
    // Handle operation
    return true; // Return success
  },
);
```

## 🎛️ Notification Preferences

### Set Study Reminder Time
```dart
await notificationPreferencesNotifier.setDailyReminderTime(8, 30);
```

### Get Current Preferences
```dart
final prefs = ref.watch(notificationPreferencesProvider(userId));
prefs.whenData((notifPrefs) {
  print('Reminder: ${notifPrefs.getTimeString()}');
});
```

### Toggle Notifications
```dart
await prefs.toggleDailyReminder(true);
await prefs.toggleFriendNotifications(false);
await prefs.toggleLeaderboardNotifications(true);
```

## 🔌 Riverpod Providers

### Watch Connectivity State
```dart
final state = ref.watch(connectivityStateProvider);
```

### Check if Online
```dart
final online = ref.watch(isOnlineProvider);
```

### Check if Offline
```dart
final offline = ref.watch(isOfflineProvider);
```

### Watch Notifications Preferences
```dart
final prefs = ref.watch(notificationPreferencesProvider(userId));
```

## 📤 Send Notifications from Backend

### Friend Challenge  
```dart
await reminder.scheduleFriendChallengeNotification(
  friendName: 'John',
  challengeType: 'XP Challenge',
);
```

### Leaderboard Reset
```dart
await reminder.scheduleLeaderboardResetNotification();
```

### Achievement Unlock
```dart
await reminder.scheduleAchievementNotification(
  achievementTitle: '7-Day Streak',
  achievementDescription: 'Maintained 7 days of study',
);
```

## 🛠️ Configuration Constants

### Notification IDs
- Daily Reminder: `userId.hashCode % 2147483647`
- FCM Channel: `'lingoquest_channel'`
- Scheduled Channel: `'lingoquest_scheduled'`
- Daily Channel: `'lingoquest_daily'`

### Payload Types
- `'study_reminder'` - Daily study reminder
- `'friend_challenge'` - Friend challenge notification
- `'leaderboard_reset'` - Weekly leaderboard reset
- `'achievement_unlock'` - Achievement unlocked
- `'general'` - General notification

## 🗂️ File Locations

```
lib/
├── services/
│   ├── firebase_messaging_service.dart
│   ├── local_notifications_service.dart
│   ├── connectivity_service.dart
│   ├── offline_queue_service.dart
│   ├── study_reminder_service.dart
│   └── app_initialization_service.dart
├── providers/
│   ├── notification_preference_provider.dart
│   ├── connectivity_provider.dart
│   └── progress_provider.dart (enhanced)
└── views/
    └── widgets/
        └── offline_banner.dart
```

## ⚙️ Common Setup Tasks

### Enable Daily Reminder
```dart
// In user settings screen
await reminder.scheduleDailyReminder(
  userId: userId,
  hour: preferences.reminderHour,
  minute: preferences.reminderMinute,
);
```

### Disable Daily Reminder
```dart
await reminder.cancelDailyReminder(userId);
```

### Listen to Connectivity Changes
```dart
connectivity.addListener((state) {
  if (state == ConnectivityState.online) {
    // Sync queue
  }
});
```

### Clear Offline Queue
```dart
await OfflineQueueService().clearQueue();
```

### Get Pending Operations Count
```dart
int pending = OfflineQueueService().operationCount;
```

## 🔍 Debugging

### Check FCM Token
```dart
String? token = fcmService.fcmToken;
print('FCM Token: $token');
```

### Get Pending Notifications
```dart
final pending = await notifications.getPendingNotifications();
print('Pending: ${pending.length}');
```

### Check Initialization Status
```dart
final status = await AppInitializationService().getInitializationStatus();
print('Initialized: ${status['all_initialized']}');
```

### View Offline Queue
```dart
final ops = OfflineQueueService().getPendingOperations();
for (var op in ops) {
  print('${op.type}: ${op.id}');
}
```

## 📊 Notification Types Matrix

| Type | Trigger | Method | LocalOrFCM |
|------|---------|--------|-----------|
| Daily Reminder | User preference time | `scheduleDailyReminder()` | Local |
| Friend Challenge | Firebase Cloud Function | FCM + Local | FCM→Local |
| Leaderboard Reset | Weekly schedule | FCM | FCM |
| Achievement Unlock | XP event | `scheduleAchievementNotification()` | Local |
| Generic Alert | App event | `showNotification()` | Local |

## 🚨 Error Handling

### Handle Notification Errors
```dart
try {
  await notifications.showNotification(
    title: 'Title',
    body: 'Body',
  );
} catch (e) {
  print('Notification error: $e');
}
```

### Handle Queue Processing Errors
```dart
try {
  await OfflineQueueService().processQueue(processor: handler);
} catch (e) {
  print('Queue sync failed: $e');
  // Retry later or show error UI
}
```

### Handle Connectivity Check Errors
```dart
try {
  await connectivity.checkConnectivity();
} catch (e) {
  print('Connectivity check failed: $e');
  // Assume online
}
```

## 📈 Performance Tips

1. **Batch Queue Processing**: Process multiple operations in one transaction
2. **Throttle Connectivity Checks**: Don't check too frequently
3. **Limit Notification History**: Keep last 20 sent notifications
4. **Compress Queue Data**: Store minimal data in queue
5. **Cleanup Old Reminders**: Remove past notification records

## 🧪 Testing Checklist

- [ ] Daily reminder triggers at expected time
- [ ] Notifications show when app is in foreground
- [ ] Notifications show when app is in background
- [ ] Offline banner appears when disconnected
- [ ] Offline queue stores operations
- [ ] Queue syncs when reconnected
- [ ] Friend challenge notification shows
- [ ] Leaderboard notification shows
- [ ] Achievement notification shows
- [ ] XP rewards work offline
- [ ] Streak continues offline
- [ ] FCM token is stored

---

**Keep this card handy while developing!**
