import '../core/exports.dart';

/// Simplified AppStateManager that works with the actual service signatures
class AppStateManager extends ChangeNotifier {
  static AppStateManager? _instance;
  static AppStateManager get instance => _instance ??= AppStateManager._internal();
  
  AppStateManager._internal();

  // Core Services
  final AuthenticationService _authService = AuthenticationService.instance;
  final StorageService _storageService = StorageService();
  
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
      
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.isSuccess) {
        _currentUser = result.data;
        await _onUserSignedIn();
        notifyListeners();
        AppLogger.info('✅ User signed in successfully');
        return Result.success(result.data!);
      } else {
        _lastError = result.error;
        AppLogger.error('❌ Sign in failed: ${result.error?.message}');
        return Result.failure(result.error!);
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
      
      final result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (result.isSuccess) {
        _currentUser = result.data;
        await _onUserSignedIn();
        notifyListeners();
        AppLogger.info('✅ User account created successfully');
        return Result.success(result.data!);
      } else {
        _lastError = result.error;
        AppLogger.error('❌ Sign up failed: ${result.error?.message}');
        return Result.failure(result.error!);
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
      
      final result = await _authService.signOut();
      
      if (result.isSuccess) {
        _currentUser = null;
        await _onUserSignedOut();
        notifyListeners();
        AppLogger.info('✅ User signed out successfully');
        return Result.success(null);
      } else {
        _lastError = result.error;
        AppLogger.error('❌ Sign out failed: ${result.error?.message}');
        return Result.failure(result.error!);
      }
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
    
    await _authService.initialize();
    // StorageService doesn't have initialize method, so we skip it
    
    AppLogger.info('✅ Core services initialized');
  }
  
  Future<void> _checkAuthenticationState() async {
    AppLogger.info('🔍 Checking authentication state...');
    
    _currentUser = _authService.currentUserProfile;
    
    if (_currentUser != null) {
      AppLogger.info('✅ User already authenticated: ${_currentUser!.email}');
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
