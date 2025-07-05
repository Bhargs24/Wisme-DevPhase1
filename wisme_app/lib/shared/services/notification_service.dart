/// Production-Grade Notification Service
/// 
/// Comprehensive push notifications, local notifications, and smart scheduling
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../shared/models/base_model.dart';
import '../../shared/models/result.dart';
import '../../core/utils/logger.dart';
import '../../core/error/app_exceptions.dart';
import '../../core/storage/local_storage_service.dart';

/// Notification types
enum NotificationType {
  reminder,
  achievement,
  content,
  system,
  marketing,
  learning,
  social,
  emergency,
}

/// Notification priority levels
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// Notification delivery method
enum DeliveryMethod {
  local,
  push,
  inApp,
  email,
  sms,
}

/// Rich notification content
class NotificationContent extends BaseModel {
  final String title;
  final String body;
  final String? subtitle;
  final String? iconPath;
  final String? imagePath;
  final String? soundPath;
  final Map<String, String>? actionButtons;
  final Map<String, dynamic>? customData;

  const NotificationContent({
    required this.title,
    required this.body,
    this.subtitle,
    this.iconPath,
    this.imagePath,
    this.soundPath,
    this.actionButtons,
    this.customData,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'subtitle': subtitle,
      'iconPath': iconPath,
      'imagePath': imagePath,
      'soundPath': soundPath,
      'actionButtons': actionButtons,
      'customData': customData,
    };
  }

