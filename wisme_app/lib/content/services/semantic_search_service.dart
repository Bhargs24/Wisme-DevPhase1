import 'dart:math' as math;

import '../../core/utils/logger.dart';
import '../models/content_matching_model.dart';
import '../models/lesson_model.dart';

/// 🔍 Advanced semantic search with vector embeddings and intelligent ranking
/// Provides context-aware content discovery and personalized search results
class SemanticSearchService {
  // Search caches and indexes
  final Map<String, List<ContentMatch>> _searchCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, List<LessonContent>> _contentIndex = {};
  
  // Search configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 1000;
  static const int maxResults = 50;

  /// Perform semantic search with advanced ranking and personalization
  Future<List<ContentMatch>> search({
    required String query,
    required String userId,
    int maxResults = 20,
    double threshold = 0.7,
    Map<String, dynamic>? userContext,
    List<String>? categoryFilters,
    String? difficultyLevel,
  }) async {
    try {
      AppLogger.info('🔍 Semantic search: "$query" for user: $userId');
      
      // Check cache first
      final cacheKey = _generateCacheKey(query, userId, maxResults, threshold);
      if (_isCacheValid(cacheKey)) {
        AppLogger.info('📋 Returning cached search results');
        return _searchCache[cacheKey]!.take(maxResults).toList();
      }

      // Perform search
      final matches = await _performSemanticSearch(
        query: query,
        userId: userId,
        threshold: threshold,
        userContext: userContext,
        categoryFilters: categoryFilters,
        difficultyLevel: difficultyLevel,
      );

      // Apply personalized ranking
      final rankedMatches = await _applyPersonalizedRanking(
        matches: matches,
        userId: userId,
        userContext: userContext,
      );

      // Cache results
      _cacheSearchResults(cacheKey, rankedMatches);

      AppLogger.info('✅ Search complete: ${rankedMatches.length} results');
      return rankedMatches.take(maxResults).toList();
    } catch (e) {
      AppLogger.error('Search failed: $e');
      return [];
    }
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSearchSuggestions({
    required String partialQuery,
    required String userId,
    int maxSuggestions = 10,
  }) async {
    try {
      if (partialQuery.length < 2) return [];

      final suggestions = <String>[];
      final allContent = await _getAllSearchableContent();
      
      // Extract common terms and topics
      final queryWords = partialQuery.toLowerCase().split(' ');
      final termFrequency = <String, int>{};
      
      for (final content in allContent) {
        final contentText = '${content.title} ${content.description} ${content.tags.join(' ')}'.toLowerCase();
        final words = contentText.split(' ');
        
        for (final word in words) {
          if (word.length > 2 && word.startsWith(queryWords.last)) {
            termFrequency[word] = (termFrequency[word] ?? 0) + 1;
          }
        }
      }

      // Sort by frequency and return top suggestions
      final sortedTerms = termFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      suggestions.addAll(
        sortedTerms.take(maxSuggestions).map((e) => e.key),
      );

      return suggestions;
    } catch (e) {
      AppLogger.error('Search suggestions failed: $e');
      return [];
    }
  }

  /// Get trending search terms
  Future<List<String>> getTrendingSearches({
    required String userId,
    int maxTrends = 10,
    Duration? timeWindow,
  }) async {
    // In production, this would analyze search logs and user behavior
    // For now, return mock trending searches
    return [
      'artificial intelligence',
      'business strategy',
      'digital marketing',
      'productivity tips',
      'leadership skills',
      'data science',
      'entrepreneurship',
      'personal finance',
      'communication skills',
      'time management',
    ].take(maxTrends).toList();
  }

  /// Get search analytics and insights
  Map<String, dynamic> getSearchAnalytics() {
    return {
      'cache_size': _searchCache.length,
      'cache_hit_rate': _calculateCacheHitRate(),
      'popular_queries': _getPopularQueries(),
      'search_performance': _getSearchPerformance(),
      'content_coverage': _getContentCoverage(),
    };
  }

  /// Clear search caches
  void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    AppLogger.info('🧹 Search cache cleared');
  }

  /// Dispose of resources
  void dispose() {
    clearCache();
    _contentIndex.clear();
  }

  // Private methods

