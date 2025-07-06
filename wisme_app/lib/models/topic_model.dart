import '../core/exports.dart';
class TopicAnalysis {
  final String id;
  final String originalQuery;
  final String detectedCategory;
  final String knowledgeLevel;
  final List<String> suggestedTags;
  final double confidenceScore;
  final int estimatedSessions;
  final String recommendedCoach;
  final Map<String, dynamic> metadata;
  final DateTime analyzedAt;

  const TopicAnalysis({
    required this.id,
    required this.originalQuery,
    required this.detectedCategory,
    required this.knowledgeLevel,
    required this.suggestedTags,
    required this.confidenceScore,
    required this.estimatedSessions,
    required this.recommendedCoach,
    required this.metadata,
    required this.analyzedAt,
  });

  /// Create TopicAnalysis from GPT API response
  factory TopicAnalysis.fromGPTResponse(Map<String, dynamic> gptData, String originalQuery) {
    return TopicAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalQuery: originalQuery,
      detectedCategory: gptData['category'] ?? 'Technology',
      knowledgeLevel: gptData['intent'] ?? 'Mixed',
      suggestedTags: List<String>.from(gptData['tags'] ?? []),
      confidenceScore: (gptData['confidence'] ?? 0.8).toDouble(),
      estimatedSessions: gptData['estimated_sessions'] ?? 3,
      recommendedCoach: gptData['recommended_coach'] ?? 'kai',
      metadata: gptData,
      analyzedAt: DateTime.now(),
    );
  }

  /// Create from JSON
  factory TopicAnalysis.fromJson(Map<String, dynamic> json) {
    return TopicAnalysis(
      id: json['id'],
      originalQuery: json['original_query'],
      detectedCategory: json['detected_category'],
      knowledgeLevel: json['knowledge_level'],
      suggestedTags: List<String>.from(json['suggested_tags']),
      confidenceScore: json['confidence_score'].toDouble(),
      estimatedSessions: json['estimated_sessions'],
      recommendedCoach: json['recommended_coach'],
      metadata: json['metadata'] ?? {},
      analyzedAt: DateTime.parse(json['analyzed_at']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_query': originalQuery,
      'detected_category': detectedCategory,
      'knowledge_level': knowledgeLevel,
      'suggested_tags': suggestedTags,
      'confidence_score': confidenceScore,
      'estimated_sessions': estimatedSessions,
      'recommended_coach': recommendedCoach,
      'metadata': metadata,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  /// Create copy with modifications
  TopicAnalysis copyWith({
    String? id,
    String? originalQuery,
    String? detectedCategory,
    String? knowledgeLevel,
    List<String>? suggestedTags,
    double? confidenceScore,
    int? estimatedSessions,
    String? recommendedCoach,
    Map<String, dynamic>? metadata,
    DateTime? analyzedAt,
  }) {
    return TopicAnalysis(
      id: id ?? this.id,
      originalQuery: originalQuery ?? this.originalQuery,
      detectedCategory: detectedCategory ?? this.detectedCategory,
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      suggestedTags: suggestedTags ?? this.suggestedTags,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      estimatedSessions: estimatedSessions ?? this.estimatedSessions,
      recommendedCoach: recommendedCoach ?? this.recommendedCoach,
      metadata: metadata ?? this.metadata,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  // Business Logic Methods

  /// Get user-friendly category display name
  String get categoryDisplayName {
    switch (detectedCategory) {
      case 'Technology':
        return '💻 Technology';
      case 'Business & Finance':
        return '💼 Business & Finance';
      case 'Psychology & Mind':
        return '🧠 Psychology & Mind';
      case 'Science & Nature':
        return '🔬 Science & Nature';
      case 'Creativity & Design':
        return '🎨 Creativity & Design';
      case 'Self-Growth':
        return '🌱 Self-Growth';
      case 'History & Culture':
        return '📚 History & Culture';
      case 'Skills & Tools':
        return '🛠️ Skills & Tools';
      case 'Career & Strategy':
        return '🎯 Career & Strategy';
      case 'Law & Governance':
        return '⚖️ Law & Governance';
      case 'Geopolitics & Global Affairs':
        return '🌍 Geopolitics';
      case 'Environment & Sustainability':
        return '🌿 Environment';
      case 'Mathematics & Logic':
        return '📊 Mathematics & Logic';
      case 'Gaming & Interactive Media':
        return '🎮 Gaming & Media';
      case 'Society & Ethics':
        return '🤝 Society & Ethics';
      case 'Futurism & Exploration':
        return '🚀 Futurism';
      default:
        return '📖 General Learning';
    }
  }

  /// Check if analysis confidence is high enough for auto-generation
  bool get isHighConfidence => confidenceScore >= 0.75;

  /// Get estimated total learning time in minutes
  int get estimatedTotalMinutes => estimatedSessions * 12; // 12 minutes per session average

  /// Get knowledge level display
  String get knowledgeLevelDisplay {
    switch (knowledgeLevel.toLowerCase()) {
      case 'fundamentals':
        return 'Fundamentals';
      case 'case studies':
        return 'Case Studies';
      case 'advanced':
        return 'Advanced';
      case 'practical_application':
        return 'Practical Application';
      case 'mixed':
        return 'Mixed Approach';
      default:
        return 'Balanced Learning';
    }
  }

  /// Get recommended coach personality color
  Color get coachColor {
    switch (recommendedCoach.toLowerCase()) {
      case 'kai':
        return const Color(0xFF6366F1); // Strategic blue
      case 'vee':
        return const Color(0xFF10B981); // Energetic green
      default:
        return const Color(0xFF8B5CF6); // Custom purple
    }
  }

  @override
  String toString() {
    return 'TopicAnalysis(id: $id, query: $originalQuery, category: $detectedCategory, confidence: $confidenceScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicAnalysis && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