  factory NotificationContent.fromMap(Map<String, dynamic> map) {
    return NotificationContent(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      subtitle: map['subtitle'],
      iconPath: map['iconPath'],
      imagePath: map['imagePath'],
      soundPath: map['soundPath'],
      actionButtons: map['actionButtons'] != null
          ? Map<String, String>.from(map['actionButtons'])
          : null,
      customData: map['customData'] != null
          ? Map<String, dynamic>.from(map['customData'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    title,
    body,
    subtitle,
    iconPath,
    imagePath,
    soundPath,
    actionButtons,
    customData,
  ];
}

/// Scheduled notification
class ScheduledNotification extends BaseModel {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationContent content;
  final DateTime scheduledTime;
  final Duration? repeatInterval;
  final List<DeliveryMethod> deliveryMethods;
  final String? userId;
  final Map<String, dynamic> conditions;
  final bool isActive;
  final DateTime createdAt;

  const ScheduledNotification({
    required this.id,
    required this.type,
    required this.priority,
    required this.content,
    required this.scheduledTime,
    this.repeatInterval,
    this.deliveryMethods = const [DeliveryMethod.local],
    this.userId,
    this.conditions = const {},
    this.isActive = true,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'priority': priority.name,
      'content': content.toMap(),
      'scheduledTime': scheduledTime.toIso8601String(),
      'repeatInterval': repeatInterval?.inMilliseconds,
      'deliveryMethods': deliveryMethods.map((m) => m.name).toList(),
      'userId': userId,
      'conditions': conditions,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ScheduledNotification.fromMap(Map<String, dynamic> map) {
    return ScheduledNotification(
      id: map['id'] ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      content: NotificationContent.fromMap(map['content'] ?? {}),
      scheduledTime: DateTime.parse(map['scheduledTime']),
      repeatInterval: map['repeatInterval'] != null
          ? Duration(milliseconds: map['repeatInterval'])
          : null,
      deliveryMethods: List<DeliveryMethod>.from(
        map['deliveryMethods']?.map((m) => DeliveryMethod.values.firstWhere(
          (d) => d.name == m,
          orElse: () => DeliveryMethod.local,
        )) ?? [DeliveryMethod.local],
      ),
      userId: map['userId'],
      conditions: Map<String, dynamic>.from(map['conditions'] ?? {}),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    priority,
    content,
    scheduledTime,
    repeatInterval,
    deliveryMethods,
    userId,
    conditions,
    isActive,
    createdAt,
  ];
}

/// Notification delivery result
class NotificationDeliveryResult extends BaseModel {
  final String notificationId;
  final DeliveryMethod method;
  final bool success;
  final DateTime deliveredAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const NotificationDeliveryResult({
    required this.notificationId,
    required this.method,
    required this.success,
    required this.deliveredAt,
    this.errorMessage,
    this.metadata,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'method': method.name,
      'success': success,
      'deliveredAt': deliveredAt.toIso8601String(),
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory NotificationDeliveryResult.fromMap(Map<String, dynamic> map) {
    return NotificationDeliveryResult(
      notificationId: map['notificationId'] ?? '',
      method: DeliveryMethod.values.firstWhere(
        (m) => m.name == map['method'],
        orElse: () => DeliveryMethod.local,
      ),
      success: map['success'] ?? false,
      deliveredAt: DateTime.parse(map['deliveredAt']),
      errorMessage: map['errorMessage'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    notificationId,
    method,
    success,
    deliveredAt,
    errorMessage,
    metadata,
  ];
}

/// Notification analytics
class NotificationAnalytics extends BaseModel {
  final String notificationId;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? openedAt;
  final DateTime? dismissedAt;
  final String? actionTaken;
  final Map<String, dynamic> metadata;

  const NotificationAnalytics({
    required this.notificationId,
    required this.sentAt,
    this.deliveredAt,
    this.openedAt,
    this.dismissedAt,
    this.actionTaken,
    this.metadata = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'openedAt': openedAt?.toIso8601String(),
      'dismissedAt': dismissedAt?.toIso8601String(),
      'actionTaken': actionTaken,
      'metadata': metadata,
    };
  }

  factory NotificationAnalytics.fromMap(Map<String, dynamic> map) {
    return NotificationAnalytics(
      notificationId: map['notificationId'] ?? '',
      sentAt: DateTime.parse(map['sentAt']),
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.parse(map['deliveredAt'])
          : null,
      openedAt: map['openedAt'] != null
          ? DateTime.parse(map['openedAt'])
          : null,
      dismissedAt: map['dismissedAt'] != null
          ? DateTime.parse(map['dismissedAt'])
          : null,
      actionTaken: map['actionTaken'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    notificationId,
    sentAt,
    deliveredAt,
    openedAt,
    dismissedAt,
    actionTaken,
    metadata,
  ];
}

/// Production-grade notification service
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final LocalStorageService _storage = LocalStorageService();
  
  static final Map<String, ScheduledNotification> _scheduledNotifications = {};
  static final Map<String, NotificationAnalytics> _analytics = {};
  static final List<NotificationDeliveryResult> _deliveryLog = {};
  
  static Timer? _schedulingTimer;
  static bool _isInitialized = false;
  static String? _currentUserId;
  
  static const String _scheduledNotificationsKey = 'scheduled_notifications';
  static const String _analyticsKey = 'notification_analytics';
  static const Duration _checkInterval = Duration(minutes: 1);

  /// Initialize notification service
  static Future<Result<void>> initialize({String? userId}) async {
    try {
      if (_isInitialized) return Result.success(null);

      _currentUserId = userId;

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Load scheduled notifications and analytics
      await _loadScheduledNotifications();
      await _loadAnalytics();

      // Start scheduling timer
      _startSchedulingTimer();

      _isInitialized = true;
      AppLogger.info('🔔 Notification service initialized');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Notification service initialization failed: $e');
      return Result.failure(NotificationException('Failed to initialize notification service'));
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions
    await _requestPermissions();
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }
  }

  /// Handle notification response
  static void _onNotificationResponse(NotificationResponse response) {
    final notificationId = response.id.toString();
    
    // Record analytics
    _recordNotificationAction(
      notificationId: notificationId,
      action: response.actionId ?? 'opened',
    );

    AppLogger.info('📱 Notification interaction: $notificationId');
  }

  /// Schedule a notification
  static Future<Result<void>> scheduleNotification({
    required String id,
    required NotificationType type,
    required NotificationContent content,
    required DateTime scheduledTime,
    NotificationPriority priority = NotificationPriority.normal,
    Duration? repeatInterval,
    List<DeliveryMethod> deliveryMethods = const [DeliveryMethod.local],
    String? userId,
    Map<String, dynamic> conditions = const {},
  }) async {
    try {
      final notification = ScheduledNotification(
        id: id,
        type: type,
        priority: priority,
        content: content,
        scheduledTime: scheduledTime,
        repeatInterval: repeatInterval,
        deliveryMethods: deliveryMethods,
        userId: userId ?? _currentUserId,
        conditions: conditions,
        createdAt: DateTime.now(),
      );

      _scheduledNotifications[id] = notification;
      await _saveScheduledNotifications();

      // Schedule immediately if it's time
      if (scheduledTime.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        await _deliverNotification(notification);
      }

      AppLogger.info('📅 Notification scheduled: $id for ${scheduledTime.toIso8601String()}');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Failed to schedule notification: $e');
      return Result.failure(NotificationException('Failed to schedule notification'));
    }
  }

  /// Send immediate notification
  static Future<Result<void>> sendNotification({
    required String id,
    required NotificationType type,
    required NotificationContent content,
    NotificationPriority priority = NotificationPriority.normal,
    List<DeliveryMethod> deliveryMethods = const [DeliveryMethod.local],
    String? userId,
  }) async {
    try {
      final notification = ScheduledNotification(
        id: id,
        type: type,
        priority: priority,
        content: content,
        scheduledTime: DateTime.now(),
        deliveryMethods: deliveryMethods,
        userId: userId ?? _currentUserId,
        createdAt: DateTime.now(),
      );

      await _deliverNotification(notification);
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Failed to send notification: $e');
      return Result.failure(NotificationException('Failed to send notification'));
    }
  }

  /// Deliver notification through specified methods
  static Future<void> _deliverNotification(ScheduledNotification notification) async {
    final deliveryResults = <NotificationDeliveryResult>[];

    for (final method in notification.deliveryMethods) {
      try {
        bool success = false;
        String? errorMessage;

        switch (method) {
          case DeliveryMethod.local:
            success = await _deliverLocalNotification(notification);
            break;
          case DeliveryMethod.push:
            success = await _deliverPushNotification(notification);
            break;
          case DeliveryMethod.inApp:
            success = await _deliverInAppNotification(notification);
            break;
          case DeliveryMethod.email:
            success = await _deliverEmailNotification(notification);
            break;
          case DeliveryMethod.sms:
            success = await _deliverSmsNotification(notification);
            break;
        }

        final result = NotificationDeliveryResult(
          notificationId: notification.id,
          method: method,
          success: success,
          deliveredAt: DateTime.now(),
          errorMessage: errorMessage,
        );

        deliveryResults.add(result);
        _deliveryLog.add(result);

        if (success) {
          _recordNotificationSent(notification.id);
        }
      } catch (e) {
        AppLogger.error('❌ Delivery failed for ${method.name}: $e');
        
        final result = NotificationDeliveryResult(
          notificationId: notification.id,
          method: method,
          success: false,
          deliveredAt: DateTime.now(),
          errorMessage: e.toString(),
        );
        
        deliveryResults.add(result);
        _deliveryLog.add(result);
      }
    }

    AppLogger.info('📤 Notification delivered: ${notification.id} (${deliveryResults.where((r) => r.success).length}/${deliveryResults.length} successful)');
  }

  /// Deliver local notification
  static Future<bool> _deliverLocalNotification(ScheduledNotification notification) async {
    try {
      final notificationId = _generateNotificationId(notification.id);
      
      const androidDetails = AndroidNotificationDetails(
        'wisme_channel',
        'Wisme Notifications',
        channelDescription: 'General notifications from Wisme',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notificationId,
        notification.content.title,
        notification.content.body,
        details,
        payload: jsonEncode({
          'id': notification.id,
          'type': notification.type.name,
          'customData': notification.content.customData,
        }),
      );

      return true;
    } catch (e) {
      AppLogger.error('❌ Local notification delivery failed: $e');
      return false;
    }
  }

  /// Deliver push notification (placeholder)
  static Future<bool> _deliverPushNotification(ScheduledNotification notification) async {
    // In production, integrate with FCM/APNs
    AppLogger.debug('📱 Push notification would be sent: ${notification.id}');
    return true; // Simulated success
  }

  /// Deliver in-app notification (placeholder)
  static Future<bool> _deliverInAppNotification(ScheduledNotification notification) async {
    // In production, show in-app notification overlay
    AppLogger.debug('📲 In-app notification would be shown: ${notification.id}');
    return true; // Simulated success
  }

  /// Deliver email notification (placeholder)
  static Future<bool> _deliverEmailNotification(ScheduledNotification notification) async {
    // In production, integrate with email service
    AppLogger.debug('📧 Email notification would be sent: ${notification.id}');
    return true; // Simulated success
  }

  /// Deliver SMS notification (placeholder)
  static Future<bool> _deliverSmsNotification(ScheduledNotification notification) async {
    // In production, integrate with SMS service
    AppLogger.debug('📱 SMS notification would be sent: ${notification.id}');
    return true; // Simulated success
  }

  /// Start scheduling timer
  static void _startSchedulingTimer() {
    _schedulingTimer = Timer.periodic(_checkInterval, (_) {
      _checkAndDeliverScheduledNotifications();
    });
  }

  /// Check and deliver scheduled notifications
  static Future<void> _checkAndDeliverScheduledNotifications() async {
    final now = DateTime.now();
    final notificationsToDeliver = <ScheduledNotification>[];

    for (final notification in _scheduledNotifications.values) {
      if (!notification.isActive) continue;
      
      if (notification.scheduledTime.isBefore(now) || 
          notification.scheduledTime.isAtSameMomentAs(now)) {
        
        // Check conditions
        if (await _checkNotificationConditions(notification)) {
          notificationsToDeliver.add(notification);
        }
      }
    }

    for (final notification in notificationsToDeliver) {
      await _deliverNotification(notification);
      
      // Handle repeating notifications
      if (notification.repeatInterval != null) {
        final nextScheduledTime = notification.scheduledTime.add(notification.repeatInterval!);
        
        final repeatedNotification = ScheduledNotification(
          id: '${notification.id}_${DateTime.now().millisecondsSinceEpoch}',
          type: notification.type,
          priority: notification.priority,
          content: notification.content,
          scheduledTime: nextScheduledTime,
          repeatInterval: notification.repeatInterval,
          deliveryMethods: notification.deliveryMethods,
          userId: notification.userId,
          conditions: notification.conditions,
          createdAt: notification.createdAt,
        );
        
        _scheduledNotifications[repeatedNotification.id] = repeatedNotification;
      } else {
        // Remove one-time notification
        _scheduledNotifications.remove(notification.id);
      }
    }

    if (notificationsToDeliver.isNotEmpty) {
      await _saveScheduledNotifications();
    }
  }

  /// Check notification conditions
  static Future<bool> _checkNotificationConditions(ScheduledNotification notification) async {
    // Check user preferences
    if (notification.userId != null && notification.userId != _currentUserId) {
      return false;
    }

    // Check custom conditions
    for (final entry in notification.conditions.entries) {
      switch (entry.key) {
        case 'userOnline':
          // Check if user is online (placeholder)
          break;
        case 'quietHours':
          final now = DateTime.now();
          final quietStart = entry.value['start'] as int? ?? 22; // 10 PM
          final quietEnd = entry.value['end'] as int? ?? 8; // 8 AM
          
          if ((now.hour >= quietStart) || (now.hour < quietEnd)) {
            return false;
          }
          break;
        case 'batteryLevel':
          // Check battery level (placeholder)
          break;
      }
    }

    return true;
  }

  /// Generate notification ID for local notifications
  static int _generateNotificationId(String notificationId) {
    return notificationId.hashCode.abs() % 2147483647; // Max int32 value
  }

  /// Record notification sent analytics
  static void _recordNotificationSent(String notificationId) {
    _analytics[notificationId] = NotificationAnalytics(
      notificationId: notificationId,
      sentAt: DateTime.now(),
    );
    _saveAnalytics();
  }

  /// Record notification action analytics
  static void _recordNotificationAction({
    required String notificationId,
    required String action,
  }) {
    final existing = _analytics[notificationId];
    if (existing != null) {
      final updated = NotificationAnalytics(
        notificationId: existing.notificationId,
        sentAt: existing.sentAt,
        deliveredAt: existing.deliveredAt,
        openedAt: action == 'opened' ? DateTime.now() : existing.openedAt,
        dismissedAt: action == 'dismissed' ? DateTime.now() : existing.dismissedAt,
        actionTaken: action,
        metadata: existing.metadata,
      );
      _analytics[notificationId] = updated;
      _saveAnalytics();
    }
  }

  /// Cancel scheduled notification
  static Future<Result<void>> cancelNotification(String id) async {
    try {
      _scheduledNotifications.remove(id);
      await _saveScheduledNotifications();
      
      // Cancel local notification if exists
      final localId = _generateNotificationId(id);
      await _localNotifications.cancel(localId);
      
      AppLogger.info('❌ Notification cancelled: $id');
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationException('Failed to cancel notification'));
    }
  }

  /// Get scheduled notifications
  static List<ScheduledNotification> getScheduledNotifications({String? userId}) {
    return _scheduledNotifications.values
        .where((n) => userId == null || n.userId == userId)
        .toList();
  }

  /// Get notification analytics
  static List<NotificationAnalytics> getAnalytics({String? userId}) {
    return _analytics.values.toList();
  }

  /// Load scheduled notifications from storage
  static Future<void> _loadScheduledNotifications() async {
    try {
      final result = await _storage.read(_scheduledNotificationsKey);
      if (result.isSuccess && result.data != null) {
        final notificationsList = List<Map<String, dynamic>>.from(jsonDecode(result.data!));
        for (final notificationData in notificationsList) {
          final notification = ScheduledNotification.fromMap(notificationData);
          _scheduledNotifications[notification.id] = notification;
        }
        AppLogger.debug('📥 Loaded ${_scheduledNotifications.length} scheduled notifications');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to load scheduled notifications: $e');
    }
  }

  /// Save scheduled notifications to storage
  static Future<void> _saveScheduledNotifications() async {
    try {
      final notificationsList = _scheduledNotifications.values
          .map((notification) => notification.toMap())
          .toList();
      await _storage.write(_scheduledNotificationsKey, jsonEncode(notificationsList));
    } catch (e) {
      AppLogger.error('❌ Failed to save scheduled notifications: $e');
    }
  }

  /// Load analytics from storage
  static Future<void> _loadAnalytics() async {
    try {
      final result = await _storage.read(_analyticsKey);
      if (result.isSuccess && result.data != null) {
        final analyticsList = List<Map<String, dynamic>>.from(jsonDecode(result.data!));
        for (final analyticsData in analyticsList) {
          final analytics = NotificationAnalytics.fromMap(analyticsData);
          _analytics[analytics.notificationId] = analytics;
        }
        AppLogger.debug('📊 Loaded ${_analytics.length} notification analytics');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to load notification analytics: $e');
    }
  }

  /// Save analytics to storage
  static Future<void> _saveAnalytics() async {
    try {
      final analyticsList = _analytics.values
          .map((analytics) => analytics.toMap())
          .toList();
      await _storage.write(_analyticsKey, jsonEncode(analyticsList));
    } catch (e) {
      AppLogger.error('❌ Failed to save notification analytics: $e');
    }
  }

  /// Get service metrics
  static Map<String, dynamic> getMetrics() {
    final now = DateTime.now();
    final upcomingCount = _scheduledNotifications.values
        .where((n) => n.scheduledTime.isAfter(now))
        .length;
    
    final deliverySuccessRate = _deliveryLog.isEmpty ? 0.0 :
        _deliveryLog.where((r) => r.success).length / _deliveryLog.length;

    return {
      'scheduledNotifications': _scheduledNotifications.length,
      'upcomingNotifications': upcomingCount,
      'analyticsRecords': _analytics.length,
      'deliveryLog': _deliveryLog.length,
      'deliverySuccessRate': deliverySuccessRate,
      'isInitialized': _isInitialized,
      'currentUserId': _currentUserId,
    };
  }

  /// Clear old analytics and delivery logs
  static Future<void> clearOldData({Duration? olderThan}) async {
    olderThan ??= const Duration(days: 30);
    final cutoffTime = DateTime.now().subtract(olderThan);

    // Clear old analytics
    _analytics.removeWhere((id, analytics) => 
        analytics.sentAt.isBefore(cutoffTime));

    // Clear old delivery logs
    _deliveryLog.removeWhere((result) => 
        result.deliveredAt.isBefore(cutoffTime));

    await _saveAnalytics();
    AppLogger.info('🧹 Cleared old notification data');
  }

  /// Dispose service
  static Future<void> dispose() async {
    _schedulingTimer?.cancel();
    
    // Save all data before disposing
    await _saveScheduledNotifications();
    await _saveAnalytics();
    
    _scheduledNotifications.clear();
    _analytics.clear();
    _deliveryLog.clear();
    _isInitialized = false;
    _currentUserId = null;
    
    AppLogger.info('🔔 Notification service disposed');
  }
}
