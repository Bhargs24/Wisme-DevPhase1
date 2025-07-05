import 'dart:math' as math;

import '../../core/utils/logger.dart';
import '../../analytics/models/business_intelligence_model.dart';

/// 🎯 Advanced personalization engine with ML-powered recommendations
/// Provides intelligent content recommendations and user behavior analysis
class PersonalizationEngineService {
  // User behavior tracking
  final Map<String, List<UserInteraction>> _userInteractions = {};
  final Map<String, UserProfile> _userProfiles = {};
  final Map<String, List<ContentRecommendation>> _recommendationCache = {};
  
  // ML model state (simplified for this implementation)
  final Map<String, Map<String, double>> _userContentAffinity = {};
  final Map<String, Map<String, double>> _contentSimilarity = {};
  
  static const int maxInteractionsPerUser = 1000;
  static const int maxRecommendations = 50;
  static const Duration cacheExpiration = Duration(hours: 2);

  /// Get personalized content recommendations for a user
  Future<List<ContentRecommendation>> getPersonalizedRecommendations({
    required String userId,
    int count = 10,
    String? category,
    bool includeNovelty = true,
    Map<String, dynamic>? context,
  }) async {
    try {
      AppLogger.info('🎯 Generating personalized recommendations for user: $userId');
      
      // Check cache first
      final cacheKey = '${userId}_${category ?? 'all'}_$count';
      if (_recommendationCache.containsKey(cacheKey)) {
        final cached = _recommendationCache[cacheKey]!;
        if (cached.isNotEmpty && _isCacheValid(cached.first)) {
          AppLogger.info('📋 Returning cached recommendations');
          return cached.take(count).toList();
        }
      }

      // Get user profile and interactions
      final userProfile = await _getUserProfile(userId);
      final userInteractions = _userInteractions[userId] ?? [];
      
      // Generate recommendations using multiple algorithms
      final recommendations = <ContentRecommendation>[];
      
      // 1. Collaborative filtering recommendations
      final collaborativeRecs = await _generateCollaborativeRecommendations(
        userId: userId,
        userProfile: userProfile,
        count: (count * 0.4).round(),
        category: category,
      );
      recommendations.addAll(collaborativeRecs);
      
      // 2. Content-based recommendations
      final contentBasedRecs = await _generateContentBasedRecommendations(
        userId: userId,
        userInteractions: userInteractions,
        count: (count * 0.4).round(),
        category: category,
      );
      recommendations.addAll(contentBasedRecs);
      
      // 3. Novelty and exploration recommendations
      if (includeNovelty) {
        final noveltyRecs = await _generateNoveltyRecommendations(
          userId: userId,
          userProfile: userProfile,
          count: (count * 0.2).round(),
          category: category,
        );
        recommendations.addAll(noveltyRecs);
      }
      
      // 4. Context-aware adjustments
      if (context != null) {
        await _applyContextualAdjustments(recommendations, context);
      }
      
      // 5. Diversity and ranking optimization
      final optimizedRecs = _optimizeRecommendationDiversity(recommendations, count);
      
      // Cache results
      _recommendationCache[cacheKey] = optimizedRecs;
      
      AppLogger.info('✅ Generated ${optimizedRecs.length} personalized recommendations');
      return optimizedRecs;
    } catch (e) {
      AppLogger.error('Personalization failed for user $userId: $e');
      return [];
    }
  }

  /// Track user interaction for learning and optimization
  Future<void> trackInteraction({
    required String userId,
    required String contentId,
    required UserInteractionType interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final interaction = UserInteraction(
        id: 'interaction_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        contentId: contentId,
        interactionType: interactionType,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );
      
      // Store interaction
      _userInteractions.putIfAbsent(userId, () => []).add(interaction);
      
      // Maintain interaction history limit
      final userInteractions = _userInteractions[userId]!;
      if (userInteractions.length > maxInteractionsPerUser) {
        userInteractions.removeAt(0); // Remove oldest
      }
      
      // Update user profile
      await _updateUserProfile(userId, interaction);
      
      // Update ML models
      await _updateRecommendationModels(userId, interaction);
      
      // Clear related caches
      _clearUserCache(userId);
      
      AppLogger.info('📊 Tracked interaction: $userId -> $contentId ($interactionType)');
    } catch (e) {
      AppLogger.error('Failed to track interaction: $e');
    }
  }

