/// User's relationship and interaction history with AI coaches
class CoachRelationship {
  final String id;
  final String userId;
  final String coachId;
  final RelationshipStatus status;
  final double trustLevel;
  final double satisfactionLevel;
  final int totalSessions;
  final Duration totalInteractionTime;
  final DateTime firstInteraction;
  final DateTime lastInteraction;
  final List<String> preferences;
  final Map<String, dynamic> learningStyle;
  final List<RelationshipMilestone> milestones;
  final Map<String, dynamic> personalizations;
  final Map<String, dynamic> metadata;

  const CoachRelationship({
    required this.id,
    required this.userId,
    required this.coachId,
    required this.status,
    required this.trustLevel,
    required this.satisfactionLevel,
    required this.totalSessions,
    required this.totalInteractionTime,
    required this.firstInteraction,
    required this.lastInteraction,
    required this.preferences,
    required this.learningStyle,
    required this.milestones,
    required this.personalizations,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'coachId': coachId,
    'status': status.name,
    'trustLevel': trustLevel,
    'satisfactionLevel': satisfactionLevel,
    'totalSessions': totalSessions,
    'totalInteractionTime': totalInteractionTime.inMinutes,
    'firstInteraction': firstInteraction.toIso8601String(),
    'lastInteraction': lastInteraction.toIso8601String(),
    'preferences': preferences,
    'learningStyle': learningStyle,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'personalizations': personalizations,
    'metadata': metadata,
  };

  factory CoachRelationship.fromJson(Map<String, dynamic> json) => CoachRelationship(
    id: json['id'] as String,
    userId: json['userId'] as String,
    coachId: json['coachId'] as String,
    status: RelationshipStatus.values.byName(json['status'] as String),
    trustLevel: (json['trustLevel'] as num).toDouble(),
    satisfactionLevel: (json['satisfactionLevel'] as num).toDouble(),
    totalSessions: json['totalSessions'] as int,
    totalInteractionTime: Duration(minutes: json['totalInteractionTime'] as int),
    firstInteraction: DateTime.parse(json['firstInteraction'] as String),
    lastInteraction: DateTime.parse(json['lastInteraction'] as String),
    preferences: List<String>.from(json['preferences'] as List),
    learningStyle: json['learningStyle'] as Map<String, dynamic>,
    milestones: (json['milestones'] as List)
        .map((m) => RelationshipMilestone.fromJson(m as Map<String, dynamic>))
        .toList(),
    personalizations: json['personalizations'] as Map<String, dynamic>,
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  CoachRelationship copyWith({
    RelationshipStatus? status,
    double? trustLevel,
    double? satisfactionLevel,
    int? totalSessions,
    Duration? totalInteractionTime,
    DateTime? lastInteraction,
    List<String>? preferences,
    Map<String, dynamic>? learningStyle,
    List<RelationshipMilestone>? milestones,
    Map<String, dynamic>? personalizations,
    Map<String, dynamic>? metadata,
  }) => CoachRelationship(
    id: id,
    userId: userId,
    coachId: coachId,
    status: status ?? this.status,
    trustLevel: trustLevel ?? this.trustLevel,
    satisfactionLevel: satisfactionLevel ?? this.satisfactionLevel,
    totalSessions: totalSessions ?? this.totalSessions,
    totalInteractionTime: totalInteractionTime ?? this.totalInteractionTime,
    firstInteraction: firstInteraction,
    lastInteraction: lastInteraction ?? this.lastInteraction,
    preferences: preferences ?? this.preferences,
    learningStyle: learningStyle ?? this.learningStyle,
    milestones: milestones ?? this.milestones,
    personalizations: personalizations ?? this.personalizations,
    metadata: metadata ?? this.metadata,
  );

  /// Calculate relationship strength based on various factors
  double get relationshipStrength {
    // Weighted combination of trust, satisfaction, and interaction frequency
    final trustWeight = 0.4;
    final satisfactionWeight = 0.3;
    final frequencyWeight = 0.3;

    // Calculate frequency score based on sessions and time
    final frequencyScore = (totalSessions / 100.0).clamp(0.0, 1.0) * 0.5 +
        (totalInteractionTime.inHours / 100.0).clamp(0.0, 1.0) * 0.5;

    return (trustLevel * trustWeight +
        satisfactionLevel * satisfactionWeight +
        frequencyScore * frequencyWeight).clamp(0.0, 1.0);
  }

  /// Check if relationship is strong enough for advanced features
  bool get isStrongRelationship => relationshipStrength >= 0.7;

  /// Get latest milestone
  RelationshipMilestone? get latestMilestone {
    if (milestones.isEmpty) return null;
    return milestones.reduce((a, b) => 
        a.achievedAt.isAfter(b.achievedAt) ? a : b);
  }
}

enum RelationshipStatus {
  new_,
  building,
  established,
  strong,
  strained,
  inactive,
}

class RelationshipMilestone {
  final String id;
  final MilestoneType type;
  final String title;
  final String description;
  final DateTime achievedAt;
  final Map<String, dynamic> data;

  const RelationshipMilestone({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.achievedAt,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'achievedAt': achievedAt.toIso8601String(),
    'data': data,
  };

  factory RelationshipMilestone.fromJson(Map<String, dynamic> json) => RelationshipMilestone(
    id: json['id'] as String,
    type: MilestoneType.values.byName(json['type'] as String),
    title: json['title'] as String,
    description: json['description'] as String,
    achievedAt: DateTime.parse(json['achievedAt'] as String),
    data: json['data'] as Map<String, dynamic>,
  );
}

enum MilestoneType {
  firstInteraction,
  firstWeek,
  firstMonth,
  trustBuilding,
  personalizedLearning,
  consistentUsage,
  problemSolving,
  goalAchievement,
  longTermPartnership,
}
