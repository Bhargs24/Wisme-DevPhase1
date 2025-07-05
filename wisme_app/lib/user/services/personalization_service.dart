/// Advanced User Personalization Service
/// 
/// Analyzes user behavior and learning patterns to create personalized
/// learning experiences through data-driven insights.
library;

import 'dart:math';
import '../../shared/models/base_model.dart';
import '../../shared/models/result.dart';
import '../../core/utils/logger.dart';
import '../../core/error/app_exceptions.dart';
import '../models/content_models.dart';

/// User personality profile for deep personalization
class UserPersonalityProfile extends BaseModel {
  final String userId;
  final LearningStyle learningStyle;
  final ContentPreferences contentPreferences;
  final EngagementPattern engagementPattern;
  final List<String> predictedInterests;
  final Map<String, double> personalityScores;
  final DateTime lastUpdated;
  final double confidenceScore;

  const UserPersonalityProfile({
    required this.userId,
    required this.learningStyle,
    required this.contentPreferences,
    required this.engagementPattern,
    required this.predictedInterests,
    required this.personalityScores,
    required this.lastUpdated,
    required this.confidenceScore,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'learningStyle': learningStyle.toMap(),
      'contentPreferences': contentPreferences.toMap(),
      'engagementPattern': engagementPattern.toMap(),
      'predictedInterests': predictedInterests,
      'personalityScores': personalityScores,
      'lastUpdated': lastUpdated.toIso8601String(),
      'confidenceScore': confidenceScore,
    };
  }

  factory UserPersonalityProfile.fromMap(Map<String, dynamic> map) {
    return UserPersonalityProfile(
      userId: map['userId'] ?? '',
      learningStyle: LearningStyle.fromMap(map['learningStyle'] ?? {}),
      contentPreferences: ContentPreferences.fromMap(map['contentPreferences'] ?? {}),
      engagementPattern: EngagementPattern.fromMap(map['engagementPattern'] ?? {}),
      predictedInterests: List<String>.from(map['predictedInterests'] ?? []),
      personalityScores: Map<String, double>.from(map['personalityScores'] ?? {}),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      confidenceScore: map['confidenceScore']?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    learningStyle,
    contentPreferences,
    engagementPattern,
    predictedInterests,
    personalityScores,
    lastUpdated,
    confidenceScore,
  ];
}

/// Learning style analysis
class LearningStyle extends BaseModel {
  final String primaryStyle; // visual, auditory, kinesthetic, reading
  final double visualScore;
  final double auditoryScore;
  final double kinestheticScore;
  final double readingScore;
  final String pacePreference; // slow, moderate, fast
  final String complexityPreference; // simple, moderate, complex

  const LearningStyle({
    required this.primaryStyle,
    required this.visualScore,
    required this.auditoryScore,
    required this.kinestheticScore,
    required this.readingScore,
    required this.pacePreference,
    required this.complexityPreference,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'primaryStyle': primaryStyle,
      'visualScore': visualScore,
      'auditoryScore': auditoryScore,
      'kinestheticScore': kinestheticScore,
      'readingScore': readingScore,
      'pacePreference': pacePreference,
      'complexityPreference': complexityPreference,
    };
  }

