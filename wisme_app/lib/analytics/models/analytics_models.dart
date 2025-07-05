/// Analytics event model for tracking user interactions and learning behavior
class AnalyticsEvent {
  final String id;
  final String userId;
  final String eventType;
  final String eventName;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> context;
  final String? sessionId;
  final String? lessonId;
  final String? coachId;
  final EventCategory category;
  final EventPriority priority;

  const AnalyticsEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.eventName,
    required this.timestamp,
    required this.properties,
    required this.context,
    this.sessionId,
    this.lessonId,
    this.coachId,
    required this.category,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'eventType': eventType,
    'eventName': eventName,
    'timestamp': timestamp.toIso8601String(),
    'properties': properties,
    'context': context,
    'sessionId': sessionId,
    'lessonId': lessonId,
    'coachId': coachId,
    'category': category.name,
    'priority': priority.name,
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
    id: json['id'] as String,
    userId: json['userId'] as String,
    eventType: json['eventType'] as String,
    eventName: json['eventName'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    properties: json['properties'] as Map<String, dynamic>,
    context: json['context'] as Map<String, dynamic>,
    sessionId: json['sessionId'] as String?,
    lessonId: json['lessonId'] as String?,
    coachId: json['coachId'] as String?,
    category: EventCategory.values.byName(json['category'] as String),
    priority: EventPriority.values.byName(json['priority'] as String),
  );
}

enum EventCategory {
  learning,
  engagement,
  performance,
  behavioral,
  technical,
  business,
}

enum EventPriority {
  low,
  medium,
  high,
  critical,
}

/// Learning analytics model for comprehensive learning insights
class LearningAnalytics {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final LearningMetrics metrics;
  final EngagementMetrics engagement;
  final PerformanceMetrics performance;
  final ProgressMetrics progress;
  final BehavioralInsights behavioral;
  final List<LearningRecommendation> recommendations;
  final DateTime generatedAt;

  const LearningAnalytics({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.metrics,
    required this.engagement,
    required this.performance,
    required this.progress,
    required this.behavioral,
    required this.recommendations,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'metrics': metrics.toJson(),
    'engagement': engagement.toJson(),
    'performance': performance.toJson(),
    'progress': progress.toJson(),
    'behavioral': behavioral.toJson(),
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
    'generatedAt': generatedAt.toIso8601String(),
  };

  factory LearningAnalytics.fromJson(Map<String, dynamic> json) => LearningAnalytics(
    userId: json['userId'] as String,
    periodStart: DateTime.parse(json['periodStart'] as String),
    periodEnd: DateTime.parse(json['periodEnd'] as String),
    metrics: LearningMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
    engagement: EngagementMetrics.fromJson(json['engagement'] as Map<String, dynamic>),
    performance: PerformanceMetrics.fromJson(json['performance'] as Map<String, dynamic>),
    progress: ProgressMetrics.fromJson(json['progress'] as Map<String, dynamic>),
    behavioral: BehavioralInsights.fromJson(json['behavioral'] as Map<String, dynamic>),
    recommendations: (json['recommendations'] as List)
        .map((r) => LearningRecommendation.fromJson(r as Map<String, dynamic>))
        .toList(),
    generatedAt: DateTime.parse(json['generatedAt'] as String),
  );
}

/// Core learning metrics
class LearningMetrics {
  final Duration totalStudyTime;
  final int totalSessions;
  final int lessonsCompleted;
  final int lessonsStarted;
  final Duration averageSessionDuration;
  final double completionRate;
  final double retentionRate;
  final int streakDays;
  final int maxStreakDays;

  const LearningMetrics({
    required this.totalStudyTime,
    required this.totalSessions,
    required this.lessonsCompleted,
    required this.lessonsStarted,
    required this.averageSessionDuration,
    required this.completionRate,
    required this.retentionRate,
    required this.streakDays,
    required this.maxStreakDays,
  });

