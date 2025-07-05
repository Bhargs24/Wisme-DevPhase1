import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../error/exceptions.dart';

/// Network connectivity status
enum NetworkStatus {
  connected,
  disconnected,
  unknown,
}

/// Network connection type
enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  bluetooth,
  vpn,
  other,
  none,
}

/// Network connectivity service
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();
  
  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _statusController = StreamController.broadcast();
  final StreamController<ConnectionType> _typeController = StreamController.broadcast();
  
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  ConnectionType _currentType = ConnectionType.none;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _pingTimer;
  
  // Public streams
  Stream<NetworkStatus> get statusStream => _statusController.stream;
  Stream<ConnectionType> get typeStream => _typeController.stream;
  
  // Current state getters
  NetworkStatus get currentStatus => _currentStatus;
  ConnectionType get currentType => _currentType;
  bool get isConnected => _currentStatus == NetworkStatus.connected;
  bool get isDisconnected => _currentStatus == NetworkStatus.disconnected;
  
  /// Initialize network monitoring
  Future<void> initialize() async {
    await _checkInitialConnectivity();
    _startConnectivityMonitoring();
    _startPeriodicPing();
  }
  
  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _pingTimer?.cancel();
    _statusController.close();
    _typeController.close();
  }
  
  /// Check internet connectivity with ping test
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Check connectivity to specific host
  Future<bool> canReachHost(String host, {Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final result = await InternetAddress.lookup(host).timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Get network speed estimate (simplified)
  Future<NetworkSpeed> getNetworkSpeed() async {
    if (!isConnected) {
      return NetworkSpeed.none;
    }
    
    try {
      final stopwatch = Stopwatch()..start();
      await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 2),
      );
      stopwatch.stop();
      
      final latency = stopwatch.elapsedMilliseconds;
      
      if (latency < 100) return NetworkSpeed.fast;
      if (latency < 300) return NetworkSpeed.medium;
      if (latency < 1000) return NetworkSpeed.slow;
      return NetworkSpeed.verySlow;
    } catch (e) {
      return NetworkSpeed.unknown;
    }
  }
  
  /// Wait for network connection
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (isConnected) return;
    
    final completer = Completer<void>();
    late StreamSubscription subscription;
    late Timer timeoutTimer;
    
    subscription = statusStream.listen((status) {
      if (status == NetworkStatus.connected) {
        timeoutTimer.cancel();
        subscription.cancel();
        completer.complete();
      }
    });
    
    timeoutTimer = Timer(timeout, () {
      subscription.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          NetworkException.timeout(),
        );
      }
    });
    
    return completer.future;
  }
  
  /// Execute operation with network retry
  Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool requireConnection = true,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        if (requireConnection && !isConnected) {
          await waitForConnection(timeout: const Duration(seconds: 10));
        }
        
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        if (e is NetworkException || e is SocketException) {
          await Future.delayed(delay * attempts);
        } else {
          rethrow;
        }
      }
    }
    
    throw NetworkException('Max retries exceeded');
  }
  
  /// Check initial connectivity
  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      await _updateConnectivity(connectivityResults);
    } catch (e) {
      _updateStatus(NetworkStatus.unknown);
      _updateType(ConnectionType.none);
    }
  }
  
  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
      onError: (error) {
        _updateStatus(NetworkStatus.unknown);
      },
    );
  }
  
  /// Start periodic ping test
  void _startPeriodicPing() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_currentStatus != NetworkStatus.disconnected) {
        final hasInternet = await hasInternetConnection();
        final newStatus = hasInternet 
            ? NetworkStatus.connected 
            : NetworkStatus.disconnected;
        
        if (newStatus != _currentStatus) {
          _updateStatus(newStatus);
        }
      }
    });
  }
  
  /// Update connectivity based on connectivity results
  Future<void> _updateConnectivity(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _updateStatus(NetworkStatus.disconnected);
      _updateType(ConnectionType.none);
      return;
    }
    
    // Determine connection type
    ConnectionType type = ConnectionType.none;
    if (results.contains(ConnectivityResult.wifi)) {
      type = ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      type = ConnectionType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      type = ConnectionType.ethernet;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      type = ConnectionType.bluetooth;
    } else if (results.contains(ConnectivityResult.vpn)) {
      type = ConnectionType.vpn;
    } else if (results.contains(ConnectivityResult.other)) {
      type = ConnectionType.other;
    }
    
    _updateType(type);
    
    // Check actual internet connectivity
    final hasInternet = await hasInternetConnection();
    final status = hasInternet 
        ? NetworkStatus.connected 
        : NetworkStatus.disconnected;
    
    _updateStatus(status);
  }
  
  /// Update network status
  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }
  
  /// Update connection type
  void _updateType(ConnectionType type) {
    if (_currentType != type) {
      _currentType = type;
      _typeController.add(type);
    }
  }
}

/// Network speed categories
enum NetworkSpeed {
  none,
  verySlow,
  slow,
  medium,
  fast,
  unknown,
}

/// Network utilities
class NetworkUtils {
  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
           error is NetworkException ||
           error is TimeoutException ||
           (error is Exception && error.toString().contains('network'));
  }
  
  /// Get user-friendly network error message
  static String getNetworkErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }
    
    if (error is SocketException) {
      return 'Network connection failed. Please check your internet connection.';
    }
    
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    
    return 'Network error. Please check your connection and try again.';
  }
  
  /// Format connection type for display
  static String formatConnectionType(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
        return 'Wi-Fi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.other:
        return 'Other';
      case ConnectionType.none:
        return 'No Connection';
    }
  }
  
  /// Format network speed for display
  static String formatNetworkSpeed(NetworkSpeed speed) {
    switch (speed) {
      case NetworkSpeed.fast:
        return 'Fast';
      case NetworkSpeed.medium:
        return 'Medium';
      case NetworkSpeed.slow:
        return 'Slow';
      case NetworkSpeed.verySlow:
        return 'Very Slow';
      case NetworkSpeed.none:
        return 'No Connection';
      case NetworkSpeed.unknown:
        return 'Unknown';
    }
  }
  
  /// Get icon for connection type
  static String getConnectionTypeIcon(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
        return '📶';
      case ConnectionType.mobile:
        return '📱';
      case ConnectionType.ethernet:
        return '🔌';
      case ConnectionType.bluetooth:
        return '🔵';
      case ConnectionType.vpn:
        return '🔒';
      case ConnectionType.other:
        return '🌐';
      case ConnectionType.none:
        return '❌';
    }
  }
  
  /// Check if connection type is metered
  static bool isMeteredConnection(ConnectionType type) {
    return type == ConnectionType.mobile || type == ConnectionType.bluetooth;
  }
  
  /// Check if connection is suitable for large downloads
  static bool isSuitableForLargeDownloads(ConnectionType type, NetworkSpeed speed) {
    if (type == ConnectionType.none) return false;
    if (isMeteredConnection(type)) return false;
    return speed == NetworkSpeed.fast || speed == NetworkSpeed.medium;
  }
  
  /// Get recommended quality based on connection
  static String getRecommendedQuality(ConnectionType type, NetworkSpeed speed) {
    if (!NetworkService().isConnected) return 'offline';
    
    if (isMeteredConnection(type)) {
      switch (speed) {
        case NetworkSpeed.fast:
          return 'medium';
        case NetworkSpeed.medium:
          return 'low';
        default:
          return 'minimal';
      }
    }
    
    switch (speed) {
      case NetworkSpeed.fast:
        return 'high';
      case NetworkSpeed.medium:
        return 'medium';
      case NetworkSpeed.slow:
        return 'low';
      default:
        return 'minimal';
    }
  }
}
