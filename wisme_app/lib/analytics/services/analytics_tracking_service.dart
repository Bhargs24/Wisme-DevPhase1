import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/analytics_models.dart';
import '../data/analytics_data_service.dart';

/// Service for analytics event tracking and processing
class AnalyticsTrackingService {
  final AnalyticsDataService _dataService = AnalyticsDataService();
  final List<AnalyticsEvent> _eventQueue = [];
  final StreamController<AnalyticsEvent> _eventController = StreamController.broadcast();
  Timer? _batchTimer;
  
  static const int _batchSize = 50;
  static const Duration _batchInterval = Duration(seconds: 30);
  
  // Event stream
  Stream<AnalyticsEvent> get eventStream => _eventController.stream;
  
  /// Initialize analytics service
  void initialize() {
    _startBatchTimer();
  }
  
  /// Dispose resources
  void dispose() {
    _batchTimer?.cancel();
    _eventController.close();
    _flushEvents(); // Send any remaining events
  }
  
  /// Track an analytics event
  Future<void> trackEvent({
    required String userId,
    required String eventType,
    required String eventName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? context,
    String? sessionId,
    String? lessonId,
    String? coachId,
    EventCategory category = EventCategory.engagement,
    EventPriority priority = EventPriority.medium,
  }) async {
    final event = AnalyticsEvent(
      id: const Uuid().v4(),
      userId: userId,
      eventType: eventType,
      eventName: eventName,
      timestamp: DateTime.now(),
      properties: properties ?? {},
      context: _buildContext(context),
      sessionId: sessionId,
      lessonId: lessonId,
      coachId: coachId,
      category: category,
      priority: priority,
    );
    
    // Add to event stream
    _eventController.add(event);
    
    // Handle based on priority
    if (priority == EventPriority.critical) {
      // Send immediately for critical events
      await _dataService.storeEvent(event);
    } else {
      // Add to batch queue
      _eventQueue.add(event);
      
      // Send batch if queue is full
      if (_eventQueue.length >= _batchSize) {
        await _flushEvents();
      }
    }
  }
  
  /// Track learning session start
  Future<void> trackLearningSessionStart({
    required String userId,
    required String sessionId,
    required String lessonId,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      userId: userId,
      eventType: 'learning_session',
      eventName: 'session_start',
      properties: properties,
      sessionId: sessionId,
      lessonId: lessonId,
      category: EventCategory.learning,
      priority: EventPriority.high,
    );
  }
  
  /// Track learning session end
  Future<void> trackLearningSessionEnd({
    required String userId,
    required String sessionId,
    required String lessonId,
    required Duration duration,
    required double completionPercentage,
    Map<String, dynamic>? properties,
  }) async {
    final sessionProperties = {
      'duration_minutes': duration.inMinutes,
      'completion_percentage': completionPercentage,
      ...?properties,
    };
    
    await trackEvent(
      userId: userId,
      eventType: 'learning_session',
      eventName: 'session_end',
      properties: sessionProperties,
      sessionId: sessionId,
      lessonId: lessonId,
      category: EventCategory.learning,
      priority: EventPriority.high,
    );
  }
  
  /// Track lesson completion
  Future<void> trackLessonCompletion({
    required String userId,
    required String lessonId,
    required Duration studyTime,
    required double score,
    String? sessionId,
    Map<String, dynamic>? properties,
  }) async {
    final lessonProperties = {
      'study_time_minutes': studyTime.inMinutes,
      'score': score,
      ...?properties,
    };
    
    await trackEvent(
      userId: userId,
      eventType: 'lesson',
      eventName: 'lesson_completed',
      properties: lessonProperties,
      sessionId: sessionId,
      lessonId: lessonId,
      category: EventCategory.learning,
      priority: EventPriority.high,
    );
  }
  
