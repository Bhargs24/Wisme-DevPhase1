/// Data models for user personalization and adaptive learning
library;

/// User's learning style preferences
enum LearningStyle { 
  quickLearner, 
  deepThinker, 
  storyLearner, 
  balanced 
}

/// User engagement patterns
enum EngagementPattern { 
  newUser, 
  casual, 
  regular, 
  explorer, 
  powerUser 
}

/// User's content preferences based on historical data
class ContentPreferences {
  final List<String> preferredCategories;
  final List<String> preferredFormats;
  final double averageRating;
  final double contentDiversity;

  ContentPreferences({
    required this.preferredCategories,
    required this.preferredFormats,
    required this.averageRating,
    required this.contentDiversity,
  });

  factory ContentPreferences.defaultPreferences() {
    return ContentPreferences(
      preferredCategories: ['Technology'],
      preferredFormats: ['concept'],
      averageRating: 3.0,
      contentDiversity: 1.0,
    );
  }
}

/// Comprehensive user personality profile for personalization
class UserPersonalityProfile {
  final String userId;
  final LearningStyle learningStyle;
  final ContentPreferences contentPreferences;
  final EngagementPattern engagementPattern;
  final List<String> predictedInterests;
  final Map<String, double> personalityScores;
  final DateTime lastUpdated;
  final double confidenceScore;

  UserPersonalityProfile({
    required this.userId,
    required this.learningStyle,
    required this.contentPreferences,
    required this.engagementPattern,
    required this.predictedInterests,
    required this.personalityScores,
    required this.lastUpdated,
    required this.confidenceScore,
  });

  factory UserPersonalityProfile.defaultProfile(String userId) {
    return UserPersonalityProfile(
      userId: userId,
      learningStyle: LearningStyle.balanced,
      contentPreferences: ContentPreferences.defaultPreferences(),
      engagementPattern: EngagementPattern.newUser,
      predictedInterests: [],
      personalityScores: {},
      lastUpdated: DateTime.now(),
      confidenceScore: 0.0,
    );
  }
}

