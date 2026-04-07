import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

@freezed
class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String id,
    required String front,
    required String back,
    required String audioUrl,
    required String exampleSentence,
    required String deckId,
    required DateTime nextReviewDate,
    required double easeFactor,
    required int interval,
    required int repetitions,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);
}
