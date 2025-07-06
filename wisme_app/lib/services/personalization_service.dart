/// User Personalization Service
/// 
/// Analyzes user behavior and learning patterns to create personalized
/// learning experiences through data-driven insights.
library;

import 'dart:math';
import '../models/lesson_model.dart';
import '../models/personalization_model.dart';
import '../utils/logger.dart';

/// Service for analyzing user behavior and generating personality profiles
class PersonalizationService {
  static final Map<String, UserPersonalityProfile> _userProfiles = {};

  /// Generate user personality profile from behavior data
  static UserPersonalityProfile generateUserProfile({
    required String userId,
    required List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model> consumedContent,
    required Map<String, double> ratings,
    required Map<String, Duration> listeningTimes,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      AppLogger.info('Generating user profile for: $userId');

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
      
      AppLogger.info('Generated personality profile with ${profile.confidenceScore.toStringAsFixed(2)} confidence');
      return profile;
    } catch (e) {
      AppLogger.error('Personality profiling failed: $e');
      return UserPersonalityProfile.defaultProfile(userId);
    }
  }

  static LearningStyle _analyzeLearningStyle(List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model> content, Map<String, Duration> times) {
    final avgDuration = times.values.isEmpty ? 0 : 
        times.values.map((d) => d.inMinutes).reduce((a, b) => a + b) / times.length;
    
    final hasStoryPreference = content.where((c) => c.contentType.contains('story')).length > content.length * 0.4;
    final hasConceptPreference = content.where((c) => c.contentType.contains('concept')).length > content.length * 0.4;
    
    if (avgDuration > 15 && hasConceptPreference) return LearningStyle.deepThinker;
    if (avgDuration < 5) return LearningStyle.quickLearner;
    if (hasStoryPreference) return LearningStyle.storyLearner;
    return LearningStyle.balanced;
  }

  static ContentPreferences _analyzeContentPreferences(List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model> content, Map<String, double> ratings) {
    final categoryScores = <String, double>{};
    final formatScores = <String, double>{};
    
    for (final block in content) {
      final rating = ratings[block.id] ?? 3.0;
      categoryScores[block.category] = (categoryScores[block.category] ?? 0) + rating;
      formatScores[block.contentType] = (formatScores[block.contentType] ?? 0) + rating;
    }

    return ContentPreferences(
      preferredCategories: _getTopKeys(categoryScores, 3),
      preferredFormats: _getTopKeys(formatScores, 2),
      averageRating: ratings.values.isEmpty ? 3.0 : ratings.values.reduce((a, b) => a + b) / ratings.length,
      contentDiversity: categoryScores.length.toDouble(),
    );
  }

  static EngagementPattern _analyzeEngagementPattern(Map<String, Duration> times) {
    if (times.isEmpty) return EngagementPattern.newUser;
    
    final avgSession = times.values.map((d) => d.inMinutes).reduce((a, b) => a + b) / times.length;
    final sessionCount = times.length;
    
    if (sessionCount > 50 && avgSession > 20) return EngagementPattern.powerUser;
    if (sessionCount > 20 && avgSession > 10) return EngagementPattern.regular;
    if (avgSession < 5) return EngagementPattern.casual;
    return EngagementPattern.explorer;
  }

  static List<String> _predictFutureInterests(List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model> content, Map<String, double> ratings) {
    final interests = <String>[];
    final topRatedContent = content.where((c) => (ratings[c.id] ?? 0) >= 4.0).toList();
    
    for (final block in topRatedContent) {
      interests.addAll(block.category.split(' '));
      if (block.contentType.contains('story')) interests.add('storytelling');
      if (block.difficulty == 'advanced') interests.add('advanced_topics');
    }
    
    return interests.toSet().take(10).toList();
  }

  static Map<String, double> _calculatePersonalityScores(List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model> content, Map<String, double> ratings) {
    final scores = <String, double>{
      'curiosity': 0.5,
      'patience': 0.5,
      'analytical': 0.5,
      'creative': 0.5,
      'social': 0.5,
    };

    // Analyze curiosity (variety of topics)
    final uniqueCategories = content.map((c) => c.category).toSet().length;
    scores['curiosity'] = min(1.0, uniqueCategories / 10.0);

    // Analyze patience (long content preference)
    final avgContentLength = content.isEmpty ? 0 : 
        content.map((c) => c.duration.inMinutes).reduce((a, b) => a + b) / content.length;
    scores['patience'] = min(1.0, avgContentLength / 30.0);

    // Analyze analytical thinking (technical content preference)
    final techContent = content.where((c) => 
        c.category.toLowerCase().contains('technology') || 
        c.category.toLowerCase().contains('science')).length;
    scores['analytical'] = min(1.0, techContent / max(1, content.length));

    return scores;
  }

  static double _calculateConfidenceScore(int contentCount, int ratingCount) {
    if (contentCount == 0) return 0.0;
    return min(1.0, (contentCount * 0.1 + ratingCount * 0.2) / 10.0);
  }

  static List<String> _getTopKeys(Map<String, double> scores, int count) {
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(count).map((e) => e.key).toList();
  }

  /// Get cached user profile
  static UserPersonalityProfile? getUserProfile(String userId) {
    return _userProfiles[userId];
  }
}


