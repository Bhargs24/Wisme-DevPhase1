/// Content item model representing any piece of learning content
class ContentItem {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final String content;
  final ContentFormat format;
  final List<String> tags;
  final DifficultyLevel difficulty;
  final Duration estimatedDuration;
  final List<ContentResource> resources;
  final ContentMetadata metadata;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? creatorId;
  final Map<String, dynamic> configuration;

  const ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.format,
    required this.tags,
    required this.difficulty,
    required this.estimatedDuration,
    required this.resources,
    required this.metadata,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.creatorId,
    required this.configuration,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.name,
    'content': content,
    'format': format.name,
    'tags': tags,
    'difficulty': difficulty.name,
    'estimatedDuration': estimatedDuration.inMinutes,
    'resources': resources.map((r) => r.toJson()).toList(),
    'metadata': metadata.toJson(),
    'isPublished': isPublished,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'creatorId': creatorId,
    'configuration': configuration,
  };

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    type: ContentType.values.byName(json['type'] as String),
    content: json['content'] as String,
    format: ContentFormat.values.byName(json['format'] as String),
    tags: List<String>.from(json['tags'] as List),
    difficulty: DifficultyLevel.values.byName(json['difficulty'] as String),
    estimatedDuration: Duration(minutes: json['estimatedDuration'] as int),
    resources: (json['resources'] as List)
        .map((r) => ContentResource.fromJson(r as Map<String, dynamic>))
        .toList(),
    metadata: ContentMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    isPublished: json['isPublished'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    creatorId: json['creatorId'] as String?,
    configuration: json['configuration'] as Map<String, dynamic>,
  );

  ContentItem copyWith({
    String? title,
    String? description,
    ContentType? type,
    String? content,
    ContentFormat? format,
    List<String>? tags,
    DifficultyLevel? difficulty,
    Duration? estimatedDuration,
    List<ContentResource>? resources,
    ContentMetadata? metadata,
    bool? isPublished,
    DateTime? updatedAt,
    String? creatorId,
    Map<String, dynamic>? configuration,
  }) => ContentItem(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    type: type ?? this.type,
    content: content ?? this.content,
    format: format ?? this.format,
    tags: tags ?? this.tags,
    difficulty: difficulty ?? this.difficulty,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    resources: resources ?? this.resources,
    metadata: metadata ?? this.metadata,
    isPublished: isPublished ?? this.isPublished,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    creatorId: creatorId ?? this.creatorId,
    configuration: configuration ?? this.configuration,
  );
}

enum ContentType {
  lesson,
  article,
  video,
  audio,
  interactive,
  quiz,
  exercise,
  reference,
  tutorial,
  case_study,
}

enum ContentFormat {
  text,
  markdown,
  html,
  json,
  audio,
  video,
  interactive,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

class ContentResource {
  final String id;
  final String title;
  final String url;
  final ResourceType type;
  final String? description;
  final Map<String, dynamic> metadata;

  const ContentResource({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.description,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'type': type.name,
    'description': description,
    'metadata': metadata,
  };

  factory ContentResource.fromJson(Map<String, dynamic> json) => ContentResource(
    id: json['id'] as String,
    title: json['title'] as String,
    url: json['url'] as String,
    type: ResourceType.values.byName(json['type'] as String),
    description: json['description'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>,
  );
}

enum ResourceType {
  link,
  document,
  image,
  video,
  audio,
  download,
  tool,
}

class ContentMetadata {
  final int wordCount;
  final List<String> keywords;
  final String language;
  final double readabilityScore;
  final List<String> learningObjectives;
  final Map<String, dynamic> analytics;
  final Map<String, dynamic> seo;

  const ContentMetadata({
    required this.wordCount,
    required this.keywords,
    required this.language,
    required this.readabilityScore,
    required this.learningObjectives,
    required this.analytics,
    required this.seo,
  });

  Map<String, dynamic> toJson() => {
    'wordCount': wordCount,
    'keywords': keywords,
    'language': language,
    'readabilityScore': readabilityScore,
    'learningObjectives': learningObjectives,
    'analytics': analytics,
    'seo': seo,
  };

  factory ContentMetadata.fromJson(Map<String, dynamic> json) => ContentMetadata(
    wordCount: json['wordCount'] as int,
    keywords: List<String>.from(json['keywords'] as List),
    language: json['language'] as String,
    readabilityScore: (json['readabilityScore'] as num).toDouble(),
    learningObjectives: List<String>.from(json['learningObjectives'] as List),
    analytics: json['analytics'] as Map<String, dynamic>,
    seo: json['seo'] as Map<String, dynamic>,
  );
}
