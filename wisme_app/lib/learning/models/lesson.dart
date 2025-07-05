/// Core lesson model representing individual learning units
class Lesson {
  final String id;
  final String title;
  final String description;
  final String contentText;
  final LessonType type;
  final DifficultyLevel difficulty;
  final Duration estimatedDuration;
  final List<String> tags;
  final List<String> prerequisites;
  final List<LearningObjective> objectives;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int sortOrder;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.contentText,
    required this.type,
    required this.difficulty,
    required this.estimatedDuration,
    required this.tags,
    required this.prerequisites,
    required this.objectives,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'contentText': contentText,
    'type': type.name,
    'difficulty': difficulty.name,
    'estimatedDuration': estimatedDuration.inMinutes,
    'tags': tags,
    'prerequisites': prerequisites,
    'objectives': objectives.map((obj) => obj.toJson()).toList(),
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'sortOrder': sortOrder,
  };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    contentText: json['contentText'] as String,
    type: LessonType.values.byName(json['type'] as String),
    difficulty: DifficultyLevel.values.byName(json['difficulty'] as String),
    estimatedDuration: Duration(minutes: json['estimatedDuration'] as int),
    tags: List<String>.from(json['tags'] as List),
    prerequisites: List<String>.from(json['prerequisites'] as List),
    objectives: (json['objectives'] as List)
        .map((obj) => LearningObjective.fromJson(obj as Map<String, dynamic>))
        .toList(),
    metadata: json['metadata'] as Map<String, dynamic>,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isActive: json['isActive'] as bool? ?? true,
    sortOrder: json['sortOrder'] as int? ?? 0,
  );

  Lesson copyWith({
    String? title,
    String? description,
    String? contentText,
    LessonType? type,
    DifficultyLevel? difficulty,
    Duration? estimatedDuration,
    List<String>? tags,
    List<String>? prerequisites,
    List<LearningObjective>? objectives,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
    bool? isActive,
    int? sortOrder,
  }) => Lesson(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    contentText: contentText ?? this.contentText,
    type: type ?? this.type,
    difficulty: difficulty ?? this.difficulty,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    tags: tags ?? this.tags,
    prerequisites: prerequisites ?? this.prerequisites,
    objectives: objectives ?? this.objectives,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
}

enum LessonType {
  text,
  audio,
  interactive,
  quiz,
  practice,
  review,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

class LearningObjective {
  final String id;
  final String description;
  final ObjectiveType type;
  final bool isCompleted;

  const LearningObjective({
    required this.id,
    required this.description,
    required this.type,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'type': type.name,
    'isCompleted': isCompleted,
  };

  factory LearningObjective.fromJson(Map<String, dynamic> json) => LearningObjective(
    id: json['id'] as String,
    description: json['description'] as String,
    type: ObjectiveType.values.byName(json['type'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}

enum ObjectiveType {
  knowledge,
  comprehension,
  application,
  analysis,
  synthesis,
  evaluation,
}
