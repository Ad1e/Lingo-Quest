import 'package:injectable/injectable.dart';

/// Abstract repository interface for social operations
abstract class SocialRepository {
  /// Get leaderboard
  Future<Leaderboard> getLeaderboard({
    required String timeframe, // 'weekly', 'monthly', 'all-time'
    String region = 'global',
    int limit = 100,
  });

  /// Get user rank
  Future<UserRank?> getUserRank({
    required String userId,
    required String timeframe,
  });

  /// Get user's friends
  Future<List<Friend>> getFriends(String userId);

  /// Add friend
  Future<void> addFriend(String userId, String friendId);

  /// Remove friend
  Future<void> removeFriend(String userId, String friendId);

  /// Send friend request
  Future<void> sendFriendRequest(String userId, String targetUserId);

  /// Accept friend request
  Future<void> acceptFriendRequest(String userId, String requesterId);

  /// Challenge friend
  Future<String> challengeFriend({
    required String userId,
    required String friendId,
    required String challengeType,
    required int duration, // minutes
  });

  /// Get active challenges
  Future<List<Challenge>> getActiveChallenges(String userId);

  /// Complete challenge
  Future<void> completeChallenge(String challengeId, int score);

  /// Get challenge details
  Future<Challenge?> getChallengeById(String challengeId);

  /// Search users
  Future<List<UserProfile>> searchUsers(String query);

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId);
}

/// Domain model for Leaderboard
class Leaderboard {
  final List<LeaderboardEntry> entries;
  final DateTime generatedAt;
  final String timeframe;

  Leaderboard({
    required this.entries,
    required this.generatedAt,
    required this.timeframe,
  });
}

/// Domain model for Leaderboard Entry
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int xp;
  final int level;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.xp,
    required this.level,
    this.avatarUrl,
  });
}

/// Domain model for User Rank
class UserRank {
  final int rank;
  final int totalUsers;
  final int xp;
  final int level;
  final double percentile; // 0.0-100.0

  UserRank({
    required this.rank,
    required this.totalUsers,
    required this.xp,
    required this.level,
    required this.percentile,
  });
}

/// Domain model for Friend
class Friend {
  final String id;
  final String username;
  final String? avatarUrl;
  final int level;
  final int xp;
  final bool isOnline;

  Friend({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.isOnline,
  });
}

/// Domain model for Challenge
class Challenge {
  final String id;
  final String userId1;
  final String userId2;
  final String type; // 'deck', 'daily-challenge', 'timed'
  final int duration; // minutes
  final int score1;
  final int score2;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Challenge({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.type,
    required this.duration,
    required this.score1,
    required this.score2,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });
}

/// Domain model for User Profile
class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int level;
  final int xp;
  final int streak;
  final int totalCardsStudied;
  final int friendCount;
  final bool isFriend;

  UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.level,
    required this.xp,
    required this.streak,
    required this.totalCardsStudied,
    required this.friendCount,
    required this.isFriend,
  });
}
