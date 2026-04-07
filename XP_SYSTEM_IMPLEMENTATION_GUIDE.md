# XP System Implementation Guide

## Overview

The XP (Experience Points) system is a gamification feature that rewards users for studying, completing lessons, and achieving milestones. The system includes:

- **XP Gains**: Points awarded for various learning activities
- **Level Progression**: Dynamic level thresholds based on cumulative XP
- **Achievements**: Special unlocks for milestones (streaks, card counts, etc.)
- **Visual Feedback**: Animated notifications for XP gains, level ups, and achievement unlocks
- **Streaks**: Bonus multiplier based on consecutive study days

## Architecture

### Core Models (`lib/utils/gamification_models.dart`)

#### `XpEventType` Enum
Defines the types of events that grant XP:
- `flashcardStudied` - 5 XP per flashcard (base)
- `flashcardRatedEasy` - +5 XP bonus when rating easy (double on top of base)
- `lessonCompleted` - 50 XP per lesson
- `dailyChallengeCompleted` - 30 XP per challenge
- `friendChallengeWon` - 20 XP per win

#### `XpEvent` Model
Represents a single XP gain event with:
- `type`: Event type
- `amount`: XP amount awarded
- `timestamp`: When the event occurred
- `description`: Human-readable description

#### `AchievementType` & `AchievementUnlock`
Defines achievement types and models:
- `firstCard` - Study first flashcard
- `streak7Days` - Maintain 7-day streak
- `streak30Days` - Maintain 30-day streak
- `cards100Reviewed` - Review 100 flashcards
- `firstLessonCompleted` - Complete first lesson
- `level5Reached` - Reach level 5
- `friendChallengeWon` - Win first friend challenge

#### `GamificationUtils` Class
Utility class with static methods:

**XP Calculation:**
```dart
// Calculate base XP for an event
int xp = GamificationUtils.calculateXp(XpEventType.flashcardStudied);
```

**Level Calculations:**
```dart
// Get XP threshold for a specific level
int threshold = GamificationUtils.getLevelThreshold(5); // Level 5 threshold

// Calculate level from total XP
int level = GamificationUtils.calculateLevel(totalXp);
```

**Achievement Checking:**
```dart
// Check if an achievement should unlock
AchievementType? achievement = GamificationUtils.checkAchievementUnlock(
  totalCardsStudied: 100,
  streak: 7,
  level: 5,
  isFirstCard: false,
  isFirstLesson: false,
  isChallengeWon: false,
);
```

### State Management (`lib/providers/progress_provider.dart`)

#### `ProgressState`
Enhanced state with:
- `xp`: Total XP earned
- `level`: Current level
- `streak`: Current study streak
- `totalCardsStudied`: Lifetime cards studied
- `unlockedAchievements`: List of unlocked achievements
- `recentXpEvents`: Last 20 XP events
- Computed properties: `levelProgress`, `xpToNextLevel`, `xpInCurrentLevel`

#### `ProgressNotifier`
Enhanced state notifier with new methods:

**New Method: `addXpForEvent()`**
```dart
// Add XP from an event with optional streak bonus
final (int xpAdded, int? newLevel, AchievementUnlock?) = 
  await progressNotifier.addXpForEvent(
    XpEventType.flashcardStudied,
    streakBonus: true,
  );

// Handle results
if (xpAdded > 0) {
  // Show XP gain notification
}
if (newLevel != null) {
  // Show level up animation
}
if (achievement != null) {
  // Show achievement unlock animation
}
```

### UI Components

#### `XpGainOverlay` (`lib/views/widgets/xp_gain_overlay.dart`)
Animated overlay widget that shows:
- XP gain notifications (amber gradient, floating up)
- Level up animations (purple gradient, with Lottie)
- Achievement unlock animations (amber gradient, with Lottie)

**Usage:**
```dart
XpGainOverlay(
  xpAmount: 5,
  type: XpAnimationType.xpGain,
  onAnimationComplete: () {
    // Called when animation finishes
  },
)
```

#### Gamification Widgets (`lib/views/widgets/gamification_widgets.dart`)

**`LevelDisplay` Widget**
Shows circular level badge with progress bar.

```dart
LevelDisplay(
  userId: userId,
  levelBadgeSize: Size(80, 80),
  showDetails: true,
)
```

**`AchievementDisplay` Widget**
Shows grid of achievements with detail dialog.

```dart
AchievementDisplay(
  userId: userId,
  maxShowCount: 6,
)
```

**`StreakDisplay` Widget**
Shows current streak with fire emoji.

```dart
StreakDisplay(
  userId: userId,
  showFlame: true,
)
```

## Integration Examples

### Example 1: Flashcard Study Flow

```dart
// In your flashcard study view
import 'package:language_learning_app/providers/progress_provider.dart';
import 'package:language_learning_app/utils/gamification_models.dart';
import 'package:language_learning_app/views/widgets/xp_gain_overlay.dart';

class FlashcardStudyView extends ConsumerWidget {
  final String userId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressNotifier = ref.read(progressProvider(userId).notifier);
    
    return Stack(
      children: [
        // Your main flashcard UI
        FlashcardContent(
          onFlashcardStudied: () async {
            // Award XP when user studies a flashcard
            final (xp, levelUp, achievement) = 
              await progressNotifier.addXpForEvent(
                XpEventType.flashcardStudied,
                streakBonus: true,
              );
            
            // Notifications are handled by XpNotificationOverlay
          },
        ),
        
        // Overlay container for notifications
        XpNotificationOverlay(
          child: Container(), // Empty container, just for overlay
        ),
      ],
    );
  }
}
```

