// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProgressModel _$UserProgressModelFromJson(Map<String, dynamic> json) {
  return _UserProgressModel.fromJson(json);
}

/// @nodoc
mixin _$UserProgressModel {
  String get userId => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  DateTime get lastStudyDate => throw _privateConstructorUsedError;
  List<String> get completedLessons => throw _privateConstructorUsedError;
  int get totalCardsStudied => throw _privateConstructorUsedError;

  /// Serializes this UserProgressModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressModelCopyWith<UserProgressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressModelCopyWith<$Res> {
  factory $UserProgressModelCopyWith(
    UserProgressModel value,
    $Res Function(UserProgressModel) then,
  ) = _$UserProgressModelCopyWithImpl<$Res, UserProgressModel>;
  @useResult
  $Res call({
    String userId,
    int xp,
    int level,
    int streak,
    DateTime lastStudyDate,
    List<String> completedLessons,
    int totalCardsStudied,
  });
}

/// @nodoc
class _$UserProgressModelCopyWithImpl<$Res, $Val extends UserProgressModel>
    implements $UserProgressModelCopyWith<$Res> {
  _$UserProgressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? lastStudyDate = null,
    Object? completedLessons = null,
    Object? totalCardsStudied = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            streak: null == streak
                ? _value.streak
                : streak // ignore: cast_nullable_to_non_nullable
                      as int,
            lastStudyDate: null == lastStudyDate
                ? _value.lastStudyDate
                : lastStudyDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedLessons: null == completedLessons
                ? _value.completedLessons
                : completedLessons // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            totalCardsStudied: null == totalCardsStudied
                ? _value.totalCardsStudied
                : totalCardsStudied // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProgressModelImplCopyWith<$Res>
    implements $UserProgressModelCopyWith<$Res> {
  factory _$$UserProgressModelImplCopyWith(
    _$UserProgressModelImpl value,
    $Res Function(_$UserProgressModelImpl) then,
  ) = __$$UserProgressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int xp,
    int level,
    int streak,
    DateTime lastStudyDate,
    List<String> completedLessons,
    int totalCardsStudied,
  });
}

/// @nodoc
class __$$UserProgressModelImplCopyWithImpl<$Res>
    extends _$UserProgressModelCopyWithImpl<$Res, _$UserProgressModelImpl>
    implements _$$UserProgressModelImplCopyWith<$Res> {
  __$$UserProgressModelImplCopyWithImpl(
    _$UserProgressModelImpl _value,
    $Res Function(_$UserProgressModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? lastStudyDate = null,
    Object? completedLessons = null,
    Object? totalCardsStudied = null,
  }) {
    return _then(
      _$UserProgressModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        streak: null == streak
            ? _value.streak
            : streak // ignore: cast_nullable_to_non_nullable
                  as int,
        lastStudyDate: null == lastStudyDate
            ? _value.lastStudyDate
            : lastStudyDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedLessons: null == completedLessons
            ? _value._completedLessons
            : completedLessons // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalCardsStudied: null == totalCardsStudied
            ? _value.totalCardsStudied
            : totalCardsStudied // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressModelImpl implements _UserProgressModel {
  const _$UserProgressModelImpl({
    required this.userId,
    required this.xp,
    required this.level,
    required this.streak,
    required this.lastStudyDate,
    required final List<String> completedLessons,
    required this.totalCardsStudied,
  }) : _completedLessons = completedLessons;

  factory _$UserProgressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressModelImplFromJson(json);

  @override
  final String userId;
  @override
  final int xp;
  @override
  final int level;
  @override
  final int streak;
  @override
  final DateTime lastStudyDate;
  final List<String> _completedLessons;
  @override
  List<String> get completedLessons {
    if (_completedLessons is EqualUnmodifiableListView)
      return _completedLessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedLessons);
  }

  @override
  final int totalCardsStudied;

  @override
  String toString() {
    return 'UserProgressModel(userId: $userId, xp: $xp, level: $level, streak: $streak, lastStudyDate: $lastStudyDate, completedLessons: $completedLessons, totalCardsStudied: $totalCardsStudied)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.lastStudyDate, lastStudyDate) ||
                other.lastStudyDate == lastStudyDate) &&
            const DeepCollectionEquality().equals(
              other._completedLessons,
              _completedLessons,
            ) &&
            (identical(other.totalCardsStudied, totalCardsStudied) ||
                other.totalCardsStudied == totalCardsStudied));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    xp,
    level,
    streak,
    lastStudyDate,
    const DeepCollectionEquality().hash(_completedLessons),
    totalCardsStudied,
  );

  /// Create a copy of UserProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressModelImplCopyWith<_$UserProgressModelImpl> get copyWith =>
      __$$UserProgressModelImplCopyWithImpl<_$UserProgressModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressModelImplToJson(this);
  }
}

abstract class _UserProgressModel implements UserProgressModel {
  const factory _UserProgressModel({
    required final String userId,
    required final int xp,
    required final int level,
    required final int streak,
    required final DateTime lastStudyDate,
    required final List<String> completedLessons,
    required final int totalCardsStudied,
  }) = _$UserProgressModelImpl;

  factory _UserProgressModel.fromJson(Map<String, dynamic> json) =
      _$UserProgressModelImpl.fromJson;

  @override
  String get userId;
  @override
  int get xp;
  @override
  int get level;
  @override
  int get streak;
  @override
  DateTime get lastStudyDate;
  @override
  List<String> get completedLessons;
  @override
  int get totalCardsStudied;

  /// Create a copy of UserProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressModelImplCopyWith<_$UserProgressModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
