class PerformanceService {
  static final Map<String, double> _metrics = {};

  static void recordMetric(String key, double value) {
    _metrics[key] = value;
    // TODO: Send to actual performance monitoring service
    print('Performance: $key = $value');
  }

  static double? getMetric(String key) {
    return _metrics[key];
  }

  static Map<String, double> getAllMetrics() {
    return Map.from(_metrics);
  }
}