  /// Get user learning insights and preferences
  Future<Map<String, dynamic>> getUserInsights(String userId) async {
    final userProfile = await _getUserProfile(userId);
    final interactions = _userInteractions[userId] ?? [];
    
    return {
      'learning_preferences': userProfile.preferences,
      'interaction_count': interactions.length,
      'favorite_categories': _analyzeFavoriteCategories(interactions),
      'learning_velocity': _calculateLearningVelocity(interactions),
      'engagement_score': _calculateEngagementScore(interactions),
      'content_diversity': _analyzeContentDiversity(interactions),
      'optimal_session_length': _calculateOptimalSessionLength(interactions),
      'peak_learning_times': _analyzePeakLearningTimes(interactions),
    };
  }

  /// Update user preferences and learning goals
  Future<void> updateUserPreferences({
    required String userId,
    Map<String, dynamic>? preferences,
    List<String>? interests,
    String? learningStyle,
    Map<String, dynamic>? goals,
  }) async {
    final userProfile = await _getUserProfile(userId);
    
    final updatedProfile = userProfile.copyWith(
      preferences: preferences ?? userProfile.preferences,
      interests: interests ?? userProfile.interests,
      learningStyle: learningStyle ?? userProfile.learningStyle,
      goals: goals ?? userProfile.goals,
      updatedAt: DateTime.now(),
    );
    
    _userProfiles[userId] = updatedProfile;
    _clearUserCache(userId);
    
    AppLogger.info('👤 Updated preferences for user: $userId');
  }

  /// Get personalization analytics and model performance
  Map<String, dynamic> getPersonalizationAnalytics() {
    return {
      'total_users': _userProfiles.length,
      'total_interactions': _getTotalInteractions(),
      'recommendation_cache_size': _recommendationCache.length,
      'model_accuracy': _calculateModelAccuracy(),
      'user_engagement_distribution': _getUserEngagementDistribution(),
      'content_popularity': _getContentPopularity(),
      'recommendation_diversity': _getRecommendationDiversity(),
    };
  }

  /// Clear all caches and reset models
  void clearCache() {
    _recommendationCache.clear();
    AppLogger.info('🧹 Personalization cache cleared');
  }

  /// Dispose of resources
  void dispose() {
    _userInteractions.clear();
    _userProfiles.clear();
    _recommendationCache.clear();
    _userContentAffinity.clear();
    _contentSimilarity.clear();
  }

  // Private methods

  Future<List<ContentRecommendation>> _generateCollaborativeRecommendations({
    required String userId,
    required UserProfile userProfile,
    required int count,
    String? category,
  }) async {
    // Find similar users based on interaction patterns
    final similarUsers = await _findSimilarUsers(userId);
    final recommendations = <ContentRecommendation>[];
    
    for (final similarUserId in similarUsers.take(10)) {
      final similarUserInteractions = _userInteractions[similarUserId] ?? [];
      
      for (final interaction in similarUserInteractions) {
        if (interaction.interactionType == UserInteractionType.rate ||
            interaction.interactionType == UserInteractionType.like ||
            interaction.interactionType == UserInteractionType.complete) {
          
          // Check if user hasn't seen this content
          final userHasSeen = _userInteractions[userId]
              ?.any((i) => i.contentId == interaction.contentId) ?? false;
          
          if (!userHasSeen) {
            recommendations.add(ContentRecommendation(
              id: 'collab_${interaction.contentId}',
              contentId: interaction.contentId,
              score: 0.8 + (math.Random().nextDouble() * 0.2),
              reason: 'Users with similar interests enjoyed this content',
              algorithm: 'collaborative_filtering',
              features: {
                'similar_user_id': similarUserId,
                'interaction_type': interaction.interactionType.toString(),
              },
            ));
          }
        }
      }
    }
    
    return recommendations.take(count).toList();
  }

  Future<List<ContentRecommendation>> _generateContentBasedRecommendations({
    required String userId,
    required List<UserInteraction> userInteractions,
    required int count,
    String? category,
  }) async {
    final recommendations = <ContentRecommendation>[];
    
    // Analyze user's content preferences
    final contentAffinity = _userContentAffinity[userId] ?? {};
    
    // Generate recommendations based on content similarity
    for (final interaction in userInteractions.where((i) => 
        i.interactionType == UserInteractionType.rate ||
        i.interactionType == UserInteractionType.like ||
        i.interactionType == UserInteractionType.complete)) {
      
      final similarContent = _findSimilarContent(interaction.contentId);
      
      for (final similarContentId in similarContent.take(3)) {
        // Check if user hasn't seen this content
        final userHasSeen = userInteractions
            .any((i) => i.contentId == similarContentId);
        
        if (!userHasSeen) {
          final affinityScore = contentAffinity[similarContentId] ?? 0.5;
          
          recommendations.add(ContentRecommendation(
            id: 'content_$similarContentId',
            contentId: similarContentId,
            score: 0.7 + (affinityScore * 0.3),
            reason: 'Similar to content you\'ve enjoyed',
            algorithm: 'content_based',
            features: {
              'source_content_id': interaction.contentId,
              'affinity_score': affinityScore,
            },
          ));
        }
      }
    }
    
    return recommendations.take(count).toList();
  }

