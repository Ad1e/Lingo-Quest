import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/domain/repositories/progress_repository.dart';
import 'package:language_learning_app/domain/usecases/get_user_stats_usecase.dart';
import 'package:language_learning_app/providers/app_providers.dart';
import 'package:language_learning_app/utils/gamification_models.dart';

/// State for user progress with gamification
class ProgressState {
  final int xp;
  final int level;
  final int streak;
  final int totalCardsStudied;
  final bool isLoading;
  final String? error;
  final DateTime? lastStudyDate;
  final List<AchievementUnlock> unlockedAchievements;
  final List<XpEvent> recentXpEvents;
  final int? lastLevelUpXp;

  ProgressState({
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.totalCardsStudied = 0,
    this.isLoading = false,
    this.error,
    this.lastStudyDate,
    this.unlockedAchievements = const [],
    this.recentXpEvents = const [],
    this.lastLevelUpXp,
  });

  /// Calculate progress to next level using gamification formula
  int get xpToNextLevel {
    int nextLevelThreshold = GamificationUtils.getNextLevelThreshold(level);
    return (nextLevelThreshold - xp).clamp(0, nextLevelThreshold);
  }

  /// Calculate current level progress percentage
  double get levelProgress {
    int currentLevelThreshold = GamificationUtils.getLevelThreshold(level);
    int nextLevelThreshold = GamificationUtils.getNextLevelThreshold(level);
    int xpInCurrentLevel = xp - currentLevelThreshold;
    int xpRequired = nextLevelThreshold - currentLevelThreshold;
    if (xpRequired <= 0) return 0.0;
    return (xpInCurrentLevel / xpRequired).clamp(0.0, 1.0);
  }

  /// Get current XP in level (for display purposes)
  int get xpInCurrentLevel {
    int currentLevelThreshold = GamificationUtils.getLevelThreshold(level);
    return (xp - currentLevelThreshold).clamp(0, 999999);
  }

  /// Get total XP needed for current level
  int get xpNeededForLevel {
    int currentLevelThreshold = GamificationUtils.getLevelThreshold(level);
    int nextLevelThreshold = GamificationUtils.getNextLevelThreshold(level);
    return nextLevelThreshold - currentLevelThreshold;
  }

  ProgressState copyWith({
    int? xp,
    int? level,
    int? streak,
    int? totalCardsStudied,
    bool? isLoading,
    String? error,
    DateTime? lastStudyDate,
    List<AchievementUnlock>? unlockedAchievements,
    List<XpEvent>? recentXpEvents,
    int? lastLevelUpXp,
  }) {
    return ProgressState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      recentXpEvents: recentXpEvents ?? this.recentXpEvents,
      lastLevelUpXp: lastLevelUpXp ?? this.lastLevelUpXp,
    );
  }
}

/// StateNotifier for managing user progress with gamification
class ProgressNotifier extends StateNotifier<ProgressState> {
  final ProgressRepository _progressRepository;
  final String _userId;

  ProgressNotifier(
    this._progressRepository,
    this._userId,
  ) : super(ProgressState()) {
    loadProgress();
  }

