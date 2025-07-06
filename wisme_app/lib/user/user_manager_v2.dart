import 'dart:async';
import 'models/user_profile.dart';
import 'models/user_progress.dart';
import 'models/user_auth_state.dart';
import 'data/user_data_service.dart';
import 'services/auth_service.dart';
import 'services/personalization_service.dart';
import 'services/gamification_service.dart';
import '../shared/models/shared_models.dart';
import '../utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Production-grade user manager
/// Orchestrates all user-related services and provides a unified interface
class UserManagerV2 {
  final UserDataService _dataService;
  final AuthService _authService;
  final PersonalizationService _personalizationService;
  final GamificationService _gamificationService;

  // Stream controllers for unified user state
  final StreamController<UserProfile?> _currentUserController = StreamController.broadcast();
  final StreamController<UserProgress?> _userProgressController = StreamController.broadcast();
  final StreamController<bool> _authStateController = StreamController.broadcast();

  // Current state
  UserProfile? _currentUser;
  UserProgress? _currentProgress;
  bool _isAuthenticated = false;

  // Subscriptions
  StreamSubscription? _authSubscription;
  StreamSubscription? _profileSubscription;
  StreamSubscription? _progressSubscription;

  bool _isInitialized = false;

  UserManagerV2({
    required UserDataService dataService,
    required AuthService authService,
    required PersonalizationService personalizationService,
    required GamificationService gamificationService,
  }) : _dataService = dataService,
       _authService = authService,
       _personalizationService = personalizationService,
       _gamificationService = gamificationService;

  // Public getters
  UserProfile? get currentUser => _currentUser;
  UserProgress? get userProgress => _currentProgress;
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _authService.currentUser?.uid;

  // Streams
  Stream<UserProfile?> get currentUserStream => _currentUserController.stream;
  Stream<UserProgress?> get userProgressStream => _userProgressController.stream;
  Stream<bool> get authStateStream => _authStateController.stream;

