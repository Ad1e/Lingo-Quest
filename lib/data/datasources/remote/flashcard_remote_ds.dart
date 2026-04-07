import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

/// Abstract interface for remote flashcard data source
abstract class FlashcardRemoteDataSource {
  /// Sync flashcards with cloud
  Future<void> syncFlashcards(List<FlashcardRemote> flashcards);

  /// Get flashcards from cloud
  Future<List<FlashcardRemote>> getFlashcards(String userId);

  /// Get public decks
  Future<List<DeckRemote>> getPublicDecks();

  /// Search public decks
  Future<List<DeckRemote>> searchDecks(String query);

  /// Get deck details
  Future<DeckRemote?> getDeckDetails(String deckId);

  /// Create deck on cloud
  Future<String> createDeck(DeckRemote deck);

  /// Update deck on cloud
  Future<void> updateDeck(DeckRemote deck);

  /// Delete deck from cloud
  Future<void> deleteDeck(String deckId);

  /// Subscribe to deck updates
  Stream<List<FlashcardRemote>> watchFlashcards(String deckId);
}

/// Remote model for Flashcard
class FlashcardRemote {
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

  FlashcardRemote({
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'front': front,
    'back': back,
    'audioUrl': audioUrl,
    'exampleSentence': exampleSentence,
    'deckId': deckId,
    'nextReviewDate': nextReviewDate.toIso8601String(),
    'easeFactor': easeFactor,
    'interval': interval,
    'repetitions': repetitions,
    'createdAt': createdAt.toIso8601String(),
    'lastReviewedAt': lastReviewedAt.toIso8601String(),
  };

  factory FlashcardRemote.fromJson(Map<String, dynamic> json) => FlashcardRemote(
    id: json['id'] as String,
    front: json['front'] as String,
    back: json['back'] as String,
    audioUrl: json['audioUrl'] as String?,
    exampleSentence: json['exampleSentence'] as String?,
    deckId: json['deckId'] as String,
    nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
    easeFactor: (json['easeFactor'] as num).toDouble(),
    interval: (json['interval'] as num).toInt(),
    repetitions: (json['repetitions'] as num).toInt(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastReviewedAt: DateTime.parse(json['lastReviewedAt'] as String),
  );
}

/// Remote model for Deck
class DeckRemote {
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

  DeckRemote({
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'description': description,
    'language': language,
    'targetLanguage': targetLanguage,
    'cardCount': cardCount,
    'createdAt': createdAt.toIso8601String(),
    'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    'isPublic': isPublic,
  };

  factory DeckRemote.fromJson(Map<String, dynamic> json) => DeckRemote(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    language: json['language'] as String,
    targetLanguage: json['targetLanguage'] as String,
    cardCount: json['cardCount'] as int? ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastStudiedAt: json['lastStudiedAt'] != null
        ? DateTime.parse(json['lastStudiedAt'] as String)
        : null,
    isPublic: json['isPublic'] as bool? ?? false,
  );
}

/// Implementation of FlashcardRemoteDataSource
@Singleton(as: FlashcardRemoteDataSource)
class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  final FirebaseFirestore _firestore;

  FlashcardRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> syncFlashcards(List<FlashcardRemote> flashcards) async {
    // TODO: Implement batch sync to Firestore
  }

  @override
  Future<List<FlashcardRemote>> getFlashcards(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('flashcards')
          .get();

      return snapshot.docs
          .map((doc) => FlashcardRemote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch flashcards: $e');
    }
  }

  @override
  Future<List<DeckRemote>> getPublicDecks() async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('isPublic', isEqualTo: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => DeckRemote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch public decks: $e');
    }
  }

  @override
  Future<List<DeckRemote>> searchDecks(String query) async {
    try {
      final snapshot = await _firestore
          .collection('decks')
          .where('isPublic', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => DeckRemote.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search decks: $e');
    }
  }

  @override
  Future<DeckRemote?> getDeckDetails(String deckId) async {
    try {
      final doc = await _firestore.collection('decks').doc(deckId).get();
      if (!doc.exists) return null;
      return DeckRemote.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch deck details: $e');
    }
  }

  @override
  Future<String> createDeck(DeckRemote deck) async {
    try {
      final docRef = await _firestore.collection('decks').add(deck.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create deck: $e');
    }
  }

  @override
  Future<void> updateDeck(DeckRemote deck) async {
    try {
      await _firestore.collection('decks').doc(deck.id).update(deck.toJson());
    } catch (e) {
      throw Exception('Failed to update deck: $e');
    }
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    try {
      await _firestore.collection('decks').doc(deckId).delete();
    } catch (e) {
      throw Exception('Failed to delete deck: $e');
    }
  }

  @override
  Stream<List<FlashcardRemote>> watchFlashcards(String deckId) {
    return _firestore
        .collectionGroup('flashcards')
        .where('deckId', isEqualTo: deckId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlashcardRemote.fromJson(doc.data()))
            .toList());
  }
}
