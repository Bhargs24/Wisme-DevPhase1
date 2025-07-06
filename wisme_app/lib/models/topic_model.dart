import '../shared/models/base_model.dart';

/// Core topic analysis model for the Wisme learning system
/// Represents the AI's analysis of a user's learning topic input
class TopicAnalysis extends BaseModel {
  /// Original user input/query
  final String originalQuery;
  
  /// AI-detected main category (Technology, Business, Psychology, etc.)
  final String detectedCategory;
  
  /// Knowledge level preference (Fundamentals, Case Studies, etc.)
  final String knowledgeLevel;
  
  /// AI-generated tags for content matching
  final List<String> suggestedTags;
  
  /// Confidence score of the analysis (0.0 - 1.0)
  final double confidenceScore;
  
  /// Estimated learning session count for this topic
  final int estimatedSessions;
  
  /// Recommended coach personality for this topic
  final String recommendedCoach;
  
  /// Additional metadata from GPT analysis
  final Map<String, dynamic> analysisMetadata;
  
  /// When this analysis was performed
  final DateTime analyzedAt;

  const TopicAnalysis({
    required this.originalQuery,
    required this.detectedCategory,
    required this.knowledgeLevel,
    required this.suggestedTags,
    required this.confidenceScore,
    required this.estimatedSessions,
    required this.recommendedCoach,
    required this.analysisMetadata,
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
    originalQuery,
    detectedCategory,
    knowledgeLevel,
    suggestedTags,
    confidenceScore,
    estimatedSessions,
    recommendedCoach,
    analysisMetadata,
    analyzedAt,
  ];

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'originalQuery': originalQuery,
      'detectedCategory': detectedCategory,
      'knowledgeLevel': knowledgeLevel,
      'suggestedTags': suggestedTags,
      'confidenceScore': confidenceScore,
      'estimatedSessions': estimatedSessions,
      'recommendedCoach': recommendedCoach,
      'analysisMetadata': analysisMetadata,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  /// Create from JSON (Firestore, API response, etc.)
  factory TopicAnalysis.fromJson(Map<String, dynamic> json) {
    return TopicAnalysis(
      originalQuery: json['originalQuery'] ?? '',
      detectedCategory: json['detectedCategory'] ?? '',
      knowledgeLevel: json['knowledgeLevel'] ?? '',
      suggestedTags: List<String>.from(json['suggestedTags'] ?? []),
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      estimatedSessions: json['estimatedSessions'] ?? 1,
      recommendedCoach: json['recommendedCoach'] ?? 'kai',
      analysisMetadata: Map<String, dynamic>.from(json['analysisMetadata'] ?? {}),
      analyzedAt: DateTime.parse(json['analyzedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Create from GPT service response
  factory TopicAnalysis.fromGPTResponse(Map<String, dynamic> gptData) {
    return TopicAnalysis(
      originalQuery: gptData['user_input'] ?? '',
      detectedCategory: gptData['category'] ?? 'General',
      knowledgeLevel: gptData['knowledge_level'] ?? 'Mixed',
      suggestedTags: List<String>.from(gptData['tags'] ?? []),
      confidenceScore: (gptData['confidence'] ?? 0.8).toDouble(),
      estimatedSessions: gptData['estimated_sessions'] ?? 5,
      recommendedCoach: gptData['recommended_coach'] ?? 'kai',
      analysisMetadata: Map<String, dynamic>.from(gptData['metadata'] ?? {}),
      analyzedAt: DateTime.now(),
    );
  }

  /// Create a default/placeholder analysis for fallback scenarios
  factory TopicAnalysis.defaultAnalysis(String query) {
    return TopicAnalysis(
      originalQuery: query,
      detectedCategory: 'General Knowledge',
      knowledgeLevel: 'Mixed Approach',
      suggestedTags: ['beginner', 'general'],
      confidenceScore: 0.5,
      estimatedSessions: 3,
      recommendedCoach: 'kai',
      analysisMetadata: {'source': 'fallback'},
      analyzedAt: DateTime.now(),
    );
  }

  /// Copy with modifications
  TopicAnalysis copyWith({
    String? originalQuery,
    String? detectedCategory,
    String? knowledgeLevel,
    List<String>? suggestedTags,
    double? confidenceScore,
    int? estimatedSessions,
    String? recommendedCoach,
    Map<String, dynamic>? analysisMetadata,
    DateTime? analyzedAt,
  }) {
    return TopicAnalysis(
      originalQuery: originalQuery ?? this.originalQuery,
      detectedCategory: detectedCategory ?? this.detectedCategory,
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      suggestedTags: suggestedTags ?? this.suggestedTags,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      estimatedSessions: estimatedSessions ?? this.estimatedSessions,
      recommendedCoach: recommendedCoach ?? this.recommendedCoach,
      analysisMetadata: analysisMetadata ?? this.analysisMetadata,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  /// Generate unique ID for caching/storage
  String get id => '${originalQuery.replaceAll(' ', '_').toLowerCase()}_${analyzedAt.millisecondsSinceEpoch}';

  /// Check if analysis is high confidence
  bool get isHighConfidence => confidenceScore >= 0.7;

  /// Get formatted category display name
  String get categoryDisplayName {
    const categoryMap = {
      'technology': '🌐 Technology',
      'business': '📊 Business & Finance',
      'psychology': '🧠 Psychology & Mind',
      'science': '🔍 Science & Nature',
      'creativity': '💡 Creativity & Design',
      'self-growth': '🌱 Self-Growth',
      'history': '📚 History & Culture',
      'skills': '🛠 Skills & Tools',
      'career': '🎯 Career & Strategy',
      'law': '🏛 Law & Governance',
    };
    
    return categoryMap[detectedCategory.toLowerCase()] ?? '🎓 $detectedCategory';
  }

  /// Get emoji representation of knowledge level
  String get knowledgeLevelEmoji {
    const levelMap = {
      'fundamentals': '💡',
      'case studies': '💼',
      'advanced': '🔬',
      'mixed': '🎛',
      'practical': '🛠',
      'theoretical': '📖',
    };
    
    return levelMap[knowledgeLevel.toLowerCase()] ?? '🎓';
  }
}
