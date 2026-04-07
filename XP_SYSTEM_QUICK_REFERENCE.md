# XP System Quick Reference Card

## 🎮 Common Imports
```dart
import 'package:language_learning_app/gamification_exports.dart';
// OR individual imports:
import 'package:language_learning_app/utils/gamification_models.dart';
import 'package:language_learning_app/providers/progress_provider.dart';
import 'package:language_learning_app/views/widgets/gamification_widgets.dart';
import 'package:language_learning_app/views/widgets/xp_gain_overlay.dart';
```

## ⚡ Quick Code Patterns

### Award XP on Card Study
```dart
final (xp, levelUp, achievement) = 
  await progressNotifier.addXpForEvent(
    XpEventType.flashcardStudied,
    streakBonus: true,
  );

// Show notifications
if (xp > 0) overlay.showXpGain(xp);
if (levelUp != null) overlay.showLevelUp(levelUp);
if (achievement != null) overlay.showAchievementUnlock(achievement);
```

### Award XP on Lesson Complete
```dart
await progressNotifier.addXpForEvent(
  XpEventType.lessonCompleted,
);
```

### Double XP for Easy Rating
```dart
await progressNotifier.addXpForEvent(
  XpEventType.flashcardRatedEasy,
  streakBonus: true,
);
```

### Access Current Level
```dart
final progress = ref.watch(progressProvider(userId));
progress.when(
  data: (state) {
    int level = state.level;
    int totalXp = state.xp;
    double progress = state.levelProgress;
  },
);
```

### Display Gamification Widgets
```dart
// Level badge and progress
LevelDisplay(userId: userId)

// Achievements grid
AchievementDisplay(userId: userId)

// Streak counter
StreakDisplay(userId: userId)
```

## 📊 XP Values
| Event | Base XP | Notes |
|-------|---------|-------|
| Card Studied | 5 | +5 bonus when rated Easy |
| Card Rated Easy | 10 | Double multiplier applied |
| Lesson Complete | 50 | No rounding |
| Daily Challenge | 30 | Special events |
| Challenge Won | 20 | PvP feature |

## 🎯 Level Thresholds
- Level 1-10: 100 XP per level
- Level 11+: 200 XP per level
- Level 5: 500 total XP
- Level 10: 1000 total XP
- Level 20: 3000 total XP

## 🔥 Streak Bonus
| Days | Bonus | Example (5 XP) |
|------|-------|-----------------|
| 1 | 10% | 5.5 XP |
| 2 | 20% | 6 XP |
| 3 | 30% | 6.5 XP |
| 5+ | 50% | 7.5 XP |

## 🏆 Achievements
- `firstCard` - Study first card
- `streak7Days` - 7-day streak achieved
- `streak30Days` - 30-day streak (Inferno)
- `cards100Reviewed` - 100 cards studied
- `firstLessonCompleted` - Complete first lesson
- `level5Reached` - Reach level 5
- `friendChallengeWon` - Win friend challenge

## 🎨 Colors
- **Purple**: Level/XP (primary) `Colors.purple.shade600`
- **Amber**: XP Gain notification `Colors.amber.shade600`
- **Gold**: Achievements `Colors.amber.shade600`
- **Red/Orange**: Streak `Colors.red.shade600`
- **Blue**: Stats info `Colors.blue.shade600`

## 📍 File Locations
```
lib/
  utils/
    gamification_models.dart
  providers/
    progress_provider.dart
  views/
    widgets/
      xp_gain_overlay.dart
      gamification_widgets.dart
    screens/
      flashcard_study_example_view.dart (reference)
  
assets/
  lottie/
    level_up.json
    achievement_unlock.json
    xp_gain.json

Root/
  XP_SYSTEM_IMPLEMENTATION_GUIDE.md
  XP_SYSTEM_IMPLEMENTATION_SUMMARY.md
```

## 🔧 Common Issues

**Issue**: Notification not showing
- Check `XpNotificationOverlay` is in widget tree
- Verify Overlay.of(context) is available
- Ensure GlobalKey is properly initialized

**Issue**: Incorrect XP amount
- Check streak bonus is applied correctly
- Verify XpEventType is correct
- Ensure base XP value matches table above

**Issue**: Achievement not unlocking
- Verify condition in GamificationUtils
- Check achievement not already unlocked
- Ensure repository.unlockAchievement() succeeds

**Issue**: Lottie animation not playing
- Confirm .json files exist in assets/lottie/
- Check pubspec.yaml includes lottie dependency
- Verify file paths in animation widget

## 📝 Checklist for Integration

- [ ] Import gamification_exports.dart
- [ ] Add XpNotificationOverlay to widget tree
- [ ] Call addXpForEvent() on study actions
- [ ] Show notifications in overlay
- [ ] Display LevelDisplay widget
- [ ] Add StreakDisplay to header
- [ ] Show AchievementDisplay in profile
- [ ] Test level up animation
- [ ] Test achievement unlock
- [ ] Verify data persists after reload
- [ ] Check Firebase integration
- [ ] Test streak bonus calculation

## 🚀 Pro Tips

1. **Immediate Feedback**: Show XP gain instantly, achievements after delay
2. **Sound Effects**: Consider adding success sounds with Lottie
3. **Haptic Feedback**: Use vibration on level up/achievement
4. **Batch Updates**: Queue multiple XP events before sending to DB
5. **Streak Reminder**: Notify if streak at risk of breaking
6. **Share Achievements**: Allow users to share unlocks socially
7. **Prestige System**: Plan for level reset with cosmetic rewards

## 📚 Documentation
- Full Guide: `XP_SYSTEM_IMPLEMENTATION_GUIDE.md`
- Summary: `XP_SYSTEM_IMPLEMENTATION_SUMMARY.md`
- Example: `flashcard_study_example_view.dart`

## 🎓 Learning Path
1. Read Implementation Summary
2. Study gamification_models.dart
3. Review progress_provider.dart changes
4. Examine flashcard_study_example_view.dart
5. Test in your app
6. Customize as needed

---

**Keep this card handy while integrating!**
