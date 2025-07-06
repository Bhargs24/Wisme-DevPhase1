/// Production-Ready Analytics and Monitoring Service
/// 
/// Comprehensive user analytics, usage tracking, and business intelligence
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Advanced analytics service for production monitoring
class AnalyticsService {
  static final Map<String, UserSession> _activeSessions = {};
  static final List<AnalyticsEvent> _eventQueue = [];
  static Timer? _flushTimer;
  static DateTime? _appStartTime;
  static int _totalSessions = 0;
  
  /// Initialize analytics tracking
  static Future<void> initialize() async {
    _appStartTime = DateTime.now();
    _startEventFlushTimer();
    await _loadSessionData();
    AppLogger.info('📊 Analytics service initialized');
  }

  /// Start a user session
  static void startSession(String userId) {
    final session = UserSession(
      userId: userId,
      sessionId: _generateSessionId(),
      startTime: DateTime.now(),
    );
    
    _activeSessions[userId] = session;
    _totalSessions++;
    
    trackEvent('session_start', {
      'user_id': userId,
      'session_id': session.sessionId,
      'app_version': '1.0.0',
      'platform': 'mobile',
    });
  }

  /// End a user session
  static void endSession(String userId) {
    final session = _activeSessions[userId];
    if (session != null) {
      final duration = DateTime.now().difference(session.startTime);
      
      trackEvent('session_end', {
        'user_id': userId,
        'session_id': session.sessionId,
        'duration_seconds': duration.inSeconds,
        'content_consumed': session.contentConsumed,
        'interactions': session.interactions,
      });
      
      _activeSessions.remove(userId);
    }
  }

  /// Track user event
  static void trackEvent(String eventName, Map<String, dynamic> properties) {
    final event = AnalyticsEvent(
      name: eventName,
      properties: properties,
      timestamp: DateTime.now(),
      userId: properties['user_id'] as String?,
    );
    
    _eventQueue.add(event);
    
    // Update session if applicable
    final userId = properties['user_id'] as String?;
    if (userId != null && _activeSessions.containsKey(userId)) {
      _activeSessions[userId]!.interactions++;
    }
    
    AppLogger.info('📈 Event tracked: $eventName');
  }

  /// Track content consumption
  static void trackContentConsumption({
    required String userId,
    required String contentId,
    required String contentType,
    required Duration duration,
    required double completionRate,
    Map<String, dynamic>? metadata,
  }) {
    trackEvent('content_consumed', {
      'user_id': userId,
      'content_id': contentId,
      'content_type': contentType,
      'duration_seconds': duration.inSeconds,
      'completion_rate': completionRate,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    });
    
    // Update session data
    final session = _activeSessions[userId];
    if (session != null) {
      session.contentConsumed++;
      session.totalListeningTime = session.totalListeningTime + duration;
    }
  }

  /// Track user engagement metrics
  static void trackEngagement({
    required String userId,
    required String action,
    String? contentId,
    Map<String, dynamic>? context,
  }) {
    trackEvent('user_engagement', {
      'user_id': userId,
      'action': action,
      'content_id': contentId,
      'timestamp': DateTime.now().toIso8601String(),
      ...?context,
    });
  }

  /// Track conversion events
  static void trackConversion({
    required String userId,
    required String conversionType,
    double? value,
    Map<String, dynamic>? metadata,
  }) {
    trackEvent('conversion', {
      'user_id': userId,
      'conversion_type': conversionType,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    });
  }

  /// Get real-time analytics dashboard data
  static Map<String, dynamic> getDashboardData() {
    final now = DateTime.now();
    final activeUsers = _activeSessions.length;
    final avgSessionDuration = _calculateAverageSessionDuration();
    final recentEvents = _getRecentEvents(const Duration(hours: 1));
    
    return {
      'active_users': activeUsers,
      'total_sessions_today': _totalSessions,
      'avg_session_duration_minutes': avgSessionDuration.inMinutes,
      'events_last_hour': recentEvents.length,
      'app_uptime_hours': _appStartTime != null 
          ? now.difference(_appStartTime!).inHours 
          : 0,
      'popular_content': _getPopularContent(),
      'user_engagement_rate': _calculateEngagementRate(),
      'conversion_rate': _calculateConversionRate(),
    };
  }

  /// Get user analytics for personalization
  static Map<String, dynamic> getUserAnalytics(String userId) {
    final session = _activeSessions[userId];
    final userEvents = _eventQueue.where((e) => e.userId == userId).toList();
    
    final contentEvents = userEvents.where((e) => e.name == 'content_consumed').toList();
    final engagementEvents = userEvents.where((e) => e.name == 'user_engagement').toList();
    
    return {
      'current_session': session?.toMap(),
      'total_content_consumed': contentEvents.length,
      'total_engagement_events': engagementEvents.length,
      'favorite_content_types': _getFavoriteContentTypes(contentEvents),
      'learning_patterns': _analyzeLearningPatterns(contentEvents),
      'engagement_score': _calculateUserEngagementScore(userId),
    };
  }

  /// Get business intelligence metrics
  static Map<String, dynamic> getBusinessMetrics() {
    final events = _eventQueue;
    final contentEvents = events.where((e) => e.name == 'content_consumed').toList();
    final conversionEvents = events.where((e) => e.name == 'conversion').toList();
    
    return {
      'total_users': _activeSessions.keys.toSet().length,
      'total_content_plays': contentEvents.length,
      'total_conversions': conversionEvents.length,
      'revenue_metrics': _calculateRevenueMetrics(conversionEvents),
      'user_retention': _calculateRetentionMetrics(),
      'content_performance': _getContentPerformanceMetrics(),
      'platform_health': _getPlatformHealthMetrics(),
    };
  }

  /// Flush events to storage/external analytics
  static Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;
    
    try {
      // In production, send to analytics service (Firebase Analytics, Mixpanel, etc.)
      final events = List<AnalyticsEvent>.from(_eventQueue);
      _eventQueue.clear();
      
      // Store locally for offline support
      await _storeEventsLocally(events);
      
      AppLogger.info('📤 Flushed ${events.length} analytics events');
    } catch (e) {
      AppLogger.error('Failed to flush analytics events: $e');
    }
  }

  /// Store events locally for offline support
  static Future<void> _storeEventsLocally(List<AnalyticsEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = events.map((e) => e.toJson()).toList();
      await prefs.setString('analytics_events', jsonEncode(eventsJson));
    } catch (e) {
      AppLogger.error('Failed to store events locally: $e');
    }
  }

  /// Load session data from storage
  static Future<void> _loadSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalSessions = prefs.getInt('total_sessions') ?? 0;
    } catch (e) {
      AppLogger.error('Failed to load session data: $e');
    }
  }

  /// Start timer to flush events periodically
  static void _startEventFlushTimer() {
    _flushTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _flushEvents();
    });
  }

  /// Generate unique session ID
  static String _generateSessionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return '${timestamp}_$randomNum';
  }

  /// Calculate average session duration
  static Duration _calculateAverageSessionDuration() {
    if (_activeSessions.isEmpty) return Duration.zero;
    
    final totalDuration = _activeSessions.values
        .map((session) => DateTime.now().difference(session.startTime))
        .fold<Duration>(Duration.zero, (sum, duration) => sum + duration);
    
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ _activeSessions.length);
  }

  /// Get recent events
  static List<AnalyticsEvent> _getRecentEvents(Duration timeWindow) {
    final cutoff = DateTime.now().subtract(timeWindow);
    return _eventQueue.where((event) => event.timestamp.isAfter(cutoff)).toList();
  }

  /// Get popular content
  static List<Map<String, dynamic>> _getPopularContent() {
    final contentEvents = _eventQueue.where((e) => e.name == 'content_consumed').toList();
    final contentCounts = <String, int>{};
    
    for (final event in contentEvents) {
      final contentId = event.properties['content_id'] as String?;
      if (contentId != null) {
        contentCounts[contentId] = (contentCounts[contentId] ?? 0) + 1;
      }
    }
    
    final sorted = contentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(10).map((entry) => {
      'content_id': entry.key,
      'play_count': entry.value,
    }).toList();
  }

  /// Calculate engagement rate
  static double _calculateEngagementRate() {
    final totalEvents = _eventQueue.length;
    final engagementEvents = _eventQueue.where((e) => 
        e.name == 'user_engagement' || e.name == 'content_consumed').length;
    
    return totalEvents > 0 ? engagementEvents / totalEvents : 0.0;
  }

  /// Calculate conversion rate
  static double _calculateConversionRate() {
    final totalUsers = _activeSessions.keys.toSet().length;
    final convertedUsers = _eventQueue
        .where((e) => e.name == 'conversion')
        .map((e) => e.userId)
        .toSet()
        .length;
    
    return totalUsers > 0 ? convertedUsers / totalUsers : 0.0;
  }

  /// Analyze user's favorite content types
  static List<String> _getFavoriteContentTypes(List<AnalyticsEvent> contentEvents) {
    final typeCounts = <String, int>{};
    
    for (final event in contentEvents) {
      final contentType = event.properties['content_type'] as String?;
      if (contentType != null) {
        typeCounts[contentType] = (typeCounts[contentType] ?? 0) + 1;
      }
    }
    
    final sorted = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Analyze learning patterns
  static Map<String, dynamic> _analyzeLearningPatterns(List<AnalyticsEvent> contentEvents) {
    if (contentEvents.isEmpty) return {};
    
    final avgDuration = contentEvents
        .map((e) => e.properties['duration_seconds'] as int? ?? 0)
        .reduce((a, b) => a + b) / contentEvents.length;
    
    final avgCompletion = contentEvents
        .map((e) => e.properties['completion_rate'] as double? ?? 0.0)
        .reduce((a, b) => a + b) / contentEvents.length;
    
    return {
      'avg_duration_seconds': avgDuration,
      'avg_completion_rate': avgCompletion,
      'preferred_time': _getPreferredLearningTime(contentEvents),
      'learning_frequency': contentEvents.length,
    };
  }

  /// Get preferred learning time
  static String _getPreferredLearningTime(List<AnalyticsEvent> events) {
    final hourCounts = <int, int>{};
    
    for (final event in events) {
      final hour = event.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    if (hourCounts.isEmpty) return 'unknown';
    
    final mostActiveHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    if (mostActiveHour >= 6 && mostActiveHour < 12) return 'morning';
    if (mostActiveHour >= 12 && mostActiveHour < 18) return 'afternoon';
    if (mostActiveHour >= 18 && mostActiveHour < 22) return 'evening';
    return 'night';
  }

  /// Calculate user engagement score
  static double _calculateUserEngagementScore(String userId) {
    final userEvents = _eventQueue.where((e) => e.userId == userId).toList();
    if (userEvents.isEmpty) return 0.0;
    
    final contentEvents = userEvents.where((e) => e.name == 'content_consumed').length;
    final engagementEvents = userEvents.where((e) => e.name == 'user_engagement').length;
    final sessionLength = _activeSessions[userId]?.totalListeningTime.inMinutes ?? 0;
    
    // Weighted score
    return (contentEvents * 0.4 + engagementEvents * 0.3 + sessionLength * 0.3) / 10.0;
  }

  /// Calculate revenue metrics
  static Map<String, dynamic> _calculateRevenueMetrics(List<AnalyticsEvent> conversionEvents) {
    double totalRevenue = 0.0;
    int paidConversions = 0;
    
    for (final event in conversionEvents) {
      final value = event.properties['value'] as double?;
      if (value != null && value > 0) {
        totalRevenue += value;
        paidConversions++;
      }
    }
    
    return {
      'total_revenue': totalRevenue,
      'paid_conversions': paidConversions,
      'avg_revenue_per_user': paidConversions > 0 ? totalRevenue / paidConversions : 0.0,
    };
  }

  /// Calculate retention metrics
  static Map<String, dynamic> _calculateRetentionMetrics() {
    // Simplified retention calculation
    final uniqueUsers = _eventQueue.map((e) => e.userId).toSet().length;
    final returningUsers = _activeSessions.length;
    
    return {
      'total_unique_users': uniqueUsers,
      'current_active_users': returningUsers,
      'retention_rate': uniqueUsers > 0 ? returningUsers / uniqueUsers : 0.0,
    };
  }

  /// Get content performance metrics
  static Map<String, dynamic> _getContentPerformanceMetrics() {
    final contentEvents = _eventQueue.where((e) => e.name == 'content_consumed').toList();
    
    if (contentEvents.isEmpty) return {};
    
    final avgCompletion = contentEvents
        .map((e) => e.properties['completion_rate'] as double? ?? 0.0)
        .reduce((a, b) => a + b) / contentEvents.length;
    
    return {
      'total_content_plays': contentEvents.length,
      'avg_completion_rate': avgCompletion,
      'popular_content': _getPopularContent(),
    };
  }

  /// Get platform health metrics
  static Map<String, dynamic> _getPlatformHealthMetrics() {
    final errorEvents = _eventQueue.where((e) => e.name == 'error').length;
    final totalEvents = _eventQueue.length;
    
    return {
      'error_rate': totalEvents > 0 ? errorEvents / totalEvents : 0.0,
      'uptime_hours': _appStartTime != null 
          ? DateTime.now().difference(_appStartTime!).inHours 
          : 0,
      'active_sessions': _activeSessions.length,
    };
  }

  /// Force flush events immediately
  static Future<void> flush() async {
    await _flushEvents();
  }

  /// Dispose resources
  static void dispose() {
    _flushTimer?.cancel();
    _eventQueue.clear();
    _activeSessions.clear();
  }

  /// Get comprehensive learning statistics for a user
  static Future<Map<String, dynamic>> getUserLearningStats(String userId) async {
    try {
      // Get user events and calculate statistics
      final events = _eventQueue.where((event) => event.userId == userId).toList();
      final session = _activeSessions[userId];
      
      // Calculate total lessons completed
      final lessonCompletedEvents = events.where(
        (event) => event.name == 'lesson_completed'
      ).toList();
      
      // Calculate total learning time
      final learningEvents = events.where(
        (event) => event.name == 'content_generation_completed' || 
                   event.name == 'audio_played' ||
                   event.name == 'lesson_progress'
      ).toList();
      
      int totalTimeMinutes = 0;
      for (final event in learningEvents) {
        final duration = event.properties['duration_minutes'] as int? ?? 0;
        totalTimeMinutes += duration;
      }
      
      // Calculate streak days (simplified)
      final today = DateTime.now();
      final recentDays = List.generate(7, (index) => 
        today.subtract(Duration(days: index))
      );
      
      int streakDays = 0;
      for (final day in recentDays) {
        final dayEvents = events.where((event) {
          final eventDate = event.timestamp;
          return eventDate.year == day.year &&
                 eventDate.month == day.month &&
                 eventDate.day == day.day &&
                 (event.name == 'lesson_completed' || event.name == 'content_generated');
        }).toList();
        
        if (dayEvents.isNotEmpty) {
          streakDays++;
        } else {
          break; // Streak broken
        }
      }
      
      // Calculate completion rate
      final startedLessons = events.where(
        (event) => event.name == 'lesson_started'
      ).length;
      final completedLessons = lessonCompletedEvents.length;
      final completionRate = startedLessons > 0 
        ? (completedLessons / startedLessons * 100).round()
        : 0;
      
      // Get topic progress
      final topicEvents = events.where(
        (event) => event.name == 'content_generated' && 
                   event.properties.containsKey('topic')
      ).toList();
      
      final Map<String, double> topicProgress = {};
      for (final event in topicEvents) {
        final topic = event.properties['topic'] as String? ?? 'Unknown';
        final progress = event.properties['completion_percentage'] as double? ?? 0.0;
        topicProgress[topic] = (topicProgress[topic] ?? 0.0) + progress;
      }
      
      // Normalize topic progress
      topicProgress.updateAll((key, value) => 
        value > 1.0 ? 1.0 : value
      );
      
      // Get recent activities
      final recentActivities = events
        .where((event) => 
          DateTime.now().difference(event.timestamp).inDays <= 7
        )
        .take(10)
        .map((event) => {
          'description': _getActivityDescription(event),
          'time': _formatTimeAgo(event.timestamp),
          'type': event.name,
        })
        .toList();
      
      // Get achievements (simplified)
      final achievements = <Map<String, dynamic>>[];
      if (completedLessons >= 1) {
        achievements.add({'name': 'First Lesson', 'earned': true});
      }
      if (completedLessons >= 10) {
        achievements.add({'name': 'Dedicated Learner', 'earned': true});
      }
      if (streakDays >= 3) {
        achievements.add({'name': '3-Day Streak', 'earned': true});
      }
      if (totalTimeMinutes >= 60) {
        achievements.add({'name': 'Hour Scholar', 'earned': true});
      }
      
      return {
        'totalLessons': completedLessons,
        'totalTimeMinutes': totalTimeMinutes,
        'streakDays': streakDays,
        'completionRate': completionRate,
        'topicProgress': topicProgress,
        'recentActivities': recentActivities,
        'achievements': achievements,
        'sessionStarted': session?.startTime.toIso8601String(),
      };
      
    } catch (e) {
      AppLogger.error('Failed to get learning stats: $e');
      return {
        'totalLessons': 0,
        'totalTimeMinutes': 0,
        'streakDays': 0,
        'completionRate': 0,
        'topicProgress': <String, double>{},
        'recentActivities': <Map<String, dynamic>>[],
        'achievements': <Map<String, dynamic>>[],
      };
    }
  }
  
  static String _getActivityDescription(AnalyticsEvent event) {
    switch (event.name) {
      case 'lesson_completed':
        return 'Completed lesson: ${event.properties['lesson_title'] ?? 'Unknown'}';
      case 'content_generated':
        return 'Generated content for: ${event.properties['topic'] ?? 'Unknown topic'}';
      case 'audio_played':
        return 'Listened to audio content';
      case 'session_start':
        return 'Started learning session';
      default:
        return 'Learning activity';
    }
  }
  
  static String _formatTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Clear all local analytics data
  static Future<void> clearLocalAnalytics() async {
    try {
      _eventQueue.clear();
      _activeSessions.clear();
      
      // Clear stored session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('total_sessions');
      await prefs.remove('last_session_id');
      
      AppLogger.info('✅ Analytics data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear analytics data: $e');
    }
  }
}

/// User session data
class UserSession {
  final String userId;
  final String sessionId;
  final DateTime startTime;
  int interactions = 0;
  int contentConsumed = 0;
  Duration totalListeningTime = Duration.zero;

  UserSession({
    required this.userId,
    required this.sessionId,
    required this.startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'start_time': startTime.toIso8601String(),
      'interactions': interactions,
      'content_consumed': contentConsumed,
      'total_listening_minutes': totalListeningTime.inMinutes,
    };
  }
}

/// Analytics event data
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String? userId;

  AnalyticsEvent({
    required this.name,
    required this.properties,
    required this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'properties': properties,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
    };
  }
}
