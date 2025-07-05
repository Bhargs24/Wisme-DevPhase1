import 'dart:async';
import 'package:flutter/foundation.dart';
import 'error/error_handler.dart';
import 'network/network_service.dart';
import 'utils/utils.dart';
import 'utils/logger.dart';
import 'security/security_service.dart';
import 'performance/performance_service.dart';
import 'offline/offline_service.dart';
import 'resilience/resilience_service.dart';
import 'cache/cache_service.dart';
import 'initialization/app_initialization_service.dart';
import 'storage/cloud_storage_service.dart';
import 'data/firestore_data_service.dart';
import '../shared/services/notification_service.dart';

/// Core service initialization status
enum CoreServiceStatus {
  uninitialized,
  initializing,
  initialized,
  error,
}

/// Core manager for centralized app services with advanced features
class CoreManager {
  static final CoreManager _instance = CoreManager._internal();
  factory CoreManager() => _instance;
  CoreManager._internal();
  
  CoreServiceStatus _status = CoreServiceStatus.uninitialized;
  final List<String> _initializedServices = [];
  final Map<String, dynamic> _serviceInstances = {};
  final StreamController<CoreServiceStatus> _statusController = StreamController.broadcast();
  
  // Service getters
  ErrorHandler get errorHandler => _getService<ErrorHandler>('errorHandler');
  NetworkService get networkService => _getService<NetworkService>('networkService');
  CloudStorageService get cloudStorageService => _getService<CloudStorageService>('cloudStorageService');
  FirestoreDataService get firestoreDataService => _getService<FirestoreDataService>('firestoreDataService');
  
  /// Get initialization status
  CoreServiceStatus get status => _status;
  
  /// Get status stream
  Stream<CoreServiceStatus> get statusStream => _statusController.stream;
  
  /// Check if core is initialized
  bool get isInitialized => _status == CoreServiceStatus.initialized;
  
  /// Get list of initialized services
  List<String> get initializedServices => List.unmodifiable(_initializedServices);
  
  /// Initialize all core services with advanced features
  Future<void> initialize() async {
    if (_status == CoreServiceStatus.initializing || _status == CoreServiceStatus.initialized) {
      return;
    }
    
    _updateStatus(CoreServiceStatus.initializing);
    
    try {
      // Initialize advanced services using the new App Initialization Service
      await AppInitializationService.initialize();
      
      // Initialize error handler
      await _initializeErrorHandler();
      
      // Initialize network service
      await _initializeNetworkService();
      
      // Initialize cloud storage service
      await _initializeCloudStorageService();
      
      // Initialize Firestore data service
      await _initializeFirestoreDataService();
      
      // Initialize other core utilities
      await _initializeUtilities();
      
      _updateStatus(CoreServiceStatus.initialized);
      
      if (kDebugMode) {
        print('CoreManager: All services initialized successfully');
        print('Initialized services: ${_initializedServices.join(', ')}');
      }
      
    } catch (error, stackTrace) {
      _updateStatus(CoreServiceStatus.error);
      
      if (kDebugMode) {
        print('CoreManager: Initialization failed - $error');
      }
      
      // If error handler is available, use it
      if (_serviceInstances.containsKey('errorHandler')) {
        errorHandler.handleError(error, stackTrace);
      }
      
      rethrow;
    }
  }
  
  /// Dispose all services
  Future<void> dispose() async {
    try {
      // Dispose network service
      if (_serviceInstances.containsKey('networkService')) {
        networkService.dispose();
      }
      
      // Cleanup app initialization service
      await AppInitializationService.cleanup();
      
      // Dispose resilience service
      ResilienceService.dispose();
      
      _serviceInstances.clear();
      _initializedServices.clear();
      _statusController.close();
      
      _updateStatus(CoreServiceStatus.uninitialized);
      
      if (kDebugMode) {
        print('CoreManager: All services disposed');
      }
      
    } catch (error) {
      if (kDebugMode) {
        print('CoreManager: Error during disposal - $error');
      }
    }
  }
  
  /// Get service instance
  T _getService<T>(String serviceName) {
    if (!_serviceInstances.containsKey(serviceName)) {
      throw StateError('Service $serviceName not initialized. Call CoreManager.initialize() first.');
    }
    return _serviceInstances[serviceName] as T;
  }
  
  /// Register service instance
  void _registerService<T>(String name, T instance) {
    _serviceInstances[name] = instance;
    _initializedServices.add(name);
    
    if (kDebugMode) {
      print('CoreManager: Service $name initialized');
    }
  }
  
  /// Initialize error handler
  Future<void> _initializeErrorHandler() async {
    final errorHandler = ErrorHandler();
    
    // Initialize with app-specific callbacks
    errorHandler.initialize(
      onError: (exception, stackTrace) {
        // TODO: Implement error reporting (Crashlytics, Sentry, etc.)
        if (kDebugMode) {
          print('Error reported: ${exception.message}');
        }
      },
      onUserMessage: (message, severity) {
        // TODO: Show user-friendly error messages (SnackBar, Dialog, etc.)
        if (kDebugMode) {
          print('User message: $message (Severity: $severity)');
        }
      },
    );
    
    _registerService('errorHandler', errorHandler);
  }
  
  /// Initialize network service
  Future<void> _initializeNetworkService() async {
    final networkService = NetworkService();
    await networkService.initialize();
    
    _registerService('networkService', networkService);
  }
  
