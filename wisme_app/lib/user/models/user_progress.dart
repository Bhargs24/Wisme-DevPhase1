import 'package:equatable/equatable.dart';

/// Production-grade user progress tracking model
/// Tracks detailed learning progress across all dimensions
class UserProgress extends Equatable {
  final String userId;
  final String progressId;
  final OverallProgress overall;
  final Map<String, TopicProgress> topicProgress;
  final Map<String, SkillProgress> skillProgress;
  final List<LearningSession> recentSessions;
  final WeeklyProgress currentWeek;
  final MonthlyProgress currentMonth;
  final List<Achievement> achievements;
  final LearningGoals goals;
  final ProgressAnalytics analytics;
  final DateTime lastUpdated;
  final Map<String, dynamic> customMetrics;

  const UserProgress({
    required this.userId,
    required this.progressId,
    required this.overall,
    this.topicProgress = const {},
    this.skillProgress = const {},
    this.recentSessions = const [],
    required this.currentWeek,
    required this.currentMonth,
    this.achievements = const [],
    required this.goals,
    required this.analytics,
    required this.lastUpdated,
    this.customMetrics = const {},
  });

  /// Get progress for a specific topic
  TopicProgress? getTopicProgress(String topicId) => topicProgress[topicId];

  /// Get progress for a specific skill
  SkillProgress? getSkillProgress(String skillId) => skillProgress[skillId];

  /// Check if user has achieved a specific achievement
  bool hasAchievement(String achievementId) {
    return achievements.any((a) => a.id == achievementId);
  }

  /// Get completion rate for all topics
  double get overallTopicCompletion {
    if (topicProgress.isEmpty) return 0.0;
    final totalCompletion = topicProgress.values
        .map((tp) => tp.completionRate)
        .fold(0.0, (sum, rate) => sum + rate);
    return totalCompletion / topicProgress.length;
  }

  /// Get average skill level
  double get averageSkillLevel {
    if (skillProgress.isEmpty) return 0.0;
    final totalLevel = skillProgress.values
        .map((sp) => sp.currentLevel)
        .fold(0.0, (sum, level) => sum + level);
    return totalLevel / skillProgress.length;
  }

  /// Get recent performance trend
  PerformanceTrend get recentTrend {
    if (recentSessions.length < 2) return PerformanceTrend.stable;
    
    final recent = recentSessions.take(5).map((s) => s.scorePercentage).toList();
    final earlier = recentSessions.skip(5).take(5).map((s) => s.scorePercentage).toList();
    
    if (earlier.isEmpty) return PerformanceTrend.stable;
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;
    
    if (recentAvg > earlierAvg + 5) return PerformanceTrend.improving;
    if (recentAvg < earlierAvg - 5) return PerformanceTrend.declining;
    return PerformanceTrend.stable;
  }