  /// Load user progress
  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final progress = await _progressRepository.getOrCreateUserProgress(_userId);
      state = state.copyWith(
        xp: progress.xp,
        level: progress.level,
        streak: progress.streak,
        totalCardsStudied: progress.totalCardsStudied,
        lastStudyDate: progress.lastStudyDate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Add XP from an event with optional streak bonus
  Future<(int xpAdded, int? newLevel, AchievementUnlock?)> addXpForEvent(
    XpEventType type, {
    bool streakBonus = false,
  }) async {
    try {
      // Calculate base XP
      int baseXp = GamificationUtils.calculateXp(type);
      int totalXp = baseXp;

      // Apply streak bonus (10% per day streak, max 50%)
      if (streakBonus && state.streak > 0) {
        int bonusPercentage = (state.streak * 10).clamp(0, 50);
        totalXp = baseXp + (baseXp * bonusPercentage ~/ 100);
      }

      // Save XP event
      final xpEvent = XpEvent(
        type: type,
        amount: totalXp,
        timestamp: DateTime.now(),
      );

      // Update repository
      await _progressRepository.updateXp(_userId, totalXp);

      // Calculate new level
      int newTotalXp = state.xp + totalXp;
      int newLevel = GamificationUtils.calculateLevel(newTotalXp);
      bool leveledUp = newLevel > state.level;

      // Update state
      state = state.copyWith(
        xp: newTotalXp,
        level: newLevel,
        lastLevelUpXp: leveledUp ? newTotalXp : state.lastLevelUpXp,
      );

      // Add event to recent events
      final updatedEvents = [xpEvent, ...state.recentXpEvents].take(20).toList();
      state = state.copyWith(recentXpEvents: updatedEvents);

      // Check for achievements
      AchievementUnlock? achievement = await _checkAndUnlockAchievements(
        totalCardsStudied: type == XpEventType.flashcardStudied
            ? state.totalCardsStudied + 1
            : state.totalCardsStudied,
        isFirstCard: state.totalCardsStudied == 0 &&
            type == XpEventType.flashcardStudied,
        leveledUp: leveledUp,
        newLevel: newLevel,
      );

      return (totalXp, leveledUp ? newLevel : null, achievement);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Check and unlock achievements
  Future<AchievementUnlock?> _checkAndUnlockAchievements({
    required int totalCardsStudied,
    required bool isFirstCard,
    required bool leveledUp,
    required int newLevel,
  }) async {
    final achievement = GamificationUtils.checkAchievementUnlock(
      totalCardsStudied: totalCardsStudied,
      streak: state.streak,
      level: newLevel,
      isFirstCard: isFirstCard,
      isFirstLesson: false,
      isChallengeWon: false,
    );

    if (achievement != null) {
      final (title, description) =
          GamificationUtils.getAchievementDetails(achievement);

      final achievementUnlock = AchievementUnlock(
        type: achievement,
        title: title,
        description: description,
        unlockedAt: DateTime.now(),
      );

      // Add to unlocked achievements
      if (!state.unlockedAchievements
          .any((a) => a.type == achievement)) {
        final updated = [...state.unlockedAchievements, achievementUnlock];
        state = state.copyWith(unlockedAchievements: updated);

        // Save to repository
        await _progressRepository.unlockAchievement(_userId, achievement.name);
      }

      return achievementUnlock;
    }

    return null;
  }

  /// Add XP directly (legacy method)
  Future<void> addXP(int amount) async {
    try {
      await _progressRepository.updateXp(_userId, amount);

      int newTotalXp = state.xp + amount;
      int newLevel = GamificationUtils.calculateLevel(newTotalXp);

      state = state.copyWith(
        xp: newTotalXp,
        level: newLevel,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update streak with daily check
  Future<void> updateStreak(int streak) async {
    try {
      await _progressRepository.updateStreak(_userId, streak);
      state = state.copyWith(streak: streak);

      // Check if we can unlock streak achievements
      if (streak == 7 || streak == 30) {
        await _checkAndUnlockAchievements(
          totalCardsStudied: state.totalCardsStudied,
          isFirstCard: false,
          leveledUp: false,
          newLevel: state.level,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Increment cards studied
  Future<void> incrementCardsStudied() async {
    try {
      await _progressRepository.incrementCardsStudied(_userId);
      state = state.copyWith(
        totalCardsStudied: state.totalCardsStudied + 1,
        lastStudyDate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Check and update daily streak
  Future<void> checkStreak() async {
    try {
      final streak = await _progressRepository.checkAndUpdateStreak(_userId);
      state = state.copyWith(streak: streak);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get recent XP events
  List<XpEvent> getRecentXpEvents({int limit = 10}) {
    return state.recentXpEvents.take(limit).toList();
  }

  /// Get all unlocked achievements
  List<AchievementUnlock> getUnlockedAchievements() {
    return state.unlockedAchievements;
  }

  /// Check if achievement is unlocked
  bool isAchievementUnlocked(AchievementType type) {
    return state.unlockedAchievements.any((a) => a.type == type);
  }
}

/// Riverpod provider for user progress
final progressProvider =
    StateNotifierProvider.family<ProgressNotifier, ProgressState, String>(
  (ref, userId) {
    final progressRepository = ref.watch(progressRepositoryProvider);
    return ProgressNotifier(progressRepository, userId);
  },
);

/// Provider for user statistics
final userStatsProvider =
    FutureProvider.family<UserStatistics?, String>((ref, userId) async {
  final getUserStatsUseCase = ref.watch(getUserStatsUseCaseProvider);
  return getUserStatsUseCase(userId);
});

/// Provider for daily stats
final dailyStatsProvider =
    FutureProvider.family<DailyStats?, String>((ref, userId) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return progressRepository.getDailyStats(userId);
});

/// Provider for user achievements
final userAchievementsProvider =
    FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return progressRepository.getUserAchievements(userId);
});

/// Provider for XP events (derived from progress state)
final xpEventsProvider =
    Provider.family<List<XpEvent>, String>((ref, userId) {
  final state = ref.watch(progressProvider(userId));
  return state.recentXpEvents;
});

/// Provider for achievements (derived from progress state)
final achievementsProvider =
    Provider.family<List<AchievementUnlock>, String>((ref, userId) {
  final state = ref.watch(progressProvider(userId));
  return state.unlockedAchievements;
});
