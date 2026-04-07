// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementModelImpl _$$AchievementModelImplFromJson(
  Map<String, dynamic> json,
) => _$AchievementModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  iconPath: json['iconPath'] as String,
  unlockedAt: DateTime.parse(json['unlockedAt'] as String),
);

Map<String, dynamic> _$$AchievementModelImplToJson(
  _$AchievementModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'iconPath': instance.iconPath,
  'unlockedAt': instance.unlockedAt.toIso8601String(),
};