  Map<String, dynamic> toJson() => {
    'totalStudyTime': totalStudyTime.inMinutes,
    'totalSessions': totalSessions,
    'lessonsCompleted': lessonsCompleted,
    'lessonsStarted': lessonsStarted,
    'averageSessionDuration': averageSessionDuration.inMinutes,
    'completionRate': completionRate,
    'retentionRate': retentionRate,
    'streakDays': streakDays,
    'maxStreakDays': maxStreakDays,
  };

  factory LearningMetrics.fromJson(Map<String, dynamic> json) => LearningMetrics(
    totalStudyTime: Duration(minutes: json['totalStudyTime'] as int),
    totalSessions: json['totalSessions'] as int,
    lessonsCompleted: json['lessonsCompleted'] as int,
    lessonsStarted: json['lessonsStarted'] as int,
    averageSessionDuration: Duration(minutes: json['averageSessionDuration'] as int),
    completionRate: (json['completionRate'] as num).toDouble(),
    retentionRate: (json['retentionRate'] as num).toDouble(),
    streakDays: json['streakDays'] as int,
    maxStreakDays: json['maxStreakDays'] as int,
  );
}

/// User engagement metrics
class EngagementMetrics {
  final double dailyActiveScore;
  final double weeklyActiveScore;
  final double monthlyActiveScore;
  final int interactionCount;
  final Duration averageSessionLength;
  final double bounceRate;
  final Map<String, int> featureUsage;
  final List<String> preferredLearningTimes;

  const EngagementMetrics({
    required this.dailyActiveScore,
    required this.weeklyActiveScore,
    required this.monthlyActiveScore,
    required this.interactionCount,
    required this.averageSessionLength,
    required this.bounceRate,
    required this.featureUsage,
    required this.preferredLearningTimes,
  });

  Map<String, dynamic> toJson() => {
    'dailyActiveScore': dailyActiveScore,
    'weeklyActiveScore': weeklyActiveScore,
    'monthlyActiveScore': monthlyActiveScore,
    'interactionCount': interactionCount,
    'averageSessionLength': averageSessionLength.inMinutes,
    'bounceRate': bounceRate,
    'featureUsage': featureUsage,
    'preferredLearningTimes': preferredLearningTimes,
  };

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) => EngagementMetrics(
    dailyActiveScore: (json['dailyActiveScore'] as num).toDouble(),
    weeklyActiveScore: (json['weeklyActiveScore'] as num).toDouble(),
    monthlyActiveScore: (json['monthlyActiveScore'] as num).toDouble(),
    interactionCount: json['interactionCount'] as int,
    averageSessionLength: Duration(minutes: json['averageSessionLength'] as int),
    bounceRate: (json['bounceRate'] as num).toDouble(),
    featureUsage: Map<String, int>.from(json['featureUsage'] as Map),
    preferredLearningTimes: List<String>.from(json['preferredLearningTimes'] as List),
  );
}

/// Performance and achievement metrics
class PerformanceMetrics {
  final double averageScore;
  final double highestScore;
  final double lowestScore;
  final double improvementRate;
  final Map<String, double> skillLevels;
  final List<String> achievedMilestones;
  final Map<String, int> difficultyDistribution;

  const PerformanceMetrics({
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.improvementRate,
    required this.skillLevels,
    required this.achievedMilestones,
    required this.difficultyDistribution,
  });

  Map<String, dynamic> toJson() => {
    'averageScore': averageScore,
    'highestScore': highestScore,
    'lowestScore': lowestScore,
    'improvementRate': improvementRate,
    'skillLevels': skillLevels,
    'achievedMilestones': achievedMilestones,
    'difficultyDistribution': difficultyDistribution,
  };

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) => PerformanceMetrics(
    averageScore: (json['averageScore'] as num).toDouble(),
    highestScore: (json['highestScore'] as num).toDouble(),
    lowestScore: (json['lowestScore'] as num).toDouble(),
    improvementRate: (json['improvementRate'] as num).toDouble(),
    skillLevels: Map<String, double>.from(json['skillLevels'] as Map),
    achievedMilestones: List<String>.from(json['achievedMilestones'] as List),
    difficultyDistribution: Map<String, int>.from(json['difficultyDistribution'] as Map),
  );
}

