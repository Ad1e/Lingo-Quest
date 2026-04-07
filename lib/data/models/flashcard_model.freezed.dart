// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlashcardModel _$FlashcardModelFromJson(Map<String, dynamic> json) {
  return _FlashcardModel.fromJson(json);
}

/// @nodoc
mixin _$FlashcardModel {
  String get id => throw _privateConstructorUsedError;
  String get front => throw _privateConstructorUsedError;
  String get back => throw _privateConstructorUsedError;
  String get audioUrl => throw _privateConstructorUsedError;
  String get exampleSentence => throw _privateConstructorUsedError;
  String get deckId => throw _privateConstructorUsedError;
  DateTime get nextReviewDate => throw _privateConstructorUsedError;
  double get easeFactor => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  int get repetitions => throw _privateConstructorUsedError;

  /// Serializes this FlashcardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardModelCopyWith<FlashcardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardModelCopyWith<$Res> {
  factory $FlashcardModelCopyWith(
    FlashcardModel value,
    $Res Function(FlashcardModel) then,
  ) = _$FlashcardModelCopyWithImpl<$Res, FlashcardModel>;
  @useResult
  $Res call({
    String id,
    String front,
    String back,
    String audioUrl,
    String exampleSentence,
    String deckId,
    DateTime nextReviewDate,
    double easeFactor,
    int interval,
    int repetitions,
  });
}

/// @nodoc
class _$FlashcardModelCopyWithImpl<$Res, $Val extends FlashcardModel>
    implements $FlashcardModelCopyWith<$Res> {
  _$FlashcardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? front = null,
    Object? back = null,
    Object? audioUrl = null,
    Object? exampleSentence = null,
    Object? deckId = null,
    Object? nextReviewDate = null,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetitions = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            front: null == front
                ? _value.front
                : front // ignore: cast_nullable_to_non_nullable
                      as String,
            back: null == back
                ? _value.back
                : back // ignore: cast_nullable_to_non_nullable
                      as String,
            audioUrl: null == audioUrl
                ? _value.audioUrl
                : audioUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            exampleSentence: null == exampleSentence
                ? _value.exampleSentence
                : exampleSentence // ignore: cast_nullable_to_non_nullable
                      as String,
            deckId: null == deckId
                ? _value.deckId
                : deckId // ignore: cast_nullable_to_non_nullable
                      as String,
            nextReviewDate: null == nextReviewDate
                ? _value.nextReviewDate
                : nextReviewDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            easeFactor: null == easeFactor
                ? _value.easeFactor
                : easeFactor // ignore: cast_nullable_to_non_nullable
                      as double,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int,
            repetitions: null == repetitions
                ? _value.repetitions
                : repetitions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlashcardModelImplCopyWith<$Res>
    implements $FlashcardModelCopyWith<$Res> {
  factory _$$FlashcardModelImplCopyWith(
    _$FlashcardModelImpl value,
    $Res Function(_$FlashcardModelImpl) then,
  ) = __$$FlashcardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String front,
    String back,
    String audioUrl,
    String exampleSentence,
    String deckId,
    DateTime nextReviewDate,
    double easeFactor,
    int interval,
    int repetitions,
  });
}

/// @nodoc
class __$$FlashcardModelImplCopyWithImpl<$Res>
    extends _$FlashcardModelCopyWithImpl<$Res, _$FlashcardModelImpl>
    implements _$$FlashcardModelImplCopyWith<$Res> {
  __$$FlashcardModelImplCopyWithImpl(
    _$FlashcardModelImpl _value,
    $Res Function(_$FlashcardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? front = null,
    Object? back = null,
    Object? audioUrl = null,
    Object? exampleSentence = null,
    Object? deckId = null,
    Object? nextReviewDate = null,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetitions = null,
  }) {
    return _then(
      _$FlashcardModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        front: null == front
            ? _value.front
            : front // ignore: cast_nullable_to_non_nullable
                  as String,
        back: null == back
            ? _value.back
            : back // ignore: cast_nullable_to_non_nullable
                  as String,
        audioUrl: null == audioUrl
            ? _value.audioUrl
            : audioUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        exampleSentence: null == exampleSentence
            ? _value.exampleSentence
            : exampleSentence // ignore: cast_nullable_to_non_nullable
                  as String,
        deckId: null == deckId
            ? _value.deckId
            : deckId // ignore: cast_nullable_to_non_nullable
                  as String,
        nextReviewDate: null == nextReviewDate
            ? _value.nextReviewDate
            : nextReviewDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        easeFactor: null == easeFactor
            ? _value.easeFactor
            : easeFactor // ignore: cast_nullable_to_non_nullable
                  as double,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int,
        repetitions: null == repetitions
            ? _value.repetitions
            : repetitions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardModelImpl implements _FlashcardModel {
  const _$FlashcardModelImpl({
    required this.id,
    required this.front,
    required this.back,
    required this.audioUrl,
    required this.exampleSentence,
    required this.deckId,
    required this.nextReviewDate,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
  });

  factory _$FlashcardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardModelImplFromJson(json);

  @override
  final String id;
  @override
  final String front;
  @override
  final String back;
  @override
  final String audioUrl;
  @override
  final String exampleSentence;
  @override
  final String deckId;
  @override
  final DateTime nextReviewDate;
  @override
  final double easeFactor;
  @override
  final int interval;
  @override
  final int repetitions;

  @override
  String toString() {
    return 'FlashcardModel(id: $id, front: $front, back: $back, audioUrl: $audioUrl, exampleSentence: $exampleSentence, deckId: $deckId, nextReviewDate: $nextReviewDate, easeFactor: $easeFactor, interval: $interval, repetitions: $repetitions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.exampleSentence, exampleSentence) ||
                other.exampleSentence == exampleSentence) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.easeFactor, easeFactor) ||
                other.easeFactor == easeFactor) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    front,
    back,
    audioUrl,
    exampleSentence,
    deckId,
    nextReviewDate,
    easeFactor,
    interval,
    repetitions,
  );

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      __$$FlashcardModelImplCopyWithImpl<_$FlashcardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardModelImplToJson(this);
  }
}

abstract class _FlashcardModel implements FlashcardModel {
  const factory _FlashcardModel({
    required final String id,
    required final String front,
    required final String back,
    required final String audioUrl,
    required final String exampleSentence,
    required final String deckId,
    required final DateTime nextReviewDate,
    required final double easeFactor,
    required final int interval,
    required final int repetitions,
  }) = _$FlashcardModelImpl;

  factory _FlashcardModel.fromJson(Map<String, dynamic> json) =
      _$FlashcardModelImpl.fromJson;

  @override
  String get id;
  @override
  String get front;
  @override
  String get back;
  @override
  String get audioUrl;
  @override
  String get exampleSentence;
  @override
  String get deckId;
  @override
  DateTime get nextReviewDate;
  @override
  double get easeFactor;
  @override
  int get interval;
  @override
  int get repetitions;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
