import 'package:injectable/injectable.dart';

/// Abstract repository interface for flashcard operations
abstract class FlashcardRepository {
  /// Get all decks for a user
  Future<List<FlashcardDeck>> getDecksByUser(String userId);

  /// Get deck by ID
  Future<FlashcardDeck?> getDeckById(String deckId);

  /// Get all flashcards in a deck
  Future<List<Flashcard>> getFlashcardsByDeck(String deckId);

  /// Get cards due for review
  Future<List<Flashcard>> getCardsDueForReview(String deckId);

  /// Save a flashcard
  Future<void> saveFlashcard(Flashcard flashcard);

  /// Save multiple flashcards
  Future<void> saveFlashcards(List<Flashcard> flashcards);

  /// Delete flashcard
  Future<void> deleteFlashcard(String flashcardId);

  /// Create new deck
  Future<String> createDeck(FlashcardDeck deck);

  /// Update deck
  Future<void> updateDeck(FlashcardDeck deck);

  /// Delete deck
  Future<void> deleteDeck(String deckId);

  /// Sync flashcards with cloud
  Future<void> syncFlashcards();

  /// Subscribe to deck updates
  Stream<List<Flashcard>> watchFlashcards(String deckId);

  /// Get public decks
  Future<List<FlashcardDeck>> getPublicDecks();

  /// Search public decks
  Future<List<FlashcardDeck>> searchDecks(String query);
}

/// Domain model for Flashcard
class Flashcard {
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

  Flashcard({
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
  });

  Flashcard copyWith({
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
  }) {
    return Flashcard(
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
    );
  }
}

/// Domain model for Deck
class FlashcardDeck {
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

  FlashcardDeck({
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
  });

  FlashcardDeck copyWith({
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
  }) {
    return FlashcardDeck(
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
    );
  }
}
