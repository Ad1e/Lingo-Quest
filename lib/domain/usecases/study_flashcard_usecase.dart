import 'package:language_learning_app/data/models/flashcard_model.dart';
import 'package:language_learning_app/domain/repositories/flashcard_repository.dart';
import 'package:language_learning_app/domain/repositories/progress_repository.dart';
import 'package:language_learning_app/utils/spaced_repetition_algorithm.dart';

/// Use case for studying a flashcard with SM-2 algorithm
abstract class StudyFlashcardUseCase {
  /// Study a flashcard and apply SM-2 algorithm
  /// 
  /// Parameters:
  ///   - userId: Current user ID
  ///   - card: The flashcard being studied
  ///   - rating: Quality of response (0=again, 1=hard, 2=good, 3=easy)
  ///   - duration: Time spent on this card in milliseconds
  /// 
  /// Returns: Updated flashcard with new SM-2 parameters
  Future<Flashcard> call({
    required String userId,
    required Flashcard card,
    required int rating,
    required int duration,
  });
}

/// Implementation of StudyFlashcardUseCase
class StudyFlashcardUseCaseImpl implements StudyFlashcardUseCase {
  final FlashcardRepository _flashcardRepository;
  final ProgressRepository _progressRepository;

  StudyFlashcardUseCaseImpl(
    this._flashcardRepository,
    this._progressRepository,
  );

  @override
  Future<Flashcard> call({
    required String userId,
    required Flashcard card,
    required int rating,
    required int duration,
  }) async {
    // Step 1: Apply SM-2 algorithm to get updated card parameters
    // Convert Flashcard to FlashcardModel for SM-2 calculation
    final flashcardModel = _mapToFlashcardModel(card);
    final updatedModel = calculateNextReview(flashcardModel, rating);
    
    // Step 2: Save updated flashcard to repository
    final updatedCard = _mapFromFlashcardModel(updatedModel);
    await _flashcardRepository.saveFlashcard(updatedCard);
    
    // Step 3: Record study session and update progress
    final xpEarned = _calculateXP(rating, duration);
    
    final studySession = StudySession(
      userId: userId,
      flashcardId: card.id,
      deckId: card.deckId,
      quality: rating,
      reviewDuration: duration,
      reviewDate: DateTime.now(),
      xpEarned: xpEarned,
    );
    
    await _progressRepository.addStudySession(studySession);
    await _progressRepository.updateXp(userId, xpEarned);
    
    // Step 4: Check for streak updates
    final dailyStreak = await _progressRepository.checkAndUpdateStreak(userId);
    
    return updatedCard;
  }

  /// Maps domain Flashcard to FlashcardModel for SM-2 algorithm
  FlashcardModel _mapToFlashcardModel(Flashcard flashcard) {
    return FlashcardModel(
      id: flashcard.id,
      front: flashcard.front,
      back: flashcard.back,
      audioUrl: flashcard.audioUrl,
      exampleSentence: flashcard.exampleSentence,
      deckId: flashcard.deckId,
      nextReviewDate: flashcard.nextReviewDate,
      easeFactor: flashcard.easeFactor,
      interval: flashcard.interval,
      repetitions: flashcard.repetitions,
      createdAt: flashcard.createdAt,
      lastReviewedAt: DateTime.now(),
    );
  }

  /// Maps FlashcardModel back to domain Flashcard
  Flashcard _mapFromFlashcardModel(FlashcardModel model) {
    return Flashcard(
      id: model.id,
      front: model.front,
      back: model.back,
      audioUrl: model.audioUrl,
      exampleSentence: model.exampleSentence,
      deckId: model.deckId,
      nextReviewDate: model.nextReviewDate,
      easeFactor: model.easeFactor,
      interval: model.interval,
      repetitions: model.repetitions,
      createdAt: model.createdAt,
      lastReviewedAt: DateTime.now(),
    );
  }

  /// Calculate XP earned based on rating and duration
  /// 
  /// XP formula:
  /// - Base: 10 XP per card studied
  /// - Quality bonus: again=0, hard=5, good=10, easy=20
  /// - Time bonus: up to 5 XP based on study duration
  int _calculateXP(int rating, int duration) {
    int baseXP = 10;
    
    // Quality bonus
    int qualityBonus = switch (rating) {
      0 => 0,    // again
      1 => 5,    // hard
      2 => 10,   // good
      3 => 20,   // easy
      _ => 0,
    };
    
    // Time bonus (encourage longer study sessions)
    // Max 5 XP for 5 minutes (300,000 ms) or more
    int timeBonus = (duration ~/ 60000).clamp(0, 5); // ms to minutes
    
    return baseXP + qualityBonus + timeBonus;
  }
}
