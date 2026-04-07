import 'package:injectable/injectable.dart';

/// Abstract repository interface for progress operations
abstract class ProgressRepository {
  /// Get user progress
  Future<UserProgress?> getUserProgress(String userId);

  /// Create or get user progress
  Future<UserProgress> getOrCreateUserProgress(String userId);

  /// Update XP
  Future<void> updateXp(String userId, int xpAmount);

  /// Update streak
  Future<void> updateStreak(String userId, int streak);

  /// Increment cards studied
  Future<void> incrementCardsStudied(String userId);

  /// Add study session
  Future<void> addStudySession(StudySession session);

  /// Get user statistics
  Future<UserStatistics?> getUserStatistics(String userId);

  /// Get daily stats
  Future<DailyStats?> getDailyStats(String userId);

  /// Get study history
  Future<List<StudySession>> getStudyHistory(String userId, {int days = 30});

  /// Check and update streak
  Future<int> checkAndUpdateStreak(String userId);

  /// Get achievements earned
  Future<List<Achievement>> getUserAchievements(String userId);

  /// Unlock a specific achievement
  Future<void> unlockAchievement(String userId, String achievementName);
}

/// Domain model for User Progress
class UserProgress {
  final String userId;
  final int xp;
  final int level;
  final int streak;
  final DateTime? lastStudyDate;
  final int totalCardsStudied;
  final DateTime updatedAt;

  UserProgress({
    required this.userId,
    required this.xp,
    required this.level,
    required this.streak,
    this.lastStudyDate,
    required this.totalCardsStudied,
    required this.updatedAt,
  });

  UserProgress copyWith({
    String? userId,
    int? xp,
    int? level,
    int? streak,
    DateTime? lastStudyDate,
    int? totalCardsStudied,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Domain model for Study Session
class StudySession {
  final String userId;
  final String flashcardId;
  final String deckId;
  final int quality; // 0-5 rating
  final int reviewDuration; // milliseconds
  final DateTime reviewDate;
  final int xpEarned;

  StudySession({
    required this.userId,
    required this.flashcardId,
    required this.deckId,
    required this.quality,
    required this.reviewDuration,
    required this.reviewDate,
    required this.xpEarned,
  });
}

/// Domain model for User Statistics
class UserStatistics {
  final String userId;
  final int totalCardsStudied;
  final int totalLessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int level;
  final double masteryPercentage;
  final DateTime lastStudyDate;
  final int cardsStudiedToday;
  final int xpEarnedToday;

  UserStatistics({
    required this.userId,
    required this.totalCardsStudied,
    required this.totalLessonsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXp,
    required this.level,
    required this.masteryPercentage,
    required this.lastStudyDate,
    required this.cardsStudiedToday,
    required this.xpEarnedToday,
  });
}

/// Domain model for Daily Stats
class DailyStats {
  final String userId;
  final DateTime date;
  final int cardsStudied;
  final int xpEarned;
  final int lessonProgress;
  final Duration totalStudyTime;

  DailyStats({
    required this.userId,
    required this.date,
    required this.cardsStudied,
    required this.xpEarned,
    required this.lessonProgress,
    required this.totalStudyTime,
  });
}

/// Domain model for Achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.unlockedAt,
  });
}
