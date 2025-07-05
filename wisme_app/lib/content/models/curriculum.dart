/// Curriculum model representing structured learning sequences
class Curriculum {
  final String id;
  final String title;
  final String description;
  final List<CurriculumModule> modules;
  final CurriculumLevel level;
  final Duration estimatedTotalDuration;
  final List<String> prerequisites;
  final List<CurriculumOutcome> outcomes;
  final CurriculumStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? creatorId;
  final Map<String, dynamic> metadata;

  const Curriculum({
    required this.id,
    required this.title,
    required this.description,
    required this.modules,
    required this.level,
    required this.estimatedTotalDuration,
    required this.prerequisites,
    required this.outcomes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.creatorId,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'modules': modules.map((m) => m.toJson()).toList(),
    'level': level.name,
    'estimatedTotalDuration': estimatedTotalDuration.inMinutes,
    'prerequisites': prerequisites,
    'outcomes': outcomes.map((o) => o.toJson()).toList(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'creatorId': creatorId,
    'metadata': metadata,
  };

  factory Curriculum.fromJson(Map<String, dynamic> json) => Curriculum(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    modules: (json['modules'] as List)
        .map((m) => CurriculumModule.fromJson(m as Map<String, dynamic>))
        .toList(),
    level: CurriculumLevel.values.byName(json['level'] as String),
    estimatedTotalDuration: Duration(minutes: json['estimatedTotalDuration'] as int),
    prerequisites: List<String>.from(json['prerequisites'] as List),
    outcomes: (json['outcomes'] as List)
        .map((o) => CurriculumOutcome.fromJson(o as Map<String, dynamic>))
        .toList(),
    status: CurriculumStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    creatorId: json['creatorId'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  Curriculum copyWith({
    String? title,
    String? description,
    List<CurriculumModule>? modules,
    CurriculumLevel? level,
    Duration? estimatedTotalDuration,
    List<String>? prerequisites,
    List<CurriculumOutcome>? outcomes,
    CurriculumStatus? status,
    DateTime? updatedAt,
    String? creatorId,
    Map<String, dynamic>? metadata,
  }) => Curriculum(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    modules: modules ?? this.modules,
    level: level ?? this.level,
    estimatedTotalDuration: estimatedTotalDuration ?? this.estimatedTotalDuration,
    prerequisites: prerequisites ?? this.prerequisites,
    outcomes: outcomes ?? this.outcomes,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    creatorId: creatorId ?? this.creatorId,
    metadata: metadata ?? this.metadata,
  );

  /// Get module by ID
  CurriculumModule? getModule(String moduleId) {
    try {
      return modules.firstWhere((module) => module.id == moduleId);
    } catch (e) {
      return null;
    }
  }

  /// Get total content items count
  int get totalContentItems {
    return modules.fold(0, (total, module) => total + module.contentItems.length);
  }

  /// Check if curriculum is published
  bool get isPublished => status == CurriculumStatus.published;

  /// Get curriculum progress for completed content items
  double calculateProgress(List<String> completedContentIds) {
    if (totalContentItems == 0) return 0.0;
    
    int completedCount = 0;
    for (final module in modules) {
      for (final contentId in module.contentItems) {
        if (completedContentIds.contains(contentId)) {
          completedCount++;
        }
      }
    }
    
    return completedCount / totalContentItems;
  }
}

enum CurriculumLevel {
  foundation,
  intermediate,
  advanced,
  expert,
  specialization,
}

enum CurriculumStatus {
  draft,
  review,
  published,
  archived,
  deprecated,
}

class CurriculumModule {
  final String id;
  final String title;
  final String description;
  final List<String> contentItems;
  final int sortOrder;
  final Duration estimatedDuration;
  final bool isRequired;
  final List<String> prerequisites;
  final Map<String, dynamic> metadata;

  const CurriculumModule({
    required this.id,
    required this.title,
    required this.description,
    required this.contentItems,
    required this.sortOrder,
    required this.estimatedDuration,
    required this.isRequired,
    required this.prerequisites,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'contentItems': contentItems,
    'sortOrder': sortOrder,
    'estimatedDuration': estimatedDuration.inMinutes,
    'isRequired': isRequired,
    'prerequisites': prerequisites,
    'metadata': metadata,
  };

  factory CurriculumModule.fromJson(Map<String, dynamic> json) => CurriculumModule(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    contentItems: List<String>.from(json['contentItems'] as List),
    sortOrder: json['sortOrder'] as int,
    estimatedDuration: Duration(minutes: json['estimatedDuration'] as int),
    isRequired: json['isRequired'] as bool,
    prerequisites: List<String>.from(json['prerequisites'] as List),
    metadata: json['metadata'] as Map<String, dynamic>,
  );
}

class CurriculumOutcome {
  final String id;
  final String title;
  final String description;
  final OutcomeType type;
  final List<String> skills;
  final bool isAssessable;

  const CurriculumOutcome({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.skills,
    required this.isAssessable,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'skills': skills,
    'isAssessable': isAssessable,
  };

  factory CurriculumOutcome.fromJson(Map<String, dynamic> json) => CurriculumOutcome(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    type: OutcomeType.values.byName(json['type'] as String),
    skills: List<String>.from(json['skills'] as List),
    isAssessable: json['isAssessable'] as bool,
  );
}

enum OutcomeType {
  knowledge,
  skill,
  competency,
  behavior,
  certification,
}