  Future<List<ContentRecommendation>> _generateNoveltyRecommendations({
    required String userId,
    required UserProfile userProfile,
    required int count,
    String? category,
  }) async {
    final recommendations = <ContentRecommendation>[];
    
    // Find content in unexplored categories
    final userCategories = _getUserCategories(userId);
    final allCategories = ['business', 'technology', 'science', 'arts', 'health'];
    final unexploredCategories = allCategories
        .where((cat) => !userCategories.contains(cat))
        .toList();
    
    for (final category in unexploredCategories.take(3)) {
      // Get popular content in this category
      final popularContent = _getPopularContentInCategory(category);
      
      for (final contentId in popularContent.take(2)) {
        recommendations.add(ContentRecommendation(
          id: 'novelty_$contentId',
          contentId: contentId,
          score: 0.6 + (math.Random().nextDouble() * 0.2),
          reason: 'Explore new topics in $category',
          algorithm: 'novelty_exploration',
          features: {
            'category': category,
            'exploration_type': 'category_diversification',
          },
        ));
      }
    }
    
    return recommendations.take(count).toList();
  }

  Future<void> _applyContextualAdjustments(
    List<ContentRecommendation> recommendations,
    Map<String, dynamic> context,
  ) async {
    final timeOfDay = context['time_of_day'] as String?;
    final sessionDuration = context['session_duration'] as Duration?;
    final device = context['device'] as String?;
    
    for (final rec in recommendations) {
      double adjustment = 0.0;
      
      // Time-based adjustments
      if (timeOfDay == 'morning') {
        if (rec.features['category'] == 'productivity') {
          adjustment += 0.1;
        }
      } else if (timeOfDay == 'evening') {
        if (rec.features['category'] == 'relaxation') {
          adjustment += 0.1;
        }
      }
      
      // Session duration adjustments
      if (sessionDuration != null) {
        if (sessionDuration.inMinutes < 10) {
          // Prefer shorter content
          if (rec.features['estimated_duration_minutes'] as int? ?? 15 < 10) {
            adjustment += 0.05;
          }
        }
      }
      
      // Apply adjustment
      rec.score = math.min(1.0, rec.score + adjustment);
    }
  }

  List<ContentRecommendation> _optimizeRecommendationDiversity(
    List<ContentRecommendation> recommendations,
    int targetCount,
  ) {
    // Sort by score first
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    
    // Apply diversity optimization
    final diversified = <ContentRecommendation>[];
    final usedCategories = <String>{};
    final usedAlgorithms = <String>{};
    
    for (final rec in recommendations) {
      if (diversified.length >= targetCount) break;
      
      final category = rec.features['category'] as String? ?? 'unknown';
      final algorithm = rec.algorithm;
      
      // Ensure diversity in categories and algorithms
      if (diversified.length < targetCount * 0.7 || // First 70% can be any
          (!usedCategories.contains(category) && usedCategories.length < 5) ||
          (!usedAlgorithms.contains(algorithm) && usedAlgorithms.length < 3)) {
        
        diversified.add(rec);
        usedCategories.add(category);
        usedAlgorithms.add(algorithm);
      }
    }
    
    // Fill remaining slots with highest scoring content
    for (final rec in recommendations) {
      if (diversified.length >= targetCount) break;
      if (!diversified.contains(rec)) {
        diversified.add(rec);
      }
    }
    
    return diversified.take(targetCount).toList();
  }

  Future<UserProfile> _getUserProfile(String userId) async {
    if (_userProfiles.containsKey(userId)) {
      return _userProfiles[userId]!;
    }
    
    // Create default profile for new user
    final profile = UserProfile(
      id: userId,
      userId: userId,
      preferences: {},
      interests: [],
      learningStyle: 'adaptive',
      goals: {},
    );
    
    _userProfiles[userId] = profile;
    return profile;
  }