  /// Initialize cloud storage service
  Future<void> _initializeCloudStorageService() async {
    try {
      final cloudStorageService = CloudStorageService();
      _serviceInstances['cloudStorageService'] = cloudStorageService;
      _initializedServices.add('cloudStorageService');
      AppLogger.info('✅ CloudStorageService initialized');
    } catch (e) {
      AppLogger.error('❌ Failed to initialize CloudStorageService: $e');
      throw Exception('CloudStorageService initialization failed: $e');
    }
  }
  
  /// Initialize Firestore data service
  Future<void> _initializeFirestoreDataService() async {
    try {
      final firestoreDataService = FirestoreDataService();
      _serviceInstances['firestoreDataService'] = firestoreDataService;
      _initializedServices.add('firestoreDataService');
      AppLogger.info('✅ FirestoreDataService initialized');
    } catch (e) {
      AppLogger.error('❌ Failed to initialize FirestoreDataService: $e');
      throw Exception('FirestoreDataService initialization failed: $e');
    }
  }
  
  /// Initialize other utilities
  Future<void> _initializeUtilities() async {
    // Register utility classes that don't need initialization
    _registerService('dateTimeUtils', DateTimeUtils);
    _registerService('stringUtils', StringUtils);
    _registerService('validationUtils', ValidationUtils);
    _registerService('mathUtils', MathUtils);
    _registerService('encryptionUtils', EncryptionUtils);
    _registerService('listUtils', ListUtils);
    _registerService('fileSizeUtils', FileSizeUtils);
    _registerService('platformUtils', PlatformUtils);
  }
  
  /// Update service status
  void _updateStatus(CoreServiceStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }
  
  /// Wait for initialization
  Future<void> waitForInitialization({Duration timeout = const Duration(seconds: 30)}) async {
    if (isInitialized) return;
    
    final completer = Completer<void>();
    late StreamSubscription subscription;
    late Timer timeoutTimer;
    
    subscription = statusStream.listen((status) {
      if (status == CoreServiceStatus.initialized) {
        timeoutTimer.cancel();
        subscription.cancel();
        completer.complete();
      } else if (status == CoreServiceStatus.error) {
        timeoutTimer.cancel();
        subscription.cancel();
        completer.completeError(StateError('Core initialization failed'));
      }
    });
    
    timeoutTimer = Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Core initialization timeout', timeout));
      }
    });
    
    return completer.future;
  }
  
  /// Restart core services
  Future<void> restart() async {
    await dispose();
    await initialize();
  }
  
  /// Get service health status
  Map<String, bool> getServiceHealth() {
    final health = <String, bool>{};
    
    // Check error handler
    health['errorHandler'] = _serviceInstances.containsKey('errorHandler');
    
    // Check network service
    health['networkService'] = _serviceInstances.containsKey('networkService') && 
                               networkService.currentStatus != NetworkStatus.unknown;
    
    return health;
  }
  
  /// Check if all services are healthy
  bool get isHealthy {
    final health = getServiceHealth();
    return health.values.every((isHealthy) => isHealthy);
  }
  
  /// Get core information
  Map<String, dynamic> getCoreInfo() {
    return {
      'status': _status.name,
      'initializedServices': _initializedServices,
      'serviceHealth': getServiceHealth(),
      'isHealthy': isHealthy,
      'networkStatus': _serviceInstances.containsKey('networkService') 
          ? networkService.currentStatus.name 
          : 'unavailable',
      'connectionType': _serviceInstances.containsKey('networkService')
          ? networkService.currentType.name
          : 'unavailable',
    };
  }
  
  /// Execute with core services check
  Future<T> withCore<T>(Future<T> Function() operation) async {
    if (!isInitialized) {
      await waitForInitialization();
    }
    
    if (!isHealthy) {
      throw StateError('Core services are not healthy');
    }
    
    return operation();
  }
  
  /// Execute with error handling
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    bool suppressErrors = false,
  }) async {
    try {
      return await withCore(operation);
    } catch (error, stackTrace) {
      if (!suppressErrors && _serviceInstances.containsKey('errorHandler')) {
        errorHandler.handleError(error, stackTrace);
      }
      return defaultValue;
    }
  }
}

/// Extension for easy access to core services
extension CoreExtension on CoreManager {
  /// Quick access to error handling
  Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    bool suppressErrors = false,
  }) {
    return ErrorHandler.handleAsync(
      operation,
      defaultValue: defaultValue,
      suppressErrors: suppressErrors,
    );
  }
  
  /// Quick access to sync error handling
  T? handleSync<T>(
    T Function() operation, {
    T? defaultValue,
    bool suppressErrors = false,
  }) {
    return ErrorHandler.handleSync(
      operation,
      defaultValue: defaultValue,
      suppressErrors: suppressErrors,
    );
  }
}

/// Global core manager instance
final core = CoreManager();

/// Core initialization result
class CoreInitializationResult {
  final bool success;
  final Duration duration;
  final List<String> initializedServices;
  final String? error;
  
  const CoreInitializationResult({
    required this.success,
    required this.duration,
    required this.initializedServices,
    this.error,
  });
  
  @override
  String toString() {
    return 'CoreInitializationResult(success: $success, duration: $duration, services: $initializedServices${error != null ? ', error: $error' : ''})';
  }
}

/// Core initializer with timing and error tracking
class CoreInitializer {
  /// Initialize core with detailed result
  static Future<CoreInitializationResult> initialize() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      await core.initialize();
      stopwatch.stop();
      
      return CoreInitializationResult(
        success: true,
        duration: stopwatch.elapsed,
        initializedServices: core.initializedServices,
      );
    } catch (error) {
      stopwatch.stop();
      
      return CoreInitializationResult(
        success: false,
        duration: stopwatch.elapsed,
        initializedServices: core.initializedServices,
        error: error.toString(),
      );
    }
  }
}