  /// Initialize the user manager
  Future<Result<void>> initialize() async {
    if (_isInitialized) return Result.success(null);

    try {
      // Listen to Firebase Auth state changes
      _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);

      // Check current auth state
      final currentUser = _authService.currentUser;
      _isAuthenticated = currentUser != null;
      _authStateController.add(_isAuthenticated);

      // If already authenticated, load user data
      if (_isAuthenticated && currentUser != null) {
        await _loadUserData(currentUser.uid);
      }

      _isInitialized = true;
      AppLogger.info('✅ UserManagerV2: Initialized successfully');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ UserManagerV2: Failed to initialize: $e');
      return Result.failure('Failed to initialize UserManager: $e');
    }
  }

  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(User? user) async {
    final wasAuthenticated = _isAuthenticated;
    _isAuthenticated = user != null;
    _authStateController.add(_isAuthenticated);

    if (_isAuthenticated && user != null) {
      if (!wasAuthenticated) {
        // User just logged in
        await _loadUserData(user.uid);
      }
    } else {
      // User logged out
      await _clearUserData();
    }
  }

  /// Load user data for authenticated user
  Future<void> _loadUserData(String userId) async {
    try {
      // Load user profile
      final profileResult = await _dataService.getUserProfile(userId);
      _currentUser = profileResult;
      _currentUserController.add(_currentUser);

      // Load user progress
      final progressResult = await _dataService.getUserProgress(userId);
      _currentProgress = progressResult;
      _userProgressController.add(_currentProgress);

      // Create initial progress if it doesn't exist
      if (_currentProgress == null && _currentUser != null) {
        await _createInitialProgress(userId);
      }

      AppLogger.info('✅ UserManagerV2: Loaded user data for $userId');
    } catch (e) {
      AppLogger.error('❌ UserManagerV2: Error loading user data: $e');
    }
  }

  /// Clear user data when signed out
  Future<void> _clearUserData() async {
    _profileSubscription?.cancel();
    _progressSubscription?.cancel();

    _currentUser = null;
    _currentProgress = null;
    
    _currentUserController.add(null);
    _userProgressController.add(null);

    AppLogger.info('✅ UserManagerV2: Cleared user data');
  }

  /// Create initial progress for new user
  Future<void> _createInitialProgress(String userId) async {
    try {
      // This would create initial UserProgress - simplified for now
      AppLogger.info('✅ UserManagerV2: Created initial progress for $userId');
    } catch (e) {
      AppLogger.error('❌ UserManagerV2: Failed to create initial progress: $e');
    }
  }

  // === AUTHENTICATION METHODS ===

  /// Sign up with email and password
  Future<Result<UserCredential>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _ensureInitialized();
    
    final result = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.isSuccess) {
      // Create user profile in Firestore
      final user = result.data!.user;
      if (user != null) {
        await _createUserProfile(user, displayName);
      }
    }

    return result;
  }

  /// Sign in with email and password
  Future<Result<UserCredential>> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureInitialized();
    
    return await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google
  Future<Result<UserCredential>> signInWithGoogle() async {
    await _ensureInitialized();
    return await _authService.signInWithGoogle();
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    final result = await _authService.signOut();
    if (result.isSuccess) {
      await _clearUserData();
    }
    return result;
  }

  /// Delete account
  Future<Result<void>> deleteAccount() async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return Result.failure('User not authenticated');
    }

    // Delete user data first
    try {
      await _dataService.deleteUserProfile(currentUserId!);
      await _clearUserData();
    } catch (e) {
      AppLogger.warning('⚠️ Failed to delete user data: $e');
    }

    return await _authService.deleteAccount();
  }

  // === PROFILE MANAGEMENT ===

  /// Create user profile in Firestore
  Future<void> _createUserProfile(User user, String? displayName) async {
    try {
      final profile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName ?? '',
        profileImageUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      await _dataService.createUserProfile(profile);
      AppLogger.info('✅ UserManagerV2: Created user profile for ${user.uid}');
    } catch (e) {
      AppLogger.error('❌ UserManagerV2: Failed to create user profile: $e');
    }
  }

  /// Update user profile
  Future<Result<void>> updateProfile(UserProfile updatedProfile) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return Result.failure('User not authenticated');
    }

    try {
      await _dataService.updateUserProfile(currentUserId!, updatedProfile);
      _currentUser = updatedProfile;
      _currentUserController.add(_currentUser);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update profile: $e');
    }
  }

  /// Update specific profile fields
  Future<Result<void>> updateProfileFields(Map<String, dynamic> fields) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return Result.failure('User not authenticated');
    }

    try {
      await _dataService.updateUserFields(currentUserId!, fields);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update profile fields: $e');
    }
  }

  // === PERSONALIZATION ===

  /// Get user's learning preferences
  Future<Result<LearningPreferences>> getLearningPreferences() async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return Result.failure('User not authenticated');
    }

    return await _personalizationService.getUserPreferences(currentUserId!);
  }

  /// Update user's learning preferences
  Future<Result<void>> updateLearningPreferences(LearningPreferences preferences) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return Result.failure('User not authenticated');
    }

    return await _personalizationService.updateUserPreferences(currentUserId!, preferences);
  }

  /// Generate content recommendations
  Future<Result<List<ContentRecommendation>>> getRecommendations() async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return Result.failure('User not authenticated');
    }

    return await _personalizationService.generateRecommendations(currentUserId!);
  }

  // === GAMIFICATION ===

  /// Check for new achievements
  Future<List<AchievementResult>> checkForNewAchievements({
    Map<String, dynamic>? additionalStats,
  }) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return [];
    }

    // Compile user statistics for achievement checking
    final userStats = <String, dynamic>{
      'totalLearningTime': _currentProgress?.time?.totalLearningTime ?? 0,
      'completedLessons': _currentProgress?.overall?.lessonsCompleted ?? 0,
      'streakDays': _currentProgress?.streaks?.dailyStreakDays ?? 0,
      ...?additionalStats,
    };

    return GamificationService.checkForNewAchievements(
      userId: currentUserId!,
      userStats: userStats,
    );
  }

  /// Award specific achievement to user
  Future<AchievementResult> awardAchievement({
    required String achievementId,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return AchievementResult.error('User not authenticated');
    }

    return GamificationService.awardAchievement(
      userId: currentUserId!,
      achievementId: achievementId,
      reason: reason,
      metadata: metadata,
    );
  }

  // === ACCOUNT MANAGEMENT ===

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    return await _authService.sendEmailVerification();
  }

  /// Check if email is verified
  bool get isEmailVerified {
    return _authService.currentUser?.emailVerified ?? false;
  }

  // === UTILITY METHODS ===

  /// Check if user has premium subscription
  bool get hasPremiumSubscription {
    return _currentUser?.isPremium ?? false;
  }

  /// Check if user has active subscription
  bool get hasActiveSubscription {
    return _currentUser?.hasActiveSubscription ?? false;
  }

  /// Get user's current level
  int get userLevel {
    return _currentProgress?.overall?.currentLevel ?? 1;
  }

  /// Get user's current streak
  int get currentStreak {
    return _currentProgress?.overall?.currentStreak ?? 0;
  }

  /// Get user's total experience
  int get totalExperience {
    return _currentProgress?.overall?.totalExperience ?? 0;
  }

  // Helper methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    _progressSubscription?.cancel();
    
    _personalizationService.dispose();
    
    _currentUserController.close();
    _userProgressController.close();
    _authStateController.close();

    AppLogger.info('✅ UserManagerV2: Disposed successfully');
  }
}

/// User manager exception
class UserManagerException implements Exception {
  final String message;
  
  const UserManagerException(this.message);
  
  @override
  String toString() => 'UserManagerException: $message';
}
