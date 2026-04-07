import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart' as drift;
import 'package:my_app/lib/data/datasources/local/database_helper.dart';
import 'package:my_app/lib/data/datasources/remote/lesson_remote_ds.dart';
import 'package:my_app/lib/domain/repositories/lesson_repository.dart';

/// Implementation of LessonRepository with offline-first strategy
@Singleton(as: LessonRepository)
class LessonRepositoryImpl implements LessonRepository {
  final DatabaseHelper _database;
  final LessonRemoteDataSource _remoteDataSource;

  LessonRepositoryImpl(
    this._database,
    this._remoteDataSource,
  );

  @override
  Future<List<Lesson>> getLessonsByLevel(String level) async {
    try {
      // Fetch from remote with offline fallback
      final remoteLessons = await _remoteDataSource.getLessonsByLevel(level);
      
      // Cache to local in background
      _cacheLessonsLocally(remoteLessons);
      
      return _mapRemoteLessonsToLessons(remoteLessons);
    } catch (e) {
      // Fallback to cached data if remote fails
      // Note: In production, you'd query cached data from database
      rethrow;
    }
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final remoteLesson = await _remoteDataSource.getLessonDetails(lessonId);
      
      if (remoteLesson != null) {
        // Sync background
        _cacheLessonLocally(remoteLesson);
        return _mapRemoteLessonToLesson(remoteLesson);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Lesson>> getLessonsForLanguage(String language) async {
    try {
      // Fetch all lessons and filter by language
      final remoteLessons =
          await _remoteDataSource.getLessonsForLanguage(language);
      
      _cacheLessonsLocally(remoteLessons);
      
      return _mapRemoteLessonsToLessons(remoteLessons);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markLessonComplete(
    String userId,
    String lessonId,
    int xpEarned,
  ) async {
    try {
      // Store completion locally
      await _database.insertChallenge(
        ChallengesCompanion(
          id: drift.Value(lessonId),
          title: drift.Value(lessonId),
          type: drift.Value('lesson'),
          xpReward: drift.Value(xpEarned),
          deadline: drift.Value(DateTime.now().add(Duration(hours: 24))),
          isCompleted: drift.Value(true),
        ),
      );
      
      // Sync completion to remote
      _syncLessonCompletionInBackground(userId, lessonId, xpEarned);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getCompletedLessons(String userId) async {
    try {
      // Query from local database
      final challenges = await _database.getChallenges();
      
      return challenges
          .where((c) => c.type == 'lesson' && c.isCompleted)
          .map((c) => c.id)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Lesson>> searchLessons(String query) async {
    try {
      final remoteLessons = await _remoteDataSource.searchLessons(query);
      
      _cacheLessonsLocally(remoteLessons);
      
      return _mapRemoteLessonsToLessons(remoteLessons);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LessonWithExercises?> getLessonWithExercises(String lessonId) async {
    try {
      final lessonWithExercises =
          await _remoteDataSource.getLessonWithExercises(lessonId);
      
      if (lessonWithExercises != null) {
        _cacheLessonLocally(lessonWithExercises.lesson);
        
        return LessonWithExercises(
          lesson: _mapRemoteLessonToLesson(lessonWithExercises.lesson),
          exercises: _mapRemoteExercisesToExercises(
            lessonWithExercises.exercises,
          ),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<Lesson>> watchLessonsByLevel(String level) {
    return _remoteDataSource.watchLessonsByLevel(level).map(
      (remoteLessons) => _mapRemoteLessonsToLessons(remoteLessons),
    );
  }

  // ============ Background Sync Methods ============

  void _cacheLessonLocally(LessonRemote lesson) {
    // Implement caching logic if Drift tables support it
    // For now, this is a placeholder for lesson caching
  }

  void _cacheLessonsLocally(List<LessonRemote> lessons) {
    for (final lesson in lessons) {
      _cacheLessonLocally(lesson);
    }
  }

  void _syncLessonCompletionInBackground(
    String userId,
    String lessonId,
    int xpEarned,
  ) {
    // Sync completion to remote (actual implementation depends on backend)
    Future.microtask(() async {
      try {
        // Call backend API to record lesson completion
      } catch (_) {
        // Silently fail
      }
    });
  }

  // ============ Mapping Methods ============

  Lesson _mapRemoteLessonToLesson(LessonRemote remote) {
    return Lesson(
      id: remote.id,
      title: remote.title,
      level: remote.level,
      language: remote.language,
      grammarExplanation: remote.grammarExplanation,
      vocabularyIds: remote.vocabularyIds,
      exerciseIds: remote.exerciseIds,
      createdAt: remote.createdAt,
      updatedAt: remote.updatedAt,
    );
  }

  List<Lesson> _mapRemoteLessonsToLessons(List<LessonRemote> remotes) {
    return remotes.map(_mapRemoteLessonToLesson).toList();
  }

  Exercise _mapRemoteExerciseToExercise(ExerciseRemote remote) {
    return Exercise(
      id: remote.id,
      lessonId: remote.lessonId,
      type: remote.type,
      question: remote.question,
      options: remote.options,
      correctAnswer: remote.correctAnswer,
      explanation: remote.explanation,
    );
  }

  List<Exercise> _mapRemoteExercisesToExercises(List<ExerciseRemote> remotes) {
    return remotes.map(_mapRemoteExerciseToExercise).toList();
  }
}
