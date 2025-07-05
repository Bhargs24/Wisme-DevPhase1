import 'dart:math';
import '../models/analytics_models.dart';
import '../data/analytics_data_service.dart';

/// Service for generating learning analytics and insights
class AnalyticsInsightsService {
  final AnalyticsDataService _dataService = AnalyticsDataService();
  
  /// Generate learning analytics for a user
  Future<LearningAnalytics> generateLearningAnalytics(
    String userId,
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    try {
      // Get all events for the period
      final events = await _dataService.getEventsByUser(
        userId,
        startDate: periodStart,
        endDate: periodEnd,
      );
      
      // Calculate metrics
      final metrics = await _calculateLearningMetrics(events);
      final engagement = await _calculateEngagementMetrics(events);
      final performance = await _calculatePerformanceMetrics(events);
      final progress = await _calculateProgressMetrics(events);
      final behavioral = await _calculateBehavioralInsights(events);
      final recommendations = await _generateRecommendations(
        events, metrics, engagement, performance, progress, behavioral
      );
      
      return LearningAnalytics(
        userId: userId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        metrics: metrics,
        engagement: engagement,
        performance: performance,
        progress: progress,
        behavioral: behavioral,
        recommendations: recommendations,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to generate learning analytics: $e');
    }
  }
  
  /// Calculate learning metrics
  Future<LearningMetrics> _calculateLearningMetrics(List<AnalyticsEvent> events) async {
    final learningEvents = events.where((e) => e.category == EventCategory.learning).toList();
    final sessionEvents = events.where((e) => e.eventType == 'learning_session').toList();
    
    // Calculate total study time
    Duration totalStudyTime = Duration.zero;
    final sessionDurations = <Duration>[];
    
    for (final event in sessionEvents) {
      if (event.eventName == 'session_end') {
        final durationMinutes = event.properties['duration_minutes'] as int? ?? 0;
        final duration = Duration(minutes: durationMinutes);
        totalStudyTime += duration;
        sessionDurations.add(duration);
      }
    }
    
    // Count sessions and lessons
    final uniqueSessions = sessionEvents
        .where((e) => e.sessionId != null)
        .map((e) => e.sessionId!)
        .toSet()
        .length;
    
    final lessonsCompleted = learningEvents
        .where((e) => e.eventName == 'lesson_completed')
        .length;
    
    final lessonsStarted = learningEvents
        .where((e) => e.eventName == 'lesson_started')
        .length;
    
    // Calculate completion rate
    final completionRate = lessonsStarted > 0 
        ? lessonsCompleted / lessonsStarted 
        : 0.0;
    
    // Calculate average session duration
    final averageSessionDuration = sessionDurations.isNotEmpty
        ? Duration(milliseconds: 
            sessionDurations.map((d) => d.inMilliseconds).reduce((a, b) => a + b) 
            ~/ sessionDurations.length)
        : Duration.zero;
    
    // Calculate streak days (simplified)
    final streakDays = _calculateStreakDays(events);
    
    return LearningMetrics(
      totalStudyTime: totalStudyTime,
      totalSessions: uniqueSessions,
      lessonsCompleted: lessonsCompleted,
      lessonsStarted: lessonsStarted,
      averageSessionDuration: averageSessionDuration,
      completionRate: completionRate,
      retentionRate: _calculateRetentionRate(events),
      streakDays: streakDays,
      maxStreakDays: streakDays, // Simplified for now
    );
  }
  
  /// Calculate engagement metrics
  Future<EngagementMetrics> _calculateEngagementMetrics(List<AnalyticsEvent> events) async {
    final engagementEvents = events.where((e) => e.category == EventCategory.engagement).toList();
    
    // Calculate active scores (simplified)
    final dailyActiveScore = _calculateActiveScore(events, 1);
    final weeklyActiveScore = _calculateActiveScore(events, 7);
    final monthlyActiveScore = _calculateActiveScore(events, 30);
    
    // Calculate interaction count
    final interactionCount = engagementEvents.length;
    
    // Calculate session lengths
    final sessionLengths = <Duration>[];
    final sessionEndEvents = events.where((e) => 
        e.eventType == 'learning_session' && e.eventName == 'session_end').toList();
    
    for (final event in sessionEndEvents) {
      final durationMinutes = event.properties['duration_minutes'] as int? ?? 0;
      sessionLengths.add(Duration(minutes: durationMinutes));
    }
    
    final averageSessionLength = sessionLengths.isNotEmpty
        ? Duration(milliseconds: 
            sessionLengths.map((d) => d.inMilliseconds).reduce((a, b) => a + b) 
            ~/ sessionLengths.length)
        : Duration.zero;
    
    // Calculate bounce rate (simplified)
    final bounceRate = _calculateBounceRate(events);
    
    // Calculate feature usage
    final featureUsage = <String, int>{};
    for (final event in events) {
      featureUsage[event.eventType] = (featureUsage[event.eventType] ?? 0) + 1;
    }
    
    // Determine preferred learning times
    final preferredLearningTimes = _calculatePreferredLearningTimes(events);
    
    return EngagementMetrics(
      dailyActiveScore: dailyActiveScore,
      weeklyActiveScore: weeklyActiveScore,
      monthlyActiveScore: monthlyActiveScore,
      interactionCount: interactionCount,
      averageSessionLength: averageSessionLength,
      bounceRate: bounceRate,
      featureUsage: featureUsage,
      preferredLearningTimes: preferredLearningTimes,
    );
  }
  
  /// Calculate performance metrics
  Future<PerformanceMetrics> _calculatePerformanceMetrics(List<AnalyticsEvent> events) async {
    final lessonEvents = events.where((e) => e.eventType == 'lesson').toList();
    
    // Calculate average scores
    final scores = <double>[];
    for (final event in lessonEvents) {
      if (event.eventName == 'lesson_completed') {
        final score = event.properties['score'] as double? ?? 0.0;
        scores.add(score);
      }
    }
    
    final averageScore = scores.isNotEmpty 
        ? scores.reduce((a, b) => a + b) / scores.length 
        : 0.0;
    
    final highestScore = scores.isNotEmpty ? scores.reduce(max) : 0.0;
    final lowestScore = scores.isNotEmpty ? scores.reduce(min) : 0.0;
    
    // Calculate improvement rate (simplified)
    final improvementRate = _calculateImprovementRate(scores);
    
    // Calculate consistency score
    final consistencyScore = _calculateConsistencyScore(events);
    
    // Calculate skill ratings (simplified)
    final skillRatings = <String, double>{
      'comprehension': averageScore * 0.9,
      'retention': consistencyScore,
      'application': averageScore * 0.8,
    };
    
    // Performance trends (simplified)
    final performanceTrends = <String, double>{
      'weekly_change': improvementRate,
      'monthly_change': improvementRate * 4,
    };
    
    return PerformanceMetrics(
      averageScore: averageScore,
      highestScore: highestScore,
      lowestScore: lowestScore,
      improvementRate: improvementRate,
      consistencyScore: consistencyScore,
      skillRatings: skillRatings,
      performanceTrends: performanceTrends,
    );
  }
  
  /// Calculate progress metrics
  Future<ProgressMetrics> _calculateProgressMetrics(List<AnalyticsEvent> events) async {
    final lessonEvents = events.where((e) => e.eventType == 'lesson').toList();
    
    // Count completed lessons by difficulty
    final completedByDifficulty = <String, int>{
      'beginner': 0,
      'intermediate': 0,
      'advanced': 0,
    };
    
    // Simplified skill levels
    final skillLevels = <String, String>{
      'overall': 'intermediate',
      'comprehension': 'intermediate',
      'application': 'beginner',
    };
    
    // Calculate mastery percentages (simplified)
    final masteryPercentages = <String, double>{
      'beginner': 85.0,
      'intermediate': 60.0,
      'advanced': 25.0,
    };
    
    // Learning velocity (lessons per week)
    final learningVelocity = lessonEvents
        .where((e) => e.eventName == 'lesson_completed')
        .length / 7.0; // Assuming 1 week period
    
    // Time to mastery predictions
    final timeToMastery = <String, Duration>{
      'current_lesson': const Duration(days: 3),
      'current_module': const Duration(days: 14),
      'current_course': const Duration(days: 60),
    };
    
    return ProgressMetrics(
      completedByDifficulty: completedByDifficulty,
      skillLevels: skillLevels,
      masteryPercentages: masteryPercentages,
      learningVelocity: learningVelocity,
      timeToMastery: timeToMastery,
    );
  }
  
  /// Calculate behavioral insights
  Future<BehavioralInsights> _calculateBehavioralInsights(List<AnalyticsEvent> events) async {
    // Learning patterns
    final learningPatterns = <String>[
      'Visual learner',
      'Consistent scheduler',
      'Progress-driven',
    ];
    
    // Preferred study times
    final preferredStudyTimes = _calculatePreferredLearningTimes(events);
    
    // Attention span (simplified)
    final sessionLengths = events
        .where((e) => e.eventType == 'learning_session' && e.eventName == 'session_end')
        .map((e) => Duration(minutes: e.properties['duration_minutes'] as int? ?? 0))
        .toList();
    
    final averageAttentionSpan = sessionLengths.isNotEmpty
        ? Duration(milliseconds: 
            sessionLengths.map((d) => d.inMilliseconds).reduce((a, b) => a + b) 
            ~/ sessionLengths.length)
        : const Duration(minutes: 20);
    
    // Motivation factors
    final motivationFactors = <String>[
      'Achievement badges',
      'Progress tracking',
      'Personalized feedback',
    ];
    
    // Challenge preferences
    final challengePreferences = <String, double>{
      'prefers_easy': 0.3,
      'prefers_moderate': 0.5,
      'prefers_difficult': 0.2,
    };
    
    return BehavioralInsights(
      learningPatterns: learningPatterns,
      preferredStudyTimes: preferredStudyTimes,
      averageAttentionSpan: averageAttentionSpan,
      motivationFactors: motivationFactors,
      challengePreferences: challengePreferences,
    );
  }
  
  /// Generate personalized recommendations
  Future<List<LearningRecommendation>> _generateRecommendations(
    List<AnalyticsEvent> events,
    LearningMetrics metrics,
    EngagementMetrics engagement,
    PerformanceMetrics performance,
    ProgressMetrics progress,
    BehavioralInsights behavioral,
  ) async {
    final recommendations = <LearningRecommendation>[];
    
    // Recommendation based on session length
    if (engagement.averageSessionLength.inMinutes < 15) {
      recommendations.add(LearningRecommendation(
        id: 'extend_sessions',
        type: RecommendationType.studyHabit,
        title: 'Extend Your Study Sessions',
        description: 'Try studying for 20-25 minutes for better retention.',
        priority: RecommendationPriority.medium,
        actionable: true,
        estimatedImpact: 0.3,
        category: 'Study Habits',
      ));
    }
    
    // Recommendation based on consistency
    if (metrics.streakDays < 3) {
      recommendations.add(LearningRecommendation(
        id: 'build_consistency',
        type: RecommendationType.studyHabit,
        title: 'Build a Study Streak',
        description: 'Try to study for at least 10 minutes daily to build momentum.',
        priority: RecommendationPriority.high,
        actionable: true,
        estimatedImpact: 0.5,
        category: 'Consistency',
      ));
    }
    
    // Performance-based recommendation
    if (performance.averageScore < 70) {
      recommendations.add(LearningRecommendation(
        id: 'review_content',
        type: RecommendationType.content,
        title: 'Review Previous Lessons',
        description: 'Spend time reviewing past lessons to strengthen your foundation.',
        priority: RecommendationPriority.high,
        actionable: true,
        estimatedImpact: 0.4,
        category: 'Performance',
      ));
    }
    
    return recommendations;
  }
  
  /// Helper methods for calculations
  int _calculateStreakDays(List<AnalyticsEvent> events) {
    // Simplified streak calculation
    final learningDays = events
        .where((e) => e.category == EventCategory.learning)
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort();
    
    if (learningDays.isEmpty) return 0;
    
    int streak = 1;
    for (int i = learningDays.length - 1; i > 0; i--) {
      if (learningDays[i].difference(learningDays[i - 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  double _calculateRetentionRate(List<AnalyticsEvent> events) {
    // Simplified retention rate calculation
    final sessionEvents = events.where((e) => e.eventType == 'learning_session').toList();
    if (sessionEvents.isEmpty) return 0.0;
    
    final completedSessions = sessionEvents
        .where((e) => e.eventName == 'session_end')
        .length;
    
    return completedSessions / sessionEvents.length;
  }
  
  double _calculateActiveScore(List<AnalyticsEvent> events, int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentEvents = events.where((e) => e.timestamp.isAfter(cutoffDate)).toList();
    
    // Simple scoring based on event count and variety
    final eventTypes = recentEvents.map((e) => e.eventType).toSet().length;
    final eventCount = recentEvents.length;
    
    return min(1.0, (eventCount / 10.0) * (eventTypes / 5.0));
  }
  
  double _calculateBounceRate(List<AnalyticsEvent> events) {
    // Simplified bounce rate: sessions with only one event
    final sessionGroups = <String, List<AnalyticsEvent>>{};
    
    for (final event in events) {
      if (event.sessionId != null) {
        sessionGroups[event.sessionId!] ??= [];
        sessionGroups[event.sessionId!]!.add(event);
      }
    }
    
    if (sessionGroups.isEmpty) return 0.0;
    
    final bouncedSessions = sessionGroups.values
        .where((events) => events.length <= 1)
        .length;
    
    return bouncedSessions / sessionGroups.length;
  }
  
  List<String> _calculatePreferredLearningTimes(List<AnalyticsEvent> events) {
    final hourCounts = <int, int>{};
    
    for (final event in events) {
      if (event.category == EventCategory.learning) {
        final hour = event.timestamp.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }
    
    if (hourCounts.isEmpty) return ['morning'];
    
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topHours = sortedHours.take(3).map((e) => e.key).toList();
    
    return topHours.map((hour) {
      if (hour >= 6 && hour < 12) return 'morning';
      if (hour >= 12 && hour < 18) return 'afternoon';
      if (hour >= 18 && hour < 22) return 'evening';
      return 'night';
    }).toSet().toList();
  }
  
  double _calculateImprovementRate(List<double> scores) {
    if (scores.length < 2) return 0.0;
    
    final recentScores = scores.take(5).toList();
    final olderScores = scores.skip(max(0, scores.length - 5)).toList();
    
    if (recentScores.isEmpty || olderScores.isEmpty) return 0.0;
    
    final recentAvg = recentScores.reduce((a, b) => a + b) / recentScores.length;
    final olderAvg = olderScores.reduce((a, b) => a + b) / olderScores.length;
    
    return (recentAvg - olderAvg) / olderAvg;
  }
  
  double _calculateConsistencyScore(List<AnalyticsEvent> events) {
    final learningDays = events
        .where((e) => e.category == EventCategory.learning)
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .length;
    
    final totalDays = DateTime.now().difference(
      events.isEmpty ? DateTime.now() : events.last.timestamp
    ).inDays + 1;
    
    return learningDays / totalDays;
  }
}
