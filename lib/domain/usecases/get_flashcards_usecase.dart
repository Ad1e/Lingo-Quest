import 'package:language_learning_app/domain/repositories/flashcard_repository.dart';
import 'package:language_learning_app/data/models/flashcard_model.dart';

/// Use case for fetching flashcards from a deck
abstract class GetFlashcardsUseCase {
  Future<List<Flashcard>> call({
    required String deckId,
    bool onlyDue,
  });
}

/// Implementation of GetFlashcardsUseCase
class GetFlashcardsUseCaseImpl implements GetFlashcardsUseCase {
  final FlashcardRepository _flashcardRepository;

  GetFlashcardsUseCaseImpl(this._flashcardRepository);

  @override
  Future<List<Flashcard>> call({
    required String deckId,
    bool onlyDue = false,
  }) async {
    if (onlyDue) {
      return await _flashcardRepository.getCardsDueForReview(deckId);
    }
    return await _flashcardRepository.getFlashcardsByDeck(deckId);
  }
}
