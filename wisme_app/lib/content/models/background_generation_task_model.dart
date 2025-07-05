import '../../shared/models/base_model.dart';

/// Represents a background content generation task
class BackgroundGenerationTask extends BaseModel {
  final String userId;
  final String topic;
  final String category;
  final String level;
  final Duration? targetDuration;
  final int priority;
  final DateTime queuedAt;
  final String status;
  final Map<String, dynamic> metadata;

  const BackgroundGenerationTask({
    required super.id,
    required this.userId,
    required this.topic,
    required this.category,
    required this.level,
    this.targetDuration,
    required this.priority,
    required this.queuedAt,
    this.status = 'queued',
    this.metadata = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'userId': userId,
        'topic': topic,
        'category': category,
        'level': level,
        'targetDuration': targetDuration?.inMilliseconds,
        'priority': priority,
        'queuedAt': queuedAt.toIso8601String(),
        'status': status,
        'metadata': metadata,
      };

  factory BackgroundGenerationTask.fromJson(Map<String, dynamic> json) => BackgroundGenerationTask(
        id: json['id'] as String,
        userId: json['userId'] as String,
        topic: json['topic'] as String,
        category: json['category'] as String,
        level: json['level'] as String,
        targetDuration: json['targetDuration'] != null 
            ? Duration(milliseconds: json['targetDuration'] as int) 
            : null,
        priority: json['priority'] as int,
        queuedAt: DateTime.parse(json['queuedAt'] as String),
        status: json['status'] as String? ?? 'queued',
        metadata: json['metadata'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  BackgroundGenerationTask copyWith({
    String? id,
    String? userId,
    String? topic,
    String? category,
    String? level,
    Duration? targetDuration,
    int? priority,
    DateTime? queuedAt,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BackgroundGenerationTask(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        topic: topic ?? this.topic,
        category: category ?? this.category,
        level: level ?? this.level,
        targetDuration: targetDuration ?? this.targetDuration,
        priority: priority ?? this.priority,
        queuedAt: queuedAt ?? this.queuedAt,
        status: status ?? this.status,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
