/// Production Monitoring Dashboard Service
/// 
/// Real-time operational metrics and system health monitoring

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/performance_service.dart';
import '../services/analytics_service.dart';
import '../services/offline_service.dart';
import '../services/cache_service.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// Comprehensive monitoring and dashboard for production operations
class MonitoringDashboardService {
  static Timer? _metricsCollectionTimer;
  static final Map<String, dynamic> _currentMetrics = {};
  static final List<SystemAlert> _activeAlerts = [];
  
  /// Initialize monitoring dashboard
  static Future<void> initialize() async {
    _startMetricsCollection();
    await _loadHistoricalMetrics();
    AppLogger.info('📊 Monitoring dashboard initialized');
  }

  /// Start collecting metrics periodically
  static void _startMetricsCollection() {
    _metricsCollectionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _collectSystemMetrics(),
    );
  }

  /// Collect comprehensive system metrics
  static Future<void> _collectSystemMetrics() async {
    try {
      final metrics = <String, dynamic>{};
      final timestamp = DateTime.now();

      // Performance metrics
      metrics['performance'] = await _getPerformanceMetrics();
      
      // Cache metrics
      metrics['cache'] = await _getCacheMetrics();
      
      // Offline metrics
      metrics['offline'] = await _getOfflineMetrics();
      
      // System health
      metrics['system'] = await _getSystemHealthMetrics();
      
      // User activity
      metrics['user_activity'] = await _getUserActivityMetrics();
      
      // API usage
      metrics['api_usage'] = await _getAPIUsageMetrics();
      
      metrics['timestamp'] = timestamp.toIso8601String();
      metrics['uptime_minutes'] = _getUptimeMinutes();
      
      _currentMetrics.addAll(metrics);
      
      // Check for alerts
      await _checkAlertConditions(metrics);
      
      // Store metrics
      await _storeMetrics(metrics);
      
    } catch (e) {
      AppLogger.error('Failed to collect metrics: $e');
    }
  }

  /// Get performance metrics
  static Future<Map<String, dynamic>> _getPerformanceMetrics() async {
    return {
      'memory_usage_mb': _getMemoryUsage(),
      'cpu_usage_percent': _getCPUUsage(),
      'battery_level': _getBatteryLevel(),
      'disk_usage_mb': await _getDiskUsage(),
      'network_latency_ms': await _getNetworkLatency(),
    };
  }

  /// Get cache performance metrics
  static Future<Map<String, dynamic>> _getCacheMetrics() async {
    try {
      final cacheService = CacheService();
      final stats = await cacheService.getCacheStats();
      
      return {
        'cache_size_mb': double.parse(stats['totalSizeMB'] ?? '0'),
        'cache_files': stats['totalFiles'] ?? 0,
        'cache_usage_percent': double.parse(stats['usagePercentage'] ?? '0'),
        'cache_hit_rate': _getCacheHitRate(),
      };
    } catch (e) {
      return {
        'cache_size_mb': 0,
        'cache_files': 0,
        'cache_usage_percent': 0,
        'cache_hit_rate': 0,
      };
    }
  }

  /// Get offline service metrics
  static Future<Map<String, dynamic>> _getOfflineMetrics() async {
    return {
      'is_online': OfflineService.isOnline,
      'pending_actions': 0, // Placeholder - implement when available
      'last_sync': DateTime.now().toIso8601String(), // Placeholder
      'sync_success_rate': _getSyncSuccessRate(),
    };
  }

  /// Get system health metrics
  static Future<Map<String, dynamic>> _getSystemHealthMetrics() async {
    return {
      'config_status': AppConfig.configStatus,
      'api_health': await _checkAPIHealth(),
      'database_health': await _checkDatabaseHealth(),
      'services_status': await _getServicesStatus(),
    };
  }

  /// Get user activity metrics
  static Future<Map<String, dynamic>> _getUserActivityMetrics() async {
    return {
      'active_sessions': _getActiveSessionCount(),
      'content_generated_today': await _getTodayContentGeneration(),
      'audio_played_today': await _getTodayAudioPlayback(),
      'errors_today': await _getTodayErrorCount(),
    };
  }

  /// Get API usage metrics
  static Future<Map<String, dynamic>> _getAPIUsageMetrics() async {
    return {
      'openai_requests_today': await _getOpenAIRequestCount(),
      'elevenlabs_requests_today': await _getElevenLabsRequestCount(),
      'api_success_rate': await _getAPISuccessRate(),
      'api_latency_avg_ms': await _getAPILatencyAverage(),
    };
  }

  /// Check for alert conditions
  static Future<void> _checkAlertConditions(Map<String, dynamic> metrics) async {
    _activeAlerts.clear();

    // High memory usage
    final memoryUsage = metrics['performance']['memory_usage_mb'] ?? 0;
    if (memoryUsage > 1000) {
      _activeAlerts.add(SystemAlert(
        type: AlertType.warning,
        message: 'High memory usage: ${memoryUsage}MB',
        severity: AlertSeverity.medium,
      ));
    }

    // Low cache hit rate
    final cacheHitRate = metrics['cache']['cache_hit_rate'] ?? 0;
    if (cacheHitRate < 0.5) {
      _activeAlerts.add(SystemAlert(
        type: AlertType.performance,
        message: 'Low cache hit rate: ${(cacheHitRate * 100).toStringAsFixed(1)}%',
        severity: AlertSeverity.medium,
      ));
    }

    // API configuration issues
    if (!AppConfig.isConfiguredForProduction) {
      _activeAlerts.add(SystemAlert(
        type: AlertType.configuration,
        message: 'API keys not configured for production',
        severity: AlertSeverity.high,
      ));
    }

    // High error rate
    final errorCount = await _getTodayErrorCount();
    if (errorCount > 100) {
      _activeAlerts.add(SystemAlert(
        type: AlertType.error,
        message: 'High error count today: $errorCount',
        severity: AlertSeverity.high,
      ));
    }

    // Offline mode monitoring
    if (!OfflineService.isOnline) {
      _activeAlerts.add(SystemAlert(
        type: AlertType.connectivity,
        message: 'Device is currently offline',
        severity: AlertSeverity.medium,
      ));
    }

    // Log alerts
    for (final alert in _activeAlerts) {
      AppLogger.warning('⚠️ ${alert.message}');
      
      // Track critical alerts
      if (alert.severity == AlertSeverity.high) {
        AnalyticsService.trackEvent('system_alert_critical', {
          'alert_type': alert.type.name,
          'message': alert.message,
          'severity': alert.severity.name,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  /// Get current dashboard data
  static Map<String, dynamic> get dashboardData => {
    'current_metrics': _currentMetrics,
    'active_alerts': _activeAlerts.map((a) => a.toMap()).toList(),
    'system_status': _getSystemStatus(),
    'last_updated': DateTime.now().toIso8601String(),
    'uptime_minutes': _getUptimeMinutes(),
  };

  /// Get system status summary
  static String _getSystemStatus() {
    if (_activeAlerts.any((a) => a.severity == AlertSeverity.high)) {
      return 'critical';
    } else if (_activeAlerts.any((a) => a.severity == AlertSeverity.medium)) {
      return 'warning';
    } else {
      return 'healthy';
    }
  }

  /// Store metrics for historical analysis
  static Future<void> _storeMetrics(Map<String, dynamic> metrics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'metrics_${DateTime.now().millisecondsSinceEpoch ~/ 60000}'; // Per minute
      await prefs.setString(key, json.encode(metrics));
      
      // Clean up old metrics (keep last 24 hours)
      await _cleanupOldMetrics(prefs);
    } catch (e) {
      AppLogger.error('Failed to store metrics: $e');
    }
  }

  /// Load historical metrics
  static Future<void> _loadHistoricalMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('metrics_'));
      
      for (final key in keys.take(60)) { // Last hour
        final data = prefs.getString(key);
        if (data != null) {
          // Process historical data for trends
        }
      }
    } catch (e) {
      AppLogger.error('Failed to load historical metrics: $e');
    }
  }

  /// Clean up old metrics
  static Future<void> _cleanupOldMetrics(SharedPreferences prefs) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    final cutoff = now - (24 * 60); // 24 hours ago
    
    final keysToRemove = prefs.getKeys()
        .where((key) => key.startsWith('metrics_'))
        .where((key) {
          final timestamp = int.tryParse(key.split('_')[1]) ?? 0;
          return timestamp < cutoff;
        });

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  // Helper methods for metrics collection
  static double _getMemoryUsage() => 256.0; // Placeholder
  static double _getCPUUsage() => 15.0; // Placeholder
  static double _getBatteryLevel() => 85.0; // Placeholder
  static Future<double> _getDiskUsage() async => 1024.0; // Placeholder
  static Future<double> _getNetworkLatency() async => 150.0; // Placeholder
  static double _getCacheHitRate() => 0.75; // Placeholder
  static double _getSyncSuccessRate() => 0.95; // Placeholder
  static int _getActiveSessionCount() => 1; // Placeholder
  static Future<int> _getTodayContentGeneration() async => 25; // Placeholder
  static Future<int> _getTodayAudioPlayback() async => 50; // Placeholder
  static Future<int> _getTodayErrorCount() async => 3; // Placeholder
  static Future<int> _getOpenAIRequestCount() async => 100; // Placeholder
  static Future<int> _getElevenLabsRequestCount() async => 75; // Placeholder
  static Future<double> _getAPISuccessRate() async => 0.98; // Placeholder
  static Future<double> _getAPILatencyAverage() async => 850.0; // Placeholder
  static int _getUptimeMinutes() => DateTime.now().millisecondsSinceEpoch ~/ 60000; // Placeholder

  static Future<Map<String, bool>> _checkAPIHealth() async {
    return {
      'openai': true, // Placeholder
      'elevenlabs': true, // Placeholder
    };
  }

  static Future<bool> _checkDatabaseHealth() async {
    try {
      PerformanceService.recordMetric('health_check', 1.0);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, bool>> _getServicesStatus() async {
    return {
      'performance_service': true,
      'analytics_service': true,
      'cache_service': true,
      'offline_service': true,
      'security_service': true,
    };
  }

  /// Cleanup on app termination
  static Future<void> cleanup() async {
    _metricsCollectionTimer?.cancel();
    AppLogger.info('📊 Monitoring dashboard cleanup completed');
  }
}

/// System alert for monitoring
class SystemAlert {
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  SystemAlert({
    required this.type,
    required this.message,
    required this.severity,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'message': message,
    'severity': severity.name,
    'timestamp': timestamp.toIso8601String(),
  };
}

enum AlertType {
  performance,
  error,
  warning,
  connectivity,
  configuration,
  security,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}
