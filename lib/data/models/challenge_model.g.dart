// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeModelImpl _$$ChallengeModelImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      deadline: DateTime.parse(json['deadline'] as String),
      isCompleted: json['isCompleted'] as bool,
    );

Map<String, dynamic> _$$ChallengeModelImplToJson(
  _$ChallengeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': instance.type,
  'xpReward': instance.xpReward,
  'deadline': instance.deadline.toIso8601String(),
  'isCompleted': instance.isCompleted,
};
