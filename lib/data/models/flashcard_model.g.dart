// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardModelImpl _$$FlashcardModelImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardModelImpl(
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

Map<String, dynamic> _$$FlashcardModelImplToJson(
  _$FlashcardModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'front': instance.front,
  'back': instance.back,
  'audioUrl': instance.audioUrl,
  'exampleSentence': instance.exampleSentence,
  'deckId': instance.deckId,
  'nextReviewDate': instance.nextReviewDate.toIso8601String(),
  'easeFactor': instance.easeFactor,
  'interval': instance.interval,
  'repetitions': instance.repetitions,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastReviewedAt': instance.lastReviewedAt.toIso8601String(),
};
