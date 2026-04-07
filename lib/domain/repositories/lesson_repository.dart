import 'package:injectable/injectable.dart';

/// Abstract repository interface for lesson operations
abstract class LessonRepository {
  /// Get lessons by level
  Future<List<Lesson>> getLessonsByLevel(String level);

  /// Get lesson by ID
  Future<Lesson?> getLessonById(String lessonId);

  /// Get lessons for language
  Future<List<Lesson>> getLessonsForLanguage(String language);

  /// Mark lesson as completed
  Future<void> markLessonComplete(String userId, String lessonId, int xpEarned);

  /// Get user's completed lessons
  Future<List<String>> getCompletedLessons(String userId);

  /// Search lessons
  Future<List<Lesson>> searchLessons(String query);

  /// Get lesson with exercises
  Future<LessonWithExercises?> getLessonWithExercises(String lessonId);

  /// Subscribe to lessons by level
  Stream<List<Lesson>> watchLessonsByLevel(String level);
}

/// Domain model for Lesson
class Lesson {
  final String id;
  final String title;
  final String level; // A1, A2, B1, B2, C1, C2
  final String language;
  final String grammarExplanation;
  final List<String> vocabularyIds;
  final List<String> exerciseIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.level,
    required this.language,
    required this.grammarExplanation,
    required this.vocabularyIds,
    required this.exerciseIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Lesson copyWith({
    String? id,
    String? title,
    String? level,
    String? language,
    String? grammarExplanation,
    List<String>? vocabularyIds,
    List<String>? exerciseIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      language: language ?? this.language,
      grammarExplanation: grammarExplanation ?? this.grammarExplanation,
      vocabularyIds: vocabularyIds ?? this.vocabularyIds,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Domain model for Exercise
class Exercise {
  final String id;
  final String lessonId;
  final String type; // 'choice', 'fill', 'match', 'multiple'
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  Exercise({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });
}

/// Domain model for Lesson with Exercises
class LessonWithExercises {
  final Lesson lesson;
  final List<Exercise> exercises;

  LessonWithExercises({
    required this.lesson,
    required this.exercises,
  });
}
