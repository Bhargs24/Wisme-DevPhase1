/// Content matching models for intelligent content reuse and semantic search
library;

import 'dart:typed_data';
import '../../shared/models/base_model.dart';

/// Hashtag-based content matching system for intelligent content reuse
class ContentHashtag extends BaseModel {
  final String type; // topic, subtopic, category, level, format, voice
  final String value;
  final double weight; // Importance weight for matching

  const ContentHashtag({
    required this.type,
    required this.value,
    this.weight = 1.0,
  });

  @override
  String toString() => '#${value.toLowerCase().replaceAll(' ', '_')}';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'weight': weight,
    };
  }

  factory ContentHashtag.fromMap(Map<String, dynamic> map) {
    return ContentHashtag(
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      weight: map['weight']?.toDouble() ?? 1.0,
    );
  }

  @override
  List<Object?> get props => [type, value, weight];
}

/// Content tags for comprehensive content categorization
class ContentTags extends BaseModel {
  final List<ContentHashtag> topic;
  final List<ContentHashtag> subtopic;
  final List<ContentHashtag> category;
  final List<ContentHashtag> level;
  final List<ContentHashtag> format;
  final List<ContentHashtag> voice;
  final List<ContentHashtag> mood;
  final List<ContentHashtag> industry;

  const ContentTags({
    this.topic = const [],
    this.subtopic = const [],
    this.category = const [],
    this.level = const [],
    this.format = const [],
    this.voice = const [],
    this.mood = const [],
    this.industry = const [],
  });

  /// Get all hashtags as a flat list
  List<ContentHashtag> getAllHashtags() {
    return [
      ...topic,
      ...subtopic,
      ...category,
      ...level,
      ...format,
      ...voice,
      ...mood,
      ...industry,
    ];
  }

  /// Calculate matching score with another ContentTags
  double calculateMatchingScore(ContentTags other) {
    double totalScore = 0.0;
    double totalWeight = 0.0;

    // Compare each category
    totalScore += _calculateCategoryScore(topic, other.topic);
    totalScore += _calculateCategoryScore(subtopic, other.subtopic) * 0.8;
    totalScore += _calculateCategoryScore(category, other.category) * 0.9;
    totalScore += _calculateCategoryScore(level, other.level) * 0.7;
    totalScore += _calculateCategoryScore(format, other.format) * 0.6;
    totalScore += _calculateCategoryScore(voice, other.voice) * 0.5;
    totalScore += _calculateCategoryScore(mood, other.mood) * 0.4;
    totalScore += _calculateCategoryScore(industry, other.industry) * 0.3;

    totalWeight = 1.0 + 0.8 + 0.9 + 0.7 + 0.6 + 0.5 + 0.4 + 0.3; // 5.2

    return totalScore / totalWeight;
  }