  Future<void> _updateUserProfile(String userId, UserInteraction interaction) async {
    final profile = await _getUserProfile(userId);
    
    // Update interests based on content
    final contentCategory = _getContentCategory(interaction.contentId);
    if (contentCategory != null && !profile.interests.contains(contentCategory)) {
      profile.interests.add(contentCategory);
    }
    
    // Update preferences based on interaction type
    if (interaction.interactionType == UserInteractionType.rate) {
      final rating = interaction.metadata['rating'] as double? ?? 3.0;
      if (rating >= 4.0) {
        profile.preferences[contentCategory ?? 'general'] = 
            (profile.preferences[contentCategory ?? 'general'] as double? ?? 0.5) + 0.1;
      }
    }
    
    profile.updatedAt = DateTime.now();
  }

  Future<void> _updateRecommendationModels(String userId, UserInteraction interaction) async {
    // Update user-content affinity matrix
    final userAffinity = _userContentAffinity.putIfAbsent(userId, () => {});
    
    double weight = 0.1;
    switch (interaction.interactionType) {
      case UserInteractionType.like:
        weight = 0.3;
        break;
      case UserInteractionType.rate:
        final rating = interaction.metadata['rating'] as double? ?? 3.0;
        weight = (rating - 2.5) / 5.0; // Convert 1-5 rating to weight
        break;
      case UserInteractionType.complete:
        weight = 0.2;
        break;
      case UserInteractionType.skip:
        weight = -0.1;
        break;
      default:
        weight = 0.05;
    }
    
    userAffinity[interaction.contentId] = 
        (userAffinity[interaction.contentId] ?? 0.0) + weight;
    
    // Ensure values stay within reasonable bounds
    userAffinity[interaction.contentId] = 
        math.max(-1.0, math.min(1.0, userAffinity[interaction.contentId]!));
  }

  List<String> _findSimilarUsers(String userId) {
    // Simplified user similarity based on content affinity
    final userAffinity = _userContentAffinity[userId] ?? {};
    final similarities = <String, double>{};
    
    for (final otherUserId in _userContentAffinity.keys) {
      if (otherUserId == userId) continue;
      
      final otherAffinity = _userContentAffinity[otherUserId]!;
      double similarity = 0.0;
      int commonItems = 0;
      
      for (final contentId in userAffinity.keys) {
        if (otherAffinity.containsKey(contentId)) {
          similarity += 1.0 - (userAffinity[contentId]! - otherAffinity[contentId]!).abs();
          commonItems++;
        }
      }
      
      if (commonItems > 0) {
        similarities[otherUserId] = similarity / commonItems;
      }
    }
    
    final sortedUsers = similarities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedUsers.map((e) => e.key).toList();
  }

  List<String> _findSimilarContent(String contentId) {
    // Mock content similarity - in production, use actual content vectors
    final mockSimilarity = {
      'business_1': ['business_2', 'business_3', 'leadership_1'],
      'tech_1': ['tech_2', 'ai_1', 'programming_1'],
      'marketing_1': ['marketing_2', 'business_1', 'social_1'],
    };
    
    return mockSimilarity[contentId] ?? [];
  }

  bool _isCacheValid(ContentRecommendation recommendation) {
    final createdAt = recommendation.createdAt;
    if (createdAt == null) return false;
    
    return DateTime.now().difference(createdAt) < cacheExpiration;
  }

  void _clearUserCache(String userId) {
    _recommendationCache.removeWhere((key, value) => key.startsWith(userId));
  }

  // Analytics and insights methods

