import '../core/exports.dart';
import 'dart:math' as math;
class ContentReuseService {
  final FirestoreService _firestoreService;
  
  // High-performance in-memory cache
  final Map<String, ContentBlock> _contentCache = {};
  final Map<String, ContentTags> _tagsCache = {};
  final Map<String, double> _popularityScores = {};
  final Map<String, DateTime> _accessHistory = {};
  
  static const int maxCacheSize = 1000;
  static const double freshnessDecayDays = 30.0;

  ContentReuseService({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Find and rank reusable content with advanced scoring
  Future<List<RankedContentMatch>> findRankedMatches({
    required ContentTags searchTags,
    required String userId,
    required List<String> excludeIds,
    int maxResults = 10,
    double minimumSimilarity = 0.6,
  }) async {
    try {
      AppLogger.info('🔍 Finding ranked content matches for user: $userId');
      
      // Get all available content
      final allContent = await _getAllCachedContent();
      final userHistory = await _getUserHistory(userId);
      
      final matches = <RankedContentMatch>[];
      
      for (final content in allContent) {
        if (excludeIds.contains(content.id)) continue;
        if (userHistory.contains(content.id)) continue; // Skip recently played
        
        // Get content tags
        final contentTags = await _getContentTags(content.id);
        if (contentTags == null) continue;
        
        // Calculate multiple ranking factors
        final semanticScore = _calculateSemanticSimilarity(searchTags, contentTags);
        if (semanticScore < minimumSimilarity) continue;
        
        final popularityScore = _calculatePopularityScore(content.id);
        final freshnessScore = _calculateFreshnessScore(content.createdAt);
        final diversityScore = _calculateDiversityScore(content, matches);
        final qualityScore = _calculateQualityScore(content);
        
        // Advanced weighted ranking algorithm
        final totalScore = _calculateAdvancedRanking(
          semantic: semanticScore,
          popularity: popularityScore,
          freshness: freshnessScore,
          diversity: diversityScore,
          quality: qualityScore,
        );
        
        matches.add(RankedContentMatch(
          content: content,
          tags: contentTags,
          semanticScore: semanticScore,
          popularityScore: popularityScore,
          freshnessScore: freshnessScore,
          diversityScore: diversityScore,
          qualityScore: qualityScore,
          totalScore: totalScore,
          matchReason: _generateMatchReason(searchTags, contentTags),
        ));
      }
      
      // Sort by total score and return top results
      matches.sort((a, b) => b.totalScore.compareTo(a.totalScore));
      final topMatches = matches.take(maxResults).toList();
      
      AppLogger.info('🎯 Found ${topMatches.length} ranked matches (best: ${topMatches.isNotEmpty ? (topMatches.first.totalScore * 100).toStringAsFixed(1) : 0}%)');
      
      return topMatches;
    } catch (e) {
      AppLogger.error('Failed to find ranked matches: $e');
      return [];
    }
  }

  /// Assemble optimal content mix from ranked matches
  Future<ContentAssemblyResult> assembleOptimalContent({
    required List<RankedContentMatch> rankedMatches,
    required Duration targetDuration,
    required String assemblyStrategy,
  }) async {
    try {
      AppLogger.info('🔧 Assembling optimal content from ${rankedMatches.length} matches');
      
      switch (assemblyStrategy) {
        case 'single_best':
          return _assembleSingleBest(rankedMatches, targetDuration);
        case 'multi_segment':
          return _assembleMultiSegment(rankedMatches, targetDuration);
        case 'hybrid_reuse':
          return _assembleHybridReuse(rankedMatches, targetDuration);
        default:
          return _assembleAdaptive(rankedMatches, targetDuration);
      }
    } catch (e) {
      AppLogger.error('Failed to assemble optimal content: $e');
      return ContentAssemblyResult(
        strategy: 'error',
        contentIds: [],
        estimatedDuration: Duration.zero,
        reuseRate: 0.0,
        confidenceScore: 0.0,
      );
    }
  }

  /// Track content usage for popularity scoring
  void trackContentUsage(String contentId, {
    double? userRating,
    Duration? actualListeningTime,
    bool wasSkipped = false,
  }) {
    // Update popularity score
    final currentScore = _popularityScores[contentId] ?? 0.0;
    double scoreChange = 0.1; // Base usage boost
    
    if (userRating != null) {
      scoreChange += (userRating - 3.0) * 0.2; // Rating impact
    }
    
    if (wasSkipped) {
      scoreChange -= 0.3; // Penalty for skipping
    }
    
    if (actualListeningTime != null) {
      // Boost based on completion rate (assuming 10 min average)
      final completionRate = actualListeningTime.inMinutes / 10.0;
      scoreChange += completionRate * 0.2;
    }
    
    _popularityScores[contentId] = math.max(0.0, currentScore + scoreChange);
    _accessHistory[contentId] = DateTime.now();
    
    AppLogger.info('📊 Updated popularity score for $contentId: ${_popularityScores[contentId]!.toStringAsFixed(2)}');
  }

  // Private helper methods

  Future<List<ContentBlock>> _getAllCachedContent() async {
    // Return cached content or fetch from Firestore
    if (_contentCache.isEmpty) {
      final content = await _firestoreService.getContentBlocks();
      for (final block in content) {
        _contentCache[block.id] = block;
      }
    }
    return _contentCache.values.toList();
  }

  Future<ContentTags?> _getContentTags(String contentId) async {
    if (_tagsCache.containsKey(contentId)) {
      return _tagsCache[contentId];
    }
    
    try {
      final tags = await _firestoreService.getContentTags(contentId);
      if (tags != null) {
        _tagsCache[contentId] = tags;
      }
      return tags;
    } catch (e) {
      AppLogger.error('Failed to get content tags for $contentId: $e');
      return null;
    }
  }

  Future<List<String>> _getUserHistory(String userId) async {
    try {
      final history = await _firestoreService.getUserListeningHistory(userId);
      return history?.playedContentIds ?? [];
    } catch (e) {
      AppLogger.error('Failed to get user history: $e');
      return [];
    }
  }

  double _calculateSemanticSimilarity(ContentTags searchTags, ContentTags contentTags) {
    double totalSimilarity = 0.0;
    int comparisons = 0;

    // Topic matching (highest weight)
    for (final searchTag in searchTags.topic) {
      for (final contentTag in contentTags.topic) {
        totalSimilarity += _calculateTagSimilarity(searchTag, contentTag) * 0.4;
        comparisons++;
      }
    }

    // Subtopic matching
    for (final searchTag in searchTags.subtopic) {
      for (final contentTag in contentTags.subtopic) {
        totalSimilarity += _calculateTagSimilarity(searchTag, contentTag) * 0.3;
        comparisons++;
      }
    }

    // Category and level matching
    for (final searchTag in searchTags.category) {
      for (final contentTag in contentTags.category) {
        totalSimilarity += _calculateTagSimilarity(searchTag, contentTag) * 0.2;
        comparisons++;
      }
    }

    for (final searchTag in searchTags.level) {
      for (final contentTag in contentTags.level) {
        totalSimilarity += _calculateTagSimilarity(searchTag, contentTag) * 0.1;
        comparisons++;
      }
    }

    return comparisons > 0 ? totalSimilarity / comparisons : 0.0;
  }

  double _calculateTagSimilarity(ContentHashtag tag1, ContentHashtag tag2) {
    if (tag1.value == tag2.value) return 1.0;
    
    // Semantic similarity using simple word distance
    return _calculateWordSimilarity(tag1.value, tag2.value);
  }

  double _calculateWordSimilarity(String word1, String word2) {
    // Simple Levenshtein-based similarity
    final maxLen = math.max(word1.length, word2.length);
    if (maxLen == 0) return 1.0;
    
    final distance = _levenshteinDistance(word1, word2);
    return 1.0 - (distance / maxLen);
  }

  int _levenshteinDistance(String s1, String s2) {
    final matrix = List.generate(s1.length + 1, 
        (i) => List.generate(s2.length + 1, (j) => 0));
    
    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce(math.min);
      }
    }
    
    return matrix[s1.length][s2.length];
  }

