import 'dart:typed_data';
import '../../shared/models/base_model.dart';
import 'content_block_model.dart';

/// Represents a complete content episode with audio and metadata
class ContentEpisode extends BaseModel {
  final String title;
  final String topic;
  final String category;
  final String level;
  final List<ContentBlock> contentBlocks;
  final Uint8List audioData;
  final Duration estimatedDuration;
  final double reuseRate;
  final Duration deliveryTime;
  final Map<String, dynamic> metadata;

  const ContentEpisode({
    required super.id,
    required this.title,
    required this.topic,
    required this.category,
    required this.level,
    required this.contentBlocks,
    required this.audioData,
    required this.estimatedDuration,
    required this.reuseRate,
    required this.deliveryTime,
    this.metadata = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'title': title,
        'topic': topic,
        'category': category,
        'level': level,
        'contentBlocks': contentBlocks.map((block) => block.toJson()).toList(),
        'audioData': audioData,
        'estimatedDuration': estimatedDuration.inMilliseconds,
        'reuseRate': reuseRate,
        'deliveryTime': deliveryTime.inMilliseconds,
        'metadata': metadata,
      };

  factory ContentEpisode.fromJson(Map<String, dynamic> json) => ContentEpisode(
        id: json['id'] as String,
        title: json['title'] as String,
        topic: json['topic'] as String,
        category: json['category'] as String,
        level: json['level'] as String,
        contentBlocks: (json['contentBlocks'] as List<dynamic>)
            .map((block) => ContentBlock.fromJson(block as Map<String, dynamic>))
            .toList(),
        audioData: json['audioData'] as Uint8List,
        estimatedDuration: Duration(milliseconds: json['estimatedDuration'] as int),
        reuseRate: (json['reuseRate'] as num).toDouble(),
        deliveryTime: Duration(milliseconds: json['deliveryTime'] as int),
        metadata: json['metadata'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  ContentEpisode copyWith({
    String? id,
    String? title,
    String? topic,
    String? category,
    String? level,
    List<ContentBlock>? contentBlocks,
    Uint8List? audioData,
    Duration? estimatedDuration,
    double? reuseRate,
    Duration? deliveryTime,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ContentEpisode(
        id: id ?? this.id,
        title: title ?? this.title,
        topic: topic ?? this.topic,
        category: category ?? this.category,
        level: level ?? this.level,
        contentBlocks: contentBlocks ?? this.contentBlocks,
        audioData: audioData ?? this.audioData,
        estimatedDuration: estimatedDuration ?? this.estimatedDuration,
        reuseRate: reuseRate ?? this.reuseRate,
        deliveryTime: deliveryTime ?? this.deliveryTime,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