  UserProgress copyWith({
    String? userId,
    String? progressId,
    OverallProgress? overall,
    Map<String, TopicProgress>? topicProgress,
    Map<String, SkillProgress>? skillProgress,
    List<LearningSession>? recentSessions,
    WeeklyProgress? currentWeek,
    MonthlyProgress? currentMonth,
    List<Achievement>? achievements,
    LearningGoals? goals,
    ProgressAnalytics? analytics,
    DateTime? lastUpdated,
    Map<String, dynamic>? customMetrics,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      progressId: progressId ?? this.progressId,
      overall: overall ?? this.overall,
      topicProgress: topicProgress ?? this.topicProgress,
      skillProgress: skillProgress ?? this.skillProgress,
      recentSessions: recentSessions ?? this.recentSessions,
      currentWeek: currentWeek ?? this.currentWeek,
      currentMonth: currentMonth ?? this.currentMonth,
      achievements: achievements ?? this.achievements,
      goals: goals ?? this.goals,
      analytics: analytics ?? this.analytics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      customMetrics: customMetrics ?? this.customMetrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'progressId': progressId,
      'overall': overall.toJson(),
      'topicProgress': topicProgress.map((k, v) => MapEntry(k, v.toJson())),
      'skillProgress': skillProgress.map((k, v) => MapEntry(k, v.toJson())),
      'recentSessions': recentSessions.map((s) => s.toJson()).toList(),
      'currentWeek': currentWeek.toJson(),
      'currentMonth': currentMonth.toJson(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'goals': goals.toJson(),
      'analytics': analytics.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'customMetrics': customMetrics,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'],
      progressId: json['progressId'],
      overall: OverallProgress.fromJson(json['overall']),
      topicProgress: (json['topicProgress'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, TopicProgress.fromJson(v))) ?? {},
      skillProgress: (json['skillProgress'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, SkillProgress.fromJson(v))) ?? {},
      recentSessions: (json['recentSessions'] as List<dynamic>?)
          ?.map((s) => LearningSession.fromJson(s))
          .toList() ?? [],
      currentWeek: WeeklyProgress.fromJson(json['currentWeek']),
      currentMonth: MonthlyProgress.fromJson(json['currentMonth']),
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((a) => Achievement.fromJson(a))
          .toList() ?? [],
      goals: LearningGoals.fromJson(json['goals']),
      analytics: ProgressAnalytics.fromJson(json['analytics']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      customMetrics: Map<String, dynamic>.from(json['customMetrics'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    userId, progressId, overall, topicProgress, skillProgress,
    recentSessions, currentWeek, currentMonth, achievements,
    goals, analytics, lastUpdated, customMetrics,
  ];
}

/// Overall progress summary
class OverallProgress extends Equatable {
  final int totalLessonsCompleted;
  final int totalTimeMinutes;
  final double averageScore;
  final int currentStreak;
  final int longestStreak;
  final int totalExperience;
  final int currentLevel;
  final double levelProgress;
  final DateTime? lastActivity;
  final int totalAchievements;

  const OverallProgress({
    this.totalLessonsCompleted = 0,
    this.totalTimeMinutes = 0,
    this.averageScore = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalExperience = 0,
    this.currentLevel = 1,
    this.levelProgress = 0.0,
    this.lastActivity,
    this.totalAchievements = 0,
  });

  Duration get totalTime => Duration(minutes: totalTimeMinutes);

  int get experienceToNextLevel {
    return (currentLevel * 1000) - (totalExperience % 1000);
  }

  String get formattedTotalTime {
    final hours = totalTimeMinutes ~/ 60;
    final minutes = totalTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  OverallProgress copyWith({
    int? totalLessonsCompleted,
    int? totalTimeMinutes,
    double? averageScore,
    int? currentStreak,
    int? longestStreak,
    int? totalExperience,
    int? currentLevel,
    double? levelProgress,
    DateTime? lastActivity,
    int? totalAchievements,
  }) {
    return OverallProgress(
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      averageScore: averageScore ?? this.averageScore,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalExperience: totalExperience ?? this.totalExperience,
      currentLevel: currentLevel ?? this.currentLevel,
      levelProgress: levelProgress ?? this.levelProgress,
      lastActivity: lastActivity ?? this.lastActivity,
      totalAchievements: totalAchievements ?? this.totalAchievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalTimeMinutes': totalTimeMinutes,
      'averageScore': averageScore,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalExperience': totalExperience,
      'currentLevel': currentLevel,
      'levelProgress': levelProgress,
      'lastActivity': lastActivity?.toIso8601String(),
      'totalAchievements': totalAchievements,
    };
  }

  factory OverallProgress.fromJson(Map<String, dynamic> json) {
    return OverallProgress(
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      totalTimeMinutes: json['totalTimeMinutes'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalExperience: json['totalExperience'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      levelProgress: (json['levelProgress'] ?? 0.0).toDouble(),
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity']) 
          : null,
      totalAchievements: json['totalAchievements'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    totalLessonsCompleted, totalTimeMinutes, averageScore,
    currentStreak, longestStreak, totalExperience, currentLevel,
    levelProgress, lastActivity, totalAchievements,
  ];
}

/// Topic-specific progress
class TopicProgress extends Equatable {
  final String topicId;
  final String topicName;
  final int lessonsCompleted;
  final int totalLessons;
  final double averageScore;
  final int timeSpentMinutes;
  final DateTime? lastStudied;
  final double masteryLevel;
  final List<String> completedLessons;
  final Map<String, double> conceptMastery;

  const TopicProgress({
    required this.topicId,
    required this.topicName,
    this.lessonsCompleted = 0,
    this.totalLessons = 0,
    this.averageScore = 0.0,
    this.timeSpentMinutes = 0,
    this.lastStudied,
    this.masteryLevel = 0.0,
    this.completedLessons = const [],
    this.conceptMastery = const {},
  });

  double get completionRate {
    if (totalLessons == 0) return 0.0;
    return lessonsCompleted / totalLessons;
  }

  bool get isCompleted => completionRate >= 1.0;

  int get remainingLessons => totalLessons - lessonsCompleted;

  Duration get timeSpent => Duration(minutes: timeSpentMinutes);

  TopicProgress copyWith({
    String? topicId,
    String? topicName,
    int? lessonsCompleted,
    int? totalLessons,
    double? averageScore,
    int? timeSpentMinutes,
    DateTime? lastStudied,
    double? masteryLevel,
    List<String>? completedLessons,
    Map<String, double>? conceptMastery,
  }) {
    return TopicProgress(
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      totalLessons: totalLessons ?? this.totalLessons,
      averageScore: averageScore ?? this.averageScore,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      lastStudied: lastStudied ?? this.lastStudied,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      completedLessons: completedLessons ?? this.completedLessons,
      conceptMastery: conceptMastery ?? this.conceptMastery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'topicName': topicName,
      'lessonsCompleted': lessonsCompleted,
      'totalLessons': totalLessons,
      'averageScore': averageScore,
      'timeSpentMinutes': timeSpentMinutes,
      'lastStudied': lastStudied?.toIso8601String(),
      'masteryLevel': masteryLevel,
      'completedLessons': completedLessons,
      'conceptMastery': conceptMastery,
    };
  }

  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgress(
      topicId: json['topicId'],
      topicName: json['topicName'],
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      totalLessons: json['totalLessons'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      timeSpentMinutes: json['timeSpentMinutes'] ?? 0,
      lastStudied: json['lastStudied'] != null 
          ? DateTime.parse(json['lastStudied']) 
          : null,
      masteryLevel: (json['masteryLevel'] ?? 0.0).toDouble(),
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      conceptMastery: Map<String, double>.from(json['conceptMastery'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    topicId, topicName, lessonsCompleted, totalLessons,
    averageScore, timeSpentMinutes, lastStudied, masteryLevel,
    completedLessons, conceptMastery,
  ];
}

/// Skill-specific progress
class SkillProgress extends Equatable {
  final String skillId;
  final String skillName;
  final double currentLevel;
  final double targetLevel;
  final int practiceCount;
  final DateTime? lastPracticed;
  final List<double> recentScores;
  final SkillTrend trend;
  final Map<String, dynamic> skillMetrics;

  const SkillProgress({
    required this.skillId,
    required this.skillName,
    this.currentLevel = 0.0,
    this.targetLevel = 1.0,
    this.practiceCount = 0,
    this.lastPracticed,
    this.recentScores = const [],
    this.trend = SkillTrend.stable,
    this.skillMetrics = const {},
  });

  double get progressToTarget {
    if (targetLevel == 0) return 1.0;
    return (currentLevel / targetLevel).clamp(0.0, 1.0);
  }

  double get averageRecentScore {
    if (recentScores.isEmpty) return 0.0;
    return recentScores.reduce((a, b) => a + b) / recentScores.length;
  }

  bool get isAtTarget => currentLevel >= targetLevel;

  SkillProgress copyWith({
    String? skillId,
    String? skillName,
    double? currentLevel,
    double? targetLevel,
    int? practiceCount,
    DateTime? lastPracticed,
    List<double>? recentScores,
    SkillTrend? trend,
    Map<String, dynamic>? skillMetrics,
  }) {
    return SkillProgress(
      skillId: skillId ?? this.skillId,
      skillName: skillName ?? this.skillName,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      practiceCount: practiceCount ?? this.practiceCount,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      recentScores: recentScores ?? this.recentScores,
      trend: trend ?? this.trend,
      skillMetrics: skillMetrics ?? this.skillMetrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'skillName': skillName,
      'currentLevel': currentLevel,
      'targetLevel': targetLevel,
      'practiceCount': practiceCount,
      'lastPracticed': lastPracticed?.toIso8601String(),
      'recentScores': recentScores,
      'trend': trend.toString(),
      'skillMetrics': skillMetrics,
    };
  }

  factory SkillProgress.fromJson(Map<String, dynamic> json) {
    return SkillProgress(
      skillId: json['skillId'],
      skillName: json['skillName'],
      currentLevel: (json['currentLevel'] ?? 0.0).toDouble(),
      targetLevel: (json['targetLevel'] ?? 1.0).toDouble(),
      practiceCount: json['practiceCount'] ?? 0,
      lastPracticed: json['lastPracticed'] != null 
          ? DateTime.parse(json['lastPracticed']) 
          : null,
      recentScores: List<double>.from(json['recentScores'] ?? []),
      trend: SkillTrend.values.firstWhere(
        (e) => e.toString() == json['trend'],
        orElse: () => SkillTrend.stable,
      ),
      skillMetrics: Map<String, dynamic>.from(json['skillMetrics'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    skillId, skillName, currentLevel, targetLevel, practiceCount,
    lastPracticed, recentScores, trend, skillMetrics,
  ];
}

/// Learning session record
class LearningSession extends Equatable {
  final String sessionId;
  final DateTime startTime;
  final DateTime endTime;
  final String lessonId;
  final String lessonTitle;
  final String topicId;
  final double scorePercentage;
  final int correctAnswers;
  final int totalQuestions;
  final int hintsUsed;
  final List<String> skillsPracticed;
  final Map<String, dynamic> sessionData;

  const LearningSession({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.lessonId,
    required this.lessonTitle,
    required this.topicId,
    this.scorePercentage = 0.0,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.hintsUsed = 0,
    this.skillsPracticed = const [],
    this.sessionData = const {},
  });

  Duration get duration => endTime.difference(startTime);

  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  bool get wasSuccessful => scorePercentage >= 70.0;

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'topicId': topicId,
      'scorePercentage': scorePercentage,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'hintsUsed': hintsUsed,
      'skillsPracticed': skillsPracticed,
      'sessionData': sessionData,
    };
  }

  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      sessionId: json['sessionId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      lessonId: json['lessonId'],
      lessonTitle: json['lessonTitle'],
      topicId: json['topicId'],
      scorePercentage: (json['scorePercentage'] ?? 0.0).toDouble(),
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      skillsPracticed: List<String>.from(json['skillsPracticed'] ?? []),
      sessionData: Map<String, dynamic>.from(json['sessionData'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    sessionId, startTime, endTime, lessonId, lessonTitle,
    topicId, scorePercentage, correctAnswers, totalQuestions,
    hintsUsed, skillsPracticed, sessionData,
  ];
}

/// Weekly progress summary
class WeeklyProgress extends Equatable {
  final int weekNumber;
  final int year;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int lessonsCompleted;
  final int timeSpentMinutes;
  final double averageScore;
  final int activeDays;
  final List<DateTime> studyDays;
  final Map<String, int> dailyLessons;

  const WeeklyProgress({
    required this.weekNumber,
    required this.year,
    required this.weekStart,
    required this.weekEnd,
    this.lessonsCompleted = 0,
    this.timeSpentMinutes = 0,
    this.averageScore = 0.0,
    this.activeDays = 0,
    this.studyDays = const [],
    this.dailyLessons = const {},
  });

  bool get isCurrentWeek {
    final now = DateTime.now();
    return weekStart.isBefore(now) && weekEnd.isAfter(now);
  }

  Duration get timeSpent => Duration(minutes: timeSpentMinutes);

  Map<String, dynamic> toJson() {
    return {
      'weekNumber': weekNumber,
      'year': year,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'lessonsCompleted': lessonsCompleted,
      'timeSpentMinutes': timeSpentMinutes,
      'averageScore': averageScore,
      'activeDays': activeDays,
      'studyDays': studyDays.map((d) => d.toIso8601String()).toList(),
      'dailyLessons': dailyLessons,
    };
  }

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      weekNumber: json['weekNumber'],
      year: json['year'],
      weekStart: DateTime.parse(json['weekStart']),
      weekEnd: DateTime.parse(json['weekEnd']),
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      timeSpentMinutes: json['timeSpentMinutes'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      activeDays: json['activeDays'] ?? 0,
      studyDays: (json['studyDays'] as List<dynamic>?)
          ?.map((d) => DateTime.parse(d))
          .toList() ?? [],
      dailyLessons: Map<String, int>.from(json['dailyLessons'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    weekNumber, year, weekStart, weekEnd, lessonsCompleted,
    timeSpentMinutes, averageScore, activeDays, studyDays, dailyLessons,
  ];
}

/// Monthly progress summary
class MonthlyProgress extends Equatable {
  final int month;
  final int year;
  final DateTime monthStart;
  final DateTime monthEnd;
  final int lessonsCompleted;
  final int timeSpentMinutes;
  final double averageScore;
  final int activeDays;
  final int streakDays;
  final Map<String, int> weeklyBreakdown;

  const MonthlyProgress({
    required this.month,
    required this.year,
    required this.monthStart,
    required this.monthEnd,
    this.lessonsCompleted = 0,
    this.timeSpentMinutes = 0,
    this.averageScore = 0.0,
    this.activeDays = 0,
    this.streakDays = 0,
    this.weeklyBreakdown = const {},
  });

  bool get isCurrentMonth {
    final now = DateTime.now();
    return monthStart.isBefore(now) && monthEnd.isAfter(now);
  }

  Duration get timeSpent => Duration(minutes: timeSpentMinutes);

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'monthStart': monthStart.toIso8601String(),
      'monthEnd': monthEnd.toIso8601String(),
      'lessonsCompleted': lessonsCompleted,
      'timeSpentMinutes': timeSpentMinutes,
      'averageScore': averageScore,
      'activeDays': activeDays,
      'streakDays': streakDays,
      'weeklyBreakdown': weeklyBreakdown,
    };
  }

  factory MonthlyProgress.fromJson(Map<String, dynamic> json) {
    return MonthlyProgress(
      month: json['month'],
      year: json['year'],
      monthStart: DateTime.parse(json['monthStart']),
      monthEnd: DateTime.parse(json['monthEnd']),
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      timeSpentMinutes: json['timeSpentMinutes'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      activeDays: json['activeDays'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      weeklyBreakdown: Map<String, int>.from(json['weeklyBreakdown'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    month, year, monthStart, monthEnd, lessonsCompleted,
    timeSpentMinutes, averageScore, activeDays, streakDays, weeklyBreakdown,
  ];
}

/// Achievement model
class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final AchievementType type;
  final DateTime unlockedAt;
  final Map<String, dynamic> metadata;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.unlockedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'type': type.toString(),
      'unlockedAt': unlockedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.general,
      ),
      unlockedAt: DateTime.parse(json['unlockedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, name, description, iconUrl, type, unlockedAt, metadata];
}

/// Learning goals model
class LearningGoals extends Equatable {
  final int dailyLessonsTarget;
  final int weeklyTimeTarget; // minutes
  final double monthlyScoreTarget;
  final List<String> focusTopics;
  final List<String> targetSkills;
  final DateTime? targetCompletionDate;
  final Map<String, dynamic> customGoals;

  const LearningGoals({
    this.dailyLessonsTarget = 2,
    this.weeklyTimeTarget = 150, // 2.5 hours
    this.monthlyScoreTarget = 80.0,
    this.focusTopics = const [],
    this.targetSkills = const [],
    this.targetCompletionDate,
    this.customGoals = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyLessonsTarget': dailyLessonsTarget,
      'weeklyTimeTarget': weeklyTimeTarget,
      'monthlyScoreTarget': monthlyScoreTarget,
      'focusTopics': focusTopics,
      'targetSkills': targetSkills,
      'targetCompletionDate': targetCompletionDate?.toIso8601String(),
      'customGoals': customGoals,
    };
  }

  factory LearningGoals.fromJson(Map<String, dynamic> json) {
    return LearningGoals(
      dailyLessonsTarget: json['dailyLessonsTarget'] ?? 2,
      weeklyTimeTarget: json['weeklyTimeTarget'] ?? 150,
      monthlyScoreTarget: (json['monthlyScoreTarget'] ?? 80.0).toDouble(),
      focusTopics: List<String>.from(json['focusTopics'] ?? []),
      targetSkills: List<String>.from(json['targetSkills'] ?? []),
      targetCompletionDate: json['targetCompletionDate'] != null 
          ? DateTime.parse(json['targetCompletionDate']) 
          : null,
      customGoals: Map<String, dynamic>.from(json['customGoals'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    dailyLessonsTarget, weeklyTimeTarget, monthlyScoreTarget,
    focusTopics, targetSkills, targetCompletionDate, customGoals,
  ];
}

/// Progress analytics model
class ProgressAnalytics extends Equatable {
  final double learningVelocity; // lessons per week
  final double retentionRate;
  final double engagementScore;
  final Map<String, double> strengthAreas;
  final Map<String, double> improvementAreas;
  final List<String> recommendations;
  final DateTime lastAnalysisAt;

  const ProgressAnalytics({
    this.learningVelocity = 0.0,
    this.retentionRate = 0.0,
    this.engagementScore = 0.0,
    this.strengthAreas = const {},
    this.improvementAreas = const {},
    this.recommendations = const [],
    required this.lastAnalysisAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'learningVelocity': learningVelocity,
      'retentionRate': retentionRate,
      'engagementScore': engagementScore,
      'strengthAreas': strengthAreas,
      'improvementAreas': improvementAreas,
      'recommendations': recommendations,
      'lastAnalysisAt': lastAnalysisAt.toIso8601String(),
    };
  }

  factory ProgressAnalytics.fromJson(Map<String, dynamic> json) {
    return ProgressAnalytics(
      learningVelocity: (json['learningVelocity'] ?? 0.0).toDouble(),
      retentionRate: (json['retentionRate'] ?? 0.0).toDouble(),
      engagementScore: (json['engagementScore'] ?? 0.0).toDouble(),
      strengthAreas: Map<String, double>.from(json['strengthAreas'] ?? {}),
      improvementAreas: Map<String, double>.from(json['improvementAreas'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      lastAnalysisAt: DateTime.parse(json['lastAnalysisAt']),
    );
  }

  @override
  List<Object?> get props => [
    learningVelocity, retentionRate, engagementScore,
    strengthAreas, improvementAreas, recommendations, lastAnalysisAt,
  ];
}

/// Enums
enum PerformanceTrend { improving, declining, stable }
enum SkillTrend { improving, declining, stable, mastered }
enum AchievementType { streak, completion, mastery, engagement, general }
