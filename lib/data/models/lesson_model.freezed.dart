// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) {
  return _LessonModel.fromJson(json);
}

/// @nodoc
mixin _$LessonModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  String get grammarExplanation => throw _privateConstructorUsedError;
  List<String> get vocabularyIds => throw _privateConstructorUsedError;
  List<String> get exerciseIds => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this LessonModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonModelCopyWith<LessonModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonModelCopyWith<$Res> {
  factory $LessonModelCopyWith(
    LessonModel value,
    $Res Function(LessonModel) then,
  ) = _$LessonModelCopyWithImpl<$Res, LessonModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String level,
    String grammarExplanation,
    List<String> vocabularyIds,
    List<String> exerciseIds,
    bool isCompleted,
  });
}

/// @nodoc
class _$LessonModelCopyWithImpl<$Res, $Val extends LessonModel>
    implements $LessonModelCopyWith<$Res> {
  _$LessonModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? level = null,
    Object? grammarExplanation = null,
    Object? vocabularyIds = null,
    Object? exerciseIds = null,
    Object? isCompleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            grammarExplanation: null == grammarExplanation
                ? _value.grammarExplanation
                : grammarExplanation // ignore: cast_nullable_to_non_nullable
                      as String,
            vocabularyIds: null == vocabularyIds
                ? _value.vocabularyIds
                : vocabularyIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            exerciseIds: null == exerciseIds
                ? _value.exerciseIds
                : exerciseIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonModelImplCopyWith<$Res>
    implements $LessonModelCopyWith<$Res> {
  factory _$$LessonModelImplCopyWith(
    _$LessonModelImpl value,
    $Res Function(_$LessonModelImpl) then,
  ) = __$$LessonModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String level,
    String grammarExplanation,
    List<String> vocabularyIds,
    List<String> exerciseIds,
    bool isCompleted,
  });
}

/// @nodoc
class __$$LessonModelImplCopyWithImpl<$Res>
    extends _$LessonModelCopyWithImpl<$Res, _$LessonModelImpl>
    implements _$$LessonModelImplCopyWith<$Res> {
  __$$LessonModelImplCopyWithImpl(
    _$LessonModelImpl _value,
    $Res Function(_$LessonModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? level = null,
    Object? grammarExplanation = null,
    Object? vocabularyIds = null,
    Object? exerciseIds = null,
    Object? isCompleted = null,
  }) {
    return _then(
      _$LessonModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        grammarExplanation: null == grammarExplanation
            ? _value.grammarExplanation
            : grammarExplanation // ignore: cast_nullable_to_non_nullable
                  as String,
        vocabularyIds: null == vocabularyIds
            ? _value._vocabularyIds
            : vocabularyIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        exerciseIds: null == exerciseIds
            ? _value._exerciseIds
            : exerciseIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonModelImpl implements _LessonModel {
  const _$LessonModelImpl({
    required this.id,
    required this.title,
    required this.level,
    required this.grammarExplanation,
    required final List<String> vocabularyIds,
    required final List<String> exerciseIds,
    required this.isCompleted,
  }) : _vocabularyIds = vocabularyIds,
       _exerciseIds = exerciseIds;

  factory _$LessonModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String level;
  @override
  final String grammarExplanation;
  final List<String> _vocabularyIds;
  @override
  List<String> get vocabularyIds {
    if (_vocabularyIds is EqualUnmodifiableListView) return _vocabularyIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vocabularyIds);
  }

  final List<String> _exerciseIds;
  @override
  List<String> get exerciseIds {
    if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseIds);
  }

  @override
  final bool isCompleted;

  @override
  String toString() {
    return 'LessonModel(id: $id, title: $title, level: $level, grammarExplanation: $grammarExplanation, vocabularyIds: $vocabularyIds, exerciseIds: $exerciseIds, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.grammarExplanation, grammarExplanation) ||
                other.grammarExplanation == grammarExplanation) &&
            const DeepCollectionEquality().equals(
              other._vocabularyIds,
              _vocabularyIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._exerciseIds,
              _exerciseIds,
            ) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    level,
    grammarExplanation,
    const DeepCollectionEquality().hash(_vocabularyIds),
    const DeepCollectionEquality().hash(_exerciseIds),
    isCompleted,
  );

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      __$$LessonModelImplCopyWithImpl<_$LessonModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonModelImplToJson(this);
  }
}

abstract class _LessonModel implements LessonModel {
  const factory _LessonModel({
    required final String id,
    required final String title,
    required final String level,
    required final String grammarExplanation,
    required final List<String> vocabularyIds,
    required final List<String> exerciseIds,
    required final bool isCompleted,
  }) = _$LessonModelImpl;

  factory _LessonModel.fromJson(Map<String, dynamic> json) =
      _$LessonModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get level;
  @override
  String get grammarExplanation;
  @override
  List<String> get vocabularyIds;
  @override
  List<String> get exerciseIds;
  @override
  bool get isCompleted;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
