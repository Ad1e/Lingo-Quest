import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/domain/repositories/auth_repository.dart';

/// State for authentication
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// StateNotifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(
        user: user,
        isLoggedIn: user != null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: user,
        isLoggedIn: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign up with email, password, and username
  Future<void> signUp(String email, String password, String username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        username: username,
      );
      state = state.copyWith(
        user: user,
        isLoggedIn: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
    String? bio,
  }) async {
    final user = state.user;
    if (user == null) throw Exception('No user logged in');

    try {
      await _authRepository.updateUserProfile(
        userId: user.id,
        username: username,
        avatarUrl: avatarUrl,
        bio: bio,
      );
      final updated = user.copyWith(
        username: username ?? user.username,
        avatarUrl: avatarUrl ?? user.avatarUrl,
      );
      state = state.copyWith(user: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// Riverpod provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // TODO: Get AuthRepository from dependency injection
  // final authRepository = ref.watch(authRepositoryProvider);
  // return AuthNotifier(authRepository);
  throw UnimplementedError('AuthRepository must be provided');
});

/// Convenience provider to get current user
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Convenience provider to check if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});
