import 'package:injectable/injectable.dart';
import 'package:my_app/lib/data/datasources/remote/cloud_functions_ds.dart';
import 'package:my_app/lib/domain/repositories/social_repository.dart';

/// Implementation of SocialRepository
@Singleton(as: SocialRepository)
class SocialRepositoryImpl implements SocialRepository {
  final CloudFunctionsDataSource _cloudFunctions;

  SocialRepositoryImpl(this._cloudFunctions);

  @override
  Future<Leaderboard> getLeaderboard({
    required String timeframe,
    String region = 'global',
    int limit = 100,
  }) async {
    try {
      final result = await _cloudFunctions.getLeaderboard(
        timeframe: timeframe,
        region: region,
        limit: limit,
      );
      
      return Leaderboard(
        entries: result.entries
            .asMap()
            .entries
            .map((entry) => LeaderboardEntry(
                  rank: entry.key + 1,
                  userId: entry.value.userId,
                  username: entry.value.username,
                  xp: entry.value.xp,
                  level: entry.value.level,
                  avatarUrl: entry.value.avatarUrl,
                ))
            .toList(),
        generatedAt: DateTime.now(),
        timeframe: timeframe,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserRank?> getUserRank({
    required String userId,
    required String timeframe,
  }) async {
    try {
      final result = await _cloudFunctions.getUserRank(
        userId: userId,
        timeframe: timeframe,
      );
      
      if (result != null) {
        return UserRank(
          rank: result.rank,
          totalUsers: result.totalUsers,
          xp: result.xp,
          level: result.level,
          percentile: (100 - ((result.rank / result.totalUsers) * 100)).clamp(0, 100).toDouble(),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Friend>> getFriends(String userId) async {
    try {
      // TODO: Implement with local datasource for friends list caching
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addFriend(String userId, String friendId) async {
    try {
      // TODO: Implement friend addition logic
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      // TODO: Implement friend removal logic
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendFriendRequest(String userId, String targetUserId) async {
    try {
      // TODO: Implement friend request sending
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    try {
      // TODO: Implement friend request acceptance
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> challengeFriend({
    required String userId,
    required String friendId,
    required String challengeType,
    required int duration,
  }) async {
    try {
      final challengeId = _generateChallengeId();
      final challenge = Challenge(
        id: challengeId,
        userId1: userId,
        userId2: friendId,
        type: challengeType,
        duration: duration,
        score1: 0,
        score2: 0,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      
      // TODO: Store challenge in database
      // TODO: Sync to remote
      
      return challengeId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Challenge>> getActiveChallenges(String userId) async {
    try {
      // TODO: Query active challenges from database
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> completeChallenge(String challengeId, int score) async {
    try {
      // TODO: Mark challenge as completed in database
      // TODO: Update user's score
      // TODO: Sync to remote
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Challenge?> getChallengeById(String challengeId) async {
    try {
      // TODO: Query challenge from database
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      // TODO: Search users from backend
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // TODO: Fetch user profile from backend
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============ Helper Methods ============

  String _generateChallengeId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