  List<String> _analyzeFavoriteCategories(List<UserInteraction> interactions) {
    final categoryCounts = <String, int>{};
    
    for (final interaction in interactions) {
      final category = _getContentCategory(interaction.contentId) ?? 'unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.take(5).map((e) => e.key).toList();
  }

  double _calculateLearningVelocity(List<UserInteraction> interactions) {
    if (interactions.length < 2) return 0.0;
    
    final completions = interactions
        .where((i) => i.interactionType == UserInteractionType.complete)
        .toList();
    
    if (completions.length < 2) return 0.0;
    
    final timeSpan = completions.last.timestamp.difference(completions.first.timestamp);
    return completions.length / timeSpan.inDays.clamp(1, 365);
  }

  double _calculateEngagementScore(List<UserInteraction> interactions) {
    if (interactions.isEmpty) return 0.0;
    
    double score = 0.0;
    for (final interaction in interactions) {
      switch (interaction.interactionType) {
        case UserInteractionType.complete:
          score += 1.0;
          break;
        case UserInteractionType.like:
        case UserInteractionType.rate:
          score += 0.5;
          break;
        case UserInteractionType.bookmark:
        case UserInteractionType.share:
          score += 0.3;
          break;
        default:
          score += 0.1;
      }
    }
    
    return score / interactions.length;
  }

  double _analyzeContentDiversity(List<UserInteraction> interactions) {
    final categories = interactions
        .map((i) => _getContentCategory(i.contentId))
        .where((cat) => cat != null)
        .toSet();
    
    return categories.length / 10.0; // Assuming 10 total categories
  }

  Duration _calculateOptimalSessionLength(List<UserInteraction> interactions) {
    // Analyze session patterns to determine optimal length
    // Mock implementation
    return const Duration(minutes: 15);
  }

  List<String> _analyzePeakLearningTimes(List<UserInteraction> interactions) {
    final hourCounts = <int, int>{};
    
    for (final interaction in interactions) {
      final hour = interaction.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedHours.take(3).map((e) => '${e.key}:00').toList();
  }

  String? _getContentCategory(String contentId) {
    // Mock content category mapping
    if (contentId.startsWith('business')) return 'business';
    if (contentId.startsWith('tech')) return 'technology';
    if (contentId.startsWith('marketing')) return 'marketing';
    if (contentId.startsWith('ai')) return 'artificial_intelligence';
    return null;
  }

  List<String> _getUserCategories(String userId) {
    final interactions = _userInteractions[userId] ?? [];
    return interactions
        .map((i) => _getContentCategory(i.contentId))
        .where((cat) => cat != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  List<String> _getPopularContentInCategory(String category) {
    // Mock popular content by category
    final popular = {
      'business': ['business_1', 'business_2', 'business_3'],
      'technology': ['tech_1', 'tech_2', 'ai_1'],
      'science': ['science_1', 'science_2'],
      'arts': ['art_1', 'music_1'],
      'health': ['fitness_1', 'nutrition_1'],
    };
    
    return popular[category] ?? [];
  }

  int _getTotalInteractions() {
    return _userInteractions.values.fold(0, (sum, interactions) => sum + interactions.length);
  }

  double _calculateModelAccuracy() {
    // Mock model accuracy - in production, measure against actual user behavior
    return 0.78;
  }

  Map<String, int> _getUserEngagementDistribution() {
    final distribution = <String, int>{
      'high': 0,
      'medium': 0,
      'low': 0,
    };
    
    for (final interactions in _userInteractions.values) {
      final engagementScore = _calculateEngagementScore(interactions);
      if (engagementScore > 0.7) {
        distribution['high'] = distribution['high']! + 1;
      } else if (engagementScore > 0.3) {
        distribution['medium'] = distribution['medium']! + 1;
      } else {
        distribution['low'] = distribution['low']! + 1;
      }
    }
    
    return distribution;
  }

  Map<String, int> _getContentPopularity() {
    final popularity = <String, int>{};
    
    for (final interactions in _userInteractions.values) {
      for (final interaction in interactions) {
        popularity[interaction.contentId] = (popularity[interaction.contentId] ?? 0) + 1;
      }
    }
    
    return popularity;
  }

  double _getRecommendationDiversity() {
    // Calculate average diversity across all cached recommendations
    double totalDiversity = 0.0;
    int count = 0;
    
    for (final recommendations in _recommendationCache.values) {
      final categories = recommendations
          .map((r) => r.features['category'] as String? ?? 'unknown')
          .toSet();
      totalDiversity += categories.length / recommendations.length;
      count++;
    }
    
    return count > 0 ? totalDiversity / count : 0.0;
  }
}

// Supporting data classes

class UserProfile {
  final String id;
  final String userId;
  Map<String, dynamic> preferences;
  List<String> interests;
  String learningStyle;
  Map<String, dynamic> goals;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.preferences = const {},
    this.interests = const [],
    this.learningStyle = 'adaptive',
    this.goals = const {},
    this.createdAt,
    this.updatedAt,
  }) {
    createdAt ??= DateTime.now();
    updatedAt ??= DateTime.now();
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    Map<String, dynamic>? preferences,
    List<String>? interests,
    String? learningStyle,
    Map<String, dynamic>? goals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserProfile(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        preferences: preferences ?? this.preferences,
        interests: interests ?? this.interests,
        learningStyle: learningStyle ?? this.learningStyle,
        goals: goals ?? this.goals,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class UserInteraction {
  final String id;
  final String userId;
  final String contentId;
  final UserInteractionType interactionType;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  UserInteraction({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.interactionType,
    required this.timestamp,
    this.metadata = const {},
  });
}
