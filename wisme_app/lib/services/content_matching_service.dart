import '../core/exports.dart';
import 'dart:convert';
import 'dart:math';
class ContentMatchingService {
  final FirestoreService _firestoreService;
  final GPTService _gptService;

  // Cache for frequently used data
  final Map<String, ContentTags> _contentTagsCache = {};
  final Map<String, UserListeningHistory> _userHistoryCache = {};

  ContentMatchingService({
    required FirestoreService firestoreService,
    required GPTService gptService,
  }) : _firestoreService = firestoreService,
       _gptService = gptService;

  /// Generate AI-powered hashtags during content creation (hidden from users)
  Future<ContentTags> generateHashtagsWithContent({
    required String topic,
    required String category,
    required String level,
    required String generatedScript,
    String? contentType,
    String? userContext,
  }) async {
    try {
      AppLogger.info('🏷️ Generating AI hashtags for content: $topic');

      final hashtagPrompt = '''SYSTEM: You are an expert content analyzer for Wisme's learning platform. Analyze the generated content and create comprehensive hashtags for intelligent content matching and reuse.

CONTENT TO ANALYZE:
Topic: "$topic"
Category: "$category" 
Level: "$level"
Generated Script: "$generatedScript"
Content Type: "${contentType ?? 'lesson'}"

TASK: Generate precise hashtags based on the ACTUAL content, not just the topic. Analyze the script for:
- Key concepts mentioned
- Learning objectives
- Industry applications  
- Difficulty indicators
- Content style/approach

OUTPUT FORMAT (JSON only):
{
  "topic": ["main_concept", "secondary_concept"],
  "subtopic": ["specific_skill_1", "specific_skill_2", "practical_application"],
  "semantic": ["related_term_1", "synonym_1", "broader_concept"],
  "category": ["${category.toLowerCase().replaceAll(' ', '_')}"],
  "level": ["$level"],
  "format": ["lesson_type", "delivery_style"],
  "industry": ["applicable_industry_1", "applicable_industry_2"],
  "keywords": ["searchable_term_1", "searchable_term_2", "searchable_term_3"]
}

REQUIREMENTS:
- Use exact content analysis, not assumptions
- Include semantic variations for better matching
- Use underscores instead of spaces
- Include 3-5 searchable keywords that users might search for
- Be specific based on actual script content''';

      final response = await _gptService.generateContentBlock(
        topic: hashtagPrompt,
        category: 'system',
        level: 'expert',
        contentType: 'analysis',
      );

      // Parse AI-generated hashtags
      final tagsData = jsonDecode(response['script'] ?? '{}');
      
      final contentTags = ContentTags(
        topic: _parseHashtagsWithWeights(tagsData['topic'], 'topic', 3.0),
        subtopic: _parseHashtagsWithWeights(tagsData['subtopic'], 'subtopic', 2.5),
        category: _parseHashtagsWithWeights(tagsData['category'], 'category', 2.0),
        level: _parseHashtagsWithWeights(tagsData['level'], 'level', 1.8),
        format: _parseHashtagsWithWeights(tagsData['format'], 'format', 1.5),
        industry: _parseHashtagsWithWeights(tagsData['industry'], 'industry', 1.2),
        // Store semantic tags in voice field and keywords in mood field for now
        voice: _parseHashtagsWithWeights(tagsData['semantic'], 'semantic', 2.2),
        mood: _parseHashtagsWithWeights(tagsData['keywords'], 'keywords', 2.8),
      );

      AppLogger.info('🏷️ Generated ${contentTags.allTags.length} hashtags for content');
      return contentTags;

    } catch (e) {
      AppLogger.error('Failed to generate hashtags with content: $e');
      
      // Return fallback hashtags based on topic and category
      return _generateFallbackTags(topic, category, level, contentType);
    }
  }

