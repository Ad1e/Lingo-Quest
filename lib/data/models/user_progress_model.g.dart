// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressModelImpl _$$UserProgressModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserProgressModelImpl(
  userId: json['userId'] as String,
  xp: (json['xp'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  streak: (json['streak'] as num).toInt(),
  lastStudyDate: DateTime.parse(json['lastStudyDate'] as String),
  completedLessons: (json['completedLessons'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  totalCardsStudied: (json['totalCardsStudied'] as num).toInt(),
);

Map<String, dynamic> _$$UserProgressModelImplToJson(
  _$UserProgressModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'xp': instance.xp,
  'level': instance.level,
  'streak': instance.streak,
  'lastStudyDate': instance.lastStudyDate.toIso8601String(),
  'completedLessons': instance.completedLessons,
  'totalCardsStudied': instance.totalCardsStudied,
};
