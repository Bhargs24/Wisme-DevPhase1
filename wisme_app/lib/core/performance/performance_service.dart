/// Production-Grade Performance Monitoring Service
/// 
/// Comprehensive performance tracking, analytics, and optimization
library;

import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../shared/models/base_model.dart';
import '../../shared/models/result.dart';
import '../../core/utils/logger.dart';
import '../../core/error/app_exceptions.dart';

/// Performance metric types
enum MetricType {
  latency,
  throughput,
  errorRate,
  memoryUsage,
  cpuUsage,
  networkLatency,
  apiResponseTime,
  userEngagement,
  cacheHitRate,
  batteryUsage,
}

/// Performance measurement
class PerformanceMeasurement extends BaseModel {
  final String id;
  final String name;
  final MetricType type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? userId;
  final String? sessionId;

  const PerformanceMeasurement({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata = const {},
    this.userId,
    this.sessionId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'userId': userId,
      'sessionId': sessionId,
    };
  }

  factory PerformanceMeasurement.fromMap(Map<String, dynamic> map) {
    return PerformanceMeasurement(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: MetricType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MetricType.latency,
      ),
      value: map['value']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      userId: map['userId'],
      sessionId: map['sessionId'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    value,
    unit,
    timestamp,
    metadata,
    userId,
    sessionId,
  ];
}

/// Performance baseline for comparison
class PerformanceBaseline extends BaseModel {
  final String metricName;
  final MetricType type;
  final double baseline;
  final double threshold;
  final String unit;
  final DateTime establishedAt;

  const PerformanceBaseline({
    required this.metricName,
    required this.type,
    required this.baseline,
    required this.threshold,
    required this.unit,
    required this.establishedAt,
  });

  bool isWithinThreshold(double value) {
    return (value - baseline).abs() <= threshold;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'metricName': metricName,
      'type': type.name,
      'baseline': baseline,
      'threshold': threshold,
      'unit': unit,
      'establishedAt': establishedAt.toIso8601String(),
    };
  }

  factory PerformanceBaseline.fromMap(Map<String, dynamic> map) {
    return PerformanceBaseline(
      metricName: map['metricName'] ?? '',
      type: MetricType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MetricType.latency,
      ),
      baseline: map['baseline']?.toDouble() ?? 0.0,
      threshold: map['threshold']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      establishedAt: DateTime.parse(map['establishedAt']),
    );
  }

  @override
  List<Object?> get props => [
    metricName,
    type,
    baseline,
    threshold,
    unit,
    establishedAt,
  ];
}

/// Performance alert
class PerformanceAlert extends BaseModel {
  final String id;
  final String metricName;
  final double value;
  final double threshold;
  final String severity; // low, medium, high, critical
  final String message;
  final DateTime triggeredAt;
  final bool acknowledged;

  const PerformanceAlert({
    required this.id,
    required this.metricName,
    required this.value,
    required this.threshold,
    required this.severity,
    required this.message,
    required this.triggeredAt,
    this.acknowledged = false,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'metricName': metricName,
      'value': value,
      'threshold': threshold,
      'severity': severity,
      'message': message,
      'triggeredAt': triggeredAt.toIso8601String(),
      'acknowledged': acknowledged,
    };
  }

