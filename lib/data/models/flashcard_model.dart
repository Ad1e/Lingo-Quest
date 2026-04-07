import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

@freezed
class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String id,
    required String front,
    required String back,
    String? audioUrl,
    String? exampleSentence,
    required String deckId,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int interval,
    required int repetitions,
    required DateTime createdAt,
    required DateTime lastReviewedAt,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);
}
