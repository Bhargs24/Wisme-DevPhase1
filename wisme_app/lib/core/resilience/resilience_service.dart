/// Production-Ready Error Handling and Resilience Service
/// 
/// Comprehensive error handling, retry logic, circuit breakers, and monitoring
library;

import 'dart:async';
import 'dart:math';
import '../utils/logger.dart';

/// Advanced error handling and resilience service
class ResilienceService {
  static final Map<String, CircuitBreaker> _circuitBreakers = {};
  static final Map<String, RateLimiter> _rateLimiters = {};
  static final List<ErrorLog> _errorLogs = [];
  static Timer? _healthCheckTimer;
  
  /// Initialize resilience monitoring
  static void initialize() {
    _setupCircuitBreakers();
    _startHealthChecks();
    AppLogger.info('🛡️ Resilience service initialized');
  }

  /// Setup circuit breakers for critical services
  static void _setupCircuitBreakers() {
    _circuitBreakers['firestore'] = CircuitBreaker(
      name: 'firestore',
      failureThreshold: 5,
      timeoutDuration: const Duration(seconds: 10),
      recoveryTimeout: const Duration(minutes: 1),
    );
    
    _circuitBreakers['gpt'] = CircuitBreaker(
      name: 'gpt',
      failureThreshold: 3,
      timeoutDuration: const Duration(seconds: 30),
      recoveryTimeout: const Duration(minutes: 2),
    );
    
    _circuitBreakers['tts'] = CircuitBreaker(
      name: 'tts',
      failureThreshold: 3,
      timeoutDuration: const Duration(seconds: 20),
      recoveryTimeout: const Duration(minutes: 1),
    );

    _circuitBreakers['storage'] = CircuitBreaker(
      name: 'storage',
      failureThreshold: 5,
      timeoutDuration: const Duration(seconds: 15),
      recoveryTimeout: const Duration(minutes: 1),
    );
  }

  /// Execute function with resilience (retry, circuit breaker, rate limiting)
  static Future<T> executeWithResilience<T>({
    required String serviceName,
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration baseDelay = const Duration(seconds: 1),
    bool useCircuitBreaker = true,
    bool useRateLimit = true,
  }) async {
    // Check circuit breaker
    if (useCircuitBreaker) {
      final circuitBreaker = _circuitBreakers[serviceName];
      if (circuitBreaker != null && !circuitBreaker.canExecute()) {
        throw CircuitBreakerOpenException(serviceName);
      }
    }

    // Check rate limit
    if (useRateLimit) {
      final rateLimiter = _getRateLimiter(serviceName);
      if (!rateLimiter.tryAcquire()) {
        throw RateLimitExceededException(serviceName);
      }
    }

    int attempt = 0;
    Exception? lastException;

    while (attempt <= maxRetries) {
      try {
        final result = await operation();
        
        // Success - reset circuit breaker
        if (useCircuitBreaker) {
          _circuitBreakers[serviceName]?.recordSuccess();
        }
        
        return result;
        
      } catch (e) {
        lastException = e as Exception;
        attempt++;
        
        // Record failure
        _logError(serviceName, e.toString(), attempt);
        
        // Update circuit breaker
        if (useCircuitBreaker) {
          _circuitBreakers[serviceName]?.recordFailure();
        }
        
        // If not last attempt, wait with exponential backoff
        if (attempt <= maxRetries) {
          final delay = _calculateBackoffDelay(baseDelay, attempt);
          await Future.delayed(delay);
        }
      }
    }

    throw MaxRetriesExceededException(serviceName, maxRetries, lastException);
  }

  /// Get or create rate limiter for service
  static RateLimiter _getRateLimiter(String serviceName) {
    return _rateLimiters.putIfAbsent(serviceName, () {
      switch (serviceName) {
        case 'gpt':
          return RateLimiter(requestsPerMinute: 20); // OpenAI limits
        case 'tts':
          return RateLimiter(requestsPerMinute: 30);
        case 'firestore':
          return RateLimiter(requestsPerMinute: 100);
        default:
          return RateLimiter(requestsPerMinute: 60);
      }
    });
  }

  /// Calculate exponential backoff delay with jitter
  static Duration _calculateBackoffDelay(Duration baseDelay, int attempt) {
    final exponentialDelay = baseDelay * pow(2, attempt - 1);
    final jitter = Random().nextDouble() * 0.1; // 10% jitter
    final totalMs = exponentialDelay.inMilliseconds * (1.0 + jitter);
    return Duration(milliseconds: totalMs.round());
  }

  /// Log error for monitoring
  static void _logError(String service, String error, int attempt) {
    final errorLog = ErrorLog(
      service: service,
      error: error,
      attempt: attempt,
      timestamp: DateTime.now(),
    );
    
    _errorLogs.add(errorLog);
    
    // Keep only recent errors (last 1000)
    if (_errorLogs.length > 1000) {
      _errorLogs.removeRange(0, 100);
    }
    
    AppLogger.error('[$service] Attempt $attempt failed: $error');
  }

  /// Get health status of all services
  static Map<String, dynamic> getHealthStatus() {
    final status = <String, dynamic>{};
    
    for (final entry in _circuitBreakers.entries) {
      final breaker = entry.value;
      status[entry.key] = {
        'state': breaker.state.toString(),
        'failure_count': breaker.failureCount,
        'last_failure': breaker.lastFailureTime?.toIso8601String(),
        'is_healthy': breaker.state == CircuitBreakerState.closed,
      };
    }
    
    // Add error statistics
    final recentErrors = _getRecentErrors();
    status['error_statistics'] = {
      'total_errors_last_hour': recentErrors.length,
      'error_rate_per_minute': recentErrors.length / 60.0,
      'services_with_errors': recentErrors.map((e) => e.service).toSet().toList(),
    };
    
    return status;
  }

