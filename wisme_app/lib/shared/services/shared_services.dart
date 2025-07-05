import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/shared_models.dart';

/// Device information service
class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();
  
  static const MethodChannel _channel = MethodChannel('wisme/device_info');
  
  Map<String, dynamic>? _deviceInfo;
  
  /// Get device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_deviceInfo != null) return _deviceInfo!;
    
    try {
      final info = await _channel.invokeMapMethod<String, dynamic>('getDeviceInfo');
      _deviceInfo = info ?? {};
      return _deviceInfo!;
    } catch (e) {
      // Fallback device info
      _deviceInfo = {
        'platform': 'unknown',
        'model': 'unknown',
        'version': 'unknown',
        'manufacturer': 'unknown',
        'isPhysicalDevice': true,
      };
      return _deviceInfo!;
    }
  }
  
  /// Get device platform
  Future<String> getPlatform() async {
    final info = await getDeviceInfo();
    return info['platform'] as String? ?? 'unknown';
  }
  
  /// Get device model
  Future<String> getModel() async {
    final info = await getDeviceInfo();
    return info['model'] as String? ?? 'unknown';
  }
  
  /// Get OS version
  Future<String> getVersion() async {
    final info = await getDeviceInfo();
    return info['version'] as String? ?? 'unknown';
  }
  
  /// Get device manufacturer
  Future<String> getManufacturer() async {
    final info = await getDeviceInfo();
    return info['manufacturer'] as String? ?? 'unknown';
  }
  
  /// Check if running on physical device
  Future<bool> isPhysicalDevice() async {
    final info = await getDeviceInfo();
    return info['isPhysicalDevice'] as bool? ?? true;
  }
  
  /// Get device unique identifier
  Future<String> getDeviceId() async {
    final info = await getDeviceInfo();
    return info['deviceId'] as String? ?? 'unknown';
  }
  
  /// Get device capabilities
  Future<DeviceCapabilities> getCapabilities() async {
    final info = await getDeviceInfo();
    final capabilities = info['capabilities'] as Map<String, dynamic>? ?? {};
    
    return DeviceCapabilities(
      hasCamera: capabilities['hasCamera'] as bool? ?? false,
      hasMicrophone: capabilities['hasMicrophone'] as bool? ?? false,
      hasBiometric: capabilities['hasBiometric'] as bool? ?? false,
      hasNFC: capabilities['hasNFC'] as bool? ?? false,
      hasGPS: capabilities['hasGPS'] as bool? ?? false,
      hasAccelerometer: capabilities['hasAccelerometer'] as bool? ?? false,
      hasGyroscope: capabilities['hasGyroscope'] as bool? ?? false,
    );
  }
}

/// Device capabilities model
class DeviceCapabilities {
  final bool hasCamera;
  final bool hasMicrophone;
  final bool hasBiometric;
  final bool hasNFC;
  final bool hasGPS;
  final bool hasAccelerometer;
  final bool hasGyroscope;
  
  const DeviceCapabilities({
    required this.hasCamera,
    required this.hasMicrophone,
    required this.hasBiometric,
    required this.hasNFC,
    required this.hasGPS,
    required this.hasAccelerometer,
    required this.hasGyroscope,
  });
  
  Map<String, dynamic> toJson() => {
    'hasCamera': hasCamera,
    'hasMicrophone': hasMicrophone,
    'hasBiometric': hasBiometric,
    'hasNFC': hasNFC,
    'hasGPS': hasGPS,
    'hasAccelerometer': hasAccelerometer,
    'hasGyroscope': hasGyroscope,
  };
}

/// Permission service for handling app permissions
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();
  
  static const MethodChannel _channel = MethodChannel('wisme/permissions');
  
  /// Request permission
  Future<PermissionStatus> requestPermission(Permission permission) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'requestPermission',
        {'permission': permission.name},
      );
      return PermissionStatus.values.firstWhere(
        (status) => status.name == result,
        orElse: () => PermissionStatus.denied,
      );
    } catch (e) {
      return PermissionStatus.denied;
    }
  }
  
  /// Check permission status
  Future<PermissionStatus> checkPermission(Permission permission) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'checkPermission',
        {'permission': permission.name},
      );
      return PermissionStatus.values.firstWhere(
        (status) => status.name == result,
        orElse: () => PermissionStatus.denied,
      );
    } catch (e) {
      return PermissionStatus.denied;
    }
  }
  
  /// Request multiple permissions
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    final results = <Permission, PermissionStatus>{};
    
    for (final permission in permissions) {
      results[permission] = await requestPermission(permission);
    }
    
    return results;
  }
  
  /// Check if permission is granted
  Future<bool> isPermissionGranted(Permission permission) async {
    final status = await checkPermission(permission);
    return status == PermissionStatus.granted;
  }
  
  /// Open app settings
  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } catch (e) {
      // Handle error
    }
  }
}

/// Permission types
enum Permission {
  camera,
  microphone,
  storage,
  location,
  notifications,
  contacts,
  calendar,
  photos,
}

