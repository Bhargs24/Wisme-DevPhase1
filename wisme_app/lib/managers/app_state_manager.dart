import '../core/exports.dart';

/// Simplified AppStateManager that works with the actual service signatures
class AppStateManager extends ChangeNotifier {
  static AppStateManager? _instance;
  static AppStateManager get instance => _instance ??= AppStateManager._internal();
  
  AppStateManager._internal();

  // Core Services
  final AuthService _authService = AuthService();
  
  // App State
  AppInitializationState _initState = AppInitializationState.notStarted;
  UserProfile? _currentUser;
  bool _isOnline = true;
  WismeFailure? _lastError;
  
  // Getters
  AppInitializationState get initializationState => _initState;
  UserProfile? get currentUser => _currentUser;
  bool get isOnline => _isOnline;
  bool get isInitialized => _initState == AppInitializationState.completed;
  WismeFailure? get lastError => _lastError;
  bool get hasUser => _currentUser != null;
  
  /// Initialize the entire application
  Future<Result<void>> initializeApp() async {
    try {
      _setInitState(AppInitializationState.initializing);
      AppLogger.info('🚀 Starting application initialization...');
      
      // Step 1: Initialize core services
      await _initializeCoreServices();
      
      // Step 2: Check authentication state
      await _checkAuthenticationState();
      
      // Step 3: Initialize analytics
      await _initializeAnalytics();
      
      _setInitState(AppInitializationState.completed);
      AppLogger.info('✅ Application initialization completed');
      
      return Result.success(null);
    } catch (e) {
      _lastError = UnknownFailure(message: e.toString());
      _setInitState(AppInitializationState.failed);
      AppLogger.error('❌ Application initialization failed: $e');
      return Result.failure(UnknownFailure(message: 'Initialization failed: $e'));
    }
  }
  
  /// Sign in user
  Future<Result<UserProfile>> signInUser(String email, String password) async {
    try {
      AppLogger.info('🔐 Attempting user sign in...');
      
      final userModel = await _authService.signInWithEmail(email, password);
      
      if (userModel != null) {
        // Convert UserModel to UserProfile for compatibility
        _currentUser = UserProfile(
          id: userModel.id,
          email: userModel.email,
          displayName: userModel.displayName,
          createdAt: userModel.createdAt,
          lastActiveAt: userModel.lastLoginAt,
          avatarUrl: userModel.photoURL,
          achievements: [], // Default empty achievements
        );
        await _onUserSignedIn();
        notifyListeners();
        AppLogger.info('✅ User signed in successfully');
        return Result.success(_currentUser!);
      } else {
        final failure = AuthFailure(message: 'Sign in failed', code: 'sign_in_failed');
        _lastError = failure;
        AppLogger.error('❌ Sign in failed');
        return Result.failure(failure);
      }
    } catch (e) {
      final failure = UnknownFailure(message: e.toString());
      _lastError = failure;
      AppLogger.error('❌ Sign in error: $e');
      return Result.failure(failure);
    }
  }
  
  /// Sign up new user
  Future<Result<UserProfile>> signUpUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      AppLogger.info('📝 Creating new user account...');
      
      final userModel = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: displayName,
      );
      
      if (userModel != null) {
        // Convert UserModel to UserProfile for compatibility
        _currentUser = UserProfile(
          id: userModel.id,
          email: userModel.email,
          displayName: userModel.displayName,
          createdAt: userModel.createdAt,
          lastActiveAt: userModel.lastLoginAt,
          avatarUrl: userModel.photoURL,
          achievements: [], // Default empty achievements
        );
        await _onUserSignedIn();
        notifyListeners();
        AppLogger.info('✅ User account created successfully');
        return Result.success(_currentUser!);
      } else {
        final failure = AuthFailure(message: 'Account creation failed', code: 'signup_failed');
        _lastError = failure;
        AppLogger.error('❌ Sign up failed');
        return Result.failure(failure);
      }
    } catch (e) {
      final failure = UnknownFailure(message: e.toString());
      _lastError = failure;
      AppLogger.error('❌ Sign up error: $e');
      return Result.failure(failure);
    }
  }
  
  /// Sign out user
  Future<Result<void>> signOutUser() async {
    try {
      AppLogger.info('🚪 Signing out user...');
      
      await _authService.signOut();
      
      _currentUser = null;
      await _onUserSignedOut();
      notifyListeners();
      AppLogger.info('✅ User signed out successfully');
      return Result.success(null);
    } catch (e) {
      final failure = UnknownFailure(message: e.toString());
      _lastError = failure;
      AppLogger.error('❌ Sign out error: $e');
      return Result.failure(failure);
    }
  }
  
  /// Set online/offline status
  void setOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      AppLogger.info('🌐 Network status changed: ${isOnline ? 'ONLINE' : 'OFFLINE'}');
      notifyListeners();
    }
  }
  
  /// Clear error state
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
  
  // Private helper methods
  
  void _setInitState(AppInitializationState state) {
    _initState = state;
    notifyListeners();
  }
  
  Future<void> _initializeCoreServices() async {
    AppLogger.info('🔧 Initializing core services...');
    
    // AuthService doesn't need explicit initialization
    // The service is ready when instantiated
    
    AppLogger.info('✅ Core services initialized');
  }
  
  Future<void> _checkAuthenticationState() async {
    AppLogger.info('🔍 Checking authentication state...');
    
    final firebaseUser = _authService.currentUser;
    
    if (firebaseUser != null) {
      AppLogger.info('✅ User already authenticated: ${firebaseUser.email}');
      // Get the full user profile from the service
      final userModel = await _authService.getUserProfile(firebaseUser.uid);
      if (userModel != null) {
        _currentUser = UserProfile(
          id: userModel.id,
          email: userModel.email,
          displayName: userModel.displayName,
          createdAt: userModel.createdAt,
          lastActiveAt: userModel.lastLoginAt,
          avatarUrl: userModel.photoURL,
          achievements: [], // Default empty achievements
        );
      }
      await _onUserSignedIn();
    } else {
      AppLogger.info('ℹ️ No authenticated user found');
    }
  }
  
  Future<void> _initializeAnalytics() async {
    AppLogger.info('📊 Initializing analytics...');
    
    await AnalyticsService.initialize();
    
    if (_currentUser != null) {
      AnalyticsService.startSession(_currentUser!.id);
    }
    
    AppLogger.info('✅ Analytics initialized');
  }
  
  Future<void> _onUserSignedIn() async {
    if (_currentUser != null) {
      AnalyticsService.startSession(_currentUser!.id);
      
      // Track sign in event
      AnalyticsService.trackEvent('user_signed_in', {
        'user_id': _currentUser!.id,
        'method': 'email',
      });
    }
  }
  
  Future<void> _onUserSignedOut() async {
    if (_currentUser != null) {
      AnalyticsService.endSession(_currentUser!.id);
      
      // Track sign out event
      AnalyticsService.trackEvent('user_signed_out', {
        'user_id': _currentUser!.id,
      });
    }
  }
}

/// Application initialization states
enum AppInitializationState {
  notStarted,
  initializing,
  completed,
  failed,
}
