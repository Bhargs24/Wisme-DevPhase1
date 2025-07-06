import '../core/exports.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProvider({
    required AuthService authService,
  }) : _authService = authService {
    _initializeUser();
  }

  // Getters
  UserProfile? get currentUser => _currentUser;
  UserProfile? get user => _currentUser; // Alias for UI compatibility
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get hasCompletedOnboarding => _currentUser != null; // Simplified for now

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _initializeUser() {
    // Listen to auth state changes from Firebase User
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  UserProfile _convertUserModelToProfile(UserModel userModel) {
    return UserProfile(
      id: userModel.id,
      email: userModel.email,
      displayName: userModel.displayName,
      createdAt: userModel.createdAt,
      lastActiveAt: userModel.lastLoginAt,
      avatarUrl: userModel.photoURL,
      achievements: [], // Default empty achievements
    );
  }

  Future<void> _loadUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userModel = await _authService.getUserProfile(userId);
      if (userModel != null) {
        _currentUser = _convertUserModelToProfile(userModel);
      }
      AppLogger.info('User profile loaded: ${_currentUser?.id}');
    } catch (e) {
      AppLogger.error('Failed to load user profile: $e');
      _error = 'Failed to load user profile';
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

  // User preferences helpers (simplified until UserProfile has preferences)
  String get preferredLanguage => 'en';
  String get selectedVoiceId => 'default';
  List<String> get userInterests => [];
  Duration get preferredSessionDuration => const Duration(minutes: 15);
  bool get notificationsEnabled => true;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userModel = await _authService.signInWithEmail(email, password);
      if (userModel != null) {
        _currentUser = _convertUserModelToProfile(userModel);
        AppLogger.info('User logged in: ${userModel.id}');
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
      final userModel = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
      if (userModel != null) {
        _currentUser = _convertUserModelToProfile(userModel);
        AppLogger.info('User registered: ${userModel.id}');
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

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      AppLogger.info('User logged out');
    } catch (e) {
      AppLogger.error('Logout failed: $e');
      _error = 'Logout failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Note: This is simplified for now. In a real app, you'd need to:
      // 1. Create a UserModel from UserProfile + updates
      // 2. Call _authService.updateUserProfile(userModel)
      // 3. Convert back to UserProfile
      
      // For now, just log the update attempt
      AppLogger.info('Profile update requested for user: ${_currentUser!.id}');
      AppLogger.info('Updates: $updates');
      
      // Refresh the profile to get latest data
      await refreshUserProfile();
    } catch (e) {
      AppLogger.error('Failed to update profile: $e');
      _error = 'Failed to update profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      AppLogger.info('Password reset email sent to: $email');
    } catch (e) {
      AppLogger.error('Password reset failed: $e');
      _error = 'Failed to send password reset email';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Note: This would need the user's current password in a real app
      // For now, we'll just log the attempt
      AppLogger.info('Account deletion requested for user: ${_currentUser!.id}');
      
      // In a real implementation:
      // await _authService.deleteAccount(password);
      _currentUser = null;
    } catch (e) {
      AppLogger.error('Account deletion failed: $e');
      _error = 'Failed to delete account';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markOnboardingComplete() async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // For now, just mark locally since UserProfile doesn't have onboarding field
      // In the future, this should update the backend
      AppLogger.info('Onboarding marked as complete for user: ${_currentUser!.id}');
    } catch (e) {
      AppLogger.error('Failed to mark onboarding complete: $e');
      _error = 'Failed to update onboarding status';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    await markOnboardingComplete();
  }

  /// Update the user's knowledge level for a topic
  Future<void> updateKnowledgeLevel(String level) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // For now, just log the knowledge level update
      // In a real implementation, this would update the user's profile
      AppLogger.info('Knowledge level updated for user ${_currentUser!.id}: $level');
      
      // In the future, this should:
      // 1. Update the UserProfile or UserModel with the knowledge level
      // 2. Save to backend via _authService.updateUserProfile()
      // 3. Refresh the local profile
      await refreshUserProfile();
    } catch (e) {
      AppLogger.error('Failed to update knowledge level: $e');
      _error = 'Failed to update knowledge level';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
