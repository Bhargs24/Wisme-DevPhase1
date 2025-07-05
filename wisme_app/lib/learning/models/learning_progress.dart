/// User's learning progress tracking model
class LearningProgress {
  final String id;
  final String userId;
  final String lessonId;
  final String? pathId;
  final ProgressStatus status;
  final double completionPercentage;
  final List<String> completedObjectives;
  final Duration timeSpent;
  final int attempts;
  final double? lastScore;
  final DateTime? lastAccessedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const LearningProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    this.pathId,
    required this.status,
    required this.completionPercentage,
    required this.completedObjectives,
    required this.timeSpent,
    required this.attempts,
    this.lastScore,
    this.lastAccessedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'lessonId': lessonId,
    'pathId': pathId,
    'status': status.name,
    'completionPercentage': completionPercentage,
    'completedObjectives': completedObjectives,
    'timeSpent': timeSpent.inMinutes,
    'attempts': attempts,
    'lastScore': lastScore,
    'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'metadata': metadata,
  };

  factory LearningProgress.fromJson(Map<String, dynamic> json) => LearningProgress(
    id: json['id'] as String,
    userId: json['userId'] as String,
    lessonId: json['lessonId'] as String,
    pathId: json['pathId'] as String?,
    status: ProgressStatus.values.byName(json['status'] as String),
    completionPercentage: (json['completionPercentage'] as num).toDouble(),
    completedObjectives: List<String>.from(json['completedObjectives'] as List),
    timeSpent: Duration(minutes: json['timeSpent'] as int),
    attempts: json['attempts'] as int,
    lastScore: json['lastScore'] as double?,
    lastAccessedAt: json['lastAccessedAt'] != null 
        ? DateTime.parse(json['lastAccessedAt'] as String) 
        : null,
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'] as String) 
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  LearningProgress copyWith({
    String? pathId,
    ProgressStatus? status,
    double? completionPercentage,
    List<String>? completedObjectives,
    Duration? timeSpent,
    int? attempts,
    double? lastScore,
    DateTime? lastAccessedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) => LearningProgress(
    id: id,
    userId: userId,
    lessonId: lessonId,
    pathId: pathId ?? this.pathId,
    status: status ?? this.status,
    completionPercentage: completionPercentage ?? this.completionPercentage,
    completedObjectives: completedObjectives ?? this.completedObjectives,
    timeSpent: timeSpent ?? this.timeSpent,
    attempts: attempts ?? this.attempts,
    lastScore: lastScore ?? this.lastScore,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    completedAt: completedAt ?? this.completedAt,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    metadata: metadata ?? this.metadata,
  );

  /// Check if progress is complete
  bool get isCompleted => status == ProgressStatus.completed;

  /// Check if progress is in progress
  bool get isInProgress => status == ProgressStatus.inProgress;

  /// Check if lesson has been started
  bool get isStarted => status != ProgressStatus.notStarted;

  /// Calculate effective learning rate (completion per hour)
  double get learningRate {
    if (timeSpent.inMinutes == 0) return 0.0;
    return completionPercentage / (timeSpent.inMinutes / 60.0);
  }

  /// Get mastery level based on score and completion
  MasteryLevel get masteryLevel {
    if (!isCompleted) return MasteryLevel.none;
    
    final score = lastScore ?? 0.0;
    if (score >= 90) return MasteryLevel.expert;
    if (score >= 80) return MasteryLevel.proficient;
    if (score >= 70) return MasteryLevel.competent;
    if (score >= 60) return MasteryLevel.developing;
    return MasteryLevel.beginner;
  }
}

enum ProgressStatus {
  notStarted,
  inProgress,
  completed,
  failed,
  skipped,
}

enum MasteryLevel {
  none,
  beginner,
  developing,
  competent,
  proficient,
  expert,
}