/// Permission status
enum PermissionStatus {
  granted,
  denied,
  restricted,
  permanentlyDenied,
}

/// Haptic feedback service
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();
  
  /// Light haptic feedback
  Future<void> light() async {
    await HapticFeedback.lightImpact();
  }
  
  /// Medium haptic feedback
  Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }
  
  /// Heavy haptic feedback
  Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }
  
  /// Selection haptic feedback
  Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
  
  /// Vibration pattern
  Future<void> vibrate({Duration duration = const Duration(milliseconds: 100)}) async {
    await HapticFeedback.vibrate();
  }
  
  /// Success haptic feedback
  Future<void> success() async {
    await light();
  }
  
  /// Error haptic feedback
  Future<void> error() async {
    await heavy();
  }
  
  /// Warning haptic feedback
  Future<void> warning() async {
    await medium();
  }
}

/// App lifecycle service
class AppLifecycleService {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();
  
  final StreamController<AppLifecycleState> _stateController = 
      StreamController.broadcast();
  
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  
  /// Get current app state
  AppLifecycleState get currentState => _currentState;
  
  /// Get app state stream
  Stream<AppLifecycleState> get stateStream => _stateController.stream;
  
  /// Initialize lifecycle monitoring
  void initialize() {
    // This would typically use WidgetsBindingObserver
    // For now, we'll simulate state changes
  }
  
  /// Dispose resources
  void dispose() {
    _stateController.close();
  }
  
  /// Update app state
  void _updateState(AppLifecycleState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }
  
  /// Check if app is in foreground
  bool get isInForeground => _currentState == AppLifecycleState.resumed;
  
  /// Check if app is in background
  bool get isInBackground => _currentState != AppLifecycleState.resumed;
}

/// Clipboard service
class ClipboardService {
  static final ClipboardService _instance = ClipboardService._internal();
  factory ClipboardService() => _instance;
  ClipboardService._internal();
  
  /// Copy text to clipboard
  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
  
  /// Paste text from clipboard
  Future<String?> pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
  
  /// Check if clipboard has text
  Future<bool> hasText() async {
    return await Clipboard.hasStrings();
  }
  
  /// Clear clipboard
  Future<void> clear() async {
    await Clipboard.setData(const ClipboardData(text: ''));
  }
}

/// Share service
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();
  
  static const MethodChannel _channel = MethodChannel('wisme/share');
  
  /// Share text
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await _channel.invokeMethod('shareText', {
        'text': text,
        'subject': subject,
      });
    } catch (e) {
      // Handle error
    }
  }
  
  /// Share file
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      await _channel.invokeMethod('shareFile', {
        'filePath': filePath,
        'subject': subject,
      });
    } catch (e) {
      // Handle error
    }
  }
  
  /// Share multiple files
  Future<void> shareFiles(List<String> filePaths, {String? subject}) async {
    try {
      await _channel.invokeMethod('shareFiles', {
        'filePaths': filePaths,
        'subject': subject,
      });
    } catch (e) {
      // Handle error
    }
  }
}

/// Deep link service
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();
  
  final StreamController<String> _linkController = StreamController.broadcast();
  
  /// Get deep link stream
  Stream<String> get linkStream => _linkController.stream;
  
  /// Initialize deep link handling
  void initialize() {
    // This would typically integrate with platform-specific deep link handling
  }
  
  /// Dispose resources
  void dispose() {
    _linkController.close();
  }
  
  /// Handle incoming deep link
  void handleDeepLink(String link) {
    _linkController.add(link);
  }
  
  /// Parse deep link
  DeepLink? parseDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      return DeepLink(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path,
        queryParameters: uri.queryParameters,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Deep link model
class DeepLink {
  final String scheme;
  final String host;
  final String path;
  final Map<String, String> queryParameters;
  
  const DeepLink({
    required this.scheme,
    required this.host,
    required this.path,
    required this.queryParameters,
  });
  
  /// Get full URL
  String get url => '$scheme://$host$path${_buildQueryString()}';
  
  String _buildQueryString() {
    if (queryParameters.isEmpty) return '';
    final params = queryParameters.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '?$params';
  }
  
  Map<String, dynamic> toJson() => {
    'scheme': scheme,
    'host': host,
    'path': path,
    'queryParameters': queryParameters,
  };
}

/// Notification service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  static const MethodChannel _channel = MethodChannel('wisme/notifications');
  
  /// Initialize notifications
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } catch (e) {
      // Handle error
    }
  }
  
  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
        'payload': payload,
      });
    } catch (e) {
      // Handle error
    }
  }
  
  /// Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await _channel.invokeMethod('scheduleNotification', {
        'title': title,
        'body': body,
        'scheduledDate': scheduledDate.millisecondsSinceEpoch,
        'payload': payload,
      });
    } catch (e) {
      // Handle error
    }
  }
  
  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _channel.invokeMethod('cancelNotification', {'id': id});
    } catch (e) {
      // Handle error
    }
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _channel.invokeMethod('cancelAllNotifications');
    } catch (e) {
      // Handle error
    }
  }
}
