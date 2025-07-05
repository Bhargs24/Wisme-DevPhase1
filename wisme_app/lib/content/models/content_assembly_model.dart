import '../../shared/models/base_model.dart';

/// Represents a content assembly strategy and configuration
class ContentAssembly extends BaseModel {
  final List<String> contentIds;
  final String assemblyType;
  final Duration estimatedDuration;
  final double confidenceScore;
  final Map<String, dynamic> customization;

  const ContentAssembly({
    required super.id,
    required this.contentIds,
    required this.assemblyType,
    required this.estimatedDuration,
    required this.confidenceScore,
    this.customization = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'contentIds': contentIds,
        'assemblyType': assemblyType,
        'estimatedDuration': estimatedDuration.inMilliseconds,
        'confidenceScore': confidenceScore,
        'customization': customization,
      };

  factory ContentAssembly.fromJson(Map<String, dynamic> json) => ContentAssembly(
        id: json['id'] as String,
        contentIds: (json['contentIds'] as List<dynamic>).cast<String>(),
        assemblyType: json['assemblyType'] as String,
        estimatedDuration: Duration(milliseconds: json['estimatedDuration'] as int),
        confidenceScore: (json['confidenceScore'] as num).toDouble(),
        customization: json['customization'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  ContentAssembly copyWith({
    String? id,
    List<String>? contentIds,
    String? assemblyType,
    Duration? estimatedDuration,
    double? confidenceScore,
    Map<String, dynamic>? customization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ContentAssembly(
        id: id ?? this.id,
        contentIds: contentIds ?? this.contentIds,
        assemblyType: assemblyType ?? this.assemblyType,
        estimatedDuration: estimatedDuration ?? this.estimatedDuration,
        confidenceScore: confidenceScore ?? this.confidenceScore,
        customization: customization ?? this.customization,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
