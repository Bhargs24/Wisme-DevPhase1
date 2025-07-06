import '../core/exports.dart';
import 'dart:async';
import 'dart:math' as math;
class ContentReuseEngine {
  final FirestoreService _firestoreService;
  
  // High-performance content cache
  final Map<String, ContentBlock> _contentCache = {};
  final Map<String, ContentTags> _contentTagsCache = {};
  final Map<String, List<String>> _topicIndex = {};
  
  static const int _maxCacheSize = 1000;

  ContentReuseEngine({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Find reusable content with sophisticated matching algorithm
  Future<List<ContentMatch>> findReusableContent({
    required String topic,
    required String category,
    required String level,
    required String userId,
    List<String> excludeContentIds = const [],
    int maxResults = 10,
    double minimumSimilarity = 0.6,
  }) async {
    try {
      AppLogger.info('🔍 Finding reusable content for: $topic');

      // Get all available content from database with caching
      final availableContent = await _getAvailableContent();
      
      // Generate search hashtags for the new topic
      final searchTags = await _generateSearchTags(topic, category, level);
      
      final matches = <ContentMatch>[];

      // Match against each piece of content
      for (final content in availableContent) {
        if (excludeContentIds.contains(content.id)) continue;

        // Get stored hashtags for this content
        final contentTags = await _getContentTags(content.id);
        if (contentTags == null) continue;

        // Calculate sophisticated similarity score
        final similarityScore = _calculateSimilarityScore(searchTags, contentTags);
        
        if (similarityScore >= minimumSimilarity) {
          matches.add(ContentMatch(
            contentId: content.id,
            similarityScore: similarityScore,
            semanticScore: _calculateSemanticScore(searchTags, contentTags),
            freshnessScore: _calculateFreshnessScore(content),
            totalScore: _calculateTotalScore(similarityScore, content, userId),
            matchingTags: _getMatchingTags(searchTags, contentTags),
            isExactMatch: similarityScore > 0.85,
          ));
        }
      }

      // Advanced ranking algorithm
      final rankedMatches = _rankMatches(matches, userId);
      
      AppLogger.info('✨ Found ${rankedMatches.length} reusable content matches');
      return rankedMatches.take(maxResults).toList();

    } catch (e) {
      AppLogger.error('Failed to find reusable content: $e');
      return [];
    }
  }

  /// Assemble content from multiple sources intelligently
  Future<ContentAssembly> assembleContent({
    required List<ContentMatch> matches,
    required String userId,
    Duration targetDuration = const Duration(minutes: 10),
  }) async {
    if (matches.isEmpty) {
      return ContentAssembly(
        contentIds: [],
        assemblyType: 'generate_new',
        estimatedDuration: targetDuration,
        confidenceScore: 0.0,
        customization: {'reuseRate': 0.0},
      );
    }

    // Smart assembly strategy
    final strategy = _determineAssemblyStrategy(matches, targetDuration);
    
    switch (strategy) {
      case AssemblyStrategy.directReuse:
        return _createDirectReuseAssembly(matches.first, targetDuration);
      
      case AssemblyStrategy.multiSegment:
        return _createMultiSegmentAssembly(matches, targetDuration);
      
      case AssemblyStrategy.hybridGeneration:
        return _createHybridAssembly(matches, targetDuration);
      
      default:
        return _createNewContentAssembly(targetDuration);
    }
  }

  /// Cache content for future reuse
  void cacheContent(ContentBlock content, ContentTags tags) {
    // LRU cache management
    if (_contentCache.length >= _maxCacheSize) {
      _evictOldestCacheEntry();
    }
    
    _contentCache[content.id] = content;
    _contentTagsCache[content.id] = tags;
    
    // Update topic index for fast lookups
    _updateTopicIndex(content.id, tags);
  }

  // Private helper methods

  Future<List<ContentBlock>> _getAvailableContent() async {
    // Check cache first
    if (_contentCache.isNotEmpty) {
      return _contentCache.values.toList();
    }
    
    // Load from database
    final content = await _firestoreService.getContentBlocks();
    
    // Cache the content
    for (final block in content) {
      _contentCache[block.id] = block;
    }
    
    return content;
  }

  Future<ContentTags?> _getContentTags(String contentId) async {
    // Check cache first
    if (_contentTagsCache.containsKey(contentId)) {
      return _contentTagsCache[contentId];
    }
    
    // Load from database
    final tagsData = await _firestoreService.getContentTags(contentId);
    if (tagsData != null) {
      // Convert dynamic data to ContentTags object
      final tags = ContentTags.fromMap(tagsData as Map<String, dynamic>);
      _contentTagsCache[contentId] = tags;
      return tags;
    }
    
    return null;
  }

  Future<ContentTags> _generateSearchTags(String topic, String category, String level) async {
    // This would be generated by AI during content creation and stored
    // For search, we create a simplified version
    return ContentTags(
      topic: [ContentHashtag(type: 'topic', value: topic.toLowerCase().replaceAll(' ', '_'), weight: 3.0)],
      category: [ContentHashtag(type: 'category', value: category.toLowerCase().replaceAll(' ', '_'), weight: 2.0)],
      level: [ContentHashtag(type: 'level', value: level.toLowerCase(), weight: 1.5)],
    );
  }

  double _calculateSimilarityScore(ContentTags searchTags, ContentTags contentTags) {
    double totalScore = 0.0;
    double maxScore = 0.0;

    // Topic matching (highest weight)
    final topicScore = _calculateTagSimilarity(searchTags.topic, contentTags.topic);
    totalScore += topicScore * 0.4;
    maxScore += 0.4;

    // Subtopic matching
    final subtopicScore = _calculateTagSimilarity(searchTags.subtopic, contentTags.subtopic);
    totalScore += subtopicScore * 0.3;
    maxScore += 0.3;

    // Category matching
    final categoryScore = _calculateTagSimilarity(searchTags.category, contentTags.category);
    totalScore += categoryScore * 0.2;
    maxScore += 0.2;

    // Level matching
    final levelScore = _calculateTagSimilarity(searchTags.level, contentTags.level);
    totalScore += levelScore * 0.1;
    maxScore += 0.1;

    return maxScore > 0 ? totalScore / maxScore : 0.0;
  }

  double _calculateTagSimilarity(List<ContentHashtag> tags1, List<ContentHashtag> tags2) {
    if (tags1.isEmpty || tags2.isEmpty) return 0.0;

    double bestMatch = 0.0;
    
    for (final tag1 in tags1) {
      for (final tag2 in tags2) {
        double similarity = 0.0;
        
        if (tag1.value == tag2.value) {
          similarity = 1.0; // Exact match
        } else if (_areSemanticallySimilar(tag1.value, tag2.value)) {
          similarity = 0.7; // Semantic match
        }
        
        bestMatch = math.max(bestMatch, similarity);
      }
    }
    
    return bestMatch;
  }

  bool _areSemanticallySimilar(String term1, String term2) {
    // Simple semantic similarity - in production, use NLP embeddings
    final synonymGroups = [
      ['invest', 'investment', 'investing', 'finance', 'money'],
      ['crypto', 'cryptocurrency', 'bitcoin', 'blockchain'],
      ['ai', 'artificial_intelligence', 'machine_learning', 'ml'],
      ['business', 'entrepreneur', 'startup', 'company'],
      ['learn', 'education', 'training', 'study'],
    ];

    for (final group in synonymGroups) {
      if (group.contains(term1) && group.contains(term2)) {
        return true;
      }
    }

    return false;
  }

  double _calculateSemanticScore(ContentTags searchTags, ContentTags contentTags) {
    // Calculate deeper semantic relationships
    // This is where you'd integrate with vector embeddings in production
    return 0.5; // Placeholder
  }

  double _calculateFreshnessScore(ContentBlock content) {
    final daysSinceCreated = DateTime.now().difference(content.createdAt).inDays;
    return math.max(0.0, 1.0 - (daysSinceCreated / 365.0)); // Decays over a year
  }

  double _calculateTotalScore(double similarityScore, ContentBlock content, String userId) {
    final freshnessScore = _calculateFreshnessScore(content);
    final popularityScore = _calculatePopularityScore(content);
    
    return (similarityScore * 0.6) + 
           (freshnessScore * 0.2) + 
           (popularityScore * 0.2);
  }

  double _calculatePopularityScore(ContentBlock content) {
    // Calculate based on play count and recent usage
    final normalizedPlayCount = math.min(content.playCount / 100.0, 1.0);
    return normalizedPlayCount;
  }

  List<String> _getMatchingTags(ContentTags searchTags, ContentTags contentTags) {
    final matchingTags = <String>[];
    
    // Find exact tag matches for explanation
    for (final searchTag in searchTags.allTags) {
      for (final contentTag in contentTags.allTags) {
        if (searchTag.value == contentTag.value) {
          matchingTags.add(searchTag.value);
        }
      }
    }
    
    return matchingTags;
  }

  List<ContentMatch> _rankMatches(List<ContentMatch> matches, String userId) {
    // Advanced ranking algorithm
    matches.sort((a, b) {
      // Primary: Total score
      final scoreComparison = b.totalScore.compareTo(a.totalScore);
      if (scoreComparison != 0) return scoreComparison;
      
      // Secondary: Similarity score
      final similarityComparison = b.similarityScore.compareTo(a.similarityScore);
      if (similarityComparison != 0) return similarityComparison;
      
      // Tertiary: Freshness
      return b.freshnessScore.compareTo(a.freshnessScore);
    });
    
    return matches;
  }

  AssemblyStrategy _determineAssemblyStrategy(List<ContentMatch> matches, Duration targetDuration) {
    final bestMatch = matches.first;
    
    if (bestMatch.isExactMatch && matches.length == 1) {
      return AssemblyStrategy.directReuse;
    } else if (matches.length >= 2 && bestMatch.similarityScore > 0.7) {
      return AssemblyStrategy.multiSegment;
    } else {
      return AssemblyStrategy.hybridGeneration;
    }
  }

  ContentAssembly _createDirectReuseAssembly(ContentMatch match, Duration targetDuration) {
    return ContentAssembly(
      contentIds: [match.contentId],
      assemblyType: 'direct_reuse',
      estimatedDuration: targetDuration,
      confidenceScore: match.totalScore,
      customization: {
        'reuseRate': 1.0,
        'matchType': 'exact_reuse',
        'originalScore': match.similarityScore,
      },
    );
  }

  ContentAssembly _createMultiSegmentAssembly(List<ContentMatch> matches, Duration targetDuration) {
    final selectedMatches = matches.take(3).toList();
    final avgScore = selectedMatches.fold(0.0, (sum, match) => sum + match.totalScore) / selectedMatches.length;
    
    return ContentAssembly(
      contentIds: selectedMatches.map((m) => m.contentId).toList(),
      assemblyType: 'multi_segment',
      estimatedDuration: targetDuration,
      confidenceScore: avgScore,
      customization: {
        'reuseRate': 0.8,
        'segmentCount': selectedMatches.length,
        'assemblyStrategy': 'multi_segment_blend',
      },
    );
  }

  ContentAssembly _createHybridAssembly(List<ContentMatch> matches, Duration targetDuration) {
    return ContentAssembly(
      contentIds: matches.take(2).map((m) => m.contentId).toList(),
      assemblyType: 'hybrid',
      estimatedDuration: targetDuration,
      confidenceScore: matches.first.totalScore * 0.7,
      customization: {
        'reuseRate': 0.5,
        'enhancementNeeded': true,
        'baseContent': matches.first.contentId,
      },
    );
  }

  ContentAssembly _createNewContentAssembly(Duration targetDuration) {
    return ContentAssembly(
      contentIds: [],
      assemblyType: 'generate_new',
      estimatedDuration: targetDuration,
      confidenceScore: 0.0,
      customization: {
        'reuseRate': 0.0,
        'reason': 'no_suitable_matches',
      },
    );
  }

  void _evictOldestCacheEntry() {
    // Simple LRU eviction - in production, use proper LRU cache
    if (_contentCache.isNotEmpty) {
      final firstKey = _contentCache.keys.first;
      _contentCache.remove(firstKey);
      _contentTagsCache.remove(firstKey);
    }
  }

  void _updateTopicIndex(String contentId, ContentTags tags) {
    for (final topicTag in tags.topic) {
      _topicIndex.putIfAbsent(topicTag.value, () => []).add(contentId);
    }
  }
}

enum AssemblyStrategy {
  directReuse,
  multiSegment,
  hybridGeneration,
  generateNew,
}


