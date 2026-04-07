import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/domain/repositories/social_repository.dart';
import 'package:language_learning_app/domain/usecases/get_leaderboard_usecase.dart';

/// State for leaderboard
class LeaderboardState {
  final Leaderboard? leaderboard;
  final UserRank? userRank;
  final String timeframe;
  final String region;
  final bool isLoading;
  final String? error;

  LeaderboardState({
    this.leaderboard,
    this.userRank,
    this.timeframe = 'weekly',
    this.region = 'global',
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    Leaderboard? leaderboard,
    UserRank? userRank,
    String? timeframe,
    String? region,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      leaderboard: leaderboard ?? this.leaderboard,
      userRank: userRank ?? this.userRank,
      timeframe: timeframe ?? this.timeframe,
      region: region ?? this.region,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier for managing leaderboard
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final SocialRepository _socialRepository;
  final String _userId;

  LeaderboardNotifier(
    this._socialRepository,
    this._userId,
  ) : super(LeaderboardState()) {
    loadLeaderboard();
  }

  /// Load leaderboard for current timeframe
  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final leaderboard = await _socialRepository.getLeaderboard(
        timeframe: state.timeframe,
        region: state.region,
      );
      
      final userRank = await _socialRepository.getUserRank(
        userId: _userId,
        timeframe: state.timeframe,
      );

      state = state.copyWith(
        leaderboard: leaderboard,
        userRank: userRank,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Change timeframe (weekly, monthly, all-time)
  Future<void> setTimeframe(String timeframe) async {
    state = state.copyWith(timeframe: timeframe);
    await loadLeaderboard();
  }

  /// Change region
  Future<void> setRegion(String region) async {
    state = state.copyWith(region: region);
    await loadLeaderboard();
  }

  /// Refresh leaderboard
  Future<void> refresh() async {
    await loadLeaderboard();
  }
}

/// Weekly leaderboard state
class WeeklyLeaderboardState {
  final Leaderboard? leaderboard;
  final bool isLoading;
  final String? error;

  WeeklyLeaderboardState({
    this.leaderboard,
    this.isLoading = false,
    this.error,
  });

  WeeklyLeaderboardState copyWith({
    Leaderboard? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return WeeklyLeaderboardState(
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Monthly leaderboard state
class MonthlyLeaderboardState {
  final Leaderboard? leaderboard;
  final bool isLoading;
  final String? error;

  MonthlyLeaderboardState({
    this.leaderboard,
    this.isLoading = false,
    this.error,
  });

  MonthlyLeaderboardState copyWith({
    Leaderboard? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return MonthlyLeaderboardState(
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// All-time leaderboard state
class AllTimeLeaderboardState {
  final Leaderboard? leaderboard;
  final bool isLoading;
  final String? error;

  AllTimeLeaderboardState({
    this.leaderboard,
    this.isLoading = false,
    this.error,
  });

  AllTimeLeaderboardState copyWith({
    Leaderboard? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return AllTimeLeaderboardState(
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Riverpod provider for leaderboard state
final leaderboardProvider =
    StateNotifierProvider.family<LeaderboardNotifier, LeaderboardState, String>(
  (ref, userId) {
    // TODO: Inject dependencies from ref
    // final socialRepository = ref.watch(socialRepositoryProvider);
    // return LeaderboardNotifier(socialRepository, userId);
    throw UnimplementedError('Dependencies must be provided');
  },
);

/// Provider for weekly leaderboard
final weeklyLeaderboardProvider =
    FutureProvider<Leaderboard>((ref) async {
  // TODO: Inject dependencies
  // final getLeaderboardUseCase = ref.watch(getLeaderboardUseCaseProvider);
  // return getLeaderboardUseCase(timeframe: 'weekly');
  throw UnimplementedError('Dependencies must be provided');
});

/// Provider for monthly leaderboard
final monthlyLeaderboardProvider =
    FutureProvider<Leaderboard>((ref) async {
  // TODO: Inject dependencies
  // final getLeaderboardUseCase = ref.watch(getLeaderboardUseCaseProvider);
  // return getLeaderboardUseCase(timeframe: 'monthly');
  throw UnimplementedError('Dependencies must be provided');
});

/// Provider for all-time leaderboard
final allTimeLeaderboardProvider =
    FutureProvider<Leaderboard>((ref) async {
  // TODO: Inject dependencies
  // final getLeaderboardUseCase = ref.watch(getLeaderboardUseCaseProvider);
  // return getLeaderboardUseCase(timeframe: 'all-time');
  throw UnimplementedError('Dependencies must be provided');
});

/// Provider to get user's rank
final userRankProvider =
    FutureProvider.family<UserRank?, (String userId, String timeframe)>(
  (ref, params) async {
    final (userId, timeframe) = params;
    // TODO: Inject dependencies
    // final socialRepository = ref.watch(socialRepositoryProvider);
    // return socialRepository.getUserRank(
    //   userId: userId,
    //   timeframe: timeframe,
    // );
    throw UnimplementedError('Dependencies must be provided');
  },
);
