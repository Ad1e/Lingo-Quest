import 'package:injectable/injectable.dart';
import 'package:my_app/lib/data/datasources/local/database_helper.dart';
import 'package:my_app/lib/data/datasources/local/flashcard_local_ds.dart';
import 'package:my_app/lib/data/datasources/remote/flashcard_remote_ds.dart';
import 'package:my_app/lib/domain/repositories/flashcard_repository.dart';

/// Implementation of FlashcardRepository with offline-first strategy
@Singleton(as: FlashcardRepository)
class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardLocalDataSource _localDataSource;
  final FlashcardRemoteDataSource _remoteDataSource;
  final DatabaseHelper _database;

  FlashcardRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._database,
  );

  @override
  Future<List<FlashcardDeck>> getDecksByUser(String userId) async {
    try {
      // First, return local decks immediately
      final localDecks = await _localDataSource.getDecksByUser(userId);
      
      // Sync from remote in background
      _syncDecksInBackground(userId);
      
      return _mapLocalDecksToDecks(localDecks);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FlashcardDeck?> getDeckById(String deckId) async {
    try {
      final localDeck = await _localDataSource.getDeckByIdIfExists(deckId);
      if (localDeck != null) {
        // Schedule background sync
        _syncDeckInBackground(deckId);
        return _mapLocalDeckToDeck(localDeck);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Flashcard>> getFlashcardsByDeck(String deckId) async {
    try {
      // Return local immediately
      final localCards = await _localDataSource.getFlashcardsByDeck(deckId);
      
      // Sync in background
      _syncFlashcardsInBackground(deckId);
      
      return _mapLocalFlashcardsToFlashcards(localCards);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Flashcard>> getCardsDueForReview(String deckId) async {
    try {
      final localCards = await _localDataSource.getCardsDueForReview(deckId);
      return _mapLocalFlashcardsToFlashcards(localCards);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveFlashcard(Flashcard flashcard) async {
    try {
      // Save locally first
      final localCard = _mapFlashcardToLocal(flashcard);
      await _localDataSource.saveFlashcard(localCard);
      
      // Sync to remote in background
      _syncFlashcardToRemoteInBackground(flashcard);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    try {
      // Save all locally first
      final localCards = flashcards.map(_mapFlashcardToLocal).toList();
      await _localDataSource.saveFlashcards(localCards);
      
      // Sync to remote in background
      _syncFlashcardsToRemoteInBackground(flashcards);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteFlashcard(String flashcardId) async {
    try {
      // Delete locally first
      await _localDataSource.deleteFlashcard(flashcardId);
      
      // Sync deletion to remote in background
      _syncDeletionInBackground(flashcardId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> createDeck(FlashcardDeck deck) async {
    try {
      // Create locally with generated ID
      final deckId = _generateDeckId();
      final newDeck = deck.copyWith(id: deckId);
      final localDeck = _mapDeckToLocal(newDeck);
      
      await _localDataSource.saveDeck(localDeck);
      
      // Sync to remote in background
      _syncDeckToRemoteInBackground(newDeck);
      
      return deckId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateDeck(FlashcardDeck deck) async {
    try {
      // Update locally
      final localDeck = _mapDeckToLocal(deck);
      await _localDataSource.saveDeck(localDeck);
      
      // Sync to remote in background
      _syncDeckToRemoteInBackground(deck);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    try {
      // Delete locally
      await _localDataSource.deleteDeck(deckId);
      
      // Sync deletion in background
      _syncDeckDeletionInBackground(deckId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncFlashcards() async {
    try {
      // Get unsynced cards and decks
      final unsyncedCards = await _localDataSource.getUnsyncedFlashcards();
      final unsyncedDecks = await _localDataSource.getUnsyncedDecks();
      
      // Sync all
      if (unsyncedCards.isNotEmpty) {
        await _remoteDataSource.syncFlashcards(
          unsyncedCards.map(_mapLocalFlashcardToRemote).toList(),
        );
      }
      
      if (unsyncedDecks.isNotEmpty) {
        for (final deck in unsyncedDecks) {
          await _remoteDataSource.updateDeck(
            _mapLocalDeckRemote(deck),
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<Flashcard>> watchFlashcards(String deckId) {
    return _remoteDataSource.watchFlashcards(deckId).map(
      (remoteCards) =>
          remoteCards.map((rc) => _mapRemoteFlashcardToFlashcard(rc)).toList(),
    );
  }

  @override
  Future<List<FlashcardDeck>> getPublicDecks() async {
    try {
      final remoteDecks = await _remoteDataSource.getPublicDecks();
      return remoteDecks.map(_mapRemoteDeckToDeck).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<FlashcardDeck>> searchDecks(String query) async {
    try {
      final remoteDecks = await _remoteDataSource.searchDecks(query);
      return remoteDecks.map(_mapRemoteDeckToDeck).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============ Background Sync Methods ============

  void _syncDecksInBackground(String userId) {
    _remoteDataSource.getPublicDecks().then((remoteDecks) {
      for (final deck in remoteDecks) {
        final localDeck = _mapRemoteDeckToLocal(deck);
        _localDataSource.saveDeck(localDeck);
      }
    }).catchError((_) {
      // Silently fail on background sync
    });
  }

  void _syncDeckInBackground(String deckId) {
    _remoteDataSource.getDeckDetails(deckId).then((remoteDeck) {
      if (remoteDeck != null) {
        final localDeck = _mapRemoteDeckToLocal(remoteDeck);
        _localDataSource.saveDeck(localDeck);
      }
    }).catchError((_) {});
  }

  void _syncFlashcardsInBackground(String deckId) {
    _remoteDataSource.watchFlashcards(deckId).listen(
      (remoteCards) async {
        for (final card in remoteCards) {
          final localCard = _mapRemoteFlashcardToLocal(card);
          await _localDataSource.saveFlashcard(localCard);
        }
      },
      onError: (_) {
        // Silently fail
      },
    );
  }

  void _syncFlashcardToRemoteInBackground(Flashcard flashcard) {
    _remoteDataSource
        .syncFlashcards([_mapFlashcardToRemote(flashcard)])
        .catchError((_) {});
  }

  void _syncFlashcardsToRemoteInBackground(List<Flashcard> flashcards) {
    _remoteDataSource
        .syncFlashcards(flashcards.map(_mapFlashcardToRemote).toList())
        .catchError((_) {});
  }

  void _syncDeletionInBackground(String flashcardId) {
    // Mark as deleted in local sync table, attempt remote deletion
    Future.microtask(() async {
      try {
        // Remote deletion logic here if API provides it
      } catch (_) {}
    });
  }

  void _syncDeckToRemoteInBackground(FlashcardDeck deck) {
    _remoteDataSource
        .updateDeck(_mapDeckToRemote(deck))
        .catchError((_) {});
  }

  void _syncDeckDeletionInBackground(String deckId) {
    _remoteDataSource.deleteDeck(deckId).catchError((_) {});
  }

  // ============ Mapping Methods ============

  FlashcardDeck _mapLocalDeckToDeck(DeckLocal localDeck) {
    return FlashcardDeck(
      id: localDeck.id,
      userId: localDeck.userId,
      name: localDeck.name,
      description: localDeck.description,
      language: localDeck.language,
      targetLanguage: localDeck.targetLanguage,
      cardCount: localDeck.cardCount,
      createdAt: localDeck.createdAt,
      lastStudiedAt: localDeck.lastStudiedAt,
      isPublic: localDeck.isPublic,
    );
  }

  List<FlashcardDeck> _mapLocalDecksToDecks(List<DeckLocal> localDecks) {
    return localDecks.map(_mapLocalDeckToDeck).toList();
  }

  Flashcard _mapLocalFlashcardToFlashcard(FlashcardLocal local) {
    return Flashcard(
      id: local.id,
      front: local.front,
      back: local.back,
      audioUrl: local.audioUrl,
      exampleSentence: local.exampleSentence,
      deckId: local.deckId,
      nextReviewDate: local.nextReviewDate,
      easeFactor: local.easeFactor,
      interval: local.interval,
      repetitions: local.repetitions,
      createdAt: local.createdAt,
      lastReviewedAt: local.lastReviewedAt,
    );
  }

  List<Flashcard> _mapLocalFlashcardsToFlashcards(
      List<FlashcardLocal> localCards) {
    return localCards.map(_mapLocalFlashcardToFlashcard).toList();
  }

  FlashcardLocal _mapFlashcardToLocal(Flashcard flashcard) {
    return FlashcardLocal(
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
      lastReviewedAt: flashcard.lastReviewedAt,
      isSynced: false,
    );
  }

  DeckLocal _mapDeckToLocal(FlashcardDeck deck) {
    return DeckLocal(
      id: deck.id,
      userId: deck.userId,
      name: deck.name,
      description: deck.description,
      language: deck.language,
      targetLanguage: deck.targetLanguage,
      cardCount: deck.cardCount,
      createdAt: deck.createdAt,
      lastStudiedAt: deck.lastStudiedAt,
      isPublic: deck.isPublic,
      isSynced: false,
    );
  }

  FlashcardRemote _mapFlashcardToRemote(Flashcard flashcard) {
    return FlashcardRemote(
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
    );
  }

  FlashcardLocal _mapRemoteFlashcardToLocal(FlashcardRemote remote) {
    return FlashcardLocal(
      id: remote.id,
      front: remote.front,
      back: remote.back,
      audioUrl: remote.audioUrl,
      exampleSentence: remote.exampleSentence,
      deckId: remote.deckId,
      nextReviewDate: remote.nextReviewDate,
      easeFactor: remote.easeFactor,
      interval: remote.interval,
      repetitions: remote.repetitions,
      createdAt: DateTime.now(),
      lastReviewedAt: DateTime.now(),
      isSynced: true,
    );
  }

  Flashcard _mapRemoteFlashcardToFlashcard(FlashcardRemote remote) {
    return Flashcard(
      id: remote.id,
      front: remote.front,
      back: remote.back,
      audioUrl: remote.audioUrl,
      exampleSentence: remote.exampleSentence,
      deckId: remote.deckId,
      nextReviewDate: remote.nextReviewDate,
      easeFactor: remote.easeFactor,
      interval: remote.interval,
      repetitions: remote.repetitions,
      createdAt: DateTime.now(),
      lastReviewedAt: DateTime.now(),
    );
  }

  DeckRemote _mapDeckToRemote(FlashcardDeck deck) {
    return DeckRemote(
      id: deck.id,
      userId: deck.userId,
      name: deck.name,
      description: deck.description,
      language: deck.language,
      targetLanguage: deck.targetLanguage,
      cardCount: deck.cardCount,
      createdAt: deck.createdAt,
      lastStudiedAt: deck.lastStudiedAt,
      isPublic: deck.isPublic,
    );
  }

  DeckLocal _mapRemoteDeckToLocal(DeckRemote remote) {
    return DeckLocal(
      id: remote.id,
      userId: remote.userId,
      name: remote.name,
      description: remote.description,
      language: remote.language,
      targetLanguage: remote.targetLanguage,
      cardCount: remote.cardCount,
      createdAt: remote.createdAt,
      lastStudiedAt: remote.lastStudiedAt,
      isPublic: remote.isPublic,
      isSynced: true,
    );
  }

  FlashcardDeck _mapRemoteDeckToDeck(DeckRemote remote) {
    return FlashcardDeck(
      id: remote.id,
      userId: remote.userId,
      name: remote.name,
      description: remote.description,
      language: remote.language,
      targetLanguage: remote.targetLanguage,
      cardCount: remote.cardCount,
      createdAt: remote.createdAt,
      lastStudiedAt: remote.lastStudiedAt,
      isPublic: remote.isPublic,
    );
  }

  DeckRemote _mapLocalDeckRemote(DeckLocal local) {
    return DeckRemote(
      id: local.id,
      userId: local.userId,
      name: local.name,
      description: local.description,
      language: local.language,
      targetLanguage: local.targetLanguage,
      cardCount: local.cardCount,
      createdAt: local.createdAt,
      lastStudiedAt: local.lastStudiedAt,
      isPublic: local.isPublic,
    );
  }

  String _generateDeckId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<DeckRemote?> _getDeckDetailsHelper(String deckId) async {
    return await _remoteDataSource.getDeckDetails(deckId);
  }
}