  /// Generate hashtags for a topic (legacy method for backward compatibility)
  Future<ContentTags> generateHashtagsForTopic({
    required String topic,
    required String category,
    required String level,
    String? contentType,
    String? userContext,
  }) async {
    // For legacy compatibility, generate basic tags without script analysis
    return ContentTags(
      topic: _parseHashtagsWithWeights([topic], 'topic', 3.0),
      category: _parseHashtagsWithWeights([category], 'category', 2.0),
      level: _parseHashtagsWithWeights([level], 'level', 1.8),
      format: contentType != null 
          ? _parseHashtagsWithWeights([contentType], 'format', 1.5)
          : [],
    );
  }

  /// Find matching content based on hashtags and user history
  Future<List<ContentMatch>> findMatchingContent({
    required ContentTags searchTags,
    required String userId,
    int maxResults = 10,
    double minimumSimilarity = 0.3,
    bool excludeRecentlyPlayed = true,
    int excludeWithinDays = 7,
  }) async {
    try {
      AppLogger.info('Finding matching content for user: $userId');

      // Get user listening history
      final userHistory = await _getUserHistory(userId);

      // Get all available content
      final allContent = await _firestoreService.getContentBlocks();

      List<ContentMatch> matches = [];

      for (final content in allContent) {
        // Skip if user has played this recently
        if (excludeRecentlyPlayed && 
            userHistory.wasPlayedRecently(content.id, withinDays: excludeWithinDays)) {
          continue;
        }

        // Skip if user explicitly disliked this type of content
        if (userHistory.dislikedContent.contains(content.id)) {
          continue;
        }

        // Get or generate content tags
        final contentTags = await _getContentTags(content);

        // Calculate similarity scores
        final similarityScore = searchTags.calculateSimilarity(contentTags);
        
        if (similarityScore < minimumSimilarity) continue;

        // Calculate semantic score (simplified - in production use embeddings)
        final semanticScore = _calculateSemanticSimilarity(searchTags, contentTags);

        // Calculate freshness score
        final freshnessScore = _calculateFreshnessScore(content, userHistory);

        // Calculate user preference score
        final preferenceScore = userHistory.getPreferenceScore(contentTags.allTagStrings);

        // Combined total score with weights
        final totalScore = (similarityScore * 0.4) +
                          (semanticScore * 0.25) +
                          (freshnessScore * 0.15) +
                          (preferenceScore * 0.2);

        // Get matching tags for debugging/explanation
        final matchingTags = _getMatchingTags(searchTags, contentTags);

        matches.add(ContentMatch(
          contentId: content.id,
          similarityScore: similarityScore,
          semanticScore: semanticScore,
          freshnessScore: freshnessScore,
          totalScore: totalScore,
          matchingTags: matchingTags,
          lastPlayed: userHistory.lastPlayedDates[content.id],
          isExactMatch: similarityScore > 0.8,
        ));
      }

      // Sort by total score and return top results
      matches.sort((a, b) => b.totalScore.compareTo(a.totalScore));
      
      AppLogger.info('Found ${matches.length} content matches');
      return matches.take(maxResults).toList();
    } catch (e) {
      AppLogger.error('Failed to find matching content: $e');
      return [];
    }
  }