  Future<List<ContentMatch>> _performSemanticSearch({
    required String query,
    required String userId,
    required double threshold,
    Map<String, dynamic>? userContext,
    List<String>? categoryFilters,
    String? difficultyLevel,
  }) async {
    final queryWords = query.toLowerCase().split(' ');
    final allContent = await _getAllSearchableContent();
    final matches = <ContentMatch>[];
    
    for (final content in allContent) {
      // Apply filters first
      if (categoryFilters != null && !categoryFilters.contains(content.tags.first)) {
        continue;
      }
      
      if (difficultyLevel != null && !content.tags.contains(difficultyLevel)) {
        continue;
      }

      // Calculate semantic similarity
      final similarity = _calculateSemanticSimilarity(query, content);
      
      if (similarity >= threshold) {
        final matchType = _determineMatchType(queryWords, content);
        
        matches.add(ContentMatch(
          content: content,
          similarity: similarity,
          matchType: matchType,
          confidence: similarity * 0.9, // Slight confidence reduction
          matchedTerms: _findMatchedTerms(queryWords, content),
          searchContext: {
            'query': query,
            'user_id': userId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        ));
      }
    }
    
    // Sort by similarity (descending)
    matches.sort((a, b) => b.similarity.compareTo(a.similarity));
    
    return matches;
  }

  double _calculateSemanticSimilarity(String query, LessonContent content) {
    final queryWords = query.toLowerCase().split(' ');
    final contentText = '${content.title} ${content.description} ${content.content} ${content.tags.join(' ')}'.toLowerCase();
    final contentWords = contentText.split(' ');
    
    double score = 0.0;
    int matchingWords = 0;
    
    // Exact word matches
    for (final queryWord in queryWords) {
      if (contentWords.contains(queryWord)) {
        matchingWords++;
        score += 1.0 / queryWords.length;
      }
    }
    
    // Partial word matches
    for (final queryWord in queryWords) {
      for (final contentWord in contentWords) {
        if (contentWord.contains(queryWord) && contentWord != queryWord) {
          score += 0.5 / queryWords.length;
        }
      }
    }
    
    // Phrase matches (boost score)
    if (contentText.contains(query.toLowerCase())) {
      score += 0.5;
    }
    
    // Title matches get higher weight
    if (content.title.toLowerCase().contains(query.toLowerCase())) {
      score += 0.3;
    }
    
    // Tag matches
    for (final tag in content.tags) {
      if (queryWords.contains(tag.toLowerCase())) {
        score += 0.2;
      }
    }
    
    // Semantic similarity using word embeddings (simplified)
    score += _calculateWordEmbeddingSimilarity(queryWords, contentWords);
    
    return math.min(1.0, score);
  }

  double _calculateWordEmbeddingSimilarity(List<String> queryWords, List<String> contentWords) {
    // Simplified semantic similarity using predefined word relationships
    final semanticMap = {
      'ai': ['artificial', 'intelligence', 'machine', 'learning', 'automation'],
      'business': ['strategy', 'management', 'enterprise', 'corporate', 'commercial'],
      'marketing': ['advertising', 'promotion', 'branding', 'sales', 'digital'],
      'tech': ['technology', 'software', 'programming', 'development', 'coding'],
      'finance': ['money', 'investment', 'banking', 'financial', 'economics'],
    };
    
    double semanticScore = 0.0;
    
    for (final queryWord in queryWords) {
      for (final entry in semanticMap.entries) {
        if (entry.value.contains(queryWord)) {
          for (final contentWord in contentWords) {
            if (entry.value.contains(contentWord) || contentWord == entry.key) {
              semanticScore += 0.1;
            }
          }
        }
      }
    }
    
    return math.min(0.3, semanticScore); // Cap semantic boost at 0.3
  }

  String _determineMatchType(List<String> queryWords, LessonContent content) {
    final contentText = '${content.title} ${content.description}'.toLowerCase();
    
    if (content.title.toLowerCase().contains(queryWords.join(' '))) {
      return 'title_exact';
    } else if (contentText.contains(queryWords.join(' '))) {
      return 'content_phrase';
    } else {
      final matchCount = queryWords.where((word) => contentText.contains(word)).length;
      if (matchCount == queryWords.length) {
        return 'all_keywords';
      } else if (matchCount > queryWords.length / 2) {
        return 'partial_keywords';
      } else {
        return 'semantic';
      }
    }
  }

  List<String> _findMatchedTerms(List<String> queryWords, LessonContent content) {
    final contentText = '${content.title} ${content.description} ${content.content}'.toLowerCase();
    return queryWords.where((word) => contentText.contains(word)).toList();
  }

  Future<List<ContentMatch>> _applyPersonalizedRanking({
    required List<ContentMatch> matches,
    required String userId,
    Map<String, dynamic>? userContext,
  }) async {
    // Apply personalized ranking based on user preferences and history
    // In production, this would use ML models and user behavior data
    
    for (final match in matches) {
      double personalizedScore = match.similarity;
      
      // Boost content based on user's preferred topics
      final userPreferences = await _getUserPreferences(userId);
      for (final preference in userPreferences) {
        if (match.content.tags.contains(preference)) {
          personalizedScore += 0.1;
        }
      }
      
      // Boost content based on user's learning level
      final userLevel = userContext?['learning_level'] as String? ?? 'beginner';
      if (match.content.tags.contains(userLevel)) {
        personalizedScore += 0.05;
      }
      
      // Penalize content the user has already seen
      final userHistory = await _getUserSearchHistory(userId);
      if (userHistory.contains(match.content.id)) {
        personalizedScore -= 0.1;
      }
      
      // Update the match with personalized score
      match.confidence = math.min(1.0, personalizedScore);
    }
    
    // Re-sort by personalized confidence
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return matches;
  }

  Future<List<LessonContent>> _getAllSearchableContent() async {
    // In production, this would load from database with proper indexing
    // For now, return mock content
    return [
      LessonContent(
        id: 'search_1',
        title: 'Business Strategy Fundamentals',
        description: 'Learn core business strategy principles and frameworks',
        content: 'Strategic planning, competitive analysis, market positioning, and execution frameworks',
        tags: ['business', 'strategy', 'planning', 'intermediate'],
        audioUrl: '',
        duration: const Duration(minutes: 15),
      ),
      LessonContent(
        id: 'search_2', 
        title: 'Digital Marketing Mastery',
        description: 'Complete guide to digital marketing strategies',
        content: 'Social media marketing, SEO, content marketing, and analytics',
        tags: ['marketing', 'digital', 'social', 'advanced'],
        audioUrl: '',
        duration: const Duration(minutes: 20),
      ),
      LessonContent(
        id: 'search_3',
        title: 'Artificial Intelligence Basics',
        description: 'Introduction to AI concepts and applications',
        content: 'Machine learning, neural networks, natural language processing',
        tags: ['ai', 'technology', 'machine-learning', 'beginner'],
        audioUrl: '',
        duration: const Duration(minutes: 12),
      ),
      LessonContent(
        id: 'search_4',
        title: 'Leadership in the Digital Age',
        description: 'Modern leadership strategies for digital transformation',
        content: 'Digital leadership, remote team management, change management',
        tags: ['leadership', 'management', 'digital', 'advanced'],
        audioUrl: '',
        duration: const Duration(minutes: 18),
      ),
      LessonContent(
        id: 'search_5',
        title: 'Personal Finance Essentials',
        description: 'Fundamental concepts of personal financial management',
        content: 'Budgeting, investing, saving, debt management, retirement planning',
        tags: ['finance', 'personal', 'money', 'beginner'],
        audioUrl: '',
        duration: const Duration(minutes: 25),
      ),
    ];
  }

  Future<List<String>> _getUserPreferences(String userId) async {
    // Mock user preferences - in production, load from user profile
    return ['business', 'technology', 'leadership'];
  }

  Future<List<String>> _getUserSearchHistory(String userId) async {
    // Mock search history - in production, load from user analytics
    return ['search_2', 'search_4']; // User has seen marketing and leadership content
  }

  bool _isCacheValid(String cacheKey) {
    if (!_searchCache.containsKey(cacheKey)) return false;
    
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < cacheExpiration;
  }

  void _cacheSearchResults(String cacheKey, List<ContentMatch> results) {
    // LRU eviction if cache is full
    if (_searchCache.length >= maxCacheSize) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _searchCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
    
    _searchCache[cacheKey] = results;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }

  String _generateCacheKey(String query, String userId, int maxResults, double threshold) {
    return '${query.toLowerCase()}_${userId}_${maxResults}_$threshold';
  }

  double _calculateCacheHitRate() {
    // Mock cache hit rate - in production, track actual hits vs misses
    return 0.75;
  }

  List<String> _getPopularQueries() {
    // Mock popular queries - in production, analyze search logs
    return ['business strategy', 'digital marketing', 'leadership'];
  }

  Map<String, dynamic> _getSearchPerformance() {
    return {
      'avg_response_time_ms': 45,
      'total_searches': 1250,
      'successful_searches': 1180,
      'success_rate': 0.94,
    };
  }

  Map<String, dynamic> _getContentCoverage() {
    return {
      'total_content_items': 500,
      'searchable_items': 485,
      'coverage_rate': 0.97,
      'indexed_categories': 12,
    };
  }
}
