import 'achievement.dart';

/// Industrial-grade Analytics models for learning insights and tracking
class LearningInsights {
  final String userId;
  final DateTime generatedAt;
  final Duration totalLearningTime;
  final int totalSessions;
  final int completedSessions;
  final Map<String, Duration> timeByCategory;
  final Map<String, int> sessionsByCategory;
  final LearningStreak currentStreak;
  final LearningStreak longestStreak;
  final double averageSessionDuration;
  final double completionRate;
  final Map<String, double> categoryProgress;
  final List<String> preferredLearningTimes;
  final List<Achievement> recentAchievements;
  final Map<String, dynamic> recommendations;
  final ProgressTrend weeklyTrend;
  final ProgressTrend monthlyTrend;
  final Map<String, dynamic> metadata;

  const LearningInsights({
    required this.userId,
    required this.generatedAt,
    required this.totalLearningTime,
    required this.totalSessions,
    required this.completedSessions,
    required this.timeByCategory,
    required this.sessionsByCategory,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageSessionDuration,
    required this.completionRate,
    required this.categoryProgress,
    required this.preferredLearningTimes,
    required this.recentAchievements,
    required this.recommendations,
    required this.weeklyTrend,
    required this.monthlyTrend,
    this.metadata = const {},
  });

  /// Create from JSON
  factory LearningInsights.fromJson(Map<String, dynamic> json) {
    return LearningInsights(
      userId: json['user_id'],
      generatedAt: DateTime.parse(json['generated_at']),
      totalLearningTime: Duration(milliseconds: json['total_learning_time_ms']),
      totalSessions: json['total_sessions'],
      completedSessions: json['completed_sessions'],
      timeByCategory: Map<String, Duration>.from(
        (json['time_by_category'] ?? {}).map(
          (key, value) => MapEntry(key, Duration(milliseconds: value)),
        ),
      ),
      sessionsByCategory: Map<String, int>.from(json['sessions_by_category'] ?? {}),
      currentStreak: LearningStreak.fromJson(json['current_streak']),
      longestStreak: LearningStreak.fromJson(json['longest_streak']),
      averageSessionDuration: json['average_session_duration'].toDouble(),
      completionRate: json['completion_rate'].toDouble(),
      categoryProgress: Map<String, double>.from(json['category_progress'] ?? {}),
      preferredLearningTimes: List<String>.from(json['preferred_learning_times'] ?? []),
      recentAchievements: (json['recent_achievements'] as List? ?? [])
          .map((e) => Achievement.fromJson(e))
          .toList(),
      recommendations: json['recommendations'] ?? {},
      weeklyTrend: ProgressTrend.fromJson(json['weekly_trend']),
      monthlyTrend: ProgressTrend.fromJson(json['monthly_trend']),
      metadata: json['metadata'] ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'generated_at': generatedAt.toIso8601String(),
      'total_learning_time_ms': totalLearningTime.inMilliseconds,
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'time_by_category': timeByCategory.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'sessions_by_category': sessionsByCategory,
      'current_streak': currentStreak.toJson(),
      'longest_streak': longestStreak.toJson(),
      'average_session_duration': averageSessionDuration,
      'completion_rate': completionRate,
      'category_progress': categoryProgress,
      'preferred_learning_times': preferredLearningTimes,
      'recent_achievements': recentAchievements.map((e) => e.toJson()).toList(),
      'recommendations': recommendations,
      'weekly_trend': weeklyTrend.toJson(),
      'monthly_trend': monthlyTrend.toJson(),
      'metadata': metadata,
    };
  }

  // Business Logic Methods

