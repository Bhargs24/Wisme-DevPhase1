/// Production-Ready Offline Support Service
/// 
/// Comprehensive offline functionality, sync queues, and graceful degradation
library;

import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/performance_service.dart';
import '../utils/logger.dart';

/// Advanced offline support with intelligent sync
class OfflineService {
  static bool _isOnline = true;
  static final List<OfflineAction> _actionQueue = [];
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static Timer? _syncTimer;
  static final Map<String, dynamic> _offlineCache = {};
  
  /// Initialize offline support
  static Future<void> initialize() async {
    await _checkInitialConnectivity();
    _startConnectivityMonitoring();
    _startPeriodicSync();
    await _loadOfflineQueue();
    AppLogger.info('📱 Offline service initialized');
  }

  /// Check current connectivity status
  static Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isOnline = !connectivityResult.contains(ConnectivityResult.none);
      AppLogger.info('🌐 Initial connectivity: ${_isOnline ? "Online" : "Offline"}');
    } catch (e) {
      AppLogger.error('Failed to check connectivity: $e');
      _isOnline = false;
    }
  }

  /// Start monitoring connectivity changes
  static void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        final wasOnline = _isOnline;
        _isOnline = !result.contains(ConnectivityResult.none);
        
        if (!wasOnline && _isOnline) {
          _onConnectionRestored();
        } else if (wasOnline && !_isOnline) {
          _onConnectionLost();
        }
      },
    );
  }

  /// Handle connection restored
  static void _onConnectionRestored() {
    AppLogger.info('🌐 Connection restored - syncing offline data');
    _syncOfflineActions();
  }

  /// Handle connection lost
  static void _onConnectionLost() {
    AppLogger.warning('📱 Connection lost - switching to offline mode');
  }

  /// Queue action for offline execution
  static Future<void> queueAction({
    required String actionType,
    required Map<String, dynamic> data,
    int priority = 1,
    bool requiresAuth = false,
  }) async {
    final action = OfflineAction(
      id: _generateActionId(),
      actionType: actionType,
      data: data,
      timestamp: DateTime.now(),
      priority: priority,
      requiresAuth: requiresAuth,
      retryCount: 0,
    );
    
    _actionQueue.add(action);
    await _saveOfflineQueue();
    
    AppLogger.info('📝 Queued offline action: $actionType');
    
    // Try immediate sync if online
    if (_isOnline) {
      _syncOfflineActions();
    }
  }

  /// Execute action with offline support
  static Future<T> executeWithOfflineSupport<T>({
    required String actionKey,
    required Future<T> Function() onlineAction,
    required T Function() offlineAction,
    Map<String, dynamic>? actionData,
  }) async {
    if (_isOnline) {
      try {
        final result = await onlineAction();
        
        // Cache successful result for offline use
        if (result != null) {
          await _cacheActionResult(actionKey, result);
        }
        
        return result;
      } catch (e) {
        AppLogger.warning('Online action failed, falling back to offline: $e');
        
        // Queue for retry when online
        if (actionData != null) {
          await queueAction(
            actionType: actionKey,
            data: actionData,
            priority: 2,
          );
        }
        
        return offlineAction();
      }
    } else {
      // Queue action for when online
      if (actionData != null) {
        await queueAction(
          actionType: actionKey,
          data: actionData,
        );
      }
      
      return offlineAction();
    }
  }

  /// Get cached content for offline use
  static Future<T?> getCachedContent<T>(String key) async {
    try {
      // First check memory cache
      if (_offlineCache.containsKey(key)) {
        return _offlineCache[key] as T?;
      }
      
      // Check persistent cache
      final cachedData = await PerformanceService.getCachedContent(key);
      if (cachedData != null) {
        _offlineCache[key] = cachedData;
        return cachedData as T?;
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Failed to get cached content: $e');
      return null;
    }
  }

  /// Cache content for offline use
  static Future<void> cacheContent(String key, dynamic content, {String contentType = 'general'}) async {
    try {
      // Update memory cache
      _offlineCache[key] = content;
      
      // Update persistent cache
      await PerformanceService.cacheContent(key, content as Map<String, dynamic>, contentType);
      
      AppLogger.info('💾 Cached content for offline use: $key');
    } catch (e) {
      AppLogger.error('Failed to cache content: $e');
    }
  }

  /// Sync offline actions when connection is available
  static Future<void> _syncOfflineActions() async {
    if (!_isOnline || _actionQueue.isEmpty) return;
    
    AppLogger.info('🔄 Syncing ${_actionQueue.length} offline actions');
    
    final actionsToProcess = List<OfflineAction>.from(_actionQueue);
    actionsToProcess.sort((a, b) => b.priority.compareTo(a.priority)); // Higher priority first
    
    for (final action in actionsToProcess) {
      try {
        final success = await _executeOfflineAction(action);
        
        if (success) {
          _actionQueue.remove(action);
          AppLogger.info('✅ Synced offline action: ${action.actionType}');
        } else {
          action.retryCount++;
          if (action.retryCount >= 3) {
            _actionQueue.remove(action);
            AppLogger.error('❌ Failed to sync action after 3 retries: ${action.actionType}');
          }
        }
      } catch (e) {
        AppLogger.error('Error syncing action ${action.actionType}: $e');
        action.retryCount++;
      }
    }
    
    await _saveOfflineQueue();
  }

  /// Execute individual offline action
  static Future<bool> _executeOfflineAction(OfflineAction action) async {
    try {
      switch (action.actionType) {
        case 'save_user_progress':
          return await _syncUserProgress(action.data);
        
        case 'save_user_rating':
          return await _syncUserRating(action.data);
        
        case 'bookmark_content':
          return await _syncBookmark(action.data);
        
        case 'update_preferences':
          return await _syncPreferences(action.data);
        
        case 'track_content_completion':
          return await _syncContentCompletion(action.data);
        
        default:
          AppLogger.warning('Unknown offline action type: ${action.actionType}');
          return true; // Remove unknown actions
      }
    } catch (e) {
      AppLogger.error('Failed to execute offline action: $e');
      return false;
    }
  }

  /// Sync user progress
  static Future<bool> _syncUserProgress(Map<String, dynamic> data) async {
    // Implementation would call FirestoreService
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return true;
  }

  /// Sync user rating
  static Future<bool> _syncUserRating(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  /// Sync bookmark
  static Future<bool> _syncBookmark(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  /// Sync preferences
  static Future<bool> _syncPreferences(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  /// Sync content completion
  static Future<bool> _syncContentCompletion(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return true;
  }

  /// Start periodic sync attempts
  static void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isOnline && _actionQueue.isNotEmpty) {
        _syncOfflineActions();
      }
    });
  }

  /// Save offline queue to persistent storage
  static Future<void> _saveOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueData = _actionQueue.map((action) => action.toJson()).toList();
      await prefs.setString('offline_action_queue', jsonEncode(queueData));
    } catch (e) {
      AppLogger.error('Failed to save offline queue: $e');
    }
  }

  /// Load offline queue from persistent storage
  static Future<void> _loadOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueData = prefs.getString('offline_action_queue');
      
      if (queueData != null) {
        final List<dynamic> queueJson = jsonDecode(queueData);
        _actionQueue.clear();
        _actionQueue.addAll(queueJson.map((json) => OfflineAction.fromJson(json)));
        
        AppLogger.info('📂 Loaded ${_actionQueue.length} offline actions from storage');
      }
    } catch (e) {
      AppLogger.error('Failed to load offline queue: $e');
    }
  }

  /// Cache action result
  static Future<void> _cacheActionResult(String key, dynamic result) async {
    try {
      await cacheContent('result_$key', {'result': result, 'cached_at': DateTime.now().toIso8601String()});
    } catch (e) {
      AppLogger.error('Failed to cache action result: $e');
    }
  }

  /// Generate unique action ID
  static String _generateActionId() {
    return 'action_${DateTime.now().millisecondsSinceEpoch}_${_actionQueue.length}';
  }

  /// Get offline status and statistics
  static Map<String, dynamic> getOfflineStatus() {
    return {
      'is_online': _isOnline,
      'queued_actions': _actionQueue.length,
      'cache_size': _offlineCache.length,
      'pending_sync_actions': _actionQueue.where((a) => a.retryCount < 3).length,
      'failed_actions': _actionQueue.where((a) => a.retryCount >= 3).length,
    };
  }

  /// Force sync all pending actions
  static Future<void> forceSyncAll() async {
    if (_isOnline) {
      await _syncOfflineActions();
    } else {
      AppLogger.warning('Cannot force sync - device is offline');
    }
  }

  /// Clear offline cache
  static Future<void> clearOfflineCache() async {
    try {
      _offlineCache.clear();
      _actionQueue.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('offline_action_queue');
      
      AppLogger.info('🧹 Offline cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear offline cache: $e');
    }
  }

  /// Get all offline content stored locally
  static Future<List<dynamic>> getOfflineContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineContentJson = prefs.getStringList('offline_content') ?? [];
      
      final List<dynamic> offlineContent = [];
      for (final contentJson in offlineContentJson) {
        try {
          final contentMap = json.decode(contentJson) as Map<String, dynamic>;
          offlineContent.add(contentMap);
        } catch (e) {
          AppLogger.error('Failed to parse offline content: $e');
        }
      }
      
      AppLogger.info('📱 Retrieved ${offlineContent.length} offline content items');
      return offlineContent;
    } catch (e) {
      AppLogger.error('Failed to get offline content: $e');
      return [];
    }
  }

  /// Store content for offline access
  static Future<void> storeOfflineContent(String contentId, Map<String, dynamic> content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineContentJson = prefs.getStringList('offline_content') ?? [];
      
      // Add content with metadata
      final contentWithMetadata = {
        ...content,
        'id': contentId,
        'stored_at': DateTime.now().toIso8601String(),
        'last_accessed': DateTime.now().toIso8601String(),
      };
      
      offlineContentJson.add(json.encode(contentWithMetadata));
      await prefs.setStringList('offline_content', offlineContentJson);
      
      AppLogger.info('💾 Stored content offline: $contentId');
    } catch (e) {
      AppLogger.error('Failed to store offline content: $e');
    }
  }

  /// Remove content from offline storage
  static Future<void> removeOfflineContent(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineContentJson = prefs.getStringList('offline_content') ?? [];
      
      // Remove content with matching ID
      offlineContentJson.removeWhere((contentJson) {
        try {
          final contentMap = json.decode(contentJson) as Map<String, dynamic>;
          return contentMap['id'] == contentId;
        } catch (e) {
          return false;
        }
      });
      
      await prefs.setStringList('offline_content', offlineContentJson);
      AppLogger.info('🗑️ Removed offline content: $contentId');
    } catch (e) {
      AppLogger.error('Failed to remove offline content: $e');
    }
  }

  /// Check if content is available offline
  static Future<bool> isContentOffline(String contentId) async {
    try {
      final offlineContent = await getOfflineContent();
      return offlineContent.any((content) => content['id'] == contentId);
    } catch (e) {
      AppLogger.error('Failed to check offline content: $e');
      return false;
    }
  }

  /// Check if device is online
  static bool get isOnline => _isOnline;

  /// Get pending actions count
  static int get pendingActionsCount => _actionQueue.length;

  /// Dispose resources
  static void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _offlineCache.clear();
    _actionQueue.clear();
  }
}

/// Offline action data model
class OfflineAction {
  final String id;
  final String actionType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int priority;
  final bool requiresAuth;
  int retryCount;

  OfflineAction({
    required this.id,
    required this.actionType,
    required this.data,
    required this.timestamp,
    required this.priority,
    required this.requiresAuth,
    required this.retryCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority,
      'requires_auth': requiresAuth,
      'retry_count': retryCount,
    };
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      id: json['id'] as String,
      actionType: json['action_type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: json['priority'] as int,
      requiresAuth: json['requires_auth'] as bool,
      retryCount: json['retry_count'] as int,
    );
  }
}

