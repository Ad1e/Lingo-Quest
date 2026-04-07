import 'package:injectable/injectable.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<AuthUser> signIn({required String email, required String password});

  /// Sign up with email and password
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String username,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current user
  Future<AuthUser?> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Reset password
  Future<void> resetPassword({
    required String code,
    required String newPassword,
  });

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? avatarUrl,
    String? bio,
  });

  /// Link authentication provider
  Future<void> linkAuthProvider(String provider);

  /// Get auth token
  Future<String?> getAuthToken();

  /// Verify email
  Future<void> verifyEmail(String verificationCode);

  /// Re-send verification email
  Future<void> resendVerificationEmail();

  /// Check if email exists
  Future<bool> emailExists(String email);

  /// Listen to auth state changes
  Stream<AuthUser?> get authStateChanges;
}

/// Domain model for Authenticated User
class AuthUser {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final List<String> authProviders;

  AuthUser({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    required this.emailVerified,
    required this.createdAt,
    this.lastSignInAt,
    required this.authProviders,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    List<String>? authProviders,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      authProviders: authProviders ?? this.authProviders,
    );
  }
}
