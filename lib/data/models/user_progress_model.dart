import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress_model.freezed.dart';
part 'user_progress_model.g.dart';

@freezed
class UserProgressModel with _$UserProgressModel {
  const factory UserProgressModel({
    required String userId,
    required int xp,
    required int level,
    required int streak,
    required DateTime lastStudyDate,
    required List<String> completedLessons,
    required int totalCardsStudied,
  }) = _UserProgressModel;

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserProgressModelFromJson(json);
}