### Example 2: Easy Rating Bonus

```dart
void onCardRatedEasy(String cardId) async {
  final progressNotifier = ref.read(progressProvider(userId).notifier);
  
  // Double XP bonus for easy-rated cards
  final (xp, levelUp, achievement) = 
    await progressNotifier.addXpForEvent(
      XpEventType.flashcardRatedEasy,
      streakBonus: true, // Include streak bonus if applicable
    );
  
  // xp will be 10 (5 base * 2 bonus multiplier)
}
```

### Example 3: Lesson Completion

```dart
void onLessonComplete() async {
  final progressNotifier = ref.read(progressProvider(userId).notifier);
  
  final (xp, levelUp, achievement) = 
    await progressNotifier.addXpForEvent(
      XpEventType.lessonCompleted,
    );
  
  if (levelUp != null) {
    // Show special level-up animation
    print('User reached level $levelUp!');
  }
  
  if (achievement != null) {
    // Show achievement notification
    print('Achievement unlocked: ${achievement.title}');
  }
}
```

### Example 4: Daily Streak Check

```dart
// Call this when user opens app
void checkDailyStreak() async {
  final progressNotifier = ref.read(progressProvider(userId).notifier);
  await progressNotifier.checkStreak();
  
  final progress = ref.watch(progressProvider(userId));
  print('Current streak: ${progress.value?.streak}');
}
```

## XP Scaling Formula

Level thresholds are calculated as follows:

```
Levels 1-10: 100 XP per level
  - Level 1: 100 XP
  - Level 5: 500 XP
  - Level 10: 1000 XP

Levels 11+: 200 XP per level
  - Level 11: 1200 XP
  - Level 20: 3000 XP
  - Level 50: 9000 XP
```

### Streak Bonus Calculation

```
Base XP amount = calculated from event type
Streak bonus = (streak_days * 10%) capped at 50%

Example:
- 3-day streak: 30% bonus → base_xp * 1.3
- 5-day streak: 50% bonus → base_xp * 1.5
- 10+ day streak: 50% bonus (capped) → base_xp * 1.5
```

## Testing the XP System

### Manual Testing Checklist

- [ ] Award XP for flashcard study (5 XP + streak bonus)
- [ ] Award double XP for easy-rated cards
- [ ] Check level up calculation
- [ ] Verify achievement unlocks trigger correctly
- [ ] Test streak bonus multiplier
- [ ] Verify Lottie animations play smoothly
- [ ] Test multiple simultaneous XP notifications
- [ ] Verify data persists after app restart

### Unit Tests Example

```dart
test('Calculate level from total XP', () {
  expect(GamificationUtils.calculateLevel(0), 1);
  expect(GamificationUtils.calculateLevel(100), 1);
  expect(GamificationUtils.calculateLevel(101), 2);
  expect(GamificationUtils.calculateLevel(1000), 10);
});

test('Streak bonus calculation', () {
  // Flashcard studied = 5 XP base
  // 3-day streak = 30% bonus
  final xp = GamificationUtils.calculateXp(
    XpEventType.flashcardStudied,
  );
  final withBonus = xp + (xp * 30 ~/ 100);
  expect(withBonus, 7); // 5 + 2
});

test('Achievement unlock conditions', () {
  final achievement = GamificationUtils.checkAchievementUnlock(
    totalCardsStudied: 1,
    streak: 0,
    level: 1,
    isFirstCard: true,
    isFirstLesson: false,
    isChallengeWon: false,
  );
  expect(achievement, AchievementType.firstCard);
});
```

## Firebase Integration Notes

When integrating with Firebase Realtime Database:

1. **Update XP in Firestore:**
```dart
// In ProgressRepository
Future<void> updateXp(String userId, int amount) async {
  await firestore.collection('users').doc(userId).update({
    'stats.xp': FieldValue.increment(amount),
    'stats.lastUpdated': FieldValue.serverTimestamp(),
  });
}
```

2. **Create achievement records:**
```dart
Future<void> unlockAchievement(String userId, String achievementType) async {
  await firestore
    .collection('users')
    .doc(userId)
    .collection('achievements')
    .doc(achievementType)
    .set({
      'unlockedAt': FieldValue.serverTimestamp(),
      'type': achievementType,
    });
}
```

## Performance Considerations

1. **Limit XP Events**: Keep `recentXpEvents` list to 20 items
2. **Debounce Updates**: Consider debouncing rapid XP gains
3. **Offline Support**: Queue XP events when offline, sync when online
4. **Animation Frame Rate**: Use 60fps for smooth Lottie animations
5. **Memory**: Clean up old animation controllers properly

## Future Enhancements

- [ ] Seasonal achievements and leaderboards
- [ ] Daily bonus XP amounts
- [ ] Social XP sharing with friends
- [ ] Custom achievement definitions
- [ ] Milestone notifications
- [ ] XP event analytics
- [ ] Prestige system (reset level for bonus multiplier)
- [ ] Team-based XP challenges
