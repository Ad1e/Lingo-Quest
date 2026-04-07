import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/domain/repositories/lesson_repository.dart';

/// State for lesson studies
class LessonStudyState {
  final Lesson? currentLesson;
  final List<Exercise> exercises;
  final int currentExerciseIndex;
  final bool isLoading;
  final String? error;
  final int correctAnswers;
  final int totalExercises;

  LessonStudyState({
    this.currentLesson,
    this.exercises = const [],
    this.currentExerciseIndex = 0,
    this.isLoading = false,
    this.error,
    this.correctAnswers = 0,
    this.totalExercises = 0,
  });

  Exercise? get currentExercise =>
      currentExerciseIndex < exercises.length
          ? exercises[currentExerciseIndex]
          : null;

  bool get isLessonComplete => currentExerciseIndex >= exercises.length;

  double get completionPercentage =>
      totalExercises > 0 ? (correctAnswers / totalExercises) * 100 : 0;

  LessonStudyState copyWith({
    Lesson? currentLesson,
    List<Exercise>? exercises,
    int? currentExerciseIndex,
    bool? isLoading,
    String? error,
    int? correctAnswers,
    int? totalExercises,
  }) {
    return LessonStudyState(
      currentLesson: currentLesson ?? this.currentLesson,
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalExercises: totalExercises ?? this.totalExercises,
    );
  }
}

/// StateNotifier for managing lesson study sessions
class LessonStudyNotifier extends StateNotifier<LessonStudyState> {
  final LessonRepository _lessonRepository;
  final String _userId;

  LessonStudyNotifier(
    this._lessonRepository,
    this._userId,
  ) : super(LessonStudyState());

  /// Load lesson with exercises
  Future<void> loadLesson(String lessonId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lessonWithExercises =
          await _lessonRepository.getLessonWithExercises(lessonId);

      if (lessonWithExercises != null) {
        state = state.copyWith(
          currentLesson: lessonWithExercises.lesson,
          exercises: lessonWithExercises.exercises,
          totalExercises: lessonWithExercises.exercises.length,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Lesson not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Submit answer to current exercise
  Future<void> submitAnswer(String answer) async {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    bool isCorrect = answer.trim().toLowerCase() ==
        exercise.correctAnswer.trim().toLowerCase();

    state = state.copyWith(
      correctAnswers: isCorrect ? state.correctAnswers + 1 : state.correctAnswers,
    );

    // Move to next exercise
    if (!state.isLessonComplete) {
      nextExercise();
    }
  }

  /// Move to next exercise
  void nextExercise() {
    state = state.copyWith(
      currentExerciseIndex: state.currentExerciseIndex + 1,
    );
  }

  /// Complete lesson and mark as finished
  Future<void> completeLesson() async {
    final lesson = state.currentLesson;
    if (lesson == null) return;

    try {
      // Award XP for lesson completion
      int xpReward = 50 + (state.correctAnswers * 5);
      await _lessonRepository.markLessonComplete(
        _userId,
        lesson.id,
        xpReward,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reset lesson study session
  void reset() {
    state = LessonStudyState();
  }
}

/// State for lesson list
class LessonListState {
  final List<Lesson> lessons;
  final bool isLoading;
  final String? error;
  final String? selectedLevel;

  LessonListState({
    this.lessons = const [],
    this.isLoading = false,
    this.error,
    this.selectedLevel,
  });

  LessonListState copyWith({
    List<Lesson>? lessons,
    bool? isLoading,
    String? error,
    String? selectedLevel,
  }) {
    return LessonListState(
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedLevel: selectedLevel ?? this.selectedLevel,
    );
  }
}

/// StateNotifier for managing lesson list
class LessonListNotifier extends StateNotifier<LessonListState> {
  final LessonRepository _lessonRepository;

  LessonListNotifier(this._lessonRepository) : super(LessonListState());

  /// Load lessons by level
  Future<void> loadLessonsByLevel(String level) async {
    state = state.copyWith(isLoading: true, error: null, selectedLevel: level);
    try {
      final lessons = await _lessonRepository.getLessonsByLevel(level);
      state = state.copyWith(
        lessons: lessons,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search lessons
  Future<void> searchLessons(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final lessons = await _lessonRepository.searchLessons(query);
      state = state.copyWith(
        lessons: lessons,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Riverpod provider for lesson study state
final lessonStudyProvider =
    StateNotifierProvider.family<LessonStudyNotifier, LessonStudyState, String>(
  (ref, userId) {
    // TODO: Inject dependencies from ref
    // final lessonRepository = ref.watch(lessonRepositoryProvider);
    // return LessonStudyNotifier(lessonRepository, userId);
    throw UnimplementedError('Dependencies must be provided');
  },
);

/// Riverpod provider for lesson list
final lessonListProvider =
    StateNotifierProvider<LessonListNotifier, LessonListState>((ref) {
  // TODO: Inject dependencies from ref
  // final lessonRepository = ref.watch(lessonRepositoryProvider);
  // return LessonListNotifier(lessonRepository);
  throw UnimplementedError('Dependencies must be provided');
});

/// Provider to get lessons by level
final lessonsByLevelProvider =
    FutureProvider.family<List<Lesson>, String>((ref, level) async {
  // TODO: Inject dependencies
  // final lessonRepository = ref.watch(lessonRepositoryProvider);
  // return lessonRepository.getLessonsByLevel(level);
  throw UnimplementedError('Dependencies must be provided');
});
