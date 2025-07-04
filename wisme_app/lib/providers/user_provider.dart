import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';
import '../utils/logger.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;
  final SharedPreferences _prefs;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProvider({
    required AuthService authService,
    required SharedPreferences prefs,
  }) : _authService = authService, 
       _prefs = prefs {
    _initializeUser();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  UserModel? get user => _currentUser; // Alias for UI compatibility
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  
  // Onboarding state
  bool get hasSeenOnboarding => _prefs.getBool('has_seen_onboarding') ?? false;

  Future<void> markOnboardingSeen() async {
    await _prefs.setBool('has_seen_onboarding', true);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _initializeUser() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserProfile(userId);
      AppLogger.info('User profile loaded: ${_currentUser?.id}');
    } catch (e) {
      AppLogger.error('Failed to load user profile: $e');
      _error = 'Failed to load user profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      AppLogger.info('User profile updated: ${updatedUser.id}');
    } catch (e) {
      AppLogger.error('Failed to update user profile: $e');
      _error = 'Failed to update profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserProfile() async {
    if (_currentUser != null) {
      await _loadUserProfile(_currentUser!.id);
    }
  }

  void clearUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // User preferences helpers
  String get preferredLanguage => 
      _currentUser?.preferences.preferredLanguage ?? 'en';

  String get selectedVoiceId => 
      _currentUser?.preferences.voiceId ?? 'default';

  List<String> get userInterests => 
      _currentUser?.preferences.interests ?? [];

  Duration get preferredSessionDuration => 
      _currentUser?.preferences.sessionDuration ?? const Duration(minutes: 15);

  bool get notificationsEnabled => 
      _currentUser?.preferences.notificationsEnabled ?? true;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        _currentUser = user;
        AppLogger.info('User logged in: ${user.id}');
        return true;
      } else {
        _error = 'Login failed. Please check your credentials.';
        return false;
      }
    } catch (e) {
      AppLogger.error('Login failed: $e');
      _error = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
      if (user != null) {
        _currentUser = user;
        AppLogger.info('User registered: ${user.id}');
        return true;
      } else {
        _error = 'Registration failed. Please try again.';
        return false;
      }
    } catch (e) {
      AppLogger.error('Registration failed: $e');
      _error = 'Registration failed: ${e.toString()}';
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
      if (user != null) {
        _currentUser = user;
        AppLogger.info('User signed in with Google: ${user.id}');
        return true;
      } else {
        _error = 'Google sign-in failed.';
        return false;
      }
    } catch (e) {
      AppLogger.error('Google sign-in failed: $e');
      _error = 'Google sign-in failed: ${e.toString()}';
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
      clearUser();
      AppLogger.info('User signed out');
    } catch (e) {
      AppLogger.error('Sign out failed: $e');
      _error = 'Sign out failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      AppLogger.info('Password reset email sent to: $email');
      return true;
    } catch (e) {
      AppLogger.error('Password reset failed: $e');
      _error = 'Password reset failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await signOut();
  }
}