# Offline-First Notification System - Implementation Guide

## 📋 Complete Integration Checklist

### Phase 1: Dependencies & Configuration

- [ ] Add dependencies to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Set up Firebase project in console
- [ ] Download google-services.json (Android)
- [ ] Download GoogleService-Info.plist (iOS)
- [ ] Configure Android build files
- [ ] Configure iOS Podfile
- [ ] Add notification permissions to manifests

### Phase 2: Service Setup

- [ ] Create all service files (8 total)
- [ ] Create provider files (2 total)
- [ ] Create widget files (1 total)
- [ ] Update main.dart with initialization
- [ ] Verify imports are correct
- [ ] Test that app builds without errors

### Phase 3: Testing & Verification

- [ ] Test local notifications permission
- [ ] Test FCM token generation
- [ ] Test connectivity detection
- [ ] Test offline banner display
- [ ] Send test FCM message
- [ ] Verify daily reminder scheduling
- [ ] Test offline queue operations

### Phase 4: Integration with App

- [ ] Integrate with flashcard study screen
- [ ] Add XP-related offline operations
- [ ] Add achievement notifications
- [ ] Add friend challenge notifications
- [ ] Add leaderboard notifications
- [ ] Set up queue syncing on app resume

### Phase 5: User Settings

- [ ] Add notification preferences UI
- [ ] Add time picker for daily reminder
- [ ] Add toggles for notification types
- [ ] Save preferences to SharedPreferences
- [ ] Load preferences on app start
- [ ] Update reminders when time changes

### Phase 6: Monitoring & Analytics

- [ ] Log notification sent events
- [ ] Track offline queue size
- [ ] Monitor FCM delivery rate
- [ ] Track notification engagement
- [ ] Monitor app crashes during migrations

## 🔌 Integration Points

### 1. Flashcard Study Screen

```dart
class FlashcardStudyScreen extends ConsumerWidget {
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(), // Add banner
          Expanded(
            child: FlashcardContent(
              onCardStudied: () => _handleCardStudied(ref, userId),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCardStudied(WidgetRef ref, String userId) async {
    final initService = AppInitializationService();
    
    // Check connectivity
    if (initService.connectivityService.isOffline) {
      // Queue for later
      await OfflineQueueService().addOperation(
        OfflineOperationType.recordFlashcardStudy,
        {'userId': userId, 'xp': 5},
      );
      
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved offline. Will sync when online.'),
        ),
      );
    } else {
      // Sync immediately
      // Update Firestore
    }
    
    // Always record study locally
    await initService.studyReminderService.recordStudyToday(userId);
  }
}
```

### 2. User Settings Screen

```dart
class NotificationSettingsScreen extends ConsumerWidget {
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesProvider(userId));

    return prefsAsync.when(
      data: (prefs) => ListView(
        children: [
          SwitchListTile(
            title: const Text('Daily Study Reminder'),
            value: prefs.enableDailyReminder,
            onChanged: (value) => _toggleDailyReminder(ref, userId, value),
          ),
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text(prefs.getTimeString()),
            onTap: () => _showTimePicker(context, ref, userId, prefs),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Friend Notifications'),
            value: prefs.enableFriendNotifications,
            onChanged: (value) =>
                _toggleFriendNotifications(ref, userId, value),
          ),
          SwitchListTile(
            title: const Text('Leaderboard Notifications'),
            value: prefs.enableLeaderboardNotifications,
            onChanged: (value) =>
                _toggleLeaderboardNotifications(ref, userId, value),
          ),
          SwitchListTile(
            title: const Text('Achievement Notifications'),
            value: prefs.enableAchievementNotifications,
            onChanged: (value) =>
                _toggleAchievementNotifications(ref, userId, value),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, __) => Center(child: Text('Error: $error')),
    );
  }

  Future<void> _toggleDailyReminder(
    WidgetRef ref,
    String userId,
    bool value,
  ) async {
    final notifier = ref.read(notificationPreferencesProvider(userId).notifier);
    await notifier.toggleDailyReminder(value);

    if (value) {
      // Schedule reminder
      // Get time from preferences
    } else {
      // Cancel reminder
      final initService = AppInitializationService();
      await initService.studyReminderService.cancelDailyReminder(userId);
    }
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    String userId,
    NotificationPreferences prefs,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.reminderHour,
        minute: prefs.reminderMinute,
      ),
    );

    if (picked != null) {
      final notifier = ref.read(notificationPreferencesProvider(userId).notifier);
      await notifier.setDailyReminderTime(picked.hour, picked.minute);

      // Schedule daily reminder with new time
      final initService = AppInitializationService();
      await initService.studyReminderService.scheduleDailyReminder(
        userId: userId,
        hour: picked.hour,
        minute: picked.minute,
      );
    }
  }

  Future<void> _toggleFriendNotifications(
    WidgetRef ref,
    String userId,
    bool value,
  ) async {
    final notifier = ref.read(notificationPreferencesProvider(userId).notifier);
    await notifier.toggleFriendNotifications(value);
  }

  Future<void> _toggleLeaderboardNotifications(
    WidgetRef ref,
    String userId,
    bool value,
  ) async {
    final notifier = ref.read(notificationPreferencesProvider(userId).notifier);
    await notifier.toggleLeaderboardNotifications(value);
  }

  Future<void> _toggleAchievementNotifications(
    WidgetRef ref,
    String userId,
    bool value,
  ) async {
    final notifier = ref.read(notificationPreferencesProvider(userId).notifier);
    await notifier.toggleAchievementNotifications(value);
  }
}
```

### 3. App Lifecycle Management