  /// Track coach interaction
  Future<void> trackCoachInteraction({
    required String userId,
    required String coachId,
    required String interactionType,
    String? sessionId,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      userId: userId,
      eventType: 'coach_interaction',
      eventName: interactionType,
      properties: properties,
      sessionId: sessionId,
      coachId: coachId,
      category: EventCategory.engagement,
      priority: EventPriority.medium,
    );
  }
  
  /// Track user engagement
  Future<void> trackEngagement({
    required String userId,
    required String engagementType,
    required String element,
    String? sessionId,
    Map<String, dynamic>? properties,
  }) async {
    final engagementProperties = {
      'element': element,
      ...?properties,
    };
    
    await trackEvent(
      userId: userId,
      eventType: 'engagement',
      eventName: engagementType,
      properties: engagementProperties,
      sessionId: sessionId,
      category: EventCategory.engagement,
      priority: EventPriority.low,
    );
  }
  
  /// Track audio playback
  Future<void> trackAudioPlayback({
    required String userId,
    required String audioId,
    required String action, // play, pause, complete, skip
    Duration? position,
    Duration? duration,
    String? sessionId,
    Map<String, dynamic>? properties,
  }) async {
    final audioProperties = {
      'audio_id': audioId,
      'action': action,
      if (position != null) 'position_seconds': position.inSeconds,
      if (duration != null) 'duration_seconds': duration.inSeconds,
      ...?properties,
    };
    
    await trackEvent(
      userId: userId,
      eventType: 'audio_playback',
      eventName: action,
      properties: audioProperties,
      sessionId: sessionId,
      category: EventCategory.engagement,
      priority: EventPriority.low,
    );
  }
  
  /// Track error events
  Future<void> trackError({
    required String userId,
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    String? sessionId,
    Map<String, dynamic>? properties,
  }) async {
    final errorProperties = {
      'error_type': errorType,
      'error_message': errorMessage,
      if (stackTrace != null) 'stack_trace': stackTrace,
      ...?properties,
    };
    
    await trackEvent(
      userId: userId,
      eventType: 'error',
      eventName: errorType,
      properties: errorProperties,
      sessionId: sessionId,
      category: EventCategory.technical,
      priority: EventPriority.critical,
    );
  }
  
  /// Track performance metrics
  Future<void> trackPerformance({
    required String userId,
    required String metricName,
    required double value,
    String unit = 'ms',
    String? sessionId,
    Map<String, dynamic>? properties,
  }) async {
    final performanceProperties = {
      'metric_name': metricName,
      'value': value,
      'unit': unit,
      ...?properties,
    };
    
    await trackEvent(
      userId: userId,
      eventType: 'performance',
      eventName: metricName,
      properties: performanceProperties,
      sessionId: sessionId,
      category: EventCategory.technical,
      priority: EventPriority.low,
    );
  }
  
  /// Build context information
  Map<String, dynamic> _buildContext(Map<String, dynamic>? additionalContext) {
    final context = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'flutter',
      'app_version': '1.0.0', // TODO: Get from package info
      ...?additionalContext,
    };
    
    return context;
  }
  
  /// Start batch timer
  void _startBatchTimer() {
    _batchTimer = Timer.periodic(_batchInterval, (_) {
      _flushEvents();
    });
  }
  
  /// Flush events to storage
  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;
    
    try {
      final events = List<AnalyticsEvent>.from(_eventQueue);
      _eventQueue.clear();
      
      await _dataService.storeEventsBatch(events);
    } catch (e) {
      // TODO: Implement retry logic or local storage fallback
      print('Failed to flush analytics events: $e');
    }
  }
  
  /// Get events for user
  Future<List<AnalyticsEvent>> getUserEvents(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return _dataService.getEventsByUser(
      userId,
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
    return _dataService.getEventsByCategory(
      category,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }
  
  /// Get session events
  Future<List<AnalyticsEvent>> getSessionEvents(String sessionId) async {
    return _dataService.getEventsBySession(sessionId);
  }
}
