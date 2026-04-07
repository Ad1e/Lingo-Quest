import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

@freezed
class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String id,
    required String deckId,
    required String frontText,
    required String backText,
    required String language,
    required String targetLanguage,
    String? audioUrl,
    String? imageUrl,
    String? exampleSentence,
    String? explanation,
    List<String>? tags,
    int interval = 0,
    double easeFactor = 2.5,
    int repetitions = 0,
    required DateTime nextReviewDate,
    required DateTime createdAt,
    required DateTime lastReviewedAt,
    bool isBookmarked = false,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);
}

@freezed
class FlashcardDeck with _$FlashcardDeck {
  const factory FlashcardDeck({
    required String id,
    required String userId,
    required String name,
    required String description,
    required String language,
    required String targetLanguage,
    int cardCount = 0,
    int newCards = 0,
    int reviewCards = 0,
    double masteryPercentage = 0,
    required DateTime createdAt,
    DateTime? lastStudiedAt,
    bool isPublic = false,
  }) = _FlashcardDeck;

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) =>
      _$FlashcardDeckFromJson(json);
}