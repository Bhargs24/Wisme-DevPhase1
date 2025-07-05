import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_models.dart';

/// Data service for analytics operations with Firestore
class AnalyticsDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _eventsCollection => 
      _firestore.collection('analytics_events');
  CollectionReference get _learningAnalyticsCollection => 
      _firestore.collection('learning_analytics');
  CollectionReference get _userInsightsCollection => 
      _firestore.collection('user_insights');

  /// Store analytics event
  Future<void> storeEvent(AnalyticsEvent event) async {
    try {
      await _eventsCollection.doc(event.id).set(event.toJson());
    } catch (e) {
      throw Exception('Failed to store analytics event: $e');
    }
  }

  /// Store multiple events in batch
  Future<void> storeEventsBatch(List<AnalyticsEvent> events) async {
    try {
      final batch = _firestore.batch();
      
      for (final event in events) {
        final docRef = _eventsCollection.doc(event.id);
        batch.set(docRef, event.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to store analytics events batch: $e');
    }
  }

  /// Get events by user ID
  Future<List<AnalyticsEvent>> getEventsByUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _eventsCollection.where('userId', isEqualTo: userId);
      
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      
      query = query.orderBy('timestamp', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AnalyticsEvent.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events by user: $e');
    }
  }

  /// Get events by category
  Future<List<AnalyticsEvent>> getEventsByCategory(
    EventCategory category, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _eventsCollection.where('category', isEqualTo: category.name);
      
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      
      query = query.orderBy('timestamp', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AnalyticsEvent.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events by category: $e');
    }
  }

  /// Get events by session
  Future<List<AnalyticsEvent>> getEventsBySession(String sessionId) async {
    try {
      final snapshot = await _eventsCollection
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('timestamp')
          .get();
      
      return snapshot.docs
          .map((doc) => AnalyticsEvent.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events by session: $e');
    }
  }

  /// Store learning analytics
  Future<void> storeLearningAnalytics(LearningAnalytics analytics) async {
    try {
      final docId = '${analytics.userId}_${analytics.periodStart.millisecondsSinceEpoch}';
      await _learningAnalyticsCollection.doc(docId).set(analytics.toJson());
    } catch (e) {
      throw Exception('Failed to store learning analytics: $e');
    }
  }

  /// Get learning analytics for user
  Future<List<LearningAnalytics>> getLearningAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _learningAnalyticsCollection.where('userId', isEqualTo: userId);
      
      if (startDate != null) {
        query = query.where('periodStart', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.where('periodEnd', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      
      query = query.orderBy('generatedAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => LearningAnalytics.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get learning analytics: $e');
    }
  }

  /// Get latest learning analytics for user
  Future<LearningAnalytics?> getLatestLearningAnalytics(String userId) async {
    try {
      final snapshot = await _learningAnalyticsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      return LearningAnalytics.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>
      );
    } catch (e) {
      throw Exception('Failed to get latest learning analytics: $e');
    }
  }

  /// Delete old events (data retention)
  Future<void> deleteOldEvents(DateTime cutoffDate) async {
    try {
      final snapshot = await _eventsCollection
          .where('timestamp', isLessThan: cutoffDate.toIso8601String())
          .get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete old events: $e');
    }
  }

  /// Get aggregated metrics
  Future<Map<String, dynamic>> getAggregatedMetrics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final events = await getEventsByUser(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Calculate aggregated metrics
      final totalEvents = events.length;
      final uniqueSessions = events
          .where((e) => e.sessionId != null)
          .map((e) => e.sessionId!)
          .toSet()
          .length;
      
      final categoryBreakdown = <String, int>{};
      final eventTypeBreakdown = <String, int>{};
      
      for (final event in events) {
        categoryBreakdown[event.category.name] = 
            (categoryBreakdown[event.category.name] ?? 0) + 1;
        eventTypeBreakdown[event.eventType] = 
            (eventTypeBreakdown[event.eventType] ?? 0) + 1;
      }
      
      return {
        'totalEvents': totalEvents,
        'uniqueSessions': uniqueSessions,
        'categoryBreakdown': categoryBreakdown,
        'eventTypeBreakdown': eventTypeBreakdown,
        'periodStart': startDate.toIso8601String(),
        'periodEnd': endDate.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get aggregated metrics: $e');
    }
  }

  /// Stream events for real-time analytics
  Stream<List<AnalyticsEvent>> streamUserEvents(
    String userId, {
    int limit = 50,
  }) {
    return _eventsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnalyticsEvent.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Get performance insights
  Future<Map<String, dynamic>> getPerformanceInsights(String userId) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final events = await getEventsByUser(
        userId,
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      
      // Calculate performance metrics
      final learningEvents = events.where((e) => 
          e.category == EventCategory.learning).toList();
      final engagementEvents = events.where((e) => 
          e.category == EventCategory.engagement).toList();
      
      final dailyActivity = <String, int>{};
      for (final event in events) {
        final dateKey = event.timestamp.toIso8601String().split('T')[0];
        dailyActivity[dateKey] = (dailyActivity[dateKey] ?? 0) + 1;
      }
      
      return {
        'totalLearningEvents': learningEvents.length,
        'totalEngagementEvents': engagementEvents.length,
        'dailyActivity': dailyActivity,
        'averageDailyActivity': dailyActivity.values.isEmpty 
            ? 0 
            : dailyActivity.values.reduce((a, b) => a + b) / dailyActivity.length,
      };
    } catch (e) {
      throw Exception('Failed to get performance insights: $e');
    }
  }
}
