import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/domain/repositories/social_repository.dart';

/// State for social features
class SocialState {
  final List<Friend> friends;
  final List<Challenge> activeChallenges;
  final bool isLoading;
  final String? error;
  final int friendRequestCount;

  SocialState({
    this.friends = const [],
    this.activeChallenges = const [],
    this.isLoading = false,
    this.error,
    this.friendRequestCount = 0,
  });

  SocialState copyWith({
    List<Friend>? friends,
    List<Challenge>? activeChallenges,
    bool? isLoading,
    String? error,
    int? friendRequestCount,
  }) {
    return SocialState(
      friends: friends ?? this.friends,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      friendRequestCount: friendRequestCount ?? this.friendRequestCount,
    );
  }
}

/// StateNotifier for managing social features
class SocialNotifier extends StateNotifier<SocialState> {
  final SocialRepository _socialRepository;
  final String _userId;

  SocialNotifier(
    this._socialRepository,
    this._userId,
  ) : super(SocialState()) {
    _initialize();
  }

  /// Initialize social data
  Future<void> _initialize() async {
    await loadFriends();
    await loadActiveChallenges();
  }

  /// Load friends list
  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final friends = await _socialRepository.getFriends(_userId);
      state = state.copyWith(
        friends: friends,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load active challenges
  Future<void> loadActiveChallenges() async {
    try {
      final challenges = await _socialRepository.getActiveChallenges(_userId);
      state = state.copyWith(activeChallenges: challenges);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Add friend
  Future<void> addFriend(String friendId) async {
    try {
      await _socialRepository.addFriend(_userId, friendId);
      await loadFriends();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Remove friend
  Future<void> removeFriend(String friendId) async {
    try {
      await _socialRepository.removeFriend(_userId, friendId);
      state = state.copyWith(
        friends: state.friends.where((f) => f.id != friendId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Send friend request
  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      await _socialRepository.sendFriendRequest(_userId, targetUserId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String requesterId) async {
    try {
      await _socialRepository.acceptFriendRequest(_userId, requesterId);
      state = state.copyWith(friendRequestCount: state.friendRequestCount - 1);
      await loadFriends();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Challenge a friend
  Future<void> challengeFriend({
    required String friendId,
    required String challengeType,
    required int duration,
  }) async {
    try {
      final challengeId = await _socialRepository.challengeFriend(
        userId: _userId,
        friendId: friendId,
        challengeType: challengeType,
        duration: duration,
      );
      await loadActiveChallenges();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Complete challenge
  Future<void> completeChallenge(String challengeId, int score) async {
    try {
      await _socialRepository.completeChallenge(challengeId, score);
      await loadActiveChallenges();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Riverpod provider for social state
final socialProvider =
    StateNotifierProvider.family<SocialNotifier, SocialState, String>(
  (ref, userId) {
    // TODO: Inject dependencies from ref
    // final socialRepository = ref.watch(socialRepositoryProvider);
    // return SocialNotifier(socialRepository, userId);
    throw UnimplementedError('Dependencies must be provided');
  },
);

/// Provider to get user profile
final userProfileProvider =
    FutureProvider.family<UserProfile?, String>((ref, userId) async {
  // TODO: Inject dependencies
  // final socialRepository = ref.watch(socialRepositoryProvider);
  // return socialRepository.getUserProfile(userId);
  throw UnimplementedError('Dependencies must be provided');
});

/// Provider to search users
final searchUsersProvider =
    FutureProvider.family<List<UserProfile>, String>((ref, query) async {
  // TODO: Inject dependencies
  // final socialRepository = ref.watch(socialRepositoryProvider);
  // return socialRepository.searchUsers(query);
  throw UnimplementedError('Dependencies must be provided');
});