/// Learning progress metrics
class ProgressMetrics {
  final double overallProgress;
  final Map<String, double> pathProgress;
  final Map<String, double> moduleProgress;
  final int milestoneCount;
  final double velocityScore;
  final List<String> recentAchievements;

  const ProgressMetrics({
    required this.overallProgress,
    required this.pathProgress,
    required this.moduleProgress,
    required this.milestoneCount,
    required this.velocityScore,
    required this.recentAchievements,
  });

  Map<String, dynamic> toJson() => {
    'overallProgress': overallProgress,
    'pathProgress': pathProgress,
    'moduleProgress': moduleProgress,
    'milestoneCount': milestoneCount,
    'velocityScore': velocityScore,
    'recentAchievements': recentAchievements,
  };

  factory ProgressMetrics.fromJson(Map<String, dynamic> json) => ProgressMetrics(
    overallProgress: (json['overallProgress'] as num).toDouble(),
    pathProgress: Map<String, double>.from(json['pathProgress'] as Map),
    moduleProgress: Map<String, double>.from(json['moduleProgress'] as Map),
    milestoneCount: json['milestoneCount'] as int,
    velocityScore: (json['velocityScore'] as num).toDouble(),
    recentAchievements: List<String>.from(json['recentAchievements'] as List),
  );
}

/// Behavioral insights and patterns
class BehavioralInsights {
  final String learningStyle;
  final List<String> preferredContentTypes;
  final Map<String, double> timeDistribution;
  final String motivationProfile;
  final List<String> strugglingAreas;
  final List<String> strengthAreas;
  final double consistencyScore;

  const BehavioralInsights({
    required this.learningStyle,
    required this.preferredContentTypes,
    required this.timeDistribution,
    required this.motivationProfile,
    required this.strugglingAreas,
    required this.strengthAreas,
    required this.consistencyScore,
  });

  Map<String, dynamic> toJson() => {
    'learningStyle': learningStyle,
    'preferredContentTypes': preferredContentTypes,
    'timeDistribution': timeDistribution,
    'motivationProfile': motivationProfile,
    'strugglingAreas': strugglingAreas,
    'strengthAreas': strengthAreas,
    'consistencyScore': consistencyScore,
  };

  factory BehavioralInsights.fromJson(Map<String, dynamic> json) => BehavioralInsights(
    learningStyle: json['learningStyle'] as String,
    preferredContentTypes: List<String>.from(json['preferredContentTypes'] as List),
    timeDistribution: Map<String, double>.from(json['timeDistribution'] as Map),
    motivationProfile: json['motivationProfile'] as String,
    strugglingAreas: List<String>.from(json['strugglingAreas'] as List),
    strengthAreas: List<String>.from(json['strengthAreas'] as List),
    consistencyScore: (json['consistencyScore'] as num).toDouble(),
  );
}

/// AI-powered learning recommendations
class LearningRecommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final double confidence;
  final String actionText;
  final Map<String, dynamic> actionData;
  final RecommendationPriority priority;
  final DateTime createdAt;

  const LearningRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.actionText,
    required this.actionData,
    required this.priority,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'confidence': confidence,
    'actionText': actionText,
    'actionData': actionData,
    'priority': priority.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LearningRecommendation.fromJson(Map<String, dynamic> json) => LearningRecommendation(
    id: json['id'] as String,
    type: RecommendationType.values.byName(json['type'] as String),
    title: json['title'] as String,
    description: json['description'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    actionText: json['actionText'] as String,
    actionData: json['actionData'] as Map<String, dynamic>,
    priority: RecommendationPriority.values.byName(json['priority'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

enum RecommendationType {
  content,
  schedule,
  method,
  difficulty,
  coach,
  goal,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  urgent,
}