  /// Assemble custom content episode from multiple sources
  Future<ContentAssembly> assembleCustomContent({
    required List<ContentMatch> matches,
    required String userId,
    Duration? targetDuration,
    String? preferredFormat,
  }) async {
    try {
      final targetMinutes = targetDuration?.inMinutes ?? 10;
      
      if (matches.isEmpty) {
        return ContentAssembly(
          contentIds: [],
          assemblyType: 'empty',
          estimatedDuration: Duration.zero,
          confidenceScore: 0.0,
        );
      }

      // Single high-quality match
      if (matches.first.totalScore > 0.8) {
        return ContentAssembly(
          contentIds: [matches.first.contentId],
          assemblyType: 'single',
          estimatedDuration: Duration(minutes: targetMinutes),
          confidenceScore: matches.first.totalScore,
          customization: {
            'originalScore': matches.first.totalScore,
            'matchingTags': matches.first.matchingTags,
          },
        );
      }

      // Multi-clip assembly for comprehensive coverage
      if (matches.length >= 2) {
        final selectedContent = <String>[];
        Duration totalDuration = Duration.zero;
        double avgConfidence = 0.0;

        for (final match in matches.take(3)) {
          selectedContent.add(match.contentId);
          totalDuration += Duration(minutes: targetMinutes ~/ 3);
          avgConfidence += match.totalScore;
        }

        avgConfidence /= selectedContent.length;

        return ContentAssembly(
          contentIds: selectedContent,
          assemblyType: 'multi_clip',
          estimatedDuration: totalDuration,
          confidenceScore: avgConfidence,
          customization: {
            'clipCount': selectedContent.length,
            'averageScore': avgConfidence,
            'assembly_strategy': 'comprehensive_coverage',
          },
        );
      }

      // Remix existing content with AI enhancement
      return ContentAssembly(
        contentIds: [matches.first.contentId],
        assemblyType: 'remix',
        estimatedDuration: Duration(minutes: targetMinutes),
        confidenceScore: matches.first.totalScore * 0.8, // Slightly lower confidence for remix
        customization: {
          'remixType': 'ai_enhancement',
          'originalScore': matches.first.totalScore,
          'enhancementNeeded': true,
        },
      );
    } catch (e) {
      AppLogger.error('Failed to assemble custom content: $e');
      return ContentAssembly(
        contentIds: [],
        assemblyType: 'error',
        estimatedDuration: Duration.zero,
        confidenceScore: 0.0,
      );
    }
  }

  /// Update user listening history
  Future<void> updateUserHistory({
    required String userId,
    required String contentId,
    double? userRating,
    bool? isBookmarked,
    bool? isDisliked,
    Duration? listeningTime,
  }) async {
    try {
      final history = await _getUserHistory(userId);
      
      // Update played content
      final updatedPlayedIds = List<String>.from(history.playedContentIds);
      if (!updatedPlayedIds.contains(contentId)) {
        updatedPlayedIds.add(contentId);
      }

      // Update last played dates
      final updatedLastPlayed = Map<String, DateTime>.from(history.lastPlayedDates);
      updatedLastPlayed[contentId] = DateTime.now();

      // Update play count
      final updatedPlayCount = Map<String, int>.from(history.playCount);
      updatedPlayCount[contentId] = (updatedPlayCount[contentId] ?? 0) + 1;

      // Update ratings if provided
      final updatedRatings = Map<String, double>.from(history.userRatings);
      if (userRating != null) {
        updatedRatings[contentId] = userRating;
      }

      // Update bookmarks
      final updatedBookmarks = List<String>.from(history.bookmarkedContent);
      if (isBookmarked == true && !updatedBookmarks.contains(contentId)) {
        updatedBookmarks.add(contentId);
      } else if (isBookmarked == false) {
        updatedBookmarks.remove(contentId);
      }

      // Update dislikes
      final updatedDislikes = List<String>.from(history.dislikedContent);
      if (isDisliked == true && !updatedDislikes.contains(contentId)) {
        updatedDislikes.add(contentId);
      } else if (isDisliked == false) {
        updatedDislikes.remove(contentId);
      }

      final updatedHistory = history.copyWith(
        playedContentIds: updatedPlayedIds,
        lastPlayedDates: updatedLastPlayed,
        playCount: updatedPlayCount,
        userRatings: updatedRatings,
        bookmarkedContent: updatedBookmarks,
        dislikedContent: updatedDislikes,
      );

      // Save to Firestore
      await _firestoreService.saveUserListeningHistory(userId, updatedHistory);
      
      // Update cache
      _userHistoryCache[userId] = updatedHistory;

      AppLogger.info('Updated user history for: $userId, content: $contentId');
    } catch (e) {
      AppLogger.error('Failed to update user history: $e');
    }
  }

  /// Save content tags to Firestore
  Future<void> saveContentTags(String contentId, ContentTags tags) async {
    try {
      await _firestoreService.saveContentTags(contentId, tags);
      _contentTagsCache[contentId] = tags;
    } catch (e) {
      AppLogger.error('Failed to save content tags: $e');
    }
  }

  // Helper methods

  /// Parse hashtags with custom weights for AI-generated content
  List<ContentHashtag> _parseHashtagsWithWeights(dynamic tagList, String type, double weight) {
    if (tagList == null) return [];
    
    final List<dynamic> tags = tagList is List ? tagList : [tagList];
    return tags.map((tag) => ContentHashtag(
      type: type,
      value: tag.toString().toLowerCase().replaceAll(' ', '_'),
      weight: weight,
    )).toList();
  }