  factory PerformanceAlert.fromMap(Map<String, dynamic> map) {
    return PerformanceAlert(
      id: map['id'] ?? '',
      metricName: map['metricName'] ?? '',
      value: map['value']?.toDouble() ?? 0.0,
      threshold: map['threshold']?.toDouble() ?? 0.0,
      severity: map['severity'] ?? '',
      message: map['message'] ?? '',
      triggeredAt: DateTime.parse(map['triggeredAt']),
      acknowledged: map['acknowledged'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    metricName,
    value,
    threshold,
    severity,
    message,
    triggeredAt,
    acknowledged,
  ];
}

/// Performance summary report
class PerformanceReport extends BaseModel {
  final DateTime generatedAt;
  final Duration timeRange;
  final Map<String, double> averageMetrics;
  final Map<String, double> peakMetrics;
  final Map<String, int> alertCounts;
  final List<String> recommendations;
  final double overallScore;

  const PerformanceReport({
    required this.generatedAt,
    required this.timeRange,
    required this.averageMetrics,
    required this.peakMetrics,
    required this.alertCounts,
    required this.recommendations,
    required this.overallScore,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'timeRange': timeRange.inMilliseconds,
      'averageMetrics': averageMetrics,
      'peakMetrics': peakMetrics,
      'alertCounts': alertCounts,
      'recommendations': recommendations,
      'overallScore': overallScore,
    };
  }

  factory PerformanceReport.fromMap(Map<String, dynamic> map) {
    return PerformanceReport(
      generatedAt: DateTime.parse(map['generatedAt']),
      timeRange: Duration(milliseconds: map['timeRange'] ?? 0),
      averageMetrics: Map<String, double>.from(map['averageMetrics'] ?? {}),
      peakMetrics: Map<String, double>.from(map['peakMetrics'] ?? {}),
      alertCounts: Map<String, int>.from(map['alertCounts'] ?? {}),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      overallScore: map['overallScore']?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    generatedAt,
    timeRange,
    averageMetrics,
    peakMetrics,
    alertCounts,
    recommendations,
    overallScore,
  ];
}

/// Performance monitoring service
class PerformanceService {
  static final Map<String, Queue<PerformanceMeasurement>> _measurements = {};
  static final Map<String, PerformanceBaseline> _baselines = {};
  static final List<PerformanceAlert> _activeAlerts = [];
  static final Map<String, Stopwatch> _activeTimers = {};
  
  static const int _maxMeasurements = 1000;
  static const Duration _alertCooldown = Duration(minutes: 5);
  static final Map<String, DateTime> _lastAlertTime = {};
  
  static Timer? _monitoringTimer;
  static bool _isInitialized = false;

  /// Initialize performance monitoring
  static Future<Result<void>> initialize() async {
    try {
      if (_isInitialized) return Result.success(null);

      // Establish baselines for key metrics
      await _establishBaselines();
      
      // Start continuous monitoring
      _startContinuousMonitoring();
      
      _isInitialized = true;
      AppLogger.info('📊 Performance monitoring initialized');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Performance monitoring initialization failed: $e');
      return Result.failure(PerformanceException('Failed to initialize performance monitoring'));
    }
  }

  /// Record a performance measurement
  static Result<void> recordMeasurement({
    required String name,
    required MetricType type,
    required double value,
    required String unit,
    Map<String, dynamic>? metadata,
    String? userId,
    String? sessionId,
  }) {
    try {
      final measurement = PerformanceMeasurement(
        id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        name: name,
        type: type,
        value: value,
        unit: unit,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        userId: userId,
        sessionId: sessionId,
      );

      // Store measurement
      _measurements[name] ??= Queue<PerformanceMeasurement>();
      _measurements[name]!.add(measurement);

      // Maintain queue size
      if (_measurements[name]!.length > _maxMeasurements) {
        _measurements[name]!.removeFirst();
      }

      // Check for alerts
      _checkForAlerts(measurement);

      if (kDebugMode) {
        developer.Timeline.instantSync('Performance', arguments: {
          'metric': name,
          'value': value,
          'unit': unit,
        });
      }

      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Failed to record measurement: $e');
      return Result.failure(PerformanceException('Failed to record measurement'));
    }
  }

  /// Start timing a performance metric
  static Result<void> startTimer(String name) {
    try {
      _activeTimers[name] = Stopwatch()..start();
      return Result.success(null);
    } catch (e) {
      return Result.failure(PerformanceException('Failed to start timer'));
    }
  }

  /// Stop timing and record the measurement
  static Result<void> stopTimer(
    String name, {
    Map<String, dynamic>? metadata,
    String? userId,
    String? sessionId,
  }) {
    try {
      final timer = _activeTimers[name];
      if (timer == null) {
        return Result.failure(PerformanceException('Timer not found: $name'));
      }

      timer.stop();
      final duration = timer.elapsedMilliseconds.toDouble();
      _activeTimers.remove(name);

      return recordMeasurement(
        name: name,
        type: MetricType.latency,
        value: duration,
        unit: 'ms',
        metadata: metadata,
        userId: userId,
        sessionId: sessionId,
      );
    } catch (e) {
      return Result.failure(PerformanceException('Failed to stop timer'));
    }
  }

  /// Measure execution time of a function
  static Future<Result<T>> measureExecution<T>(
    String name,
    Future<T> Function() function, {
    Map<String, dynamic>? metadata,
    String? userId,
    String? sessionId,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await function();
      stopwatch.stop();
      
      recordMeasurement(
        name: name,
        type: MetricType.latency,
        value: stopwatch.elapsedMilliseconds.toDouble(),
        unit: 'ms',
        metadata: metadata,
        userId: userId,
        sessionId: sessionId,
      );
      
      return Result.success(result);
    } catch (e) {
      stopwatch.stop();
      
      recordMeasurement(
        name: '${name}_error',
        type: MetricType.errorRate,
        value: 1.0,
        unit: 'count',
        metadata: {'error': e.toString(), ...?metadata},
        userId: userId,
        sessionId: sessionId,
      );
      
      return Result.failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Record memory usage
  static Future<Result<void>> recordMemoryUsage([String? context]) async {
    try {
      // In a real implementation, you would use platform-specific memory APIs
      // For now, we'll simulate memory measurement
      final memoryUsage = Random().nextInt(512) + 128; // Simulated MB usage
      
      return recordMeasurement(
        name: context != null ? 'memory_usage_$context' : 'memory_usage',
        type: MetricType.memoryUsage,
        value: memoryUsage.toDouble(),
        unit: 'MB',
      );
    } catch (e) {
      return Result.failure(PerformanceException('Failed to record memory usage'));
    }
  }

  /// Record network latency
  static Result<void> recordNetworkLatency({
    required String endpoint,
    required Duration latency,
    int? statusCode,
    int? responseSize,
  }) {
    return recordMeasurement(
      name: 'network_latency_$endpoint',
      type: MetricType.networkLatency,
      value: latency.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: {
        'endpoint': endpoint,
        'statusCode': statusCode,
        'responseSize': responseSize,
      },
    );
  }

  /// Record API response time
  static Result<void> recordApiResponseTime({
    required String apiName,
    required Duration responseTime,
    bool? success,
    String? errorMessage,
  }) {
    return recordMeasurement(
      name: 'api_response_time_$apiName',
      type: MetricType.apiResponseTime,
      value: responseTime.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: {
        'success': success,
        'errorMessage': errorMessage,
      },
    );
  }

  /// Record user engagement metric
  static Result<void> recordUserEngagement({
    required String action,
    required Duration duration,
    String? userId,
    String? sessionId,
  }) {
    return recordMeasurement(
      name: 'user_engagement_$action',
      type: MetricType.userEngagement,
      value: duration.inSeconds.toDouble(),
      unit: 'seconds',
      userId: userId,
      sessionId: sessionId,
    );
  }

  /// Establish performance baselines
  static Future<void> _establishBaselines() async {
    // Define standard baselines for key metrics
    final baselines = [
      PerformanceBaseline(
        metricName: 'app_startup',
        type: MetricType.latency,
        baseline: 2000.0, // 2 seconds
        threshold: 500.0, // ±500ms acceptable
        unit: 'ms',
        establishedAt: DateTime.now(),
      ),
      PerformanceBaseline(
        metricName: 'api_response',
        type: MetricType.apiResponseTime,
        baseline: 1000.0, // 1 second
        threshold: 300.0, // ±300ms acceptable
        unit: 'ms',
        establishedAt: DateTime.now(),
      ),
      PerformanceBaseline(
        metricName: 'memory_usage',
        type: MetricType.memoryUsage,
        baseline: 256.0, // 256 MB
        threshold: 64.0, // ±64MB acceptable
        unit: 'MB',
        establishedAt: DateTime.now(),
      ),
    ];

    for (final baseline in baselines) {
      _baselines[baseline.metricName] = baseline;
    }
  }

  /// Start continuous monitoring
  static void _startContinuousMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _performPeriodicChecks();
    });
  }

  /// Perform periodic health checks
  static void _performPeriodicChecks() {
    recordMemoryUsage('periodic_check');
    
    // Check for performance degradation
    _checkPerformanceTrends();
  }

  /// Check for performance alerts
  static void _checkForAlerts(PerformanceMeasurement measurement) {
    final baseline = _baselines[measurement.name];
    if (baseline == null) return;

    // Check if we're in cooldown period
    final lastAlert = _lastAlertTime[measurement.name];
    if (lastAlert != null && 
        DateTime.now().difference(lastAlert) < _alertCooldown) {
      return;
    }

    if (!baseline.isWithinThreshold(measurement.value)) {
      final severity = _determineSeverity(measurement.value, baseline);
      final alert = PerformanceAlert(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        metricName: measurement.name,
        value: measurement.value,
        threshold: baseline.threshold,
        severity: severity,
        message: _generateAlertMessage(measurement, baseline, severity),
        triggeredAt: DateTime.now(),
      );

      _activeAlerts.add(alert);
      _lastAlertTime[measurement.name] = DateTime.now();

      AppLogger.warning('⚠️ Performance alert: ${alert.message}');
    }
  }

  /// Check performance trends
  static void _checkPerformanceTrends() {
    for (final entry in _measurements.entries) {
      final measurements = entry.value.toList();
      if (measurements.length < 10) continue;

      // Check recent trend (last 10 measurements)
      final recent = measurements.takeLast(10).toList();
      final average = recent.map((m) => m.value).reduce((a, b) => a + b) / recent.length;
      
      final baseline = _baselines[entry.key];
      if (baseline != null && !baseline.isWithinThreshold(average)) {
        AppLogger.warning('📈 Performance trend alert for ${entry.key}: $average ${baseline.unit}');
      }
    }
  }

  /// Determine alert severity
  static String _determineSeverity(double value, PerformanceBaseline baseline) {
    final deviation = (value - baseline.baseline).abs();
    final thresholdMultiplier = deviation / baseline.threshold;

    if (thresholdMultiplier > 3.0) return 'critical';
    if (thresholdMultiplier > 2.0) return 'high';
    if (thresholdMultiplier > 1.5) return 'medium';
    return 'low';
  }

  /// Generate alert message
  static String _generateAlertMessage(
    PerformanceMeasurement measurement,
    PerformanceBaseline baseline,
    String severity,
  ) {
    return '${measurement.name} is ${measurement.value} ${measurement.unit} '
           '(baseline: ${baseline.baseline} ${baseline.unit}, '
           'threshold: ±${baseline.threshold} ${baseline.unit}) - '
           'Severity: $severity';
  }

  /// Generate performance report
  static Result<PerformanceReport> generateReport({Duration? timeRange}) {
    try {
      timeRange ??= const Duration(hours: 24);
      final now = DateTime.now();
      final startTime = now.subtract(timeRange);

      final averageMetrics = <String, double>{};
      final peakMetrics = <String, double>{};
      final alertCounts = <String, int>{};

      // Calculate metrics
      for (final entry in _measurements.entries) {
        final measurements = entry.value
            .where((m) => m.timestamp.isAfter(startTime))
            .toList();

        if (measurements.isNotEmpty) {
          final values = measurements.map((m) => m.value).toList();
          averageMetrics[entry.key] = values.reduce((a, b) => a + b) / values.length;
          peakMetrics[entry.key] = values.reduce(max);
        }
      }

      // Count alerts by severity
      final recentAlerts = _activeAlerts
          .where((a) => a.triggeredAt.isAfter(startTime))
          .toList();

      for (final alert in recentAlerts) {
        alertCounts[alert.severity] = (alertCounts[alert.severity] ?? 0) + 1;
      }

      // Generate recommendations
      final recommendations = _generateRecommendations(averageMetrics, alertCounts);

      // Calculate overall score
      final overallScore = _calculateOverallScore(averageMetrics, alertCounts);

      final report = PerformanceReport(
        generatedAt: now,
        timeRange: timeRange,
        averageMetrics: averageMetrics,
        peakMetrics: peakMetrics,
        alertCounts: alertCounts,
        recommendations: recommendations,
        overallScore: overallScore,
      );

      return Result.success(report);
    } catch (e) {
      AppLogger.error('❌ Failed to generate performance report: $e');
      return Result.failure(PerformanceException('Failed to generate report'));
    }
  }

  /// Generate performance recommendations
  static List<String> _generateRecommendations(
    Map<String, double> averageMetrics,
    Map<String, int> alertCounts,
  ) {
    final recommendations = <String>[];

    // Check memory usage
    final memoryUsage = averageMetrics['memory_usage'];
    if (memoryUsage != null && memoryUsage > 400) {
      recommendations.add('Consider optimizing memory usage - current average: ${memoryUsage.toInt()}MB');
    }

    // Check API response times
    final apiResponseTimes = averageMetrics.entries
        .where((e) => e.key.startsWith('api_response_time_'))
        .toList();
    
    for (final entry in apiResponseTimes) {
      if (entry.value > 2000) {
        recommendations.add('Optimize API response time for ${entry.key}: ${entry.value.toInt()}ms');
      }
    }

    // Check alert frequency
    final totalAlerts = alertCounts.values.fold(0, (sum, count) => sum + count);
    if (totalAlerts > 10) {
      recommendations.add('High alert frequency detected - consider investigating root causes');
    }

    return recommendations;
  }

  /// Calculate overall performance score
  static double _calculateOverallScore(
    Map<String, double> averageMetrics,
    Map<String, int> alertCounts,
  ) {
    double score = 100.0;

    // Deduct points for high alert counts
    final criticalAlerts = alertCounts['critical'] ?? 0;
    final highAlerts = alertCounts['high'] ?? 0;
    final mediumAlerts = alertCounts['medium'] ?? 0;

    score -= criticalAlerts * 10;
    score -= highAlerts * 5;
    score -= mediumAlerts * 2;

    // Deduct points for poor metrics
    for (final entry in averageMetrics.entries) {
      final baseline = _baselines[entry.key];
      if (baseline != null && !baseline.isWithinThreshold(entry.value)) {
        score -= 5;
      }
    }

    return max(0.0, score);
  }

  /// Get active alerts
  static List<PerformanceAlert> getActiveAlerts() {
    return List.from(_activeAlerts);
  }

  /// Acknowledge alert
  static Result<void> acknowledgeAlert(String alertId) {
    try {
      final alertIndex = _activeAlerts.indexWhere((a) => a.id == alertId);
      if (alertIndex != -1) {
        // Since PerformanceAlert is immutable, we need to replace it
        final alert = _activeAlerts[alertIndex];
        _activeAlerts[alertIndex] = PerformanceAlert(
          id: alert.id,
          metricName: alert.metricName,
          value: alert.value,
          threshold: alert.threshold,
          severity: alert.severity,
          message: alert.message,
          triggeredAt: alert.triggeredAt,
          acknowledged: true,
        );
        return Result.success(null);
      } else {
        return Result.failure(const PerformanceException('Alert not found'));
      }
    } catch (e) {
      return Result.failure(PerformanceException('Failed to acknowledge alert'));
    }
  }

  /// Get performance metrics
  static Map<String, dynamic> getMetrics() {
    return {
      'totalMeasurements': _measurements.values.fold(0, (sum, queue) => sum + queue.length),
      'activeTimers': _activeTimers.length,
      'activeAlerts': _activeAlerts.length,
      'baselines': _baselines.length,
      'isMonitoring': _monitoringTimer?.isActive ?? false,
    };
  }

  /// Clear old measurements
  static Result<void> clearOldMeasurements({Duration? olderThan}) {
    try {
      olderThan ??= const Duration(days: 7);
      final cutoffTime = DateTime.now().subtract(olderThan);

      for (final queue in _measurements.values) {
        queue.removeWhere((m) => m.timestamp.isBefore(cutoffTime));
      }

      AppLogger.info('🧹 Cleared old performance measurements');
      return Result.success(null);
    } catch (e) {
      return Result.failure(PerformanceException('Failed to clear old measurements'));
    }
  }

  /// Dispose service
  static Future<void> dispose() async {
    _monitoringTimer?.cancel();
    _measurements.clear();
    _baselines.clear();
    _activeAlerts.clear();
    _activeTimers.clear();
    _lastAlertTime.clear();
    _isInitialized = false;
    AppLogger.info('📊 Performance service disposed');
  }
}
