/// Crystal clear hashtag system for audio content matching
/// Replaces the confusing "ContentHashtag" with audio-specific naming
class AudioHashtag {
  final String type; // topic, subtopic, category, level, format, voice, mood, industry
  final String value;
  final double weight; // Importance weight for matching (0.0 - 5.0)

  const AudioHashtag({
    required this.type,
    required this.value,
    this.weight = 1.0,
  });

  /// Create a hashtag string representation
  @override
  String toString() => '#${value.toLowerCase().replaceAll(' ', '_')}';

  /// Get normalized hashtag value for consistent matching
  String get normalizedValue => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'weight': weight,
    };
  }

  factory AudioHashtag.fromJson(Map<String, dynamic> json) {
    return AudioHashtag(
      type: json['type'] as String,
      value: json['value'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioHashtag && 
           other.type == type && 
           other.normalizedValue == normalizedValue;
  }

  @override
  int get hashCode => Object.hash(type, normalizedValue);
}

/// Complete hashtag collection for audio content
class AudioHashtagCollection {
  final List<AudioHashtag> topic;
  final List<AudioHashtag> subtopic;
  final List<AudioHashtag> category;
  final List<AudioHashtag> level;
  final List<AudioHashtag> format;
  final List<AudioHashtag> voice;
  final List<AudioHashtag> mood;
  final List<AudioHashtag> industry;
  final List<AudioHashtag> semantic;
  final List<AudioHashtag> keywords;

  const AudioHashtagCollection({
    this.topic = const [],
    this.subtopic = const [],
    this.category = const [],
    this.level = const [],
    this.format = const [],
    this.voice = const [],
    this.mood = const [],
    this.industry = const [],
    this.semantic = const [],
    this.keywords = const [],
  });

  /// Get all hashtags as a flat list
  List<AudioHashtag> get allHashtags => [
    ...topic,
    ...subtopic,
    ...category,
    ...level,
    ...format,
    ...voice,
    ...mood,
    ...industry,
    ...semantic,
    ...keywords,
  ];

  /// Get hashtags as strings for easy comparison
  List<String> get allHashtagStrings => allHashtags.map((tag) => tag.toString()).toList();

  /// Get hashtags with their weights for scoring
  Map<String, double> get hashtagWeights {
    final Map<String, double> weights = {};
    for (final tag in allHashtags) {
      weights[tag.toString()] = tag.weight;
    }
    return weights;
  }

  /// Calculate weighted similarity score with another collection
  double calculateWeightedSimilarity(AudioHashtagCollection other) {
    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final tag in allHashtags) {
      totalWeight += tag.weight;
      
      // Check if the other collection has this tag
      final hasMatch = other.allHashtagStrings.contains(tag.toString());
      if (hasMatch) {
        totalScore += tag.weight;
      }
    }

    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }

  /// Get the most important hashtags (highest weights)
  List<AudioHashtag> get priorityHashtags {
    final sorted = List<AudioHashtag>.from(allHashtags);
    sorted.sort((a, b) => b.weight.compareTo(a.weight));
    return sorted.take(10).toList(); // Top 10 most important
  }

  /// Filter hashtags by type
  List<AudioHashtag> getHashtagsByType(String type) {
    return allHashtags.where((tag) => tag.type == type).toList();
  }

  /// Create collection from simple string list
  factory AudioHashtagCollection.fromStrings(List<String> hashtags, {String type = 'general', double weight = 1.0}) {
    final audioHashtags = hashtags.map((tag) => AudioHashtag(
      type: type,
      value: tag,
      weight: weight,
    )).toList();

    return AudioHashtagCollection(
      keywords: audioHashtags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic.map((tag) => tag.toJson()).toList(),
      'subtopic': subtopic.map((tag) => tag.toJson()).toList(),
      'category': category.map((tag) => tag.toJson()).toList(),
      'level': level.map((tag) => tag.toJson()).toList(),
      'format': format.map((tag) => tag.toJson()).toList(),
      'voice': voice.map((tag) => tag.toJson()).toList(),
      'mood': mood.map((tag) => tag.toJson()).toList(),
      'industry': industry.map((tag) => tag.toJson()).toList(),
      'semantic': semantic.map((tag) => tag.toJson()).toList(),
      'keywords': keywords.map((tag) => tag.toJson()).toList(),
    };
  }

  factory AudioHashtagCollection.fromJson(Map<String, dynamic> json) {
    return AudioHashtagCollection(
      topic: (json['topic'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      subtopic: (json['subtopic'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      category: (json['category'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      level: (json['level'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      format: (json['format'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      voice: (json['voice'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      mood: (json['mood'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      industry: (json['industry'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      semantic: (json['semantic'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
      keywords: (json['keywords'] as List?)?.map((item) => AudioHashtag.fromJson(item)).toList() ?? [],
    );
  }

  @override
  String toString() {
    return 'AudioHashtagCollection(${allHashtags.length} hashtags, priority: ${priorityHashtags.take(3).map((t) => t.toString()).join(', ')})';
  }
}

/// Audio content matching result with score and details
class AudioMatchResult {
  final String audioId;
  final double similarityScore;
  final List<AudioHashtag> matchingHashtags;
  final AudioHashtagCollection targetHashtags;
  final DateTime matchedAt;

  const AudioMatchResult({
    required this.audioId,
    required this.similarityScore,
    required this.matchingHashtags,
    required this.targetHashtags,
    required this.matchedAt,
  });

  /// Check if this is a strong match (similarity > 0.7)
  bool get isStrongMatch => similarityScore > 0.7;

  /// Check if this is a good match (similarity > 0.5)
  bool get isGoodMatch => similarityScore > 0.5;

  /// Get match quality description
  String get matchQuality {
    if (similarityScore > 0.8) return 'Excellent';
    if (similarityScore > 0.6) return 'Good';
    if (similarityScore > 0.4) return 'Fair';
    return 'Poor';
  }

  @override
  String toString() {
    return 'AudioMatchResult(audioId: $audioId, score: ${(similarityScore * 100).toStringAsFixed(1)}%, quality: $matchQuality)';
  }
}