  double _calculatePopularityScore(String contentId) {
    return _popularityScores[contentId] ?? 0.0;
  }

  double _calculateFreshnessScore(DateTime createdAt) {
    final daysSinceCreated = DateTime.now().difference(createdAt).inDays;
    return math.max(0.0, 1.0 - (daysSinceCreated / freshnessDecayDays));
  }

  double _calculateDiversityScore(ContentBlock content, List<RankedContentMatch> existingMatches) {
    if (existingMatches.isEmpty) return 1.0;
    
    // Reduce score if too similar to already selected content
    double diversityPenalty = 0.0;
    for (final match in existingMatches) {
      if (match.content.category == content.category) {
        diversityPenalty += 0.2;
      }
      if (match.content.contentType == content.contentType) {
        diversityPenalty += 0.1;
      }
    }
    
    return math.max(0.0, 1.0 - diversityPenalty);
  }

  double _calculateQualityScore(ContentBlock content) {
    double score = 0.5; // Base score
    
    // Script length indicates thorough content
    if (content.script.length > 500) score += 0.2;
    if (content.script.length > 1000) score += 0.1;
    
    // Has audio file
    if (content.audioUrl != null) score += 0.2;
    
    // Access count indicates proven quality
    if (content.accessCount > 10) score += 0.1;
    if (content.accessCount > 50) score += 0.1;
    if (content.accessCount > 100) score += 0.1;
    
    return math.min(1.0, score);
  }

  double _calculateAdvancedRanking({
    required double semantic,
    required double popularity,
    required double freshness,
    required double diversity,
    required double quality,
  }) {
    // Advanced weighted ranking algorithm
    return (semantic * 0.4) +        // Most important: relevance
           (quality * 0.25) +        // Content quality
           (popularity * 0.15) +     // User engagement
           (diversity * 0.1) +       // Content mix variety
           (freshness * 0.1);        // Recency bonus
  }

