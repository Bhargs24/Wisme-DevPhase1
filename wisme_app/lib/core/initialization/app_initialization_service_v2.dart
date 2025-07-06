import 'package:firebase_core/firebase_core.dart';
import '../../user/manager_factory.dart';
import '../../utils/logger.dart';

/// Production-grade app initialization service for the new architecture
/// Handles all app startup tasks including Firebase and manager initialization
class AppInitializationServiceV2 {
  static bool _isInitialized = false;

  /// Initialize the entire application
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.info('🚀 AppInitializationServiceV2: Starting app initialization...');

      // 1. Initialize Firebase
      await _initializeFirebase();

      // 2. Initialize all managers and services through the factory
      await _initializeManagers();

      _isInitialized = true;
      AppLogger.info('✅ AppInitializationServiceV2: App initialization completed successfully');
    } catch (e) {
      AppLogger.error('❌ AppInitializationServiceV2: Initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize Firebase services
  static Future<void> _initializeFirebase() async {
    try {
      AppLogger.info('📋 AppInitializationServiceV2: Initializing Firebase...');

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        AppLogger.info('✅ AppInitializationServiceV2: Firebase initialized');
      } else {
        AppLogger.info('✅ AppInitializationServiceV2: Firebase already initialized');
      }
    } catch (e) {
      AppLogger.error('❌ AppInitializationServiceV2: Firebase initialization failed: $e');
      
      // Don't fail the entire app if Firebase fails - some features will be limited
      AppLogger.warning('⚠️ AppInitializationServiceV2: Continuing without Firebase - some features will be limited');
    }
  }

  /// Initialize all managers and services
  static Future<void> _initializeManagers() async {
    try {
      AppLogger.info('📋 AppInitializationServiceV2: Initializing managers...');

      // Initialize the manager factory which handles all service dependencies
      final managerFactory = ManagerFactory();
      await managerFactory.initialize();

      AppLogger.info('✅ AppInitializationServiceV2: All managers initialized successfully');
    } catch (e) {
      AppLogger.error('❌ AppInitializationServiceV2: Manager initialization failed: $e');
      rethrow;
    }
  }

  /// Get initialization status
  static bool get isInitialized => _isInitialized;

  /// Reset initialization (mainly for testing)
  static void reset() {
    _isInitialized = false;
    ManagerFactory.reset();
  }

  /// Dispose all resources
  static void dispose() {
    if (_isInitialized) {
      ManagerFactory().dispose();
      _isInitialized = false;
      AppLogger.info('✅ AppInitializationServiceV2: All resources disposed');
    }
  }
}
