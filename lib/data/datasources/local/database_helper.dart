import 'package:drift/drift.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database_helper.g.dart';

// ============================================================================
// DRIFT TABLES
// ============================================================================

/// Flashcard Table
@DataClassName('FlashcardEntity')
class Flashcards extends Table {
  TextColumn get id => text()();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get exampleSentence => text().nullable()();
  TextColumn get deckId => text()();
  DateTimeColumn get nextReviewDate => dateTime()();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Flashcard Deck Table
@DataClassName('DeckEntity')
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get language => text()();
  TextColumn get targetLanguage => text()();
  IntColumn get cardCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// User Progress Table
@DataClassName('ProgressEntity')
class UserProgress extends Table {
  TextColumn get userId => text()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStudyDate => dateTime().nullable()();
  IntColumn get totalCardsStudied => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Study History Table
@DataClassName('StudyHistoryEntity')
class StudyHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get flashcardId => text()();
  TextColumn get deckId => text()();
  IntColumn get quality => integer()(); // 0-5 rating
  IntColumn get reviewDuration => integer()(); // milliseconds
  DateTimeColumn get reviewDate => dateTime()();
}

/// Daily Challenge Table
@DataClassName('ChallengeEntity')
class Challenges extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get type => text()(); // 'flashcard', 'lesson', etc.
  IntColumn get xpReward => integer()();
  DateTimeColumn get deadline => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Achievement Table
@DataClassName('AchievementEntity')
class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get iconPath => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// DRIFT DATABASE CLASS
// ============================================================================

@DriftDatabase(tables: [
  Flashcards,
  Decks,
  UserProgress,
  StudyHistory,
  Challenges,
  Achievements,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ========================================================================
  // FLASHCARD QUERIES
  // ========================================================================

  /// Get all flashcards for a deck
  Future<List<FlashcardEntity>> getFlashcardsByDeck(String deckId) {
    return (select(flashcards)..where((tbl) => tbl.deckId.equals(deckId)))
        .get();
  }

  /// Get flashcard by ID
  Future<FlashcardEntity?> getFlashcardById(String id) {
    return (select(flashcards)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get cards due for review
  Future<List<FlashcardEntity>> getCardsDueForReview(String deckId) {
    return (select(flashcards)
          ..where((tbl) =>
              tbl.deckId.equals(deckId) &
              tbl.nextReviewDate.isSmallerOrEqualValue(DateTime.now())))
        .get();
  }

  /// Insert or update flashcard
  Future<void> upsertFlashcard(FlashcardEntity flashcard) {
    return into(flashcards).insert(
      flashcard,
      onConflict: DoUpdate((_) => flashcard),
    );
  }

  /// Batch insert flashcards
  Future<void> insertFlashcards(List<FlashcardEntity> cards) async {
    await batch((batch) {
      batch.insertAll(flashcards, cards, mode: InsertMode.insertOrReplace);
    });
  }

  /// Delete flashcard
  Future<int> deleteFlashcard(String id) {
    return (delete(flashcards)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ========================================================================
  // DECK QUERIES
  // ========================================================================

  /// Get all decks for user
  Future<List<DeckEntity>> getDecksByUser(String userId) {
    return (select(decks)..where((tbl) => tbl.userId.equals(userId))).get();
  }

  /// Get deck by ID
  Future<DeckEntity?> getDeckById(String id) {
    return (select(decks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update deck
  Future<void> upsertDeck(DeckEntity deck) {
    return into(decks).insert(
      deck,
      onConflict: DoUpdate((_) => deck),
    );
  }

  /// Delete deck and associated flashcards
  Future<void> deleteDeck(String deckId) async {
    await (delete(flashcards)..where((tbl) => tbl.deckId.equals(deckId))).go();
    await (delete(decks)..where((tbl) => tbl.id.equals(deckId))).go();
  }

  // ========================================================================
  // PROGRESS QUERIES
  // ========================================================================

  /// Get user progress
  Future<ProgressEntity?> getUserProgress(String userId) {
    return (select(userProgress)..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Update XP
  Future<void> updateXp(String userId, int xpAmount) async {
    final current = await getUserProgress(userId);
    if (current != null) {
      final newLevel = (current.xp + xpAmount) ~/ 1000 + 1;
      await (update(userProgress)..where((tbl) => tbl.userId.equals(userId)))
          .write(ProgressEntity(
        xp: current.xp + xpAmount,
        level: newLevel,
        userId: userId,
        streak: current.streak,
        lastStudyDate: current.lastStudyDate,
        totalCardsStudied: current.totalCardsStudied,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Update streak
  Future<void> updateStreak(String userId, int streak) async {
    final current = await getUserProgress(userId);
    if (current != null) {
      await (update(userProgress)..where((tbl) => tbl.userId.equals(userId)))
          .write(ProgressEntity(
        xp: current.xp,
        level: current.level,
        userId: userId,
        streak: streak,
        lastStudyDate: DateTime.now(),
        totalCardsStudied: current.totalCardsStudied,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Increment total cards studied
  Future<void> incrementCardsStudied(String userId) async {
    final current = await getUserProgress(userId);
    if (current != null) {
      await (update(userProgress)..where((tbl) => tbl.userId.equals(userId)))
          .write(ProgressEntity(
        xp: current.xp,
        level: current.level,
        userId: userId,
        streak: current.streak,
        lastStudyDate: current.lastStudyDate,
        totalCardsStudied: current.totalCardsStudied + 1,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Create or get user progress
  Future<ProgressEntity> getOrCreateProgress(String userId) async {
    final existing = await getUserProgress(userId);
    if (existing != null) return existing;

    final newProgress = ProgressEntity(
      userId: userId,
      xp: 0,
      level: 1,
      streak: 0,
      lastStudyDate: null,
      totalCardsStudied: 0,
      updatedAt: DateTime.now(),
    );

    await into(userProgress).insert(newProgress);
    return newProgress;
  }

  // ========================================================================
  // STUDY HISTORY QUERIES
  // ========================================================================

  /// Add study history entry
  Future<int> addStudyHistory(StudyHistoryEntity history) {
    return into(studyHistory).insert(history);
  }

  /// Get study history for user
  Future<List<StudyHistoryEntity>> getStudyHistory(String userId) {
    return (select(studyHistory)..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  /// Get study history for last N days
  Future<List<StudyHistoryEntity>> getStudyHistoryForDays(
    String userId,
    int days,
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return (select(studyHistory)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.reviewDate.isAfter(cutoffDate)))
        .get();
  }

  // ========================================================================
  // CHALLENGE QUERIES
  // ========================================================================

  /// Get active challenges for user
  Future<List<ChallengeEntity>> getActiveChallenges(String userId) {
    return (select(challenges)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.isCompleted.equals(false) &
              tbl.deadline.isAfter(DateTime.now())))
        .get();
  }

  /// Complete challenge
  Future<int> completeChallenge(String challengeId) {
    return (update(challenges)..where((tbl) => tbl.id.equals(challengeId)))
        .write(const ChallengeEntity(isCompleted: true));
  }

  /// Insert challenge
  Future<void> insertChallenge(ChallengeEntity challenge) {
    return into(challenges).insert(challenge);
  }

  // ========================================================================
  // ACHIEVEMENT QUERIES
  // ========================================================================

  /// Get achievements for user
  Future<List<AchievementEntity>> getAchievements(String userId) {
    return (select(achievements)..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  /// Unlock achievement
  Future<void> unlockAchievement(AchievementEntity achievement) {
    return into(achievements).insert(
      achievement,
      onConflict: DoUpdate((_) => achievement),
    );
  }
  // ── Compatibility helpers used by repository implementations ──────────────

  /// Alias used by progress_repository_impl.dart
  Future<int> insertStudyHistory(StudyHistoryCompanion entry) {
    return into(studyHistory).insert(entry);
  }

  /// Alias: get all challenges (repository uses no-arg form)
  Future<List<ChallengeEntity>> getChallenges() {
    return select(challenges).get();
  }

  /// Alias: get achievements without userId filter (repository uses no-arg form)
  Future<List<AchievementEntity>> getAchievementsAll() {
    return select(achievements).get();
  }

  /// Alias: unlock achievement by String achievement name
  Future<void> unlockAchievementByName(
      String userId, String achievementName) async {
    final entity = AchievementEntity(
      id: achievementName,
      userId: userId,
      title: achievementName,
      description: '',
      iconPath: '',
      unlockedAt: DateTime.now(),
    );
    await unlockAchievement(entity);
  }
}

// ============================================================================
// DatabaseHelper typedef — lets repository files reference DatabaseHelper
// without any changes.
// ============================================================================
typedef DatabaseHelper = AppDatabase;

// ============================================================================
// DATABASE CONNECTION
// ============================================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app_database.sqlite');
    return driftDatabase(file);
  });
}
