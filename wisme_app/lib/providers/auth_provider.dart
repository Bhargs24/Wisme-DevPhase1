import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required AuthService authService}) : _authService = authService {
    _initializeAuthState();
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _initializeAuthState() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
      AppLogger.info('Auth state changed: ${user?.uid ?? 'null'}');
    });
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(email, password);
      AppLogger.info('User signed in: ${user?.id}');
      return user != null;
    } catch (e) {
      AppLogger.error('Sign in failed: $e');
      _error = _getReadableErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, {String? name}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.registerWithEmail(
        email: email, 
        password: password, 
        name: name ?? 'User'
      );
      AppLogger.info('User created: ${user?.id}');
      return user != null;
    } catch (e) {
      AppLogger.error('User creation failed: $e');
      _error = _getReadableErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      AppLogger.info('User signed in with Google: ${user?.id}');
      return user != null;
    } catch (e) {
      AppLogger.error('Google sign in failed: $e');
      _error = _getReadableErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      AppLogger.info('User signed out');
    } catch (e) {
      AppLogger.error('Sign out failed: $e');
      _error = 'Failed to sign out';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      AppLogger.info('Password reset email sent to: $email');
      return true;
    } catch (e) {
      AppLogger.error('Password reset failed: $e');
      _error = _getReadableErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update Firebase Auth profile
      await _user!.updateDisplayName(displayName);
      if (photoURL != null) {
        await _user!.updatePhotoURL(photoURL);
      }
      AppLogger.info('Profile updated');
      return true;
    } catch (e) {
      AppLogger.error('Profile update failed: $e');
      _error = 'Failed to update profile';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(String password) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.deleteAccount(password);
      AppLogger.info('Account deleted');
      return true;
    } catch (e) {
      AppLogger.error('Account deletion failed: $e');
      _error = 'Failed to delete account';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getReadableErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else {
      return 'An error occurred. Please try again';
    }
  }
}
