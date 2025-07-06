import '../core/core_manager.dart';
import '../core/data/firestore_data_service.dart';
import '../core/storage/cloud_storage_service.dart';
import '../audio/audio_manager.dart';
import '../audio/services/tts_service.dart';
import '../audio/services/audio_player_service.dart';
import '../audio/services/elevenlabs_service.dart';
import '../content/content_manager.dart';
import '../content/services/gpt_service.dart';
import 'user_manager_v2.dart';
import 'data/user_data_service_v2.dart';
import 'services/auth_service.dart';
import 'services/personalization_service_v2.dart';
import 'services/gamification_service_v2.dart';
import '../utils/logger.dart';

/// Production-grade manager factory for the new architecture
/// Creates and configures all domain managers with proper dependency injection
class ManagerFactory {
  static ManagerFactory? _instance;
  
  // Core services
  late final CoreManager _coreManager;
  late final FirestoreDataService _firestoreService;
  late final CloudStorageService _storageService;
  
  // Domain services
  late final AuthService _authService;
  late final UserDataServiceV2 _userDataService;
  late final PersonalizationServiceV2 _personalizationService;
  late final GamificationServiceV2 _gamificationService;
  late final GPTService _gptService;
  late final TTSService _ttsService;
  late final AudioPlayerService _audioPlayerService;
  late final ElevenLabsService _elevenLabsService;
  
  // Domain managers
  late final UserManagerV2 _userManager;
  late final AudioManager _audioManager;
  late final ContentManager _contentManager;
  
  bool _isInitialized = false;

  ManagerFactory._internal();

  factory ManagerFactory() {
    _instance ??= ManagerFactory._internal();
    return _instance!;
  }

  /// Initialize all managers and services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('🚀 ManagerFactory: Starting initialization...');

      // 1. Initialize core services first
      await _initializeCoreServices();

      // 2. Initialize domain services
      await _initializeDomainServices();

      // 3. Initialize domain managers
      await _initializeDomainManagers();

      _isInitialized = true;
      AppLogger.info('✅ ManagerFactory: All services and managers initialized successfully');
    } catch (e) {
      AppLogger.error('❌ ManagerFactory: Initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize core services
  Future<void> _initializeCoreServices() async {
    AppLogger.info('📋 ManagerFactory: Initializing core services...');

    // Core manager with data and storage services
    _coreManager = CoreManager();
    await _coreManager.initialize();

    // Get initialized services from core manager
    _firestoreService = _coreManager.firestoreService;
    _storageService = _coreManager.storageService;

    AppLogger.info('✅ ManagerFactory: Core services initialized');
  }

  /// Initialize domain-specific services
  Future<void> _initializeDomainServices() async {
    AppLogger.info('📋 ManagerFactory: Initializing domain services...');

    // User domain services
    _authService = AuthService();
    _userDataService = UserDataServiceV2(firestoreService: _firestoreService);
    _personalizationService = PersonalizationServiceV2(firestoreService: _firestoreService);
    _gamificationService = GamificationServiceV2(firestoreService: _firestoreService);

    // Content domain services
    _gptService = GPTService();

    // Audio domain services
    _ttsService = TTSService();
    _audioPlayerService = AudioPlayerService();
    _elevenLabsService = ElevenLabsService();

    AppLogger.info('✅ ManagerFactory: Domain services initialized');
  }

  /// Initialize domain managers
  Future<void> _initializeDomainManagers() async {
    AppLogger.info('📋 ManagerFactory: Initializing domain managers...');

    // User manager with all user-related services
    _userManager = UserManagerV2(
      dataService: _userDataService,
      authService: _authService,
      personalizationService: _personalizationService,
      gamificationService: _gamificationService,
    );
    await _userManager.initialize();

    // Audio manager with all audio services
    _audioManager = AudioManager(
      ttsService: _ttsService,
      audioPlayerService: _audioPlayerService,
      elevenLabsService: _elevenLabsService,
    );
    await _audioManager.initialize();

    // Content manager with content services
    _contentManager = ContentManager(
      gptService: _gptService,
    );
    await _contentManager.initialize();

    AppLogger.info('✅ ManagerFactory: Domain managers initialized');
  }

  // === GETTERS FOR MANAGERS ===

  /// Get the user manager instance
  UserManagerV2 get userManager {
    _ensureInitialized();
    return _userManager;
  }

  /// Get the core manager instance
  CoreManager get coreManager {
    _ensureInitialized();
    return _coreManager;
  }

  /// Get the audio manager instance
  AudioManager get audioManager {
    _ensureInitialized();
    return _audioManager;
  }

  /// Get the content manager instance
  ContentManager get contentManager {
    _ensureInitialized();
    return _contentManager;
  }

  // === GETTERS FOR CORE SERVICES ===

  /// Get the Firestore data service instance
  FirestoreDataService get firestoreService {
    _ensureInitialized();
    return _firestoreService;
  }

  /// Get the cloud storage service instance
  CloudStorageService get storageService {
    _ensureInitialized();
    return _storageService;
  }

  // === GETTERS FOR DOMAIN SERVICES ===

  /// Get the authentication service instance
  AuthService get authService {
    _ensureInitialized();
    return _authService;
  }

  /// Get the user data service instance
  UserDataServiceV2 get userDataService {
    _ensureInitialized();
    return _userDataService;
  }

  /// Get the personalization service instance
  PersonalizationServiceV2 get personalizationService {
    _ensureInitialized();
    return _personalizationService;
  }

  /// Get the gamification service instance
  GamificationServiceV2 get gamificationService {
    _ensureInitialized();
    return _gamificationService;
  }

  /// Get the GPT service instance
  GPTService get gptService {
    _ensureInitialized();
    return _gptService;
  }

  /// Get the TTS service instance
  TTSService get ttsService {
    _ensureInitialized();
    return _ttsService;
  }

  /// Get the audio player service instance
  AudioPlayerService get audioPlayerService {
    _ensureInitialized();
    return _audioPlayerService;
  }

  /// Get the ElevenLabs service instance
  ElevenLabsService get elevenLabsService {
    _ensureInitialized();
    return _elevenLabsService;
  }

  // === UTILITY METHODS ===

  /// Check if the factory is initialized
  bool get isInitialized => _isInitialized;

  /// Ensure the factory is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('ManagerFactory has not been initialized. Call initialize() first.');
    }
  }

  /// Reset the singleton instance (mainly for testing)
  static void reset() {
    _instance?._dispose();
    _instance = null;
  }

  /// Dispose all resources
  void _dispose() {
    if (!_isInitialized) return;

    try {
      // Dispose managers
      _userManager.dispose();
      _audioManager.dispose();
      _contentManager.dispose();

      // Dispose services
      _userDataService.dispose();
      _personalizationService.dispose();
      _gamificationService.dispose();

      // Dispose core manager
      _coreManager.dispose();

      _isInitialized = false;
      AppLogger.info('✅ ManagerFactory: All resources disposed');
    } catch (e) {
      AppLogger.error('❌ ManagerFactory: Error during disposal: $e');
    }
  }

  /// Dispose all resources (public method)
  void dispose() {
    _dispose();
  }
}

/// Helper extension for easy access to managers throughout the app
extension ManagerFactoryAccess on ManagerFactory {
  /// Quick access to user manager
  UserManagerV2 get user => userManager;

  /// Quick access to audio manager
  AudioManager get audio => audioManager;

  /// Quick access to content manager
  ContentManager get content => contentManager;

  /// Quick access to core manager
  CoreManager get core => coreManager;
}

/// Global access to manager factory
ManagerFactory get managers => ManagerFactory();
