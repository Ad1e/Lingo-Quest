import 'package:language_learning_app/domain/repositories/social_repository.dart';

/// Use case for fetching leaderboard rankings
abstract class GetLeaderboardUseCase {
  /// Get leaderboard for a specific timeframe
  /// 
  /// Parameters:
  ///   - timeframe: 'weekly', 'monthly', or 'all-time'
  ///   - region: Geographic region for leaderboard (default: 'global')
  ///   - limit: Maximum number of entries (default: 100)
  /// 
  /// Returns: Leaderboard with ranked entries
  Future<Leaderboard> call({
    required String timeframe,
    String region,
    int limit,
  });
}

/// Implementation of GetLeaderboardUseCase
class GetLeaderboardUseCaseImpl implements GetLeaderboardUseCase {
  final SocialRepository _socialRepository;

  GetLeaderboardUseCaseImpl(this._socialRepository);

  @override
  Future<Leaderboard> call({
    required String timeframe,
    String region = 'global',
    int limit = 100,
  }) async {
    return await _socialRepository.getLeaderboard(
      timeframe: timeframe,
      region: region,
      limit: limit,
    );
  }
}
