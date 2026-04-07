import 'package:injectable/injectable.dart';

/// Abstract interface for local progress data source
abstract class ProgressLocalDataSource {
  /// Get user's progress
  Future<ProgressLocal?> getUserProgress(String userId);

  /// Create or get user progress
  Future<ProgressLocal> getOrCreateUserProgress(String userId);

  /// Update XP for user
  Future<void> updateXp(String userId, int xpAmount);

  /// Update streak for user
  Future<void> updateStreak(String userId, int streak);

  /// Increment total cards studied
  Future<void> incrementCardsStudied(String userId);

  /// Add study history entry
  Future<void> addStudyHistory(StudyHistoryLocal history);

  /// Get study history for user
  Future<List<StudyHistoryLocal>> getStudyHistory(String userId);

  /// Get study history for last N days
  Future<List<StudyHistoryLocal>> getStudyHistoryForDays(String userId, int days);

  /// Get daily study streak
  Future<int> getDailyStreak(String userId);

  /// Check if user studied today
  Future<bool> hasStudiedToday(String userId);

  /// Calculate XP for today
  Future<int> getTodayXp(String userId);

  /// Get total XP earned
  Future<int> getTotalXp(String userId);

  /// Get user's level
  Future<int> getUserLevel(String userId);

  /// Get total cards studied
  Future<int> getTotalCardsStudied(String userId);
}

/// Local model for User Progress
class ProgressLocal {
  final String userId;
  final int xp;
  final int level;
  final int streak;
  final DateTime? lastStudyDate;
  final int totalCardsStudied;
  final DateTime updatedAt;

  ProgressLocal({
    required this.userId,
    required this.xp,
    required this.level,
    required this.streak,
    this.lastStudyDate,
    required this.totalCardsStudied,
    required this.updatedAt,
  });

  ProgressLocal copyWith({
    String? userId,
    int? xp,
    int? level,
    int? streak,
    DateTime? lastStudyDate,
    int? totalCardsStudied,
    DateTime? updatedAt,
  }) {
    return ProgressLocal(
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

/// Local model for Study History
class StudyHistoryLocal {
  final int? id;
  final String userId;
  final String flashcardId;
  final String deckId;
  final int quality; // 0-5 rating from spaced repetition
  final int reviewDuration; // milliseconds
  final DateTime reviewDate;

  StudyHistoryLocal({
    this.id,
    required this.userId,
    required this.flashcardId,
    required this.deckId,
    required this.quality,
    required this.reviewDuration,
    required this.reviewDate,
  });

  StudyHistoryLocal copyWith({
    int? id,
    String? userId,
    String? flashcardId,
    String? deckId,
    int? quality,
    int? reviewDuration,
    DateTime? reviewDate,
  }) {
    return StudyHistoryLocal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      flashcardId: flashcardId ?? this.flashcardId,
      deckId: deckId ?? this.deckId,
      quality: quality ?? this.quality,
      reviewDuration: reviewDuration ?? this.reviewDuration,
      reviewDate: reviewDate ?? this.reviewDate,
    );
  }
}

/// Implementation of ProgressLocalDataSource
@Singleton(as: ProgressLocalDataSource)
class ProgressLocalDataSourceImpl implements ProgressLocalDataSource {
  // TODO: Inject AppDatabase when Drift is fully configured
  // final AppDatabase database;
  // ProgressLocalDataSourceImpl(this.database);

  @override
  Future<ProgressLocal?> getUserProgress(String userId) async {
    // TODO: Implement using Drift
    return null;
  }

  @override
  Future<ProgressLocal> getOrCreateUserProgress(String userId) async {
    // TODO: Implement using Drift
    return ProgressLocal(
      userId: userId,
      xp: 0,
      level: 1,
      streak: 0,
      totalCardsStudied: 0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateXp(String userId, int xpAmount) async {
    // TODO: Implement using Drift
  }

  @override
  Future<void> updateStreak(String userId, int streak) async {
    // TODO: Implement using Drift
  }

  @override
  Future<void> incrementCardsStudied(String userId) async {
    // TODO: Implement using Drift
  }

  @override
  Future<void> addStudyHistory(StudyHistoryLocal history) async {
    // TODO: Implement using Drift
  }

  @override
  Future<List<StudyHistoryLocal>> getStudyHistory(String userId) async {
    // TODO: Implement using Drift
    return [];
  }

  @override
  Future<List<StudyHistoryLocal>> getStudyHistoryForDays(
    String userId,
    int days,
  ) async {
    // TODO: Implement using Drift
    return [];
  }

  @override
  Future<int> getDailyStreak(String userId) async {
    // TODO: Implement using Drift
    final progress = await getUserProgress(userId);
    return progress?.streak ?? 0;
  }

  @override
  Future<bool> hasStudiedToday(String userId) async {
    // TODO: Implement using Drift
    final progress = await getUserProgress(userId);
    if (progress?.lastStudyDate == null) return false;

    final today = DateTime.now();
    final lastStudy = progress!.lastStudyDate!;

    return lastStudy.year == today.year &&
        lastStudy.month == today.month &&
        lastStudy.day == today.day;
  }

  @override
  Future<int> getTodayXp(String userId) async {
    // TODO: Implement using Drift
    final history = await getStudyHistoryForDays(userId, 1);
    return history.length * 10; // Placeholder calculation
  }

  @override
  Future<int> getTotalXp(String userId) async {
    // TODO: Implement using Drift
    final progress = await getUserProgress(userId);
    return progress?.xp ?? 0;
  }

  @override
  Future<int> getUserLevel(String userId) async {
    // TODO: Implement using Drift
    final progress = await getUserProgress(userId);
    return progress?.level ?? 1;
  }

  @override
  Future<int> getTotalCardsStudied(String userId) async {
    // TODO: Implement using Drift
    final progress = await getUserProgress(userId);
    return progress?.totalCardsStudied ?? 0;
  }
}
