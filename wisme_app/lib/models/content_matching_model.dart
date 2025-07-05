/// Hashtag-based content matching system for intelligent content reuse
class ContentHashtag {
  final String type; // topic, subtopic, category, level, format, voice
  final String value;
  final double weight; // Importance weight for matching

  ContentHashtag({
    required this.type,
    required this.value,
    this.weight = 1.0,
  });

  @override
  String toString() => '#${value.toLowerCase().replaceAll(' ', '_')}';

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
}

class ContentTags {
  final List<ContentHashtag> topic;
  final List<ContentHashtag> subtopic;
  final List<ContentHashtag> category;
  final List<ContentHashtag> level;
  final List<ContentHashtag> format;
  final List<ContentHashtag> voice;
  final List<ContentHashtag> mood;
  final List<ContentHashtag> industry;

  ContentTags({
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
  List<ContentHashtag> get allTags => [
    ...topic,
    ...subtopic,
    ...category,
    ...level,
    ...format,
    ...voice,
    ...mood,
    ...industry,
  ];

  /// Get hashtags as strings for easy comparison
  List<String> get allTagStrings => allTags.map((tag) => tag.toString()).toList();

  /// Calculate similarity score with another ContentTags
  double calculateSimilarity(ContentTags other) {
    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final tag in allTags) {
      totalWeight += tag.weight;
      
      // Check if the other ContentTags has this tag
      final hasMatch = other.allTagStrings.contains(tag.toString());
      if (hasMatch) {
        totalScore += tag.weight;
      }
    }

    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'topic': topic.map((tag) => tag.toMap()).toList(),
      'subtopic': subtopic.map((tag) => tag.toMap()).toList(),
      'category': category.map((tag) => tag.toMap()).toList(),
      'level': level.map((tag) => tag.toMap()).toList(),
      'format': format.map((tag) => tag.toMap()).toList(),
      'voice': voice.map((tag) => tag.toMap()).toList(),
      'mood': mood.map((tag) => tag.toMap()).toList(),
      'industry': industry.map((tag) => tag.toMap()).toList(),
    };
  }

  factory ContentTags.fromMap(Map<String, dynamic> map) {
    return ContentTags(
      topic: (map['topic'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
      subtopic: (map['subtopic'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
      category: (map['category'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
      level: (map['level'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
      format: (map['format'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
      voice: (map['voice'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
      mood: (map['mood'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
      industry: (map['industry'] as List? ?? []).map((e) => ContentHashtag.fromMap(e)).toList(),
    );
  }
}

class ContentMatch {
  final String contentId;
  final double similarityScore;
  final double semanticScore;
  final double freshnessScore;
  final double totalScore;
  final List<String> matchingTags;
  final DateTime? lastPlayed;
  final bool isExactMatch;

  ContentMatch({
    required this.contentId,
    required this.similarityScore,
    required this.semanticScore,
    required this.freshnessScore,
    required this.totalScore,
    required this.matchingTags,
    this.lastPlayed,
    this.isExactMatch = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'similarityScore': similarityScore,
      'semanticScore': semanticScore,
      'freshnessScore': freshnessScore,
      'totalScore': totalScore,
      'matchingTags': matchingTags,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'isExactMatch': isExactMatch,
    };
  }
}

class UserListeningHistory {
  final String userId;
  final List<String> playedContentIds;
  final Map<String, DateTime> lastPlayedDates;
  final Map<String, int> playCount;
  final Map<String, double> userRatings;
  final List<String> bookmarkedContent;
  final List<String> dislikedContent;

  UserListeningHistory({
    required this.userId,
    this.playedContentIds = const [],
    this.lastPlayedDates = const {},
    this.playCount = const {},
    this.userRatings = const {},
    this.bookmarkedContent = const [],
    this.dislikedContent = const [],
  });

  /// Check if content has been played by user
  bool hasPlayed(String contentId) => playedContentIds.contains(contentId);

  /// Check if content was played recently (within days)
  bool wasPlayedRecently(String contentId, {int withinDays = 30}) {
    final lastPlayed = lastPlayedDates[contentId];
    if (lastPlayed == null) return false;
    
    final daysSince = DateTime.now().difference(lastPlayed).inDays;
    return daysSince <= withinDays;
  }

  /// Get user's preference score for similar content
  double getPreferenceScore(List<String> tags) {
    double totalScore = 0.0;
    int ratingCount = 0;

    // Calculate based on ratings of similar content
    for (final contentId in userRatings.keys) {
      // In a real implementation, you'd check if contentId has similar tags
      final rating = userRatings[contentId] ?? 0.0;
      totalScore += rating;
      ratingCount++;
    }

    return ratingCount > 0 ? totalScore / ratingCount : 0.5;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'playedContentIds': playedContentIds,
      'lastPlayedDates': lastPlayedDates.map((k, v) => MapEntry(k, v.toIso8601String())),
      'playCount': playCount,
      'userRatings': userRatings,
      'bookmarkedContent': bookmarkedContent,
      'dislikedContent': dislikedContent,
    };
  }

  factory UserListeningHistory.fromMap(Map<String, dynamic> map) {
    return UserListeningHistory(
      userId: map['userId'] ?? '',
      playedContentIds: List<String>.from(map['playedContentIds'] ?? []),
      lastPlayedDates: (map['lastPlayedDates'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, DateTime.parse(v))),
      playCount: Map<String, int>.from(map['playCount'] ?? {}),
      userRatings: Map<String, double>.from(map['userRatings'] ?? {}),
      bookmarkedContent: List<String>.from(map['bookmarkedContent'] ?? []),
      dislikedContent: List<String>.from(map['dislikedContent'] ?? []),
    );
  }

  /// Create copy with updated data
  UserListeningHistory copyWith({
    List<String>? playedContentIds,
    Map<String, DateTime>? lastPlayedDates,
    Map<String, int>? playCount,
    Map<String, double>? userRatings,
    List<String>? bookmarkedContent,
    List<String>? dislikedContent,
  }) {
    return UserListeningHistory(
      userId: userId,
      playedContentIds: playedContentIds ?? this.playedContentIds,
      lastPlayedDates: lastPlayedDates ?? this.lastPlayedDates,
      playCount: playCount ?? this.playCount,
      userRatings: userRatings ?? this.userRatings,
      bookmarkedContent: bookmarkedContent ?? this.bookmarkedContent,
      dislikedContent: dislikedContent ?? this.dislikedContent,
    );
  }
}

/// Smart content assembly for creating dynamic episodes
class ContentAssembly {
  final List<String> contentIds;
  final String assemblyType; // single, multi_clip, remix, custom
  final Map<String, dynamic> customization;
  final Duration estimatedDuration;
  final double confidenceScore;

  ContentAssembly({
    required this.contentIds,
    required this.assemblyType,
    this.customization = const {},
    required this.estimatedDuration,
    required this.confidenceScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'contentIds': contentIds,
      'assemblyType': assemblyType,
      'customization': customization,
      'estimatedDurationSeconds': estimatedDuration.inSeconds,
      'confidenceScore': confidenceScore,
    };
  }
}