```dart
class AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleManager({required this.child});

  @override
  ConsumerState<AppLifecycleManager> createState() =>
      _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager>
    with WidgetsBindingObserver {
  late AppInitializationService _initService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initService = AppInitializationService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _initService.disposeAllServices();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - sync offline queue
        _syncOfflineQueue();
        _initService.connectivityService.checkConnectivity();
        break;
      case AppLifecycleState.paused:
        // App going to background
        break;
      case AppLifecycleState.detached:
        // App being destroyed
        break;
      case AppLifecycleState.inactive:
        // App becoming inactive
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  Future<void> _syncOfflineQueue() async {
    final queueService = OfflineQueueService();

    if (!_initService.connectivityService.isOnline) {
      return; // Only sync when online
    }

    await queueService.processQueue(
      processor: (operation) async {
        try {
          // Handle each operation type
          switch (operation.type) {
            case OfflineOperationType.addXp:
              // Sync XP to Firestore
              return await _syncXpToFirestore(operation);
            case OfflineOperationType.recordFlashcardStudy:
              return await _syncFlashcardStudyToFirestore(operation);
            case OfflineOperationType.updateStreak:
              return await _syncStreakToFirestore(operation);
            case OfflineOperationType.unlockAchievement:
              return await _syncAchievementToFirestore(operation);
            case OfflineOperationType.updateUserProfile:
              return await _syncProfileToFirestore(operation);
          }
        } catch (e) {
          developer.log('Error syncing operation: $e', error: e);
          return false;
        }
      },
    );
  }

  Future<bool> _syncXpToFirestore(OfflineOperation operation) async {
    // TODO: Implement Firestore sync
    // final userId = operation.data['userId'];
    // final xp = operation.data['xp'];
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .update({'statistics.xp': FieldValue.increment(xp)});
    return true;
  }

  Future<bool> _syncFlashcardStudyToFirestore(
      OfflineOperation operation) async {
    // TODO: Implement
    return true;
  }

  Future<bool> _syncStreakToFirestore(OfflineOperation operation) async {
    // TODO: Implement
    return true;
  }

  Future<bool> _syncAchievementToFirestore(OfflineOperation operation) async {
    // TODO: Implement
    return true;
  }

  Future<bool> _syncProfileToFirestore(OfflineOperation operation) async {
    // TODO: Implement
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

### 4. Hook into App Initialization

Wrap your app with lifecycle manager:

```dart
void main() async {
  // ... initialization code ...
  runApp(
    ProviderScope(
      child: AppLifecycleManager(
        child: const MyApp(),
      ),
    ),
  );
}
```

## 🔄 Sync Queue Processing Flow

```
App Resumed
    ↓
Check if Online
    ↓ YES
Process Queue
    ↓
For each operation:
  - Get operation data
  - Sync to Firestore
  - Mark as completed
  - Remove from queue
    ↓
Update UI
    ↓
Done
```

## 📱 Daily Reminder Flow

```
App Starts
    ↓
Load notification preferences
    ↓
Schedule daily reminder at time
    ↓
When time arrives
    ↓
System triggers notification
    ↓
User may tap notification
    ↓
App shows notification data/navigates
```

## 🔍 Error Handling Strategy

### Network Error During Sync
```dart
try {
  await syncToFirestore(operation);
} on FirebaseException catch (e) {
  if (e.code == 'network-error') {
    // Keep operation in queue, retry later
    return false;
  } else {
    // Other error - log and continue
    return false;
  }
} catch (e) {
  // Unknown error - keep in queue
  return false;
}
```

### Permission Error
```dart
try {
  await notifications.showNotification(...);
} catch (e) {
  if (e.message.contains('Permission')) {
    // Show permission request UI
    requestNotificationPermissions();
  }
}
```

## 📊 Testing Scenarios

### Test 1: Offline Then Online
1. Enable Flight Mode
2. Study flashcard
3. Verify offline banner shows
4. Verify operation queued
5. Disable Flight Mode
6. Verify operation syncs
7. Verify banner disappears

### Test 2: Daily Reminder
1. Set study reminder for 5 minutes from now
2. Wait for notification
3. Verify notification shows
4. Tap notification
5. Verify payload is correct

### Test 3: Friend Challenge Notification
1. Send friend challenge via API
2. Verify FCM message received
3. Verify local notification shown
4. Verify payload type is correct

### Test 4: Offline Studies
1. Enable offline mode
2. Study multiple cards
3. Check XP updated locally
4. Go online
5. Verify all changes synced
6. Check Firestore
7. Verify data integrity

## 🚀 Deployment Checklist

- [ ] All services initialized at app start
- [ ] Offline banner visible on all screens
- [ ] Daily reminders schedule correctly
- [ ] Offline queue persists reliably
- [ ] Queue syncs on connectivity change
- [ ] FCM tokens saved correctly
- [ ] Permissions requested appropriately
- [ ] Error messages are user-friendly
- [ ] Performance is acceptable
- [ ] Battery usage is reasonable
- [ ] Memory usage is stable
- [ ] No crashes on offline/online toggle

## 📞 Debugging Tips

### Enable Verbose Logging
```dart
developer.log('Message', level: 800); // Always log
```

### Check Offline Queue Status
Add debug screen to view:
- Pending operations count
- Operation details
- Last sync time
- Connectivity state

### Monitor FCM
- Check Firebase Console
- View message delivery stats
- Check token freshness
- Monitor error rates

### Test Notifications
```dart
// Add test button in debug screen
ElevatedButton(
  onPressed: () async {
    final initService = AppInitializationService();
    await initService.localNotificationsService.showNotification(
      title: 'Test',
      body: 'Test notification',
    );
  },
  child: const Text('Send Test Notification'),
)
```

---

**Next Steps**:
1. Follow Phase 1 setup steps
2. Test each phase before moving to next
3. Integrate with your app screens
4. Monitor for issues
5. Optimize performance

**Estimated Time**: 4-6 hours for complete integration
