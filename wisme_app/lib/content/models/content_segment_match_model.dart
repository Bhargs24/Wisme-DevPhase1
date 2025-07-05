import '../../shared/models/base_model.dart';
import 'content_segment_model.dart';

/// Represents a match between content segments with similarity scoring
class ContentSegmentMatch extends BaseModel {
  final ContentSegment segment;
  final double similarity;
  final DateTime lastUsed;
  final String matchType;
  final double confidence;

  const ContentSegmentMatch({
    required super.id,
    required this.segment,
    required this.similarity,
    required this.lastUsed,
    this.matchType = 'semantic',
    this.confidence = 0.0,
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'segment': segment.toJson(),
        'similarity': similarity,
        'lastUsed': lastUsed.toIso8601String(),
        'matchType': matchType,
        'confidence': confidence,
      };

  factory ContentSegmentMatch.fromJson(Map<String, dynamic> json) => ContentSegmentMatch(
        id: json['id'] as String,
        segment: ContentSegment.fromJson(json['segment'] as Map<String, dynamic>),
        similarity: (json['similarity'] as num).toDouble(),
        lastUsed: DateTime.parse(json['lastUsed'] as String),
        matchType: json['matchType'] as String? ?? 'semantic',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  ContentSegmentMatch copyWith({
    String? id,
    ContentSegment? segment,
    double? similarity,
    DateTime? lastUsed,
    String? matchType,
    double? confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ContentSegmentMatch(
        id: id ?? this.id,
        segment: segment ?? this.segment,
        similarity: similarity ?? this.similarity,
        lastUsed: lastUsed ?? this.lastUsed,
        matchType: matchType ?? this.matchType,
        confidence: confidence ?? this.confidence,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
