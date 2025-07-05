import 'dart:async';
import 'models/analytics_models.dart';
import 'data/analytics_data_service.dart';
import 'services/analytics_tracking_service.dart';
import 'services/analytics_insights_service.dart';

/// Unified manager for all analytics functionality
class AnalyticsManager {
  static final AnalyticsManager _instance = AnalyticsManager._internal();
  factory AnalyticsManager() => _instance;
  AnalyticsManager._internal();
  
  late final AnalyticsDataService _dataService;
  late final AnalyticsTrackingService _trackingService;
  late final AnalyticsInsightsService _insightsService;
  
  bool _isInitialized = false;
  String? _currentUserId;
  String? _currentSessionId;
  
  // Event streams
  Stream<AnalyticsEvent> get eventStream => _trackingService.eventStream;
  
  /// Initialize analytics manager
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;
    
    _dataService = AnalyticsDataService();
    _trackingService = AnalyticsTrackingService();
    _insightsService = AnalyticsInsightsService();
    
    _trackingService.initialize();
    
    if (userId != null) {
      _currentUserId = userId;
    }
    
    _isInitialized = true;
  }
  
  /// Dispose resources
  void dispose() {
    _trackingService.dispose();
    _isInitialized = false;
  }
  
  /// Set current user
  void setUser(String userId) {
    _currentUserId = userId;
  }
  
  /// Set current session
  void setSession(String sessionId) {
    _currentSessionId = sessionId;
  }
  
  /// Clear current session
  void clearSession() {
    _currentSessionId = null;
  }
  
  // TRACKING METHODS
  
  /// Track any event with automatic user and session context
  Future<void> trackEvent({
    required String eventType,
    required String eventName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? context,
    String? lessonId,
    String? coachId,
    EventCategory category = EventCategory.engagement,
    EventPriority priority = EventPriority.medium,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackEvent(
      userId: _currentUserId!,
      eventType: eventType,
      eventName: eventName,
      properties: properties,
      context: context,
      sessionId: _currentSessionId,
      lessonId: lessonId,
      coachId: coachId,
      category: category,
      priority: priority,
    );
  }
  
  /// Track learning session start
  Future<void> trackLearningSessionStart({
    required String sessionId,
    required String lessonId,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    _currentSessionId = sessionId;
    
    await _trackingService.trackLearningSessionStart(
      userId: _currentUserId!,
      sessionId: sessionId,
      lessonId: lessonId,
      properties: properties,
    );
  }
  
  /// Track learning session end
  Future<void> trackLearningSessionEnd({
    required String sessionId,
    required String lessonId,
    required Duration duration,
    required double completionPercentage,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackLearningSessionEnd(
      userId: _currentUserId!,
      sessionId: sessionId,
      lessonId: lessonId,
      duration: duration,
      completionPercentage: completionPercentage,
      properties: properties,
    );
    
    // Clear session after ending
    if (_currentSessionId == sessionId) {
      _currentSessionId = null;
    }
  }
  
  /// Track lesson completion
  Future<void> trackLessonCompletion({
    required String lessonId,
    required Duration studyTime,
    required double score,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackLessonCompletion(
      userId: _currentUserId!,
      lessonId: lessonId,
      studyTime: studyTime,
      score: score,
      sessionId: _currentSessionId,
      properties: properties,
    );
  }
  
  /// Track coach interaction
  Future<void> trackCoachInteraction({
    required String coachId,
    required String interactionType,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackCoachInteraction(
      userId: _currentUserId!,
      coachId: coachId,
      interactionType: interactionType,
      sessionId: _currentSessionId,
      properties: properties,
    );
  }
  
  /// Track user engagement
  Future<void> trackEngagement({
    required String engagementType,
    required String element,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackEngagement(
      userId: _currentUserId!,
      engagementType: engagementType,
      element: element,
      sessionId: _currentSessionId,
      properties: properties,
    );
  }
  
  /// Track audio playback
  Future<void> trackAudioPlayback({
    required String audioId,
    required String action,
    Duration? position,
    Duration? duration,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackAudioPlayback(
      userId: _currentUserId!,
      audioId: audioId,
      action: action,
      position: position,
      duration: duration,
      sessionId: _currentSessionId,
      properties: properties,
    );
  }
  
  /// Track error
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackError(
      userId: _currentUserId!,
      errorType: errorType,
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      sessionId: _currentSessionId,
      properties: properties,
    );
  }
  
  /// Track performance metric
  Future<void> trackPerformance({
    required String metricName,
    required double value,
    String unit = 'ms',
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    if (_currentUserId == null) return;
    
    await _trackingService.trackPerformance(
      userId: _currentUserId!,
      metricName: metricName,
      value: value,
      unit: unit,
      sessionId: _currentSessionId,
      properties: properties,
    );
  }
  
  // ANALYTICS RETRIEVAL METHODS
  
  /// Get user events
  Future<List<AnalyticsEvent>> getUserEvents({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    _ensureInitialized();
    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) return [];
    
    return _trackingService.getUserEvents(
      targetUserId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
  
  /// Get events by category
  Future<List<AnalyticsEvent>> getEventsByCategory(
    EventCategory category, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    _ensureInitialized();
    
    return _trackingService.getEventsByCategory(
      category,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
  
  /// Get session events
  Future<List<AnalyticsEvent>> getSessionEvents(String sessionId) async {
    _ensureInitialized();
    return _trackingService.getSessionEvents(sessionId);
  }
  
  /// Generate learning analytics
  Future<LearningAnalytics> generateLearningAnalytics({
    String? userId,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    _ensureInitialized();
    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) {
      throw Exception('No user ID available for analytics generation');
    }
    
    final start = periodStart ?? DateTime.now().subtract(const Duration(days: 30));
    final end = periodEnd ?? DateTime.now();
    
    final analytics = await _insightsService.generateLearningAnalytics(
      targetUserId,
      start,
      end,
    );
    
    // Store the generated analytics
    await _dataService.storeLearningAnalytics(analytics);
    
    return analytics;
  }
  
  /// Get stored learning analytics
  Future<List<LearningAnalytics>> getLearningAnalytics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    _ensureInitialized();
    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) return [];
    
    return _dataService.getLearningAnalytics(
      targetUserId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
  
  /// Get latest learning analytics
  Future<LearningAnalytics?> getLatestLearningAnalytics({String? userId}) async {
    _ensureInitialized();
    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) return null;
    
    return _dataService.getLatestLearningAnalytics(targetUserId);
  }
  
  /// Get aggregated metrics
  Future<Map<String, dynamic>> getAggregatedMetrics({
    String? userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _ensureInitialized();
    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) return {};
    
    return _dataService.getAggregatedMetrics(targetUserId, startDate, endDate);
  }
  
  /// Get performance insights
  Future<Map<String, dynamic>> getPerformanceInsights({String? userId}) async {
    _ensureInitialized();
    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) return {};
    
    return _dataService.getPerformanceInsights(targetUserId);
  }
  
  /// Stream user events for real-time analytics
  Stream<List<AnalyticsEvent>> streamUserEvents({
    String? userId,
    int limit = 50,
  }) {
    _ensureInitialized();
    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) {
      return Stream.value([]);
    }
    
    return _dataService.streamUserEvents(targetUserId, limit: limit);
  }
  
  // UTILITY METHODS
  
  /// Generate daily analytics report
  Future<LearningAnalytics> generateDailyReport({String? userId}) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return generateLearningAnalytics(
      userId: userId,
      periodStart: startOfDay,
      periodEnd: endOfDay,
    );
  }
  
  /// Generate weekly analytics report
  Future<LearningAnalytics> generateWeeklyReport({String? userId}) async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return generateLearningAnalytics(
      userId: userId,
      periodStart: startOfWeek,
      periodEnd: endOfWeek,
    );
  }
  
  /// Generate monthly analytics report
  Future<LearningAnalytics> generateMonthlyReport({String? userId}) async {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = DateTime(today.year, today.month + 1, 1);
    
    return generateLearningAnalytics(
      userId: userId,
      periodStart: startOfMonth,
      periodEnd: endOfMonth,
    );
  }
  
  /// Clean up old analytics data
  Future<void> cleanupOldData({Duration retentionPeriod = const Duration(days: 365)}) async {
    _ensureInitialized();
    final cutoffDate = DateTime.now().subtract(retentionPeriod);
    await _dataService.deleteOldEvents(cutoffDate);
  }
  
  /// Get current user ID
  String? get currentUserId => _currentUserId;
  
  /// Get current session ID
  String? get currentSessionId => _currentSessionId;
  
  /// Check if analytics is initialized
  bool get isInitialized => _isInitialized;
  
  /// Ensure analytics is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('AnalyticsManager not initialized. Call initialize() first.');
    }
  }
}
