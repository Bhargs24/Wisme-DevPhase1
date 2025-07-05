/// Learning path model representing structured curriculum sequences
class LearningPath {
  final String id;
  final String title;
  final String description;
  final List<String> lessonIds;
  final PathType type;
  final DifficultyLevel difficulty;
  final Duration estimatedTotalDuration;
  final List<String> tags;
  final List<PathPrerequisite> prerequisites;
  final List<PathOutcome> outcomes;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? creatorId;
  final Map<String, dynamic> metadata;

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonIds,
    required this.type,
    required this.difficulty,
    required this.estimatedTotalDuration,
    required this.tags,
    required this.prerequisites,
    required this.outcomes,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.creatorId,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'lessonIds': lessonIds,
    'type': type.name,
    'difficulty': difficulty.name,
    'estimatedTotalDuration': estimatedTotalDuration.inMinutes,
    'tags': tags,
    'prerequisites': prerequisites.map((req) => req.toJson()).toList(),
    'outcomes': outcomes.map((outcome) => outcome.toJson()).toList(),
    'isPublished': isPublished,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'creatorId': creatorId,
    'metadata': metadata,
  };

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    lessonIds: List<String>.from(json['lessonIds'] as List),
    type: PathType.values.byName(json['type'] as String),
    difficulty: DifficultyLevel.values.byName(json['difficulty'] as String),
    estimatedTotalDuration: Duration(minutes: json['estimatedTotalDuration'] as int),
    tags: List<String>.from(json['tags'] as List),
    prerequisites: (json['prerequisites'] as List)
        .map((req) => PathPrerequisite.fromJson(req as Map<String, dynamic>))
        .toList(),
    outcomes: (json['outcomes'] as List)
        .map((outcome) => PathOutcome.fromJson(outcome as Map<String, dynamic>))
        .toList(),
    isPublished: json['isPublished'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    creatorId: json['creatorId'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  LearningPath copyWith({
    String? title,
    String? description,
    List<String>? lessonIds,
    PathType? type,
    DifficultyLevel? difficulty,
    Duration? estimatedTotalDuration,
    List<String>? tags,
    List<PathPrerequisite>? prerequisites,
    List<PathOutcome>? outcomes,
    bool? isPublished,
    DateTime? updatedAt,
    String? creatorId,
    Map<String, dynamic>? metadata,
  }) => LearningPath(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    lessonIds: lessonIds ?? this.lessonIds,
    type: type ?? this.type,
    difficulty: difficulty ?? this.difficulty,
    estimatedTotalDuration: estimatedTotalDuration ?? this.estimatedTotalDuration,
    tags: tags ?? this.tags,
    prerequisites: prerequisites ?? this.prerequisites,
    outcomes: outcomes ?? this.outcomes,
    isPublished: isPublished ?? this.isPublished,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    creatorId: creatorId ?? this.creatorId,
    metadata: metadata ?? this.metadata,
  );

  /// Get lesson at specific index with bounds checking
  String? getLessonAt(int index) {
    if (index < 0 || index >= lessonIds.length) return null;
    return lessonIds[index];
  }

  /// Get next lesson after given lesson ID
  String? getNextLesson(String currentLessonId) {
    final currentIndex = lessonIds.indexOf(currentLessonId);
    if (currentIndex == -1 || currentIndex >= lessonIds.length - 1) return null;
    return lessonIds[currentIndex + 1];
  }

  /// Get previous lesson before given lesson ID
  String? getPreviousLesson(String currentLessonId) {
    final currentIndex = lessonIds.indexOf(currentLessonId);
    if (currentIndex <= 0) return null;
    return lessonIds[currentIndex - 1];
  }
}

enum PathType {
  course,
  specialization,
  bootcamp,
  workshop,
  certification,
  custom,
}

// Already defined in lesson.dart, but imported here
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

class PathPrerequisite {
  final String id;
  final String description;
  final PrerequisiteType type;
  final bool isRequired;

  const PathPrerequisite({
    required this.id,
    required this.description,
    required this.type,
    required this.isRequired,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'type': type.name,
    'isRequired': isRequired,
  };

  factory PathPrerequisite.fromJson(Map<String, dynamic> json) => PathPrerequisite(
    id: json['id'] as String,
    description: json['description'] as String,
    type: PrerequisiteType.values.byName(json['type'] as String),
    isRequired: json['isRequired'] as bool,
  );
}

enum PrerequisiteType {
  skill,
  knowledge,
  experience,
  certification,
  path,
}

class PathOutcome {
  final String id;
  final String description;
  final OutcomeType type;
  final List<String> skills;

  const PathOutcome({
    required this.id,
    required this.description,
    required this.type,
    required this.skills,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'type': type.name,
    'skills': skills,
  };

  factory PathOutcome.fromJson(Map<String, dynamic> json) => PathOutcome(
    id: json['id'] as String,
    description: json['description'] as String,
    type: OutcomeType.values.byName(json['type'] as String),
    skills: List<String>.from(json['skills'] as List),
  );
}

enum OutcomeType {
  skill,
  knowledge,
  competency,
  certification,
  portfolio,
}
