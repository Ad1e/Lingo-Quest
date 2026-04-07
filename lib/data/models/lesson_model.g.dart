// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonModelImpl _$$LessonModelImplFromJson(Map<String, dynamic> json) =>
    _$LessonModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      level: json['level'] as String,
      grammarExplanation: json['grammarExplanation'] as String,
      vocabularyIds: (json['vocabularyIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exerciseIds: (json['exerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isCompleted: json['isCompleted'] as bool,
    );

Map<String, dynamic> _$$LessonModelImplToJson(_$LessonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'level': instance.level,
      'grammarExplanation': instance.grammarExplanation,
      'vocabularyIds': instance.vocabularyIds,
      'exerciseIds': instance.exerciseIds,
      'isCompleted': instance.isCompleted,
    };
