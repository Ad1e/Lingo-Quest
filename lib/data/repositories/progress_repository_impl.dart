import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart' as drift;
import 'package:my_app/lib/data/datasources/local/database_helper.dart';
import 'package:my_app/lib/data/datasources/local/progress_local_ds.dart';
import 'package:my_app/lib/data/datasources/remote/cloud_functions_ds.dart';
import 'package:my_app/lib/domain/repositories/progress_repository.dart';

/// Implementation of ProgressRepository with offline-first strategy
@Singleton(as: ProgressRepository)
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource _localDataSource;
  final CloudFunctionsDataSource _remoteFunctions;
  final DatabaseHelper _database;

  ProgressRepositoryImpl(
    this._localDataSource,
    this._remoteFunctions,
    this._database,
  );

  @override
  Future<UserProgress?> getUserProgress(String userId) async {
    try {
      // Return local progress immediately
      final localProgress = await _localDataSource.getUserProgress(userId);
      
      // Sync from remote in background
      _syncProgressInBackground(userId);
      
      return localProgress != null ? _mapLocalProgressToProgress(localProgress) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProgress> getOrCreateUserProgress(String userId) async {
    try {
      final localProgress = await _localDataSource.getOrCreateUserProgress(userId);
      
      // Sync in background
      _syncProgressInBackground(userId);
      
      return _mapLocalProgressToProgress(localProgress);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateXp(String userId, int xpAmount) async {
    try {
      // Update locally immediately
      await _localDataSource.updateXp(userId, xpAmount);
      
      // Sync to remote in background
      _syncXpUpdateInBackground(userId, xpAmount);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateStreak(String userId, int streak) async {
    try {
      // Update locally
      await _localDataSource.updateStreak(userId, streak);
      
      // Sync to remote
      _syncStreakUpdateInBackground(userId, streak);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> incrementCardsStudied(String userId) async {
    try {
      // Update locally
      await _localDataSource.incrementCardsStudied(userId);
      
      // Sync in background
      _syncCardsStudiedInBackground(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addStudySession(StudySession session) async {
    try {
      // Add locally
      final localSession = _mapStudySessionToLocal(session);
      await _database.insertStudyHistory(
        StudyHistoryCompanion(
          userId: drift.Value(session.userId),
          flashcardId: drift.Value(session.flashcardId),
          deckId: drift.Value(session.deckId),
          quality: drift.Value(session.quality),
          reviewDuration: drift.Value(session.reviewDuration),
          reviewDate: drift.Value(session.reviewDate),
        ),
      );
      
      // Sync in background
      _syncStudySessionInBackground(session);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserStatistics?> getUserStatistics(String userId) async {
    try {
      // Calculate from local data
      final progress = await _localDataSource.getUserProgress(userId);
      if (progress == null) return null;
      
      final totalCards = progress.totalCardsStudied;
      final xp = progress.xp;
      final level = progress.level;
      final streak = progress.streak;
      
      // Get today's stats
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final studyHistory = await _localDataSource.getStudyHistory(
        userId,
        days: 1,
      );
      
      final cardsToday = studyHistory.length;
      final xpToday = studyHistory.fold(0, (sum, session) => sum + session.xpEarned ?? 0);
      
      return UserStatistics(
        userId: userId,
        totalCardsStudied: totalCards,
        totalLessonsCompleted: 0, // TODO: Query from database
        currentStreak: streak,
        longestStreak: streak, // TODO: Track separately
        totalXp: xp,
        level: level,
        masteryPercentage: (totalCards * 100 / 1000).clamp(0, 100).toDouble(),
        lastStudyDate: progress.lastStudyDate ?? DateTime.now(),
        cardsStudiedToday: cardsToday,
        xpEarnedToday: xpToday,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DailyStats?> getDailyStats(String userId) async {
    try {
      final today = DateTime.now();
      final studyHistory = await _localDataSource.getStudyHistory(userId, days: 1);
      
      final cardsStudied = studyHistory.length;
      final xpEarned = studyHistory.fold(0, (sum, session) => sum + session.xpEarned ?? 0);
      final totalTime = studyHistory.fold(
        Duration.zero,
        (total, session) => total + Duration(milliseconds: session.reviewDuration ?? 0),
      );
      
      return DailyStats(
        userId: userId,
        date: today,
        cardsStudied: cardsStudied,
        xpEarned: xpEarned,
        lessonProgress: 0, // TODO: Calculate from database
        totalStudyTime: totalTime,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<StudySession>> getStudyHistory(String userId, {int days = 30}) async {
    try {
      final localHistory = await _localDataSource.getStudyHistory(userId, days: days);
      return _mapLocalSessionsToSessions(localHistory);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> checkAndUpdateStreak(String userId) async {
    try {
      final dailyStreak = await _localDataSource.getDailyStreak(userId);
      final hasStudiedToday = await _localDataSource.hasStudiedToday(userId);
      
      if (!hasStudiedToday && dailyStreak > 0) {
        // Streak was broken
        await _localDataSource.updateStreak(userId, 0);
        return 0;
      }
      
      return dailyStreak;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final achievements = await _database.getAchievements();
      return _mapLocalAchievementsToAchievements(achievements);
    } catch (e) {
      rethrow;
    }
  }

  // ============ Background Sync Methods ============

  void _syncProgressInBackground(String userId) {
    Future.microtask(() async {
      try {
        final localProgress = await _localDataSource.getUserProgress(userId);
        if (localProgress != null) {
          // TODO: Implement remote sync if backend API exists
        }
      } catch (_) {
        // Silently fail
      }
    });
  }

  void _syncXpUpdateInBackground(String userId, int xpAmount) {
    Future.microtask(() async {
      try {
        // Sync to remote (backend implementation)
      } catch (_) {}
    });
  }

  void _syncStreakUpdateInBackground(String userId, int streak) {
    Future.microtask(() async {
      try {
        final milestoneResult = await _remoteFunctions.checkStreakMilestone(
          userId: userId,
          currentStreak: streak,
        );
        // Handle milestone achievements
      } catch (_) {}
    });
  }

  void _syncCardsStudiedInBackground(String userId) {
    Future.microtask(() async {
      try {
        // Sync to remote
      } catch (_) {}
    });
  }

  void _syncStudySessionInBackground(StudySession session) {
    Future.microtask(() async {
      try {
        // Sync to remote
      } catch (_) {}
    });
  }

  // ============ Mapping Methods ============

  UserProgress _mapLocalProgressToProgress(ProgressLocal local) {
    return UserProgress(
      userId: local.userId,
      xp: local.xp,
      level: local.level,
      streak: local.streak,
      lastStudyDate: local.lastStudyDate,
      totalCardsStudied: local.totalCardsStudied,
      updatedAt: DateTime.now(),
    );
  }

  StudySession _mapLocalSessionToSession(StudyHistoryLocal local) {
    return StudySession(
      userId: local.userId,
      flashcardId: local.flashcardId,
      deckId: local.deckId,
      quality: local.quality,
      reviewDuration: local.reviewDuration,
      reviewDate: local.reviewDate,
      xpEarned: local.xpEarned ?? 0,
    );
  }

  List<StudySession> _mapLocalSessionsToSessions(
      List<StudyHistoryLocal> locals) {
    return locals.map(_mapLocalSessionToSession).toList();
  }

  StudyHistoryLocal _mapStudySessionToLocal(StudySession session) {
    return StudyHistoryLocal(
      userId: session.userId,
      flashcardId: session.flashcardId,
      deckId: session.deckId,
      quality: session.quality,
      reviewDuration: session.reviewDuration,
      reviewDate: session.reviewDate,
      xpEarned: session.xpEarned,
    );
  }

  Achievement _mapLocalAchievementToAchievement(AchievementsData local) {
    return Achievement(
      id: local.id,
      title: local.id,
      description: '',
      iconPath: '',
      unlockedAt: local.id is String ? DateTime.now() : DateTime.now(),
    );
  }

  List<Achievement> _mapLocalAchievementsToAchievements(
      List<AchievementsData> locals) {
    return locals
        .map(_mapLocalAchievementToAchievement)
        .toList();
  }
}
