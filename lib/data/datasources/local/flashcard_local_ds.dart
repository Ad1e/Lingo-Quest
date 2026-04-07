import 'package:injectable/injectable.dart';

/// Abstract interface for local flashcard data source
abstract class FlashcardLocalDataSource {
  /// Get all flashcards in a deck
  Future<List<FlashcardLocal>> getFlashcardsByDeck(String deckId);

  /// Get single flashcard
  Future<FlashcardLocal?> getFlashcardById(String id);

  /// Get cards due for review
  Future<List<FlashcardLocal>> getCardsDueForReview(String deckId);

  /// Save flashcard
  Future<void> saveFlashcard(FlashcardLocal flashcard);

  /// Save multiple flashcards
  Future<void> saveFlashcards(List<FlashcardLocal> flashcards);

  /// Delete flashcard
  Future<void> deleteFlashcard(String id);

  /// Get all decks for user
  Future<List<DeckLocal>> getDecksByUser(String userId);

  /// Get deck by ID
  Future<DeckLocal?> getDeckById(String id);

  /// Save deck
  Future<void> saveDeck(DeckLocal deck);

  /// Delete deck and all its cards
  Future<void> deleteDeck(String deckId);

  /// Update flashcard's sync status
  Future<void> updateFlashcardSyncStatus(String id, bool synced);

  /// Get unsynced flashcards
  Future<List<FlashcardLocal>> getUnsyncedFlashcards();

  /// Get unsynced decks
  Future<List<DeckLocal>> getUnsyncedDecks();
}

/// Local model for Flashcard
class FlashcardLocal {
  final String id;
  final String front;
  final String back;
  final String? audioUrl;
  final String? exampleSentence;
  final String deckId;
  final DateTime nextReviewDate;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime createdAt;
  final DateTime lastReviewedAt;
  final bool isSynced;

  FlashcardLocal({
    required this.id,
    required this.front,
    required this.back,
    this.audioUrl,
    this.exampleSentence,
    required this.deckId,
    required this.nextReviewDate,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    required this.createdAt,
    required this.lastReviewedAt,
    this.isSynced = false,
  });

  FlashcardLocal copyWith({
    String? id,
    String? front,
    String? back,
    String? audioUrl,
    String? exampleSentence,
    String? deckId,
    DateTime? nextReviewDate,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
    bool? isSynced,
  }) {
    return FlashcardLocal(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      audioUrl: audioUrl ?? this.audioUrl,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      deckId: deckId ?? this.deckId,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

/// Local model for Deck
class DeckLocal {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String language;
  final String targetLanguage;
  final int cardCount;
  final DateTime createdAt;
  final DateTime? lastStudiedAt;
  final bool isPublic;
  final bool isSynced;

  DeckLocal({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.language,
    required this.targetLanguage,
    this.cardCount = 0,
    required this.createdAt,
    this.lastStudiedAt,
    this.isPublic = false,
    this.isSynced = false,
  });

  DeckLocal copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? language,
    String? targetLanguage,
    int? cardCount,
    DateTime? createdAt,
    DateTime? lastStudiedAt,
    bool? isPublic,
    bool? isSynced,
  }) {
    return DeckLocal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      language: language ?? this.language,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      isPublic: isPublic ?? this.isPublic,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

/// Implementation of FlashcardLocalDataSource
@Singleton(as: FlashcardLocalDataSource)
class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  // TODO: Inject AppDatabase when Drift is fully configured
  // final AppDatabase database;
  // FlashcardLocalDataSourceImpl(this.database);

  @override
  Future<List<FlashcardLocal>> getFlashcardsByDeck(String deckId) async {
    // TODO: Implement using Drift
    return [];
  }

  @override
  Future<FlashcardLocal?> getFlashcardById(String id) async {
    // TODO: Implement using Drift
    return null;
  }

  @override
  Future<List<FlashcardLocal>> getCardsDueForReview(String deckId) async {
    // TODO: Implement using Drift
    return [];
  }

  @override
  Future<void> saveFlashcard(FlashcardLocal flashcard) async {
    // TODO: Implement using Drift
  }

  @override
  Future<void> saveFlashcards(List<FlashcardLocal> flashcards) async {
    // TODO: Implement using Drift
  }

  @override
  Future<void> deleteFlashcard(String id) async {
    // TODO: Implement using Drift
  }

  @override
  Future<List<DeckLocal>> getDecksByUser(String userId) async {
    // TODO: Implement using Drift
    return [];
  }

  @override
  Future<DeckLocal?> getDeckById(String id) async {
    // TODO: Implement using Drift
    return null;
  }

  @override
  Future<void> saveDeck(DeckLocal deck) async {
    // TODO: Implement using Drift
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    // TODO: Implement using Drift
  }

  @override
  Future<void> updateFlashcardSyncStatus(String id, bool synced) async {
    // TODO: Implement using Drift
  }

  @override
  Future<List<FlashcardLocal>> getUnsyncedFlashcards() async {
    // TODO: Implement using Drift
    return [];
  }

  @override
  Future<List<DeckLocal>> getUnsyncedDecks() async {
    // TODO: Implement using Drift
    return [];
  }
}