  factory LearningStyle.fromMap(Map<String, dynamic> map) {
    return LearningStyle(
      primaryStyle: map['primaryStyle'] ?? '',
      visualScore: map['visualScore']?.toDouble() ?? 0.0,
      auditoryScore: map['auditoryScore']?.toDouble() ?? 0.0,
      kinestheticScore: map['kinestheticScore']?.toDouble() ?? 0.0,
      readingScore: map['readingScore']?.toDouble() ?? 0.0,
      pacePreference: map['pacePreference'] ?? '',
      complexityPreference: map['complexityPreference'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    primaryStyle,
    visualScore,
    auditoryScore,
    kinestheticScore,
    readingScore,
    pacePreference,
    complexityPreference,
  ];
}

/// Content preferences analysis
class ContentPreferences extends BaseModel {
  final Map<String, double> topicAffinity;
  final Map<String, double> formatPreferences;
  final Duration preferredDuration;
  final List<String> favoriteVoices;
  final double interactivityPreference;
  final double difficultyPreference;

  const ContentPreferences({
    required this.topicAffinity,
    required this.formatPreferences,
    required this.preferredDuration,
    required this.favoriteVoices,
    required this.interactivityPreference,
    required this.difficultyPreference,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'topicAffinity': topicAffinity,
      'formatPreferences': formatPreferences,
      'preferredDuration': preferredDuration.inMilliseconds,
      'favoriteVoices': favoriteVoices,
      'interactivityPreference': interactivityPreference,
      'difficultyPreference': difficultyPreference,
    };
  }

  factory ContentPreferences.fromMap(Map<String, dynamic> map) {
    return ContentPreferences(
      topicAffinity: Map<String, double>.from(map['topicAffinity'] ?? {}),
      formatPreferences: Map<String, double>.from(map['formatPreferences'] ?? {}),
      preferredDuration: Duration(milliseconds: map['preferredDuration'] ?? 0),
      favoriteVoices: List<String>.from(map['favoriteVoices'] ?? []),
      interactivityPreference: map['interactivityPreference']?.toDouble() ?? 0.0,
      difficultyPreference: map['difficultyPreference']?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    topicAffinity,
    formatPreferences,
    preferredDuration,
    favoriteVoices,
    interactivityPreference,
    difficultyPreference,
  ];
}

/// User engagement pattern analysis
class EngagementPattern extends BaseModel {
  final Map<String, double> timeOfDayActivity;
  final Map<String, double> dayOfWeekActivity;
  final double averageSessionDuration;
  final double completionRate;
  final double retentionRate;
  final List<String> dropoffPoints;

  const EngagementPattern({
    required this.timeOfDayActivity,
    required this.dayOfWeekActivity,
    required this.averageSessionDuration,
    required this.completionRate,
    required this.retentionRate,
    required this.dropoffPoints,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'timeOfDayActivity': timeOfDayActivity,
      'dayOfWeekActivity': dayOfWeekActivity,
      'averageSessionDuration': averageSessionDuration,
      'completionRate': completionRate,
      'retentionRate': retentionRate,
      'dropoffPoints': dropoffPoints,
    };
  }

  factory EngagementPattern.fromMap(Map<String, dynamic> map) {
    return EngagementPattern(
      timeOfDayActivity: Map<String, double>.from(map['timeOfDayActivity'] ?? {}),
      dayOfWeekActivity: Map<String, double>.from(map['dayOfWeekActivity'] ?? {}),
      averageSessionDuration: map['averageSessionDuration']?.toDouble() ?? 0.0,
      completionRate: map['completionRate']?.toDouble() ?? 0.0,
      retentionRate: map['retentionRate']?.toDouble() ?? 0.0,
      dropoffPoints: List<String>.from(map['dropoffPoints'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
    timeOfDayActivity,
    dayOfWeekActivity,
    averageSessionDuration,
    completionRate,
    retentionRate,
    dropoffPoints,
  ];
}

/// Content recommendation based on personalization
class ContentRecommendation extends BaseModel {
  final String contentId;
  final String title;
  final String category;
  final double relevanceScore;
  final double personalizedScore;
  final String reasoning;
  final Map<String, dynamic> metadata;

  const ContentRecommendation({
    required this.contentId,
    required this.title,
    required this.category,
    required this.relevanceScore,
    required this.personalizedScore,
    required this.reasoning,
    this.metadata = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'title': title,
      'category': category,
      'relevanceScore': relevanceScore,
      'personalizedScore': personalizedScore,
      'reasoning': reasoning,
      'metadata': metadata,
    };
  }

  factory ContentRecommendation.fromMap(Map<String, dynamic> map) {
    return ContentRecommendation(
      contentId: map['contentId'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      relevanceScore: map['relevanceScore']?.toDouble() ?? 0.0,
      personalizedScore: map['personalizedScore']?.toDouble() ?? 0.0,
      reasoning: map['reasoning'] ?? '',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    contentId,
    title,
    category,
    relevanceScore,
    personalizedScore,
    reasoning,
    metadata,
  ];
}

/// Service for analyzing user behavior and generating personality profiles
class PersonalizationService {
  static final Map<String, UserPersonalityProfile> _userProfiles = {};
  static final Map<String, List<ContentRecommendation>> _recommendationCache = {};

  /// Generate user personality profile from behavior data
  static Result<UserPersonalityProfile> generateUserProfile({
    required String userId,
    required List<ContentBlock> consumedContent,
    required Map<String, double> ratings,
    required Map<String, Duration> listeningTimes,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      AppLogger.info('🧠 Generating user profile for: $userId');

      // Analyze learning preferences
      final learningStyle = _analyzeLearningStyle(consumedContent, listeningTimes);
      
      // Analyze content preferences
      final contentPreferences = _analyzeContentPreferences(consumedContent, ratings);
      
      // Analyze engagement patterns
      final engagementPattern = _analyzeEngagementPattern(listeningTimes);
      
      // Predict future interests
      final predictedInterests = _predictFutureInterests(consumedContent, ratings);
      
      // Calculate personality scores
      final personalityScores = _calculatePersonalityScores(consumedContent, ratings);

      final profile = UserPersonalityProfile(
        userId: userId,
        learningStyle: learningStyle,
        contentPreferences: contentPreferences,
        engagementPattern: engagementPattern,
        predictedInterests: predictedInterests,
        personalityScores: personalityScores,
        lastUpdated: DateTime.now(),
        confidenceScore: _calculateConfidenceScore(consumedContent.length, ratings.length),
      );

      _userProfiles[userId] = profile;
      AppLogger.info('✅ User profile generated with confidence: ${profile.confidenceScore}');
      
      return Result.success(profile);
    } catch (e) {
      AppLogger.error('❌ Failed to generate user profile: $e');
      return Result.failure(PersonalizationException('Failed to generate user profile'));
    }
  }

  /// Analyze user's learning style preferences
  static LearningStyle _analyzeLearningStyle(
    List<ContentBlock> content,
    Map<String, Duration> listeningTimes,
  ) {
    double visualScore = 0.0;
    double auditoryScore = 0.0;
    double kinestheticScore = 0.0;
    double readingScore = 0.0;

    for (final block in content) {
      final duration = listeningTimes[block.id] ?? Duration.zero;
      final engagement = duration.inSeconds / (block.estimatedDuration?.inSeconds ?? 1);

      switch (block.type.toLowerCase()) {
        case 'visual':
        case 'image':
        case 'diagram':
          visualScore += engagement;
          break;
        case 'audio':
        case 'speech':
        case 'music':
          auditoryScore += engagement;
          break;
        case 'interactive':
        case 'exercise':
        case 'hands-on':
          kinestheticScore += engagement;
          break;
        case 'text':
        case 'reading':
        case 'article':
          readingScore += engagement;
          break;
      }
    }

    // Normalize scores
    final total = visualScore + auditoryScore + kinestheticScore + readingScore;
    if (total > 0) {
      visualScore /= total;
      auditoryScore /= total;
      kinestheticScore /= total;
      readingScore /= total;
    }

    // Determine primary style
    final scores = {
      'visual': visualScore,
      'auditory': auditoryScore,
      'kinesthetic': kinestheticScore,
      'reading': readingScore,
    };
    final primaryStyle = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Determine pace and complexity preferences
    final avgDuration = listeningTimes.values.isEmpty 
        ? Duration.zero 
        : Duration(milliseconds: 
            listeningTimes.values.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ 
            listeningTimes.values.length);

    final pacePreference = avgDuration.inMinutes < 3 ? 'fast' :
                          avgDuration.inMinutes < 7 ? 'moderate' : 'slow';

    return LearningStyle(
      primaryStyle: primaryStyle,
      visualScore: visualScore,
      auditoryScore: auditoryScore,
      kinestheticScore: kinestheticScore,
      readingScore: readingScore,
      pacePreference: pacePreference,
      complexityPreference: 'moderate', // Default, can be refined
    );
  }

  /// Analyze user's content preferences
  static ContentPreferences _analyzeContentPreferences(
    List<ContentBlock> content,
    Map<String, double> ratings,
  ) {
    final topicAffinity = <String, double>{};
    final formatPreferences = <String, double>{};
    final favoriteVoices = <String>[];
    
    double totalRating = 0.0;
    int ratingCount = 0;

    for (final block in content) {
      final rating = ratings[block.id];
      if (rating != null) {
        // Analyze topic affinity
        if (block.topic != null) {
          topicAffinity[block.topic!] = (topicAffinity[block.topic!] ?? 0.0) + rating;
        }
        
        // Analyze format preferences
        formatPreferences[block.type] = (formatPreferences[block.type] ?? 0.0) + rating;
        
        // Track favorite voices
        if (block.voice != null && rating > 4.0) {
          favoriteVoices.add(block.voice!);
        }
        
        totalRating += rating;
        ratingCount++;
      }
    }

    // Calculate average durations and preferences
    final durations = content.map((c) => c.estimatedDuration ?? Duration.zero).toList();
    final avgDuration = durations.isEmpty ? const Duration(minutes: 5) :
        Duration(milliseconds: durations.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ durations.length);

    return ContentPreferences(
      topicAffinity: topicAffinity,
      formatPreferences: formatPreferences,
      preferredDuration: avgDuration,
      favoriteVoices: favoriteVoices.toSet().toList(),
      interactivityPreference: totalRating / max(ratingCount, 1),
      difficultyPreference: 0.7, // Default moderate difficulty
    );
  }

  /// Analyze user's engagement patterns
  static EngagementPattern _analyzeEngagementPattern(Map<String, Duration> listeningTimes) {
    final timeOfDayActivity = <String, double>{};
    final dayOfWeekActivity = <String, double>{};
    final dropoffPoints = <String>[];
    
    // For this implementation, we'll use placeholder data
    // In production, this would analyze real timestamp data
    
    double totalDuration = 0.0;
    int sessionCount = listeningTimes.length;
    int completedSessions = 0;

    for (final duration in listeningTimes.values) {
      totalDuration += duration.inSeconds;
      if (duration.inMinutes >= 2) { // Consider 2+ minutes as completed
        completedSessions++;
      }
    }

    final avgSessionDuration = sessionCount > 0 ? totalDuration / sessionCount : 0.0;
    final completionRate = sessionCount > 0 ? completedSessions / sessionCount : 0.0;

    return EngagementPattern(
      timeOfDayActivity: {
        'morning': 0.3,
        'afternoon': 0.4,
        'evening': 0.3,
      },
      dayOfWeekActivity: {
        'monday': 0.15,
        'tuesday': 0.15,
        'wednesday': 0.15,
        'thursday': 0.15,
        'friday': 0.15,
        'saturday': 0.12,
        'sunday': 0.13,
      },
      averageSessionDuration: avgSessionDuration,
      completionRate: completionRate,
      retentionRate: 0.75, // Placeholder
      dropoffPoints: dropoffPoints,
    );
  }

  /// Predict future interests based on past behavior
  static List<String> _predictFutureInterests(
    List<ContentBlock> content,
    Map<String, double> ratings,
  ) {
    final interestMap = <String, double>{};
    
    for (final block in content) {
      final rating = ratings[block.id];
      if (rating != null && rating > 3.5 && block.topic != null) {
        interestMap[block.topic!] = (interestMap[block.topic!] ?? 0.0) + rating;
      }
    }
    
    // Sort by interest score and return top interests
    final sortedInterests = interestMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedInterests.take(10).map((e) => e.key).toList();
  }

  /// Calculate personality scores
  static Map<String, double> _calculatePersonalityScores(
    List<ContentBlock> content,
    Map<String, double> ratings,
  ) {
    // Simplified personality analysis based on Big Five model
    double openness = 0.0;
    double conscientiousness = 0.0;
    double extraversion = 0.0;
    double agreeableness = 0.0;
    double neuroticism = 0.0;

    // Analyze content preferences for personality indicators
    for (final block in content) {
      final rating = ratings[block.id] ?? 0.0;
      
      // Openness to experience
      if (block.category?.toLowerCase().contains('creative') == true ||
          block.category?.toLowerCase().contains('art') == true) {
        openness += rating;
      }
      
      // Conscientiousness
      if (block.category?.toLowerCase().contains('productivity') == true ||
          block.category?.toLowerCase().contains('planning') == true) {
        conscientiousness += rating;
      }
      
      // Extraversion
      if (block.category?.toLowerCase().contains('social') == true ||
          block.category?.toLowerCase().contains('communication') == true) {
        extraversion += rating;
      }
    }

    // Normalize scores (simplified)
    final contentCount = max(content.length, 1);
    return {
      'openness': openness / contentCount / 5.0,
      'conscientiousness': conscientiousness / contentCount / 5.0,
      'extraversion': extraversion / contentCount / 5.0,
      'agreeableness': agreeableness / contentCount / 5.0,
      'neuroticism': neuroticism / contentCount / 5.0,
    };
  }

  /// Calculate confidence score for the profile
  static double _calculateConfidenceScore(int contentCount, int ratingCount) {
    // Confidence increases with more data points
    final dataScore = min(1.0, (contentCount + ratingCount) / 50.0);
    
    // Higher confidence with more ratings
    final ratingScore = min(1.0, ratingCount / 20.0);
    
    return (dataScore + ratingScore) / 2.0;
  }

  /// Generate personalized content recommendations
  static Result<List<ContentRecommendation>> generateRecommendations({
    required String userId,
    required List<ContentBlock> availableContent,
    int limit = 10,
  }) {
    try {
      final profile = _userProfiles[userId];
      if (profile == null) {
        return Result.failure(const PersonalizationException('User profile not found'));
      }

      final recommendations = <ContentRecommendation>[];
      
      for (final content in availableContent) {
        final score = _calculatePersonalizedScore(content, profile);
        
        if (score > 0.3) { // Minimum threshold
          recommendations.add(ContentRecommendation(
            contentId: content.id,
            title: content.title ?? 'Untitled Content',
            category: content.category ?? 'General',
            relevanceScore: score,
            personalizedScore: score,
            reasoning: _generateRecommendationReasoning(content, profile),
          ));
        }
      }

      // Sort by personalized score and limit results
      recommendations.sort((a, b) => b.personalizedScore.compareTo(a.personalizedScore));
      final limitedRecommendations = recommendations.take(limit).toList();

      // Cache recommendations
      _recommendationCache[userId] = limitedRecommendations;

      AppLogger.info('🎯 Generated ${limitedRecommendations.length} recommendations for user: $userId');
      return Result.success(limitedRecommendations);
    } catch (e) {
      AppLogger.error('❌ Failed to generate recommendations: $e');
      return Result.failure(PersonalizationException('Failed to generate recommendations'));
    }
  }

  /// Calculate personalized score for content
  static double _calculatePersonalizedScore(ContentBlock content, UserPersonalityProfile profile) {
    double score = 0.0;
    
    // Topic affinity
    if (content.topic != null) {
      final topicScore = profile.contentPreferences.topicAffinity[content.topic] ?? 0.0;
      score += topicScore * 0.4;
    }
    
    // Format preferences
    final formatScore = profile.contentPreferences.formatPreferences[content.type] ?? 0.0;
    score += formatScore * 0.3;
    
    // Learning style match
    final styleScore = _calculateLearningStyleMatch(content, profile.learningStyle);
    score += styleScore * 0.3;
    
    return min(1.0, score / 3.0); // Normalize to 0-1
  }

  /// Calculate learning style match score
  static double _calculateLearningStyleMatch(ContentBlock content, LearningStyle learningStyle) {
    switch (content.type.toLowerCase()) {
      case 'visual':
      case 'image':
        return learningStyle.visualScore;
      case 'audio':
      case 'speech':
        return learningStyle.auditoryScore;
      case 'interactive':
      case 'exercise':
        return learningStyle.kinestheticScore;
      case 'text':
      case 'reading':
        return learningStyle.readingScore;
      default:
        return 0.5; // Neutral score for unknown types
    }
  }

  /// Generate reasoning for recommendation
  static String _generateRecommendationReasoning(ContentBlock content, UserPersonalityProfile profile) {
    final reasons = <String>[];
    
    if (content.topic != null && 
        profile.contentPreferences.topicAffinity.containsKey(content.topic)) {
      reasons.add('matches your interest in ${content.topic}');
    }
    
    if (profile.contentPreferences.formatPreferences.containsKey(content.type)) {
      reasons.add('${content.type} format aligns with your preferences');
    }
    
    if (content.type.toLowerCase() == profile.learningStyle.primaryStyle) {
      reasons.add('matches your ${profile.learningStyle.primaryStyle} learning style');
    }
    
    return reasons.isEmpty 
        ? 'Recommended based on your learning profile'
        : 'Recommended because it ${reasons.join(' and ')}';
  }

  /// Get cached recommendations
  static List<ContentRecommendation>? getCachedRecommendations(String userId) {
    return _recommendationCache[userId];
  }

  /// Get user profile
  static UserPersonalityProfile? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  /// Update user profile
  static Result<void> updateUserProfile(String userId, UserPersonalityProfile profile) {
    try {
      _userProfiles[userId] = profile;
      AppLogger.info('📝 User profile updated for: $userId');
      return Result.success(null);
    } catch (e) {
      return Result.failure(PersonalizationException('Failed to update user profile'));
    }
  }

  /// Clear user data
  static Result<void> clearUserData(String userId) {
    try {
      _userProfiles.remove(userId);
      _recommendationCache.remove(userId);
      AppLogger.info('🧹 User data cleared for: $userId');
      return Result.success(null);
    } catch (e) {
      return Result.failure(PersonalizationException('Failed to clear user data'));
    }
  }

  /// Get service metrics
  static Map<String, dynamic> getMetrics() {
    return {
      'totalProfiles': _userProfiles.length,
      'cachedRecommendations': _recommendationCache.length,
      'averageConfidence': _userProfiles.values.isEmpty ? 0.0 :
          _userProfiles.values.map((p) => p.confidenceScore).reduce((a, b) => a + b) / _userProfiles.length,
    };
  }

  /// Dispose service
  static void dispose() {
    _userProfiles.clear();
    _recommendationCache.clear();
    AppLogger.info('🧠 Personalization service disposed');
  }
}
