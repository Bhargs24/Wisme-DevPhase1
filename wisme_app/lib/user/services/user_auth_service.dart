import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_auth_state.dart';
import '../models/user_profile.dart';
import '../data/user_data_service.dart';

/// Production-grade user authentication service
/// Manages authentication with Firebase Auth and biometric authentication
class UserAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final LocalAuthentication _localAuth;
  final UserDataService _userDataService;

  // Stream controllers for auth state changes
  final StreamController<UserAuthState> _authStateController = StreamController.broadcast();
  
  // Current auth state
  UserAuthState _currentState = UserAuthState.initial();
  
  // Auth configuration
  final AuthConfig _config;

  UserAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    LocalAuthentication? localAuth,
    required UserDataService userDataService,
    AuthConfig? config,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _localAuth = localAuth ?? LocalAuthentication(),
       _userDataService = userDataService,
       _config = config ?? const AuthConfig() {
    _initializeAuthListener();
  }

  // Public getters
  UserAuthState get currentState => _currentState;
  Stream<UserAuthState> get authStateStream => _authStateController.stream;
  bool get isAuthenticated => _currentState.isAuthenticated;
  String? get currentUserId => _currentState.userId;

  void _initializeAuthListener() {
    _firebaseAuth.authStateChanges().listen(_handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      _updateAuthState(UserAuthState.initial());
    } else {
      try {
        final tokens = await _createTokensFromUser(user);
        final securityInfo = await _getUserSecurityInfo(user.uid);
        
        _updateAuthState(UserAuthState.authenticated(
          userId: user.uid,
          tokens: tokens,
          securityInfo: securityInfo,
          authMetadata: {
            'email': user.email,
            'emailVerified': user.emailVerified,
            'creationTime': user.metadata.creationTime?.toIso8601String(),
            'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
          },
        ));
      } catch (e) {
        _updateAuthState(UserAuthState.error(
          AuthError.unknown('Failed to process auth state change: $e')
        ));
      }
    }
  }

  // === EMAIL/PASSWORD AUTHENTICATION ===

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    Map<String, dynamic> additionalData = const {},
  }) async {
    try {
      _updateAuthState(UserAuthState.loading());

      // Validate inputs
      if (!_isValidEmail(email)) {
        throw AuthError.invalidCredentials('Invalid email format');
      }
      
      if (!_isValidPassword(password)) {
        throw AuthError.invalidCredentials('Password must be at least 8 characters');
      }

      // Create user account
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthError.unknown('Failed to create user account');
      }

      // Update display name
      await user.updateDisplayName(displayName);

      // Create user profile
      final userProfile = UserProfile(
        id: user.uid,
        email: email,
        displayName: displayName,
        settings: const UserSettings(),
        learningPreferences: const LearningPreferences(),
        subscription: const UserSubscription(),
        stats: const UserStats(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customFields: additionalData,
      );

      await _userDataService.createUserProfile(userProfile);

      // Send verification email if required
      if (_config.requireEmailVerification && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      return AuthResult.success(
        userId: user.uid,
        authMethod: AuthMethod.emailPassword,
        isNewUser: true,
      );

    } on FirebaseAuthException catch (e) {
      final authError = _mapFirebaseError(e);
      _updateAuthState(UserAuthState.error(authError));
      return AuthResult.failure(authError);
    } catch (e) {
      final authError = AuthError.unknown(e.toString());
      _updateAuthState(UserAuthState.error(authError));
      return AuthResult.failure(authError);
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
    bool rememberDevice = false,
  }) async {
    try {
      _updateAuthState(UserAuthState.loading());

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthError.invalidCredentials('Sign in failed');
      }

      // Check if email verification is required
      if (_config.requireEmailVerification && !user.emailVerified) {
        await signOut();
        throw AuthError.unknown('Please verify your email before signing in');
      }

      // Update last active time
      await _userDataService.updateUserFields(user.uid, {
        'lastActiveAt': DateTime.now().toIso8601String(),
      });

      return AuthResult.success(
        userId: user.uid,
        authMethod: AuthMethod.emailPassword,
        isNewUser: false,
      );

    } on FirebaseAuthException catch (e) {
      final authError = _mapFirebaseError(e);
      _updateAuthState(UserAuthState.error(authError));
      return AuthResult.failure(authError);
    } catch (e) {
      final authError = AuthError.unknown(e.toString());
      _updateAuthState(UserAuthState.error(authError));
      return AuthResult.failure(authError);
    }
  }

  // === GOOGLE AUTHENTICATION ===

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      _updateAuthState(UserAuthState.loading());

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _updateAuthState(UserAuthState.initial());
        return AuthResult.cancelled();
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw AuthError.unknown('Google sign in failed');
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // Create profile for new users
      if (isNewUser) {
        final userProfile = UserProfile(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          firstName: googleUser.displayName?.split(' ').first,
          lastName: googleUser.displayName?.split(' ').skip(1).join(' '),
          profileImageUrl: user.photoURL,
          settings: const UserSettings(),
          learningPreferences: const LearningPreferences(),
          subscription: const UserSubscription(),
          stats: const UserStats(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userDataService.createUserProfile(userProfile);
      } else {
        // Update last active time for existing users
        await _userDataService.updateUserFields(user.uid, {
          'lastActiveAt': DateTime.now().toIso8601String(),
        });
      }

      return AuthResult.success(
        userId: user.uid,
        authMethod: AuthMethod.google,
        isNewUser: isNewUser,
      );

    } catch (e) {
      final authError = AuthError.unknown('Google sign in failed: $e');
      _updateAuthState(UserAuthState.error(authError));
      return AuthResult.failure(authError);
    }
  }

  // === BIOMETRIC AUTHENTICATION ===

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Enable biometric authentication for user
  Future<bool> enableBiometricAuth() async {
    try {
      if (!await isBiometricAvailable()) {
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for Wisme',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated && _currentState.userId != null) {
        await _userDataService.updateUserFields(_currentState.userId!, {
          'isBiometricEnabled': true,
        });
        
        _updateAuthState(_currentState.copyWith(isBiometricEnabled: true));
      }

      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    try {
      if (_currentState.userId != null) {
        await _userDataService.updateUserFields(_currentState.userId!, {
          'isBiometricEnabled': false,
        });
        
        _updateAuthState(_currentState.copyWith(isBiometricEnabled: false));
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometric() async {
    try {
      if (!_currentState.isBiometricEnabled) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate with biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // === PASSWORD MANAGEMENT ===

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthError.reauthRequired('User not authenticated');
      }

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Update security info
      if (_currentState.userId != null) {
        await _userDataService.updateUserFields(_currentState.userId!, {
          'lastPasswordChange': DateTime.now().toIso8601String(),
        });
      }

      return AuthResult.success(
        userId: user.uid,
        authMethod: AuthMethod.emailPassword,
        isNewUser: false,
      );

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  // === SESSION MANAGEMENT ===

  /// Refresh authentication tokens
  Future<bool> refreshTokens() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      await user.getIdToken(true); // Force refresh
      
      final tokens = await _createTokensFromUser(user);
      _updateAuthState(_currentState.updateTokens(tokens));
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      _updateAuthState(UserAuthState.initial());
    } catch (e) {
      _updateAuthState(UserAuthState.error(
        AuthError.unknown('Sign out failed: $e')
      ));
    }
  }

  /// Sign out from all devices
  Future<void> signOutFromAllDevices() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // This would require custom backend implementation
        // For now, just sign out from current device
        await signOut();
      }
    } catch (e) {
      await signOut();
    }
  }

  // === ACCOUNT MANAGEMENT ===

  /// Delete user account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthError.reauthRequired('User not authenticated');
      }

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user data
      await _userDataService.deleteUserProfile(user.uid);

      // Delete Firebase Auth account
      await user.delete();

      _updateAuthState(UserAuthState.initial());

      return AuthResult.success(
        userId: user.uid,
        authMethod: AuthMethod.emailPassword,
        isNewUser: false,
      );

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e));
    } catch (e) {
      return AuthResult.failure(AuthError.unknown(e.toString()));
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      await user.sendEmailVerification();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    await user.reload();
    return user.emailVerified;
  }

  // === UTILITY METHODS ===

  /// Check auth status and refresh if needed
  Future<void> checkAuthStatus() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      if (_currentState.needsTokenRefresh) {
        await refreshTokens();
      }
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  /// Create auth tokens from Firebase user
  Future<AuthTokens> _createTokensFromUser(User user) async {
    final idToken = await user.getIdToken();
    final tokenResult = await user.getIdTokenResult();
    
    return AuthTokens(
      accessToken: idToken,
      tokenType: 'Bearer',
      expiresAt: tokenResult.expirationTime!,
      claims: tokenResult.claims ?? {},
    );
  }

  /// Get user security information
  Future<UserSecurityInfo> _getUserSecurityInfo(String userId) async {
    // This would fetch from your security service
    // For now, return basic security info
    return const UserSecurityInfo(
      securitySettings: SecuritySettings(),
    );
  }

  /// Map Firebase Auth errors to custom auth errors
  AuthError _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthError.invalidCredentials();
      case 'user-disabled':
        return AuthError.accountDisabled();
      case 'too-many-requests':
        return AuthError.tooManyAttempts();
      case 'network-request-failed':
        return AuthError.networkError();
      case 'requires-recent-login':
        return AuthError.reauthRequired();
      default:
        return AuthError.unknown(e.message ?? 'Authentication failed');
    }
  }

  /// Update auth state and notify listeners
  void _updateAuthState(UserAuthState newState) {
    _currentState = newState;
    _authStateController.add(_currentState);
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

/// Authentication result model
class AuthResult {
  final bool success;
  final String? userId;
  final AuthMethod? authMethod;
  final bool isNewUser;
  final AuthError? error;
  final bool wasCancelled;

  const AuthResult._({
    required this.success,
    this.userId,
    this.authMethod,
    this.isNewUser = false,
    this.error,
    this.wasCancelled = false,
  });

  factory AuthResult.success({
    required String userId,
    required AuthMethod authMethod,
    required bool isNewUser,
  }) {
    return AuthResult._(
      success: true,
      userId: userId,
      authMethod: authMethod,
      isNewUser: isNewUser,
    );
  }

  factory AuthResult.failure(AuthError error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }

  factory AuthResult.cancelled() {
    return const AuthResult._(
      success: false,
      wasCancelled: true,
    );
  }
}

/// Authentication configuration
class AuthConfig {
  final bool requireEmailVerification;
  final Duration sessionTimeout;
  final int maxLoginAttempts;
  final Duration lockoutDuration;

  const AuthConfig({
    this.requireEmailVerification = true,
    this.sessionTimeout = const Duration(hours: 24),
    this.maxLoginAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
  });
}
