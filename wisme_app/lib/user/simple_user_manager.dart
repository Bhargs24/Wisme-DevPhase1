import 'dart:async';
import '../shared/models/result.dart';
import '../core/utils/logger.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';

/// Simple user manager that integrates the new auth service
class UserManager {
  final AuthService _authService;

  // Stream controllers for user state
  final StreamController<UserModel?> _currentUserController = StreamController.broadcast();

  // Current state
  UserModel? _currentUser;

  // Subscriptions
  StreamSubscription? _authSubscription;

  UserManager({required AuthService authService}) : _authService = authService {
    _initialize();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;

  // Streams
  Stream<UserModel?> get currentUserStream => _currentUserController.stream;
  Stream<UserModel?> get authStateChanges => 
    _authService.authStateChanges.map((user) => user != null ? _authService.getCurrentUserModel() : null);

  /// Initialize user manager
  void _initialize() {
    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
    
    // Set initial user if already authenticated
    _currentUser = _authService.getCurrentUserModel();
    _currentUserController.add(_currentUser);

    AppLogger.info('👤 UserManager initialized');
  }

  /// Handle auth state changes
  void _onAuthStateChanged(user) {
    final userModel = _authService.getCurrentUserModel();
    _currentUser = userModel;
    _currentUserController.add(userModel);
    
    if (userModel != null) {
      AppLogger.info('👤 User authenticated: ${userModel.email}');
    } else {
      AppLogger.info('👤 User signed out');
    }
  }

  /// Sign up with email and password
  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final result = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (result.isSuccess) {
        final userModel = _authService.getCurrentUserModel();
        if (userModel != null) {
          AppLogger.info('✅ User signed up successfully: ${userModel.email}');
          return Result.success(userModel);
        } else {
          return Result.failure('Failed to get user model after sign up');
        }
      } else {
        return Result.failure(result.error);
      }
    } catch (e) {
      AppLogger.error('❌ Sign up error: $e');
      return Result.failure('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      
      if (result.isSuccess) {
        final userModel = _authService.getCurrentUserModel();
        if (userModel != null) {
          AppLogger.info('✅ User signed in successfully: ${userModel.email}');
          return Result.success(userModel);
        } else {
          return Result.failure('Failed to get user model after sign in');
        }
      } else {
        return Result.failure(result.error);
      }
    } catch (e) {
      AppLogger.error('❌ Sign in error: $e');
      return Result.failure('Sign in failed: $e');
    }
  }

  /// Sign in with Google
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result.isSuccess) {
        final userModel = _authService.getCurrentUserModel();
        if (userModel != null) {
          AppLogger.info('✅ User signed in with Google: ${userModel.email}');
          return Result.success(userModel);
        } else {
          return Result.failure('Failed to get user model after Google sign in');
        }
      } else {
        return Result.failure(result.error);
      }
    } catch (e) {
      AppLogger.error('❌ Google sign in error: $e');
      return Result.failure('Google sign in failed: $e');
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      final result = await _authService.signOut();
      
      if (result.isSuccess) {
        AppLogger.info('✅ User signed out successfully');
        return Result.success(null);
      } else {
        return Result.failure(result.error);
      }
    } catch (e) {
      AppLogger.error('❌ Sign out error: $e');
      return Result.failure('Sign out failed: $e');
    }
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    return await _authService.sendPasswordResetEmail(email: email);
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    return await _authService.sendEmailVerification();
  }

  /// Reload user data
  Future<Result<void>> reloadUser() async {
    final result = await _authService.reloadUser();
    if (result.isSuccess) {
      // Update current user model
      _currentUser = _authService.getCurrentUserModel();
      _currentUserController.add(_currentUser);
    }
    return result;
  }

  /// Update user profile
  Future<Result<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final result = await _authService.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
    
    if (result.isSuccess) {
      // Update current user model
      _currentUser = _authService.getCurrentUserModel();
      _currentUserController.add(_currentUser);
    }
    
    return result;
  }

  /// Update password
  Future<Result<void>> updatePassword({
    required String newPassword,
  }) async {
    return await _authService.updatePassword(newPassword: newPassword);
  }

  /// Delete account
  Future<Result<void>> deleteAccount() async {
    return await _authService.deleteAccount();
  }

  /// Re-authenticate user
  Future<Result<void>> reauthenticate({
    required String password,
  }) async {
    return await _authService.reauthenticate(password: password);
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _currentUserController.close();
    AppLogger.info('👤 UserManager disposed');
  }
}