  String _generateMatchReason(ContentTags searchTags, ContentTags contentTags) {
    final reasons = <String>[];
    
    // Check topic matches
    for (final searchTag in searchTags.topic) {
      for (final contentTag in contentTags.topic) {
        if (searchTag.value == contentTag.value) {
          reasons.add('Exact topic match: ${searchTag.value}');
        }
      }
    }
    
    // Check category matches
    for (final searchTag in searchTags.category) {
      for (final contentTag in contentTags.category) {
        if (searchTag.value == contentTag.value) {
          reasons.add('Category match: ${searchTag.value}');
        }
      }
    }
    
    return reasons.isNotEmpty ? reasons.first : 'Semantic similarity';
  }

  // Assembly strategies

  ContentAssemblyResult _assembleSingleBest(List<RankedContentMatch> matches, Duration targetDuration) {
    if (matches.isEmpty) {
      return ContentAssemblyResult(
        strategy: 'single_best',
        contentIds: [],
        estimatedDuration: Duration.zero,
        reuseRate: 0.0,
        confidenceScore: 0.0,
      );
    }

    final bestMatch = matches.first;
    return ContentAssemblyResult(
      strategy: 'single_best',
      contentIds: [bestMatch.content.id],
      estimatedDuration: bestMatch.content.duration,
      reuseRate: 1.0,
      confidenceScore: bestMatch.totalScore,
      metadata: {
        'match_reason': bestMatch.matchReason,
        'semantic_score': bestMatch.semanticScore,
      },
    );
  }

  ContentAssemblyResult _assembleMultiSegment(List<RankedContentMatch> matches, Duration targetDuration) {
    final selectedContent = <String>[];
    Duration totalDuration = Duration.zero;
    double avgScore = 0.0;
    
    final targetMinutes = targetDuration.inMinutes;
    
    for (final match in matches) {
      if (totalDuration.inMinutes >= targetMinutes) break;
      if (selectedContent.length >= 3) break; // Max 3 segments
      
      selectedContent.add(match.content.id);
      totalDuration += match.content.duration;
      avgScore += match.totalScore;
    }
    
    avgScore = selectedContent.isNotEmpty ? avgScore / selectedContent.length : 0.0;
    
    return ContentAssemblyResult(
      strategy: 'multi_segment',
      contentIds: selectedContent,
      estimatedDuration: totalDuration,
      reuseRate: 0.8, // Slightly lower due to multiple segments
      confidenceScore: avgScore,
    );
  }

  ContentAssemblyResult _assembleHybridReuse(List<RankedContentMatch> matches, Duration targetDuration) {
    // Use best existing content + indicate need for AI enhancement
    final baseContent = matches.isNotEmpty ? [matches.first.content.id] : <String>[];
    
    return ContentAssemblyResult(
      strategy: 'hybrid_reuse',
      contentIds: baseContent,
      estimatedDuration: targetDuration,
      reuseRate: 0.6, // Partial reuse with AI enhancement
      confidenceScore: matches.isNotEmpty ? matches.first.totalScore * 0.8 : 0.0,
      metadata: {
        'needs_ai_enhancement': true,
        'base_content_score': matches.isNotEmpty ? matches.first.totalScore : 0.0,
      },
    );
  }

  ContentAssemblyResult _assembleAdaptive(List<RankedContentMatch> matches, Duration targetDuration) {
    if (matches.isEmpty) {
      return ContentAssemblyResult(
        strategy: 'generate_new',
        contentIds: [],
        estimatedDuration: targetDuration,
        reuseRate: 0.0,
        confidenceScore: 0.0,
      );
    }

    // Adaptive strategy based on match quality
    final bestScore = matches.first.totalScore;
    
    if (bestScore > 0.8) {
      return _assembleSingleBest(matches, targetDuration);
    } else if (bestScore > 0.6 && matches.length >= 2) {
      return _assembleMultiSegment(matches, targetDuration);
    } else {
      return _assembleHybridReuse(matches, targetDuration);
    }
  }
}

/// Ranked content match with detailed scoring
class RankedContentMatch {
  final ContentBlock content;
  final ContentTags tags;
  final double semanticScore;
  final double popularityScore;
  final double freshnessScore;
  final double diversityScore;
  final double qualityScore;
  final double totalScore;
  final String matchReason;

  RankedContentMatch({
    required this.content,
    required this.tags,
    required this.semanticScore,
    required this.popularityScore,
    required this.freshnessScore,
    required this.diversityScore,
    required this.qualityScore,
    required this.totalScore,
    required this.matchReason,
  });
}

/// Content assembly result with detailed metrics
class ContentAssemblyResult {
  final String strategy;
  final List<String> contentIds;
  final Duration estimatedDuration;
  final double reuseRate;
  final double confidenceScore;
  final Map<String, dynamic> metadata;

  ContentAssemblyResult({
    required this.strategy,
    required this.contentIds,
    required this.estimatedDuration,
    required this.reuseRate,
    required this.confidenceScore,
    this.metadata = const {},
  });
}

