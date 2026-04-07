import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:language_learning_app/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
@Singleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) throw Exception('Sign in failed');
      
      return _mapFirebaseUserToAuthUser(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) throw Exception('Sign up failed');
      
      // Update user profile with username
      await user.updateDisplayName(username);
      await user.reload();
      
      // Send verification email
      await user.sendEmailVerification();
      
      return _mapFirebaseUserToAuthUser(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      
      return _mapFirebaseUserToAuthUser(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      // Update Firebase profile
      if (username != null) {
        await user.updateDisplayName(username);
      }
      
      if (avatarUrl != null) {
        await user.updatePhotoURL(avatarUrl);
      }
      
      await user.reload();
      
      // TODO: Store bio and additional profile data in Firestore
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> linkAuthProvider(String provider) async {
    try {
      // TODO: Implement provider linking (Google, Apple, etc.)
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await _firebaseAuth.currentUser?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> verifyEmail(String verificationCode) async {
    try {
      // Note: Verification is typically handled by Firebase email link
      // This is a placeholder for custom email verification if needed
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await user.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> emailExists(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
      (user) => user != null ? _mapFirebaseUserToAuthUser(user) : null,
    );
  }

  // ============ Helper Methods ============

  AuthUser _mapFirebaseUserToAuthUser(User user) {
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      username: user.displayName ?? '',
      avatarUrl: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: user.metadata.lastSignInTime,
      authProviders: user.providerData.map((p) => p.providerId).toList(),
    );
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'email-already-in-use':
        return Exception('The account already exists for that email.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'operation-not-allowed':
        return Exception('Operation not allowed.');
      case 'user-disabled':
        return Exception('The user account has been disabled.');
      case 'user-not-found':
        return Exception('There is no user account with this email.');
      case 'wrong-password':
        return Exception('The password is incorrect.');
      case 'too-many-requests':
        return Exception('Too many failed login attempts. Please try again later.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
