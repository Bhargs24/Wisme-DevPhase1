/// Content Segment Models
/// 
/// Models for content segmentation and reuse
library;

/// Individual content segment for reuse
class ContentSegment {
  final String id;
  final String content;
  final String topic;
  final String category;
  final String level;
  final Duration estimatedDuration;
  final DateTime createdAt;
  final int reuseCount;
  final double qualityScore;
  final Map<String, dynamic> metadata;

  const ContentSegment({
    required this.id,
    required this.content,
    required this.topic,
    required this.category,
    required this.level,
    required this.estimatedDuration,
    required this.createdAt,
    this.reuseCount = 0,
    this.qualityScore = 1.0,
    this.metadata = const {},
  });

  factory ContentSegment.fromJson(Map<String, dynamic> json) {
    return ContentSegment(
      id: json['id'] as String,
      content: json['content'] as String,
      topic: json['topic'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      estimatedDuration: Duration(seconds: json['duration_seconds'] as int),
      createdAt: DateTime.parse(json['created_at'] as String),
      reuseCount: json['reuse_count'] as int? ?? 0,
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 1.0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'topic': topic,
      'category': category,
      'level': level,
      'duration_seconds': estimatedDuration.inSeconds,
      'created_at': createdAt.toIso8601String(),
      'reuse_count': reuseCount,
      'quality_score': qualityScore,
      'metadata': metadata,
    };
  }

  ContentSegment copyWith({
    String? id,
    String? content,
    String? topic,
    String? category,
    String? level,
    Duration? estimatedDuration,
    DateTime? createdAt,
    int? reuseCount,
    double? qualityScore,
    Map<String, dynamic>? metadata,
  }) {
    return ContentSegment(
      id: id ?? this.id,
      content: content ?? this.content,
      topic: topic ?? this.topic,
      category: category ?? this.category,
      level: level ?? this.level,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      reuseCount: reuseCount ?? this.reuseCount,
      qualityScore: qualityScore ?? this.qualityScore,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentSegment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ContentSegment(id: $id, topic: $topic, duration: ${estimatedDuration.inMinutes}min)';
  }
}

/// Content segment match with similarity score
class ContentSegmentMatch {
  final ContentSegment segment;
  final double similarity;
  final DateTime lastUsed;

  const ContentSegmentMatch({
    required this.segment,
    required this.similarity,
    required this.lastUsed,
  });

  @override
  String toString() {
    return 'ContentSegmentMatch(segment: ${segment.id}, similarity: ${similarity.toStringAsFixed(3)})';
  }
}

/// Content tags for semantic matching
class ContentTags {
  final String primaryTopic;
  final String category;
  final String level;
  final List<String> semanticTags;
  final List<String> keywords;
  final String contentType;
  final Map<String, dynamic> metadata;

  const ContentTags({
    required this.primaryTopic,
    required this.category,
    required this.level,
    this.semanticTags = const [],
    this.keywords = const [],
    this.contentType = 'general',
    this.metadata = const {},
  });

  factory ContentTags.fromJson(Map<String, dynamic> json) {
    return ContentTags(
      primaryTopic: json['primary_topic'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      semanticTags: List<String>.from(json['semantic_tags'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      contentType: json['content_type'] as String? ?? 'general',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_topic': primaryTopic,
      'category': category,
      'level': level,
      'semantic_tags': semanticTags,
      'keywords': keywords,
      'content_type': contentType,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'ContentTags(topic: $primaryTopic, category: $category, level: $level)';
  }
}
