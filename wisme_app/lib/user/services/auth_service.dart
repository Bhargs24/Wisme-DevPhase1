import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../shared/models/result.dart';
import '../../user/models/user_model.dart';
import '../../core/utils/logger.dart';

/// Production-grade authentication service for the new architecture
class AuthService {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  bool _isFirebaseAvailable = false;

  AuthService() {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        _isFirebaseAvailable = true;
        AppLogger.info('✅ AuthService: Firebase Auth initialized');
      } else {
        AppLogger.warning('⚠️ AuthService: Firebase not initialized - Auth features disabled');
        _isFirebaseAvailable = false;
      }
    } catch (e) {
      AppLogger.warning('⚠️ AuthService: Firebase initialization check failed: $e');
      _isFirebaseAvailable = false;
    }
  }

  void _checkFirebaseAvailability() {
    if (!_isFirebaseAvailable || _auth == null) {
      throw Exception('Firebase Auth is not available. Please configure Firebase to use this feature.');
    }
  }

  /// Get current authenticated user
  User? get currentUser {
    if (!_isFirebaseAvailable || _auth == null) return null;
    try {
      return _auth!.currentUser;
    } catch (e) {
      AppLogger.warning('⚠️ Cannot get current user - Firebase not initialized');
      return null;
    }
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    if (!_isFirebaseAvailable || _auth == null) {
      return Stream.value(null);
    }
    try {
      return _auth!.authStateChanges();
    } catch (e) {
      AppLogger.warning('⚠️ Cannot get auth state changes - Firebase not initialized');
      return Stream.value(null);
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return currentUser != null;
  }

  /// Sign up with email and password
  Future<Result<UserCredential>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _checkFirebaseAvailability();

      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      AppLogger.info('✅ User signed up successfully: ${credential.user?.email}');
      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Sign up failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Sign up error: $e');
      return Result.failure('An unexpected error occurred during sign up');
    }
  }

  /// Sign in with email and password
  Future<Result<UserCredential>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _checkFirebaseAvailability();

      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppLogger.info('✅ User signed in successfully: ${credential.user?.email}');
      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Sign in failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Sign in error: $e');
      return Result.failure('An unexpected error occurred during sign in');
    }
  }

  /// Sign in with Google
  Future<Result<UserCredential>> signInWithGoogle() async {
    try {
      _checkFirebaseAvailability();

      if (_googleSignIn == null) {
        return Result.failure('Google Sign-In is not available');
      }

      // Trigger the authentication flow
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return Result.failure('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth!.signInWithCredential(credential);

      AppLogger.info('✅ User signed in with Google: ${userCredential.user?.email}');
      return Result.success(userCredential);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Google sign in failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Google sign in error: $e');
      return Result.failure('An unexpected error occurred during Google sign in');
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      _checkFirebaseAvailability();

      // Sign out from Google if signed in
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }

      // Sign out from Firebase
      await _auth!.signOut();

      AppLogger.info('✅ User signed out successfully');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Sign out error: $e');
      return Result.failure('Failed to sign out');
    }
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      _checkFirebaseAvailability();

      await _auth!.sendPasswordResetEmail(email: email);

      AppLogger.info('✅ Password reset email sent to: $email');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Password reset failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Password reset error: $e');
      return Result.failure('Failed to send password reset email');
    }
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    try {
      _checkFirebaseAvailability();

      final user = currentUser;
      if (user == null) {
        return Result.failure('No user is currently signed in');
      }

      if (user.emailVerified) {
        return Result.failure('Email is already verified');
      }

      await user.sendEmailVerification();

      AppLogger.info('✅ Email verification sent to: ${user.email}');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Email verification failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Email verification error: $e');
      return Result.failure('Failed to send email verification');
    }
  }

  /// Reload current user data
  Future<Result<void>> reloadUser() async {
    try {
      _checkFirebaseAvailability();

      final user = currentUser;
      if (user == null) {
        return Result.failure('No user is currently signed in');
      }

      await user.reload();
      AppLogger.info('✅ User data reloaded');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ User reload error: $e');
      return Result.failure('Failed to reload user data');
    }
  }

  /// Update user profile
  Future<Result<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _checkFirebaseAvailability();

      final user = currentUser;
      if (user == null) {
        return Result.failure('No user is currently signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      AppLogger.info('✅ User profile updated');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Profile update failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Profile update error: $e');
      return Result.failure('Failed to update profile');
    }
  }

  /// Update user password
  Future<Result<void>> updatePassword({
    required String newPassword,
  }) async {
    try {
      _checkFirebaseAvailability();

      final user = currentUser;
      if (user == null) {
        return Result.failure('No user is currently signed in');
      }

      await user.updatePassword(newPassword);

      AppLogger.info('✅ User password updated');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Password update failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Password update error: $e');
      return Result.failure('Failed to update password');
    }
  }

  /// Delete user account
  Future<Result<void>> deleteAccount() async {
    try {
      _checkFirebaseAvailability();

      final user = currentUser;
      if (user == null) {
        return Result.failure('No user is currently signed in');
      }

      await user.delete();

      AppLogger.info('✅ User account deleted');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Account deletion failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Account deletion error: $e');
      return Result.failure('Failed to delete account');
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<Result<void>> reauthenticate({
    required String password,
  }) async {
    try {
      _checkFirebaseAvailability();

      final user = currentUser;
      if (user == null) {
        return Result.failure('No user is currently signed in');
      }

      if (user.email == null) {
        return Result.failure('User email is not available');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      AppLogger.info('✅ User re-authenticated');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Re-authentication failed: ${e.code} - ${e.message}');
      return Result.failure(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error('❌ Re-authentication error: $e');
      return Result.failure('Failed to re-authenticate');
    }
  }

  /// Convert Firebase User to UserModel
  UserModel? getCurrentUserModel() {
    final user = currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
      metadata: UserMetadata(
        creationTime: user.metadata.creationTime,
        lastSignInTime: user.metadata.lastSignInTime,
      ),
      providers: user.providerData
          .map((info) => UserProviderInfo(
                providerId: info.providerId,
                uid: info.uid ?? '',
                email: info.email,
                displayName: info.displayName,
                photoURL: info.photoURL,
              ))
          .toList(),
    );
  }

  /// Check if service is available
  bool get isAvailable => _isFirebaseAvailable;

  /// Get user-friendly error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }
}
