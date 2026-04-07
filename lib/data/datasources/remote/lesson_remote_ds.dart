import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

/// Abstract interface for remote lesson data source
abstract class LessonRemoteDataSource {
  /// Get lessons by level
  Future<List<LessonRemote>> getLessonsByLevel(String level);

  /// Get lesson details
  Future<LessonRemote?> getLessonDetails(String lessonId);

  /// Get all lessons for language
  Future<List<LessonRemote>> getLessonsForLanguage(String language);

  /// Search lessons
  Future<List<LessonRemote>> searchLessons(String query);

  /// Get lesson with exercises
  Future<LessonWithExercises?> getLessonWithExercises(String lessonId);

  /// Subscribe to lesson updates
  Stream<List<LessonRemote>> watchLessonsByLevel(String level);
}

/// Remote model for Lesson
class LessonRemote {
  final String id;
  final String title;
  final String level; // A1, A2, B1, B2, C1, C2
  final String language;
  final String grammarExplanation;
  final List<String> vocabularyIds;
  final List<String> exerciseIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonRemote({
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'level': level,
    'language': language,
    'grammarExplanation': grammarExplanation,
    'vocabularyIds': vocabularyIds,
    'exerciseIds': exerciseIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LessonRemote.fromJson(Map<String, dynamic> json) => LessonRemote(
    id: json['id'] as String,
    title: json['title'] as String,
    level: json['level'] as String,
    language: json['language'] as String,
    grammarExplanation: json['grammarExplanation'] as String,
    vocabularyIds: List<String>.from(json['vocabularyIds'] as List? ?? []),
    exerciseIds: List<String>.from(json['exerciseIds'] as List? ?? []),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

/// Lesson with exercises
class LessonWithExercises {
  final LessonRemote lesson;
  final List<ExerciseRemote> exercises;

  LessonWithExercises({
    required this.lesson,
    required this.exercises,
  });
}

/// Remote model for Exercise
class ExerciseRemote {
  final String id;
  final String lessonId;
  final String type; // 'choice', 'fill', 'match', etc.
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  ExerciseRemote({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'lessonId': lessonId,
    'type': type,
    'question': question,
    'options': options,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
  };

  factory ExerciseRemote.fromJson(Map<String, dynamic> json) => ExerciseRemote(
    id: json['id'] as String,
    lessonId: json['lessonId'] as String,
    type: json['type'] as String,
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List? ?? []),
    correctAnswer: json['correctAnswer'] as String,
    explanation: json['explanation'] as String?,
  );
}

/// Implementation of LessonRemoteDataSource
@Singleton(as: LessonRemoteDataSource)
class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  final FirebaseFirestore _firestore;

  LessonRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<LessonRemote>> getLessonsByLevel(String level) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('level', isEqualTo: level)
          .get();

      return snapshot.docs
          .map((doc) => LessonRemote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lessons: $e');
    }
  }

  @override
  Future<LessonRemote?> getLessonDetails(String lessonId) async {
    try {
      final doc = await _firestore.collection('lessons').doc(lessonId).get();
      if (!doc.exists) return null;
      return LessonRemote.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch lesson details: $e');
    }
  }

  @override
  Future<List<LessonRemote>> getLessonsForLanguage(String language) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('language', isEqualTo: language)
          .get();

      return snapshot.docs
          .map((doc) => LessonRemote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch language lessons: $e');
    }
  }

  @override
  Future<List<LessonRemote>> searchLessons(String query) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => LessonRemote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search lessons: $e');
    }
  }

  @override
  Future<LessonWithExercises?> getLessonWithExercises(String lessonId) async {
    try {
      final lessonDoc =
          await _firestore.collection('lessons').doc(lessonId).get();
      if (!lessonDoc.exists) return null;

      final lesson = LessonRemote.fromJson(lessonDoc.data()!);

      final exercisesSnapshot = await _firestore
          .collection('lessons')
          .doc(lessonId)
          .collection('exercises')
          .get();

      final exercises = exercisesSnapshot.docs
          .map((doc) => ExerciseRemote.fromJson(doc.data()))
          .toList();

      return LessonWithExercises(lesson: lesson, exercises: exercises);
    } catch (e) {
      throw Exception('Failed to fetch lesson with exercises: $e');
    }
  }

  @override
  Stream<List<LessonRemote>> watchLessonsByLevel(String level) {
    return _firestore
        .collection('lessons')
        .where('level', isEqualTo: level)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LessonRemote.fromJson(doc.data()))
            .toList());
  }
}
