import 'dart:async';
import 'models/user_profile.dart';
import 'models/user_progress.dart';
import 'data/user_data_service.dart';
import 'services/auth_service.dart';
import 'services/personalization_service.dart';
import 'services/gamification_service.dart' as gamification;
import '../shared/models/result.dart';
import '../utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Production-grade user manager
/// Orchestrates all user-related services and provides a unified interface
class UserManager {
  final UserDataService _dataService;
  final AuthService _authService;
  final PersonalizationService _personalizationService;
  final gamification.GamificationService _gamificationService;

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

  UserManager({
    required UserDataService dataService,
    required AuthService authService,
    required PersonalizationService personalizationService,
    required gamification.GamificationService gamificationService,
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
      // Listen to Firebase Auth state changes directly
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
      AppLogger.info('✅ UserManager: Initialized successfully');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ UserManager: Failed to initialize: $e');
      return Result.failure(Exception('Failed to initialize UserManager: $e'));
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
      // Subscribe to real-time user profile updates
      _dataService.subscribeToUserProfile(userId);
      _profileSubscription = _dataService.userProfileStream.listen((profile) {
        _currentUser = profile;
        _currentUserController.add(_currentUser);
      });

      // Subscribe to real-time user progress updates
      _dataService.subscribeToUserProgress(userId);
      _progressSubscription = _dataService.userProgressStream.listen((progress) {
        _currentProgress = progress;
        _userProgressController.add(_currentProgress);
      });

      // Load initial data
      _currentUser = await _dataService.getUserProfile(userId);
      _currentProgress = await _dataService.getUserProgress(userId);

      // Create initial progress if it doesn't exist
      if (_currentProgress == null && _currentUser != null) {
        await _createInitialProgress(userId);
      }

      _currentUserController.add(_currentUser);
      _userProgressController.add(_currentProgress);
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Clear user data when signed out
  Future<void> _clearUserData() async {
    _profileSubscription?.cancel();
    _progressSubscription?.cancel();
    _dataService.unsubscribeAll();

    _currentUser = null;
    _currentProgress = null;
    
    _currentUserController.add(null);
    _userProgressController.add(null);
  }

  /// Create initial progress for new user
  Future<void> _createInitialProgress(String userId) async {
    final initialProgress = UserProgress(
      userId: userId,
      progressId: '${userId}_progress',
      overall: const OverallProgress(),
      currentWeek: WeeklyProgress(
        weekNumber: _getWeekNumber(DateTime.now()),
        year: DateTime.now().year,
        weekStart: _getWeekStart(DateTime.now()),
        weekEnd: _getWeekEnd(DateTime.now()),
      ),
      currentMonth: MonthlyProgress(
        month: DateTime.now().month,
        year: DateTime.now().year,
        monthStart: DateTime(DateTime.now().year, DateTime.now().month, 1),
        monthEnd: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
      ),
      goals: const LearningGoals(),
      analytics: ProgressAnalytics(lastAnalysisAt: DateTime.now()),
      lastUpdated: DateTime.now(),
    );

    await _dataService.createUserProgress(initialProgress);
    _currentProgress = initialProgress;
  }

  // === AUTHENTICATION METHODS ===

  /// Sign up with email and password
  Future<Result<UserCredential>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _ensureInitialized();
    
    final result = await _authService.signUpWithEmailPassword(
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
    
    return await _authService.signInWithEmailPassword(
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
      return Result.failure(Exception('User not authenticated'));
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
        settings: const UserSettings(),
        learningPreferences: const LearningPreferences(),
        subscription: const UserSubscription(),
        stats: const UserStats(),
      );

      await _dataService.createUserProfile(profile);
      AppLogger.info('✅ UserManager: Created user profile for ${user.uid}');
    } catch (e) {
      AppLogger.error('❌ UserManager: Failed to create user profile: $e');
    }
  }

  // === PROFILE MANAGEMENT ===

  /// Update user profile
  Future<void> updateProfile(UserProfile updatedProfile) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.updateUserProfile(currentUserId!, updatedProfile);
  }