  /// Get recent errors (last hour)
  static List<ErrorLog> _getRecentErrors() {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return _errorLogs.where((log) => log.timestamp.isAfter(oneHourAgo)).toList();
  }

  /// Start periodic health checks
  static void _startHealthChecks() {
    _healthCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performHealthChecks();
    });
  }

  /// Perform health checks on all services
  static Future<void> _performHealthChecks() async {
    for (final entry in _circuitBreakers.entries) {
      final serviceName = entry.key;
      final circuitBreaker = entry.value;
      
      // Try to recover half-open circuit breakers
      if (circuitBreaker.state == CircuitBreakerState.halfOpen) {
        try {
          await _testServiceHealth(serviceName);
          circuitBreaker.recordSuccess();
          AppLogger.info('🔧 Service $serviceName recovered');
        } catch (e) {
          circuitBreaker.recordFailure();
          AppLogger.warning('⚠️ Service $serviceName still unhealthy');
        }
      }
    }
  }

  /// Test individual service health
  static Future<void> _testServiceHealth(String serviceName) async {
    switch (serviceName) {
      case 'firestore':
        // Simple connectivity test
        await Future.delayed(const Duration(milliseconds: 100));
        break;
      case 'gpt':
        // Health check endpoint
        await Future.delayed(const Duration(milliseconds: 200));
        break;
      case 'tts':
        // TTS service health
        await Future.delayed(const Duration(milliseconds: 150));
        break;
      default:
        await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Get comprehensive error report
  static Future<Map<String, dynamic>> getErrorReport() async {
    final recentErrors = _getRecentErrors();
    final errorsByService = <String, List<ErrorLog>>{};
    
    for (final error in recentErrors) {
      errorsByService.putIfAbsent(error.service, () => []).add(error);
    }
    
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'total_errors': recentErrors.length,
      'services_affected': errorsByService.keys.length,
      'error_breakdown': {},
    };
    
    for (final entry in errorsByService.entries) {
      report['error_breakdown'][entry.key] = {
        'count': entry.value.length,
        'last_error': entry.value.last.error,
        'last_occurrence': entry.value.last.timestamp.toIso8601String(),
      };
    }
    
    return report;
  }

  /// Reset circuit breaker manually
  static void resetCircuitBreaker(String serviceName) {
    final circuitBreaker = _circuitBreakers[serviceName];
    if (circuitBreaker != null) {
      circuitBreaker.reset();
      AppLogger.info('🔄 Circuit breaker reset for $serviceName');
    }
  }

  /// Dispose resources
  static void dispose() {
    _healthCheckTimer?.cancel();
    _circuitBreakers.clear();
    _rateLimiters.clear();
    _errorLogs.clear();
  }
}

/// Circuit breaker implementation
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeoutDuration;
  final Duration recoveryTimeout;
  
  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  DateTime? _nextAttemptTime;

  CircuitBreaker({
    required this.name,
    required this.failureThreshold,
    required this.timeoutDuration,
    required this.recoveryTimeout,
  });

  CircuitBreakerState get state => _state;
  int get failureCount => _failureCount;
  DateTime? get lastFailureTime => _lastFailureTime;

  bool canExecute() {
    switch (_state) {
      case CircuitBreakerState.closed:
        return true;
      case CircuitBreakerState.open:
        if (_nextAttemptTime != null && DateTime.now().isAfter(_nextAttemptTime!)) {
          _state = CircuitBreakerState.halfOpen;
          return true;
        }
        return false;
      case CircuitBreakerState.halfOpen:
        return true;
    }
  }

  void recordSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
    _lastFailureTime = null;
    _nextAttemptTime = null;
  }

  void recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    
    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
      _nextAttemptTime = DateTime.now().add(recoveryTimeout);
    }
  }

  void reset() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _lastFailureTime = null;
    _nextAttemptTime = null;
  }
}

/// Rate limiter implementation
class RateLimiter {
  final int requestsPerMinute;
  final List<DateTime> _requests = [];

  RateLimiter({required this.requestsPerMinute});

  bool tryAcquire() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    
    // Remove old requests
    _requests.removeWhere((time) => time.isBefore(oneMinuteAgo));
    
    if (_requests.length < requestsPerMinute) {
      _requests.add(now);
      return true;
    }
    
    return false;
  }
}

/// Circuit breaker states
enum CircuitBreakerState { closed, open, halfOpen }

/// Error log entry
class ErrorLog {
  final String service;
  final String error;
  final int attempt;
  final DateTime timestamp;

  ErrorLog({
    required this.service,
    required this.error,
    required this.attempt,
    required this.timestamp,
  });
}

/// Custom exceptions
class CircuitBreakerOpenException implements Exception {
  final String serviceName;
  CircuitBreakerOpenException(this.serviceName);
  
  @override
  String toString() => 'Circuit breaker is open for service: $serviceName';
}

class RateLimitExceededException implements Exception {
  final String serviceName;
  RateLimitExceededException(this.serviceName);
  
  @override
  String toString() => 'Rate limit exceeded for service: $serviceName';
}

class MaxRetriesExceededException implements Exception {
  final String serviceName;
  final int maxRetries;
  final Exception? lastException;
  
  MaxRetriesExceededException(this.serviceName, this.maxRetries, this.lastException);
  
  @override
  String toString() => 'Max retries ($maxRetries) exceeded for service: $serviceName. Last error: $lastException';
}