  double _calculateCategoryScore(List<ContentHashtag> list1, List<ContentHashtag> list2) {
    if (list1.isEmpty && list2.isEmpty) return 1.0;
    if (list1.isEmpty || list2.isEmpty) return 0.0;

    double score = 0.0;
    for (final tag1 in list1) {
      for (final tag2 in list2) {
        if (tag1.value.toLowerCase() == tag2.value.toLowerCase()) {
          score += (tag1.weight + tag2.weight) / 2;
        }
      }
    }

    return score / (list1.length + list2.length);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'topic': topic.map((x) => x.toMap()).toList(),
      'subtopic': subtopic.map((x) => x.toMap()).toList(),
      'category': category.map((x) => x.toMap()).toList(),
      'level': level.map((x) => x.toMap()).toList(),
      'format': format.map((x) => x.toMap()).toList(),
      'voice': voice.map((x) => x.toMap()).toList(),
      'mood': mood.map((x) => x.toMap()).toList(),
      'industry': industry.map((x) => x.toMap()).toList(),
    };
  }

  factory ContentTags.fromMap(Map<String, dynamic> map) {
    return ContentTags(
      topic: List<ContentHashtag>.from(
        map['topic']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
      subtopic: List<ContentHashtag>.from(
        map['subtopic']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
      category: List<ContentHashtag>.from(
        map['category']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
      level: List<ContentHashtag>.from(
        map['level']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
      format: List<ContentHashtag>.from(
        map['format']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
      voice: List<ContentHashtag>.from(
        map['voice']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
      mood: List<ContentHashtag>.from(
        map['mood']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
      industry: List<ContentHashtag>.from(
        map['industry']?.map((x) => ContentHashtag.fromMap(x)) ?? [],
      ),
    );
  }

  @override
  List<Object?> get props => [
    topic,
    subtopic,
    category,
    level,
    format,
    voice,
    mood,
    industry,
  ];
}

/// Content metadata for matching and organization
class ContentMetadata extends BaseModel {
  final String topic;
  final String category;
  final String level;
  final DateTime createdAt;
  final String userId;
  final ContentTags? tags;
  final Map<String, dynamic>? customFields;

  const ContentMetadata({
    required this.topic,
    required this.category,
    required this.level,
    required this.createdAt,
    required this.userId,
    this.tags,
    this.customFields,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'category': category,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'tags': tags?.toMap(),
      'customFields': customFields,
    };
  }

  factory ContentMetadata.fromMap(Map<String, dynamic> map) {
    return ContentMetadata(
      topic: map['topic'] ?? '',
      category: map['category'] ?? '',
      level: map['level'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      userId: map['userId'] ?? '',
      tags: map['tags'] != null ? ContentTags.fromMap(map['tags']) : null,
      customFields: map['customFields'],
    );
  }

  @override
  List<Object?> get props => [
    topic,
    category,
    level,
    createdAt,
    userId,
    tags,
    customFields,
  ];
}

/// Content segment for modular content assembly
class ContentSegment extends BaseModel {
  final String id;
  final String content;
  final String type;
  final Duration duration;
  final String voice;
  final SegmentMetadata metadata;
  final Uint8List? audioData;
  final bool isAdaptable;

  const ContentSegment({
    required this.id,
    required this.content,
    required this.type,
    required this.duration,
    required this.voice,
    required this.metadata,
    this.audioData,
    this.isAdaptable = true,
  });

  /// Adapt segment for specific user profile
  ContentSegment adaptForUser(UserProfile userProfile) {
    // Implement user-specific adaptations
    return ContentSegment(
      id: '${id}_adapted_${userProfile.userId}',
      content: _adaptContentForUser(content, userProfile),
      type: type,
      duration: duration,
      voice: userProfile.preferredVoice ?? voice,
      metadata: metadata,
      audioData: audioData,
      isAdaptable: isAdaptable,
    );
  }

  String _adaptContentForUser(String content, UserProfile userProfile) {
    // Apply user-specific content adaptations
    // This could include language level adjustments, personalization, etc.
    return content; // Placeholder implementation
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type,
      'duration': duration.inMilliseconds,
      'voice': voice,
      'metadata': metadata.toMap(),
      'isAdaptable': isAdaptable,
    };
  }

  factory ContentSegment.fromMap(Map<String, dynamic> map) {
    return ContentSegment(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? '',
      duration: Duration(milliseconds: map['duration'] ?? 0),
      voice: map['voice'] ?? '',
      metadata: SegmentMetadata.fromMap(map['metadata'] ?? {}),
      isAdaptable: map['isAdaptable'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    type,
    duration,
    voice,
    metadata,
    audioData,
    isAdaptable,
  ];
}

/// Segment metadata
class SegmentMetadata extends BaseModel {
  final String topic;
  final String level;
  final DateTime createdAt;
  final ContentTags? tags;

  const SegmentMetadata({
    required this.topic,
    required this.level,
    required this.createdAt,
    this.tags,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags?.toMap(),
    };
  }

  factory SegmentMetadata.fromMap(Map<String, dynamic> map) {
    return SegmentMetadata(
      topic: map['topic'] ?? '',
      level: map['level'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      tags: map['tags'] != null ? ContentTags.fromMap(map['tags']) : null,
    );
  }

  @override
  List<Object?> get props => [topic, level, createdAt, tags];
}

/// Search result for content matching
class SearchResult extends BaseModel {
  final String contentId;
  final double reuseScore;
  final List<ContentSegment> segments;
  final ContentMetadata metadata;
  final double relevanceScore;

  const SearchResult({
    required this.contentId,
    required this.reuseScore,
    required this.segments,
    required this.metadata,
    required this.relevanceScore,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'reuseScore': reuseScore,
      'segments': segments.map((x) => x.toMap()).toList(),
      'metadata': metadata.toMap(),
      'relevanceScore': relevanceScore,
    };
  }

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      contentId: map['contentId'] ?? '',
      reuseScore: map['reuseScore']?.toDouble() ?? 0.0,
      segments: List<ContentSegment>.from(
        map['segments']?.map((x) => ContentSegment.fromMap(x)) ?? [],
      ),
      metadata: ContentMetadata.fromMap(map['metadata'] ?? {}),
      relevanceScore: map['relevanceScore']?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    contentId,
    reuseScore,
    segments,
    metadata,
    relevanceScore,
  ];
}

/// Reuse analysis result
class ReuseAnalysis extends BaseModel {
  final List<ContentSegment> reusableSegments;
  final List<NewSegmentSpec> newSegmentSpecs;
  final double overallReuseScore;
  final double estimatedCostSavings;

  const ReuseAnalysis({
    required this.reusableSegments,
    required this.newSegmentSpecs,
    required this.overallReuseScore,
    required this.estimatedCostSavings,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'reusableSegments': reusableSegments.map((x) => x.toMap()).toList(),
      'newSegmentSpecs': newSegmentSpecs.map((x) => x.toMap()).toList(),
      'overallReuseScore': overallReuseScore,
      'estimatedCostSavings': estimatedCostSavings,
    };
  }

  factory ReuseAnalysis.fromMap(Map<String, dynamic> map) {
    return ReuseAnalysis(
      reusableSegments: List<ContentSegment>.from(
        map['reusableSegments']?.map((x) => ContentSegment.fromMap(x)) ?? [],
      ),
      newSegmentSpecs: List<NewSegmentSpec>.from(
        map['newSegmentSpecs']?.map((x) => NewSegmentSpec.fromMap(x)) ?? [],
      ),
      overallReuseScore: map['overallReuseScore']?.toDouble() ?? 0.0,
      estimatedCostSavings: map['estimatedCostSavings']?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    reusableSegments,
    newSegmentSpecs,
    overallReuseScore,
    estimatedCostSavings,
  ];
}

/// Specification for new content segment
class NewSegmentSpec extends BaseModel {
  final String topic;
  final String type;
  final String level;
  final Duration? targetDuration;
  final Map<String, dynamic>? requirements;

  const NewSegmentSpec({
    required this.topic,
    required this.type,
    required this.level,
    this.targetDuration,
    this.requirements,
  });

  factory NewSegmentSpec.fromSearchResult(SearchResult result) {
    return NewSegmentSpec(
      topic: result.metadata.topic,
      type: 'text', // Default type
      level: result.metadata.level,
      targetDuration: const Duration(minutes: 2),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'type': type,
      'level': level,
      'targetDuration': targetDuration?.inMilliseconds,
      'requirements': requirements,
    };
  }

  factory NewSegmentSpec.fromMap(Map<String, dynamic> map) {
    return NewSegmentSpec(
      topic: map['topic'] ?? '',
      type: map['type'] ?? '',
      level: map['level'] ?? '',
      targetDuration: map['targetDuration'] != null
          ? Duration(milliseconds: map['targetDuration'])
          : null,
      requirements: map['requirements'],
    );
  }

  @override
  List<Object?> get props => [topic, type, level, targetDuration, requirements];
}

/// Optimization strategy for content generation
class OptimizationStrategy extends BaseModel {
  final bool canDeliverInstantly;
  final List<ContentSegment> reusableSegments;
  final List<NewSegmentSpec> newSegmentSpecs;
  final double reusePercentage;
  final double estimatedCostSavings;
  final double qualityScore;
  final DateTime startTime;

  const OptimizationStrategy({
    required this.canDeliverInstantly,
    required this.reusableSegments,
    required this.newSegmentSpecs,
    required this.reusePercentage,
    required this.estimatedCostSavings,
    required this.qualityScore,
    required this.startTime,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'canDeliverInstantly': canDeliverInstantly,
      'reusableSegments': reusableSegments.map((x) => x.toMap()).toList(),
      'newSegmentSpecs': newSegmentSpecs.map((x) => x.toMap()).toList(),
      'reusePercentage': reusePercentage,
      'estimatedCostSavings': estimatedCostSavings,
      'qualityScore': qualityScore,
      'startTime': startTime.toIso8601String(),
    };
  }

  factory OptimizationStrategy.fromMap(Map<String, dynamic> map) {
    return OptimizationStrategy(
      canDeliverInstantly: map['canDeliverInstantly'] ?? false,
      reusableSegments: List<ContentSegment>.from(
        map['reusableSegments']?.map((x) => ContentSegment.fromMap(x)) ?? [],
      ),
      newSegmentSpecs: List<NewSegmentSpec>.from(
        map['newSegmentSpecs']?.map((x) => NewSegmentSpec.fromMap(x)) ?? [],
      ),
      reusePercentage: map['reusePercentage']?.toDouble() ?? 0.0,
      estimatedCostSavings: map['estimatedCostSavings']?.toDouble() ?? 0.0,
      qualityScore: map['qualityScore']?.toDouble() ?? 0.0,
      startTime: DateTime.parse(map['startTime']),
    );
  }

  @override
  List<Object?> get props => [
    canDeliverInstantly,
    reusableSegments,
    newSegmentSpecs,
    reusePercentage,
    estimatedCostSavings,
    qualityScore,
    startTime,
  ];
}

/// Assembled content result
class AssembledContent extends BaseModel {
  final List<ContentSegment> segments;
  final ContentMetadata metadata;
  final AudioData? audioData;

  const AssembledContent({
    required this.segments,
    required this.metadata,
    this.audioData,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'segments': segments.map((x) => x.toMap()).toList(),
      'metadata': metadata.toMap(),
      'audioData': audioData?.toMap(),
    };
  }

  factory AssembledContent.fromMap(Map<String, dynamic> map) {
    return AssembledContent(
      segments: List<ContentSegment>.from(
        map['segments']?.map((x) => ContentSegment.fromMap(x)) ?? [],
      ),
      metadata: ContentMetadata.fromMap(map['metadata'] ?? {}),
      audioData: map['audioData'] != null ? AudioData.fromMap(map['audioData']) : null,
    );
  }

  @override
  List<Object?> get props => [segments, metadata, audioData];
}

/// Audio data model
class AudioData extends BaseModel {
  final Uint8List data;
  final Duration duration;
  final String format;
  final String quality;

  const AudioData({
    required this.data,
    required this.duration,
    required this.format,
    required this.quality,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'duration': duration.inMilliseconds,
      'format': format,
      'quality': quality,
    };
  }

  factory AudioData.fromMap(Map<String, dynamic> map) {
    return AudioData(
      data: Uint8List(0), // Cannot serialize binary data
      duration: Duration(milliseconds: map['duration'] ?? 0),
      format: map['format'] ?? '',
      quality: map['quality'] ?? '',
    );
  }

  @override
  List<Object?> get props => [data, duration, format, quality];
}

/// Audio metadata
class AudioMetadata extends BaseModel {
  final Duration duration;
  final String format;
  final int bitrate;
  final int sampleRate;

  const AudioMetadata({
    required this.duration,
    required this.format,
    required this.bitrate,
    required this.sampleRate,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'duration': duration.inMilliseconds,
      'format': format,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
    };
  }

  factory AudioMetadata.fromMap(Map<String, dynamic> map) {
    return AudioMetadata(
      duration: Duration(milliseconds: map['duration'] ?? 0),
      format: map['format'] ?? '',
      bitrate: map['bitrate'] ?? 0,
      sampleRate: map['sampleRate'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [duration, format, bitrate, sampleRate];
}

/// Smart content result
class SmartContentResult extends BaseModel {
  final AssembledContent content;
  final double reusePercentage;
  final double costSavings;
  final Duration deliveryTime;
  final double quality;

  const SmartContentResult({
    required this.content,
    required this.reusePercentage,
    required this.costSavings,
    required this.deliveryTime,
    required this.quality,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'content': content.toMap(),
      'reusePercentage': reusePercentage,
      'costSavings': costSavings,
      'deliveryTime': deliveryTime.inMilliseconds,
      'quality': quality,
    };
  }

  factory SmartContentResult.fromMap(Map<String, dynamic> map) {
    return SmartContentResult(
      content: AssembledContent.fromMap(map['content'] ?? {}),
      reusePercentage: map['reusePercentage']?.toDouble() ?? 0.0,
      costSavings: map['costSavings']?.toDouble() ?? 0.0,
      deliveryTime: Duration(milliseconds: map['deliveryTime'] ?? 0),
      quality: map['quality']?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    content,
    reusePercentage,
    costSavings,
    deliveryTime,
    quality,
  ];
}

/// User profile for personalization
class UserProfile extends BaseModel {
  final String userId;
  final String? preferredVoice;
  final String? learningStyle;
  final List<String> interests;
  final Map<String, dynamic> preferences;

  const UserProfile({
    required this.userId,
    this.preferredVoice,
    this.learningStyle,
    this.interests = const [],
    this.preferences = const {},
  });

  factory UserProfile.empty(String userId) {
    return UserProfile(userId: userId);
  }

  Map<String, dynamic> toContext() {
    return {
      'userId': userId,
      'preferredVoice': preferredVoice,
      'learningStyle': learningStyle,
      'interests': interests,
      'preferences': preferences,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'preferredVoice': preferredVoice,
      'learningStyle': learningStyle,
      'interests': interests,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      preferredVoice: map['preferredVoice'],
      learningStyle: map['learningStyle'],
      interests: List<String>.from(map['interests'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    userId,
    preferredVoice,
    learningStyle,
    interests,
    preferences,
  ];
}