  // Removed unused _parseHashtags method - use _parseHashtagsWithWeights instead

  // Removed unused _getTagWeight method - weights are now passed directly

  ContentTags _generateFallbackTags(String topic, String category, String level, String? contentType) {
    return ContentTags(
      topic: [ContentHashtag(type: 'topic', value: topic, weight: 2.0)],
      category: [ContentHashtag(type: 'category', value: category, weight: 1.8)],
      level: [ContentHashtag(type: 'level', value: level, weight: 1.5)],
      format: contentType != null 
          ? [ContentHashtag(type: 'format', value: contentType, weight: 1.0)]
          : [],
    );
  }

  Future<UserListeningHistory> _getUserHistory(String userId) async {
    if (_userHistoryCache.containsKey(userId)) {
      return _userHistoryCache[userId]!;
    }

    try {
      final historyData = await _firestoreService.getUserListeningHistory(userId);
      final history = UserListeningHistory.fromMap(historyData as Map<String, dynamic>);
      _userHistoryCache[userId] = history;
      return history;
    } catch (e) {
      AppLogger.error('Failed to get user history: $e');
      final emptyHistory = UserListeningHistory(userId: userId);
      _userHistoryCache[userId] = emptyHistory;
      return emptyHistory;
    }
  }

  Future<ContentTags> _getContentTags(ContentBlock content) async {
    if (_contentTagsCache.containsKey(content.id)) {
      return _contentTagsCache[content.id]!;
    }

    try {
      // Try to get saved tags first
      final savedTagsData = await _firestoreService.getContentTags(content.id);
      if (savedTagsData != null) {
        final savedTags = ContentTags.fromMap(savedTagsData as Map<String, dynamic>);
        _contentTagsCache[content.id] = savedTags;
        return savedTags;
      }

      // Generate tags if not found
      final generatedTags = await generateHashtagsWithContent(
        topic: content.category, // Using category as topic
        category: content.category,
        level: content.difficultyLevel.toString(),
        generatedScript: content.transcript,
        contentType: content.contentType,
      );

      // Save for future use
      await saveContentTags(content.id, generatedTags);
      return generatedTags;
    } catch (e) {
      AppLogger.error('Failed to get content tags: $e');
      return _generateFallbackTags(content.category, content.category, content.difficultyLevel.toString(), content.contentType);
    }
  }

  double _calculateSemanticSimilarity(ContentTags searchTags, ContentTags contentTags) {
    // Simplified semantic similarity - in production, use embeddings
    final searchWords = searchTags.allTagStrings.join(' ').toLowerCase().split(' ');
    final contentWords = contentTags.allTagStrings.join(' ').toLowerCase().split(' ');
    
    int commonWords = 0;
    for (final word in searchWords) {
      if (contentWords.contains(word)) {
        commonWords++;
      }
    }
    
    final totalWords = max(searchWords.length, contentWords.length);
    return totalWords > 0 ? commonWords / totalWords : 0.0;
  }

  double _calculateFreshnessScore(ContentBlock content, UserListeningHistory history) {
    final lastPlayed = history.lastPlayedDates[content.id];
    if (lastPlayed == null) return 1.0; // Fresh content gets full score
    
    final daysSinceLastPlayed = DateTime.now().difference(lastPlayed).inDays;
    
    // Fresher content gets higher score, but not too recent to avoid repetition
    if (daysSinceLastPlayed < 1) return 0.1; // Very recent
    if (daysSinceLastPlayed < 7) return 0.3; // Recent
    if (daysSinceLastPlayed < 30) return 0.8; // Good freshness
    return 1.0; // Optimal freshness
  }

  List<String> _getMatchingTags(ContentTags searchTags, ContentTags contentTags) {
    final searchStrings = searchTags.allTagStrings.toSet();
    final contentStrings = contentTags.allTagStrings.toSet();
    return searchStrings.intersection(contentStrings).toList();
  }
}

