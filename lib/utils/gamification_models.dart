/// Enum for different types of XP events
enum XpEventType {
  flashcardStudied,
  flashcardRatedEasy,
  lessonCompleted,
  dailyChallengeCompleted,
  friendChallengeWon,
}

/// Model for an XP event
class XpEvent {
  final XpEventType type;
  final int amount;
  final DateTime timestamp;
  final String? description;

  const XpEvent({
    required this.type,
    required this.amount,
    required this.timestamp,
    this.description,
  });

  /// Get description for XP event
  String getDescription() {
    switch (type) {
      case XpEventType.flashcardStudied:
        return 'Flashcard studied';
      case XpEventType.flashcardRatedEasy:
        return 'Flashcard rated Easy';
      case XpEventType.lessonCompleted:
        return 'Lesson completed';
      case XpEventType.dailyChallengeCompleted:
        return 'Daily challenge completed';
      case XpEventType.friendChallengeWon:
        return 'Friend challenge won';
    }
  }
}

/// Enum for achievement types
enum AchievementType {
  firstCard,
  streak7Days,
  streak30Days,
  cards100Reviewed,
  firstLessonCompleted,
  level5Reached,
  friendChallengeWon,
}

/// Model for achievement unlock event
class AchievementUnlock {
  final AchievementType type;
  final String title;
  final String description;
  final DateTime unlockedAt;

  const AchievementUnlock({
    required this.type,
    required this.title,
    required this.description,
    required this.unlockedAt,
  });

  /// Get icon name for Lottie animation
  String getLottieAsset() {
    return 'assets/lottie/achievement_unlock.json';
  }
}

/// Gamification utilities
class GamificationUtils {
  /// Calculate XP amount based on event type
  static int calculateXp(XpEventType type, {bool isBonus = false}) {
    int baseXp = switch (type) {
      XpEventType.flashcardStudied => 5,
      XpEventType.flashcardRatedEasy => 5, // Additional bonus on top of base
      XpEventType.lessonCompleted => 50,
      XpEventType.dailyChallengeCompleted => 30,
      XpEventType.friendChallengeWon => 20,
    };

    // Double XP for Easy-rated cards
    if (type == XpEventType.flashcardRatedEasy && isBonus) {
      return baseXp * 2;
    }

    return baseXp;
  }

  /// Calculate level threshold (XP needed for that level)
  static int getLevelThreshold(int level) {
    if (level <= 10) {
      return level * 100;
    } else {
      // After level 10: 200 XP per level
      return (10 * 100) + ((level - 10) * 200);
    }
  }

  /// Get next level threshold
  static int getNextLevelThreshold(int currentLevel) {
    return getLevelThreshold(currentLevel + 1);
  }

  /// Calculate level from total XP
  static int calculateLevel(int totalXp) {
    if (totalXp < 100) return 1;

    for (int level = 2; level <= 50; level++) {
      if (totalXp < getLevelThreshold(level)) {
        return level - 1;
      }
    }

    return 1;
  }

  /// Check if achievement should unlock
  static AchievementType? checkAchievementUnlock({
    required int totalCardsStudied,
    required int streak,
    required int level,
    required bool isFirstCard,
    required bool isFirstLesson,
    required bool isChallengeWon,
  }) {
    // First card studied
    if (isFirstCard && totalCardsStudied == 1) {
      return AchievementType.firstCard;
    }

    // 7-day streak
    if (streak == 7) {
      return AchievementType.streak7Days;
    }

    // 30-day streak
    if (streak == 30) {
      return AchievementType.streak30Days;
    }

    // 100 cards reviewed
    if (totalCardsStudied == 100) {
      return AchievementType.cards100Reviewed;
    }

    // First lesson completed
    if (isFirstLesson) {
      return AchievementType.firstLessonCompleted;
    }

    // Level 5 reached
    if (level == 5) {
      return AchievementType.level5Reached;
    }

    // Friend challenge won
    if (isChallengeWon) {
      return AchievementType.friendChallengeWon;
    }

    return null;
  }

  /// Get achievement details
  static (String title, String description) getAchievementDetails(
    AchievementType type,
  ) {
    switch (type) {
      case AchievementType.firstCard:
        return (
          'Getting Started',
          'Studied your first flashcard'
        );
      case AchievementType.streak7Days:
        return (
          '7-Day Streak',
          'Maintained a 7-day study streak'
        );
      case AchievementType.streak30Days:
        return (
          'Inferno',
          'Maintained a 30-day study streak'
        );
      case AchievementType.cards100Reviewed:
        return (
          'Century',
          'Reviewed 100 flashcards'
        );
      case AchievementType.firstLessonCompleted:
        return (
          'Lesson Master',
          'Completed your first lesson'
        );
      case AchievementType.level5Reached:
        return (
          'Rising Star',
          'Reached Level 5'
        );
      case AchievementType.friendChallengeWon:
        return (
          'Champion',
          'Won your first friend challenge'
        );
    }
  }
}
