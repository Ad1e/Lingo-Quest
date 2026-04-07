import 'package:language_learning_app/domain/repositories/progress_repository.dart';

/// Use case for fetching user statistics
abstract class GetUserStatsUseCase {
  Future<UserStatistics?> call(String userId);
}

/// Implementation of GetUserStatsUseCase
class GetUserStatsUseCaseImpl implements GetUserStatsUseCase {
  final ProgressRepository _progressRepository;

  GetUserStatsUseCaseImpl(this._progressRepository);

  @override
  Future<UserStatistics?> call(String userId) async {
    return await _progressRepository.getUserStatistics(userId);
  }
}
