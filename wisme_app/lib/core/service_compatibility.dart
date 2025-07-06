import '../core/exports.dart';

/// Service aliases to maintain compatibility between different service interfaces
/// This allows providers to work with both old and new service interfaces

// Re-export AuthService as AuthenticationService for compatibility
typedef AuthenticationService = AuthService;

/// Extension to add missing methods to AuthService for AuthenticationService compatibility
extension AuthServiceCompatibility on AuthService {
  /// Alias for signInWithEmail to match AuthenticationService interface
  Future<Result<UserProfile>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await signInWithEmail(email, password);
      if (userModel != null) {
        final userProfile = UserProfile(
          id: userModel.id,
          email: userModel.email,
          displayName: userModel.displayName,
          avatarUrl: userModel.photoURL,
          achievements: [],
          createdAt: userModel.createdAt,
          lastActiveAt: userModel.lastLoginAt,
        );
        return Result.success(userProfile);
      } else {
        return Result.failure(AuthFailure(message: 'Authentication failed', code: 'auth_failed'));
      }
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString(), code: 'auth_error'));
    }
  }

  /// Alias for registerWithEmail to match AuthenticationService interface
  Future<Result<UserProfile>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userModel = await registerWithEmail(
        email: email,
        password: password,
        name: displayName, // registerWithEmail uses 'name', not 'displayName'
      );
      if (userModel != null) {
        final userProfile = UserProfile(
          id: userModel.id,
          email: userModel.email,
          displayName: userModel.displayName,
          avatarUrl: userModel.photoURL,
          achievements: [],
          createdAt: userModel.createdAt,
          lastActiveAt: userModel.lastLoginAt,
        );
        return Result.success(userProfile);
      } else {
        return Result.failure(AuthFailure(message: 'Registration failed', code: 'registration_failed'));
      }
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString(), code: 'registration_error'));
    }
  }

  /// Alias for signOut with Result return type
  Future<Result<void>> signOutUser() async {
    try {
      await signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(message: e.toString(), code: 'signout_error'));
    }
  }

  /// Initialize method for compatibility
  Future<void> initialize() async {
    // AuthService doesn't need explicit initialization
    AppLogger.info('AuthService initialized');
  }

  /// Get current user as UserProfile
  UserProfile? get currentUserProfile {
    final firebaseUser = currentUser; // This is a Firebase User
    if (firebaseUser != null) {
      return UserProfile(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        avatarUrl: firebaseUser.photoURL,
        achievements: [],
        createdAt: DateTime.now(), // Firebase User doesn't have createdAt, using current time
        lastActiveAt: DateTime.now(),
      );
    }
    return null;
  }

  /// Auth state stream for compatibility
  Stream<UserProfile?> get authStateChanges async* {
    // Since the original AuthService doesn't have a stream,
    // we'll create a periodic check or use a simple implementation
    UserProfile? lastUser;
    while (true) {
      final currentUserProfile = this.currentUserProfile;
      if (currentUserProfile != lastUser) {
        yield currentUserProfile;
        lastUser = currentUserProfile;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

/// Create singleton instance for compatibility
extension AuthServiceSingleton on AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService();
}

