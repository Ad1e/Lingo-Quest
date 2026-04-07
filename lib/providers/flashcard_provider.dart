import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/domain/repositories/flashcard_repository.dart';
import 'package:language_learning_app/domain/usecases/get_flashcards_usecase.dart';
import 'package:language_learning_app/domain/usecases/study_flashcard_usecase.dart';

/// State for flashcard study session
class StudySessionState {
  final List<Flashcard> cards;
  final int currentIndex;
  final int totalCards;
  final bool isLoading;
  final String? error;
  final int xpEarned;
  final int cardsStudied;

  StudySessionState({
    this.cards = const [],
    this.currentIndex = 0,
    this.totalCards = 0,
    this.isLoading = false,
    this.error,
    this.xpEarned = 0,
    this.cardsStudied = 0,
  });

  Flashcard? get currentCard =>
      currentIndex < cards.length ? cards[currentIndex] : null;

  bool get isComplete => currentIndex >= cards.length;

  StudySessionState copyWith({
    List<Flashcard>? cards,
    int? currentIndex,
    int? totalCards,
    bool? isLoading,
    String? error,
    int? xpEarned,
    int? cardsStudied,
  }) {
    return StudySessionState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCards: totalCards ?? this.totalCards,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      xpEarned: xpEarned ?? this.xpEarned,
      cardsStudied: cardsStudied ?? this.cardsStudied,
    );
  }
}

/// StateNotifier for managing flashcard study sessions
class StudySessionNotifier extends StateNotifier<StudySessionState> {
  final FlashcardRepository _flashcardRepository;
  final StudyFlashcardUseCase _studyFlashcardUseCase;
  final String _userId;

  StudySessionNotifier(
    this._flashcardRepository,
    this._studyFlashcardUseCase,
    this._userId,
  ) : super(StudySessionState());

  /// Load cards due for review from a deck
  Future<void> loadDueCards(String deckId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cards = await _flashcardRepository.getCardsDueForReview(deckId);
      state = state.copyWith(
        cards: cards,
        totalCards: cards.length,
        currentIndex: 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Study current card and apply SM-2 algorithm
  Future<void> studyCard(int rating, int duration) async {
    final card = state.currentCard;
    if (card == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final updatedCard = await _studyFlashcardUseCase(
        userId: _userId,
        card: card,
        rating: rating,
        duration: duration,
      );

      // Calculate XP for this card
      int xpGain = 10;
      switch (rating) {
        case 0:
          xpGain = 0;
        case 1:
          xpGain = 5;
        case 2:
          xpGain = 10;
        case 3:
          xpGain = 20;
      }
      xpGain += (duration ~/ 60000).clamp(0, 5); // Time bonus

      state = state.copyWith(
        xpEarned: state.xpEarned + xpGain,
        cardsStudied: state.cardsStudied + 1,
        isLoading: false,
      );

      // Move to next card
      nextCard();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Move to next card
  void nextCard() {
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
    );
  }

  /// Reset study session
  void reset() {
    state = StudySessionState();
  }
}

/// State for deck list
class DeckListState {
  final List<FlashcardDeck> decks;
  final bool isLoading;
  final String? error;

  DeckListState({
    this.decks = const [],
    this.isLoading = false,
    this.error,
  });

  DeckListState copyWith({
    List<FlashcardDeck>? decks,
    bool? isLoading,
    String? error,
  }) {
    return DeckListState(
      decks: decks ?? this.decks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier for managing deck list
class DeckListNotifier extends StateNotifier<DeckListState> {
  final FlashcardRepository _flashcardRepository;
  final String _userId;

  DeckListNotifier(
    this._flashcardRepository,
    this._userId,
  ) : super(DeckListState()) {
    loadDecks();
  }

  /// Load user's decks
  Future<void> loadDecks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final decks = await _flashcardRepository.getDecksByUser(_userId);
      state = state.copyWith(
        decks: decks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create new deck
  Future<void> createDeck(FlashcardDeck deck) async {
    try {
      final deckId = await _flashcardRepository.createDeck(deck);
      final newDeck = deck.copyWith(id: deckId);
      state = state.copyWith(
        decks: [...state.decks, newDeck],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete deck
  Future<void> deleteDeck(String deckId) async {
    try {
      await _flashcardRepository.deleteDeck(deckId);
      state = state.copyWith(
        decks: state.decks.where((d) => d.id != deckId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Riverpod provider for study session (requires user ID parameter)
final studySessionProvider =
    StateNotifierProvider.family<StudySessionNotifier, StudySessionState, String>(
  (ref, userId) {
    // TODO: Inject dependencies from ref
    // final flashcardRepository = ref.watch(flashcardRepositoryProvider);
    // final studyFlashcardUseCase = ref.watch(studyFlashcardUseCaseProvider);
    // return StudySessionNotifier(flashcardRepository, studyFlashcardUseCase, userId);
    throw UnimplementedError('Dependencies must be provided');
  },
);

/// Riverpod provider for deck list (requires user ID parameter)
final deckListProvider =
    StateNotifierProvider.family<DeckListNotifier, DeckListState, String>(
  (ref, userId) {
    // TODO: Inject dependencies from ref
    // final flashcardRepository = ref.watch(flashcardRepositoryProvider);
    // return DeckListNotifier(flashcardRepository, userId);
    throw UnimplementedError('Dependencies must be provided');
  },
);

/// Provider to get current deck's cards
final currentDeckCardsProvider =
    FutureProvider.family<List<Flashcard>, String>((ref, deckId) async {
  // TODO: Inject dependencies
  // final flashcardRepository = ref.watch(flashcardRepositoryProvider);
  // return flashcardRepository.getFlashcardsByDeck(deckId);
  throw UnimplementedError('Dependencies must be provided');
});

/// Provider to get public decks for discovery
final publicDecksProvider = FutureProvider<List<FlashcardDeck>>((ref) async {
  // TODO: Inject dependencies
  // final flashcardRepository = ref.watch(flashcardRepositoryProvider);
  // return flashcardRepository.getPublicDecks();
  throw UnimplementedError('Dependencies must be provided');
});