  /// Update specific profile fields
  Future<void> updateProfileFields(Map<String, dynamic> fields) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.updateUserFields(currentUserId!, fields);
  }

  /// Update user settings
  Future<void> updateSettings(UserSettings settings) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.updateUserSettings(currentUserId!, settings);
  }

  /// Update learning preferences
  Future<void> updateLearningPreferences(LearningPreferences preferences) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.updateLearningPreferences(currentUserId!, preferences);
  }

  /// Update subscription
  Future<void> updateSubscription(UserSubscription subscription) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.updateUserSubscription(currentUserId!, subscription);
  }

  // === PROGRESS MANAGEMENT ===

  /// Add learning session
  Future<void> addLearningSession(LearningSession session) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.addLearningSession(currentUserId!, session);
  }

  /// Update topic progress
  Future<void> updateTopicProgress(String topicId, TopicProgress progress) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.updateTopicProgress(currentUserId!, topicId, progress);
  }

  /// Update skill progress
  Future<void> updateSkillProgress(String skillId, SkillProgress progress) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.updateSkillProgress(currentUserId!, skillId, progress);
  }

  /// Add achievement
  Future<void> addAchievement(Achievement achievement) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    await _dataService.addAchievement(currentUserId!, achievement);
  }

  // === BIOMETRIC AUTHENTICATION ===
  // Note: Biometric auth methods are not implemented in current AuthService
  // These would require additional packages like local_auth

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    // TODO: Implement with local_auth package
    return false;
  }

  /// Enable biometric authentication  
  Future<bool> enableBiometricAuth() async {
    // TODO: Implement with local_auth package
    return false;
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    // TODO: Implement with local_auth package
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometric() async {
    // TODO: Implement with local_auth package
    return false;
  }

  // === DATA RETRIEVAL ===

  /// Get user sessions
  Future<List<LearningSession>> getUserSessions({
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    return await _dataService.getUserSessions(
      currentUserId!,
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get user achievements
  Future<List<Achievement>> getUserAchievements() async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    return await _dataService.getUserAchievements(currentUserId!);
  }

  /// Get user analytics
  Future<Map<String, dynamic>> getUserAnalytics() async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      throw UserManagerException('User not authenticated');
    }

    return await _dataService.getUserAnalytics(currentUserId!);
  }

  // === ACCOUNT MANAGEMENT ===

  /// Change password
  Future<Result<void>> changePassword({
    required String newPassword,
  }) async {
    await _ensureInitialized();
    
    return await _authService.updatePassword(newPassword: newPassword);
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email: email);
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    return await _authService.sendEmailVerification();
  }

  /// Check if email is verified
  bool get isEmailVerified {
    return _authService.currentUser?.emailVerified ?? false;
  }

  /// Reload user data
  Future<Result<void>> reloadUser() async {
    return await _authService.reloadUser();
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
    return _currentProgress?.overall.currentLevel ?? 1;
  }

  /// Get user's current streak
  int get currentStreak {
    return _currentProgress?.overall.currentStreak ?? 0;
  }

  /// Get user's total experience
  int get totalExperience {
    return _currentProgress?.overall.totalExperience ?? 0;
  }

  /// Check if user needs to update password
  bool get needsPasswordUpdate {
    final lastChange = _currentUser?.customFields['lastPasswordChange'];
    if (lastChange == null) return true;
    
    final lastChangeDate = DateTime.parse(lastChange);
    return DateTime.now().difference(lastChangeDate).inDays > 90;
  }

  /// Get next achievement to unlock
  Achievement? getNextAchievement() {
    // This would implement achievement logic
    // Return null for now
    return null;
  }

  /// Calculate progress to next level
  double get progressToNextLevel {
    return _currentProgress?.overall.levelProgress ?? 0.0;
  }

  // Helper methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getWeekEnd(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  /// Dispose resources
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    _progressSubscription?.cancel();
    
    _dataService.dispose();
    PersonalizationService.dispose();
    
    _currentUserController.close();
    _userProgressController.close();
    _authStateController.close();
  }

  /// Check for new achievements based on user activity
  Future<List<String>> checkForNewAchievements({
    Map<String, dynamic>? additionalStats,
  }) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return [];
    }

    // Simplified achievement checking - return list of achievement IDs
    // TODO: Implement proper gamification logic
    return [];
  }

  /// Get user's current achievements
  Map<String, dynamic>? getCurrentUserAchievements() {
    if (!isAuthenticated || currentUserId == null) {
      return null;
    }

    // TODO: Implement achievement retrieval
    return {};
  }

  /// Award specific achievement to user
  Future<bool> awardAchievement({
    required String achievementId,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();
    
    if (!isAuthenticated || currentUserId == null) {
      return false;
    }

    // TODO: Implement achievement awarding
    return true;
  }
}

/// User manager exception
class UserManagerException implements Exception {
  final String message;
  
  const UserManagerException(this.message);
  
  @override
  String toString() => 'UserManagerException: $message';
}