  /// Get formatted total learning time
  String get formattedTotalTime {
    final hours = totalLearningTime.inHours;
    final minutes = totalLearningTime.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get completion rate as percentage string
  String get formattedCompletionRate => '${(completionRate * 100).toStringAsFixed(0)}%';

  /// Get most preferred category
  String? get favoriteCategory {
    if (timeByCategory.isEmpty) return null;
    return timeByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Check if user is improving
  bool get isImproving => weeklyTrend.isPositive || monthlyTrend.isPositive;

  /// Get learning consistency score (0.0 - 1.0)
  double get consistencyScore {
    if (totalSessions == 0) return 0.0;
    
    final streakRatio = currentStreak.days / 30.0; // Based on 30-day period
    final completionRatio = completionRate;
    
    return ((streakRatio * 0.6) + (completionRatio * 0.4)).clamp(0.0, 1.0);
  }

  /// Get next milestone suggestion
  String? get nextMilestone {
    if (totalSessions < 10) {
      return 'Complete ${10 - totalSessions} more sessions to reach "Dedicated Learner"';
    } else if (currentStreak.days < 7) {
      return 'Learn ${7 - currentStreak.days} more consecutive days for "Consistent Week"';
    } else if (totalSessions < 50) {
      return 'Complete ${50 - totalSessions} more sessions to reach "Learning Enthusiast"';
    }
    return null;
  }
}

/// Learning streak information
class LearningStreak {
  final int days;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const LearningStreak({
    required this.days,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.metadata = const {},
  });

  /// Create from JSON
  factory LearningStreak.fromJson(Map<String, dynamic> json) {
    return LearningStreak(
      days: json['days'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'],
      metadata: json['metadata'] ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  /// Get streak description
  String get description {
    if (days == 0) return 'No streak';
    if (days == 1) return '1 day';
    return '$days days';
  }

  /// Check if streak is impressive (7+ days)
  bool get isImpressive => days >= 7;
}

/// Progress trend analysis
class ProgressTrend {
  final String period; // 'week', 'month', 'quarter'
  final double change; // Percentage change
  final TrendDirection direction;
  final Map<String, double> metrics;
  final DateTime calculatedAt;

  const ProgressTrend({
    required this.period,
    required this.change,
    required this.direction,
    required this.metrics,
    required this.calculatedAt,
  });

  /// Create from JSON
  factory ProgressTrend.fromJson(Map<String, dynamic> json) {
    return ProgressTrend(
      period: json['period'],
      change: json['change'].toDouble(),
      direction: TrendDirection.values.firstWhere(
        (e) => e.toString().split('.').last == json['direction'],
        orElse: () => TrendDirection.stable,
      ),
      metrics: Map<String, double>.from(json['metrics'] ?? {}),
      calculatedAt: DateTime.parse(json['calculated_at']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'change': change,
      'direction': direction.toString().split('.').last,
      'metrics': metrics,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  /// Check if trend is positive
  bool get isPositive => direction == TrendDirection.increasing;

  /// Check if trend is negative
  bool get isNegative => direction == TrendDirection.decreasing;

  /// Get formatted change percentage
  String get formattedChange {
    final prefix = isPositive ? '+' : '';
    return '$prefix${change.toStringAsFixed(1)}%';
  }

  /// Get trend emoji
  String get emoji {
    switch (direction) {
      case TrendDirection.increasing:
        return '📈';
      case TrendDirection.decreasing:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
    }
  }
}

/// Trend direction enumeration
enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

/// Learning activity data point
class LearningActivity {
  final String id;
  final String userId;
  final DateTime timestamp;
  final ActivityType type;
  final String? sessionId;
  final String? contentBlockId;
  final String? topicId;
  final Duration? duration;
  final Map<String, dynamic> data;
  final String? category;

  const LearningActivity({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    this.sessionId,
    this.contentBlockId,
    this.topicId,
    this.duration,
    this.data = const {},
    this.category,
  });

  /// Create from JSON
  factory LearningActivity.fromJson(Map<String, dynamic> json) {
    return LearningActivity(
      id: json['id'],
      userId: json['user_id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      sessionId: json['session_id'],
      contentBlockId: json['content_block_id'],
      topicId: json['topic_id'],
      duration: json['duration_ms'] != null 
          ? Duration(milliseconds: json['duration_ms']) 
          : null,
      data: json['data'] ?? {},
      category: json['category'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'session_id': sessionId,
      'content_block_id': contentBlockId,
      'topic_id': topicId,
      'duration_ms': duration?.inMilliseconds,
      'data': data,
      'category': category,
    };
  }
}

/// Activity type enumeration
enum ActivityType {
  sessionStarted,
  sessionCompleted,
  sessionPaused,
  sessionResumed,
  sessionAbandoned,
  contentPlayed,
  contentPaused,
  contentSkipped,
  contentRated,
  achievementUnlocked,
  streakMilestone,
  topicAnalyzed,
  contentDownloaded,
  settingsChanged,
  coachSelected,
  feedbackProvided,
}

/// Weekly learning summary
class WeeklyLearning {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DailyLearning> dailyLearning;
  final Duration totalTime;
  final int totalSessions;
  final int completedSessions;
  final Map<String, Duration> categoryTime;
  final List<Achievement> achievementsUnlocked;
  final double averageRating;
  final ProgressTrend trend;

  const WeeklyLearning({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.dailyLearning,
    required this.totalTime,
    required this.totalSessions,
    required this.completedSessions,
    required this.categoryTime,
    required this.achievementsUnlocked,
    required this.averageRating,
    required this.trend,
  });

  /// Get learning days count
  int get activeDays => dailyLearning.where((day) => day.hasActivity).length;

  /// Check if week goal was met (5+ days)
  bool get weekGoalMet => activeDays >= 5;

  /// Get formatted total time
  String get formattedTotalTime {
    final hours = totalTime.inHours;
    final minutes = totalTime.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Daily learning summary
class DailyLearning {
  final DateTime date;
  final Duration totalTime;
  final int sessionCount;
  final int completedSessions;
  final List<String> categoriesLearned;
  final bool hasActivity;

  const DailyLearning({
    required this.date,
    required this.totalTime,
    required this.sessionCount,
    required this.completedSessions,
    required this.categoriesLearned,
    required this.hasActivity,
  });

  /// Get day of week
  String get dayOfWeek {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
