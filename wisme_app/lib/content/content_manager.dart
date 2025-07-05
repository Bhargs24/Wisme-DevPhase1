/// Content Manager - Orchestrates all content-related operations with AI
/// 
/// Manages content generation, storage, retrieval, and caching with advanced features
library;

import 'dart:async';
import '../shared/models/result.dart';
import '../core/utils/logger.dart';
import '../core/error/app_exceptions.dart';
import 'models/content_models.dart';
import 'models/content_matching_model.dart';
import 'data/content_data_service.dart';
import 'services/smart_content_engine.dart';
import 'services/gpt_service.dart';

/// Central content management service with advanced AI capabilities
class ContentManager {
  static ContentManager? _instance;
  static ContentManager get instance => _instance ??= ContentManager._();
  
  ContentManager._();

  final ContentDataService _dataService = ContentDataService();
  final SmartContentEngine _smartEngine = SmartContentEngine.instance;
  final GPTService _gptService = GPTService();
  bool _isInitialized = false;

  /// Initialize content manager with advanced features
  Future<Result<void>> initialize() async {
    try {
      if (_isInitialized) return Result.success(null);

      // Initialize data service
      final dataResult = await _dataService.initialize();
      if (dataResult.isFailure) {
        return Result.failure(dataResult.error);
      }

      _isInitialized = true;
      AppLogger.info('📚 Content manager initialized with advanced AI features');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Content manager initialization failed: $e');
      return Result.failure(ContentException('Failed to initialize content manager'));
    }
  }

  /// Generate smart content using AI engine
  Future<Result<SmartContentResult>> generateSmartContent({
    required String userId,
    required String topic,
    required String category,
    required String level,
    String? contentType,
    Duration? targetDuration,
    String? preferredVoice,
    Map<String, dynamic>? userContext,
  }) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _smartEngine.generateSmartContent(
        userId: userId,
        topic: topic,
        category: category,
        level: level,
        contentType: contentType,
        targetDuration: targetDuration,
        preferredVoice: preferredVoice,
        userContext: userContext,
      );
    } catch (e) {
      AppLogger.error('❌ Smart content generation failed: $e');
      return Result.failure(ContentException('Smart content generation failed: $e'));
    }
  }

  /// Get content item with enhanced caching
  Future<Result<ContentItem?>> getContentItem(String contentId) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _dataService.getContentItem(contentId);
    } catch (e) {
      AppLogger.error('❌ Failed to get content item: $e');
      return Result.failure(ContentException('Failed to get content item'));
    }
  }

  /// Create new content item
  Future<Result<void>> createContentItem(ContentItem item) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _dataService.createContentItem(item);
    } catch (e) {
      AppLogger.error('❌ Failed to create content item: $e');
      return Result.failure(ContentException('Failed to create content item'));
    }
  }

  /// Update existing content item
  Future<Result<void>> updateContentItem(ContentItem item) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _dataService.updateContentItem(item);
    } catch (e) {
      AppLogger.error('❌ Failed to update content item: $e');
      return Result.failure(ContentException('Failed to update content item'));
    }
  }

  /// Delete content item
  Future<Result<void>> deleteContentItem(String contentId) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _dataService.deleteContentItem(contentId);
    } catch (e) {
      AppLogger.error('❌ Failed to delete content item: $e');
      return Result.failure(ContentException('Failed to delete content item'));
    }
  }

  /// Get content items by category
  Future<Result<List<ContentItem>>> getContentByCategory(String category) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _dataService.getContentByCategory(category);
    } catch (e) {
      AppLogger.error('❌ Failed to get content by category: $e');
      return Result.failure(ContentException('Failed to get content by category'));
    }
  }

  /// Search content items
  Future<Result<List<ContentItem>>> searchContent(String query) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _dataService.searchContent(query);
    } catch (e) {
      AppLogger.error('❌ Failed to search content: $e');
      return Result.failure(ContentException('Failed to search content'));
    }
  }

  /// Get content recommendations for user
  Future<Result<List<ContentItem>>> getRecommendations(String userId) async {
    try {
      if (!_isInitialized) {
        throw const ContentException('Content manager not initialized');
      }

      return await _dataService.getRecommendations(userId);
    } catch (e) {
      AppLogger.error('❌ Failed to get recommendations: $e');
      return Result.failure(ContentException('Failed to get recommendations'));
    }
  }

  /// Get performance metrics from smart engine
  Map<String, dynamic> getPerformanceMetrics() {
    return _smartEngine.getPerformanceMetrics();
  }

  /// Optimize performance
  Future<void> optimizePerformance() async {
    await _smartEngine.optimizePerformance();
  }

  /// Get manager status
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'smartEngineMetrics': _smartEngine.getPerformanceMetrics(),
      'dataServiceStatus': _dataService.getStatus(),
    };
  }

  /// Dispose manager and cleanup resources
  Future<void> dispose() async {
    await _smartEngine.dispose();
    await _dataService.dispose();
    _isInitialized = false;
    AppLogger.info('📚 Content manager disposed');
  }
}
      if (contentItem != null && useCache) {
        _contentCache[contentId] = contentItem;
      }

      return contentItem;
    } catch (e, stack) {
      _logger.error('Failed to get content item', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get multiple content items
  Future<List<ContentItem>> getContentItems(List<String> contentIds) async {
    try {
      final items = <ContentItem>[];
      final uncachedIds = <String>[];

      // Check cache for each item
      for (final id in contentIds) {
        if (_contentCache.containsKey(id)) {
          items.add(_contentCache[id]!);
        } else {
          uncachedIds.add(id);
        }
      }

      // Fetch uncached items
      if (uncachedIds.isNotEmpty) {
        final uncachedItems = await _dataService.getContentItems(uncachedIds);
        
        // Add to cache and results
        for (final item in uncachedItems) {
          _contentCache[item.id] = item;
          items.add(item);
        }
      }

      return items;
    } catch (e, stack) {
      _logger.error('Failed to get content items', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get content by type with caching
  Future<List<ContentItem>> getContentByType(ContentType type, {bool useCache = true}) async {
    try {
      final cacheKey = type.name;
      
      // Check cache first
      if (useCache && _contentByTypeCache.containsKey(cacheKey)) {
        return _contentByTypeCache[cacheKey]!;
      }

      final content = await _dataService.getContentByType(type);
      
      // Cache the result
      if (useCache) {
        _contentByTypeCache[cacheKey] = content;
        
        // Also cache individual items
        for (final item in content) {
          _contentCache[item.id] = item;
        }
      }

      return content;
    } catch (e, stack) {
      _logger.error('Failed to get content by type', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get content by difficulty level
  Future<List<ContentItem>> getContentByDifficulty(DifficultyLevel difficulty) async {
    try {
      return await _dataService.getContentByDifficulty(difficulty);
    } catch (e, stack) {
      _logger.error('Failed to get content by difficulty', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get content by tags
  Future<List<ContentItem>> getContentByTags(List<String> tags) async {
    try {
      return await _dataService.getContentByTags(tags);
    } catch (e, stack) {
      _logger.error('Failed to get content by tags', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Search content with advanced filtering
  Future<List<ContentItem>> searchContent({
    String? query,
    ContentType? type,
    DifficultyLevel? difficulty,
    List<String>? tags,
    int limit = 50,
  }) async {
    try {
      return await _dataService.searchContent(
        query: query,
        type: type,
        difficulty: difficulty,
        tags: tags,
        limit: limit,
      );
    } catch (e, stack) {
      _logger.error('Failed to search content', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get recommended content for user
  Future<List<ContentItem>> getRecommendedContent({
    required String userId,
    List<String>? completedContentIds,
    List<String>? preferredTags,
    DifficultyLevel? currentLevel,
    int limit = 10,
  }) async {
    try {
      List<ContentItem> candidates = [];

      // Start with user's preferred tags if available
      if (preferredTags != null && preferredTags.isNotEmpty) {
        candidates.addAll(await getContentByTags(preferredTags));
      }

      // If not enough candidates, get by difficulty level
      if (candidates.length < limit && currentLevel != null) {
        final difficultyContent = await getContentByDifficulty(currentLevel);
        candidates.addAll(difficultyContent);
      }

      // Remove already completed content
      if (completedContentIds != null && completedContentIds.isNotEmpty) {
        candidates = candidates.where((content) => 
            !completedContentIds.contains(content.id)).toList();
      }

      // Remove duplicates
      final seenIds = <String>{};
      candidates = candidates.where((content) => seenIds.add(content.id)).toList();

      // Sort by relevance
      candidates.sort((a, b) {
        int scoreA = _calculateRecommendationScore(a, preferredTags, currentLevel);
        int scoreB = _calculateRecommendationScore(b, preferredTags, currentLevel);
        
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        
        // Secondary sort by creation date (newer first)
        return b.createdAt.compareTo(a.createdAt);
      });

      return candidates.take(limit).toList();
    } catch (e, stack) {
      _logger.error('Failed to get recommended content', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === CURRICULUM OPERATIONS ===

  /// Get curriculum by ID with caching
  Future<Curriculum?> getCurriculum(String curriculumId, {bool useCache = true}) async {
    try {
      // Check cache first
      if (useCache && _curriculumCache.containsKey(curriculumId)) {
        return _curriculumCache[curriculumId];
      }

      final curriculum = await _dataService.getCurriculum(curriculumId);
      
      // Cache the result
      if (curriculum != null && useCache) {
        _curriculumCache[curriculumId] = curriculum;
      }

      return curriculum;
    } catch (e, stack) {
      _logger.error('Failed to get curriculum', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get all published curricula
  Future<List<Curriculum>> getPublishedCurricula() async {
    try {
      return await _dataService.getPublishedCurricula();
    } catch (e, stack) {
      _logger.error('Failed to get published curricula', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get curricula by level
  Future<List<Curriculum>> getCurriculaByLevel(CurriculumLevel level) async {
    try {
      return await _dataService.getCurriculaByLevel(level);
    } catch (e, stack) {
      _logger.error('Failed to get curricula by level', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get content items for a curriculum
  Future<List<ContentItem>> getContentForCurriculum(String curriculumId) async {
    try {
      return await _dataService.getContentForCurriculum(curriculumId);
    } catch (e, stack) {
      _logger.error('Failed to get content for curriculum', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get curriculum with populated content
  Future<CurriculumWithContent?> getCurriculumWithContent(String curriculumId) async {
    try {
      final curriculum = await getCurriculum(curriculumId);
      if (curriculum == null) return null;

      final content = await getContentForCurriculum(curriculumId);
      
      return CurriculumWithContent(
        curriculum: curriculum,
        content: content,
      );
    } catch (e, stack) {
      _logger.error('Failed to get curriculum with content', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get recommended curricula for user
  Future<List<Curriculum>> getRecommendedCurricula({
    required String userId,
    CurriculumLevel? currentLevel,
    List<String>? interests,
    int limit = 5,
  }) async {
    try {
      List<Curriculum> curricula = await getPublishedCurricula();

      // Filter by level if specified
      if (currentLevel != null) {
        curricula = curricula.where((curriculum) => 
            curriculum.level == currentLevel).toList();
      }

      // Score and sort curricula
      curricula.sort((a, b) {
        int scoreA = _calculateCurriculumScore(a, interests, currentLevel);
        int scoreB = _calculateCurriculumScore(b, interests, currentLevel);
        
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        
        // Secondary sort by creation date
        return b.createdAt.compareTo(a.createdAt);
      });

      return curricula.take(limit).toList();
    } catch (e, stack) {
      _logger.error('Failed to get recommended curricula', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === STATISTICS AND ANALYTICS ===

  /// Get content statistics
  Future<Map<String, dynamic>> getContentStatistics() async {
    try {
      return await _dataService.getContentStatistics();
    } catch (e, stack) {
      _logger.error('Failed to get content statistics', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get user's content progress for curriculum
  Future<CurriculumProgress> getCurriculumProgress({
    required String curriculumId,
    required List<String> completedContentIds,
  }) async {
    try {
      final curriculum = await getCurriculum(curriculumId);
      if (curriculum == null) {
        throw ServiceException('Curriculum not found: $curriculumId');
      }

      final totalProgress = curriculum.calculateProgress(completedContentIds);
      
      // Calculate module-level progress
      final moduleProgress = <String, double>{};
      for (final module in curriculum.modules) {
        if (module.contentItems.isEmpty) {
          moduleProgress[module.id] = 1.0; // Empty modules are considered complete
          continue;
        }
        
        final moduleCompletedCount = module.contentItems
            .where((contentId) => completedContentIds.contains(contentId))
            .length;
        
        moduleProgress[module.id] = moduleCompletedCount / module.contentItems.length;
      }

      return CurriculumProgress(
        curriculumId: curriculumId,
        totalProgress: totalProgress,
        moduleProgress: moduleProgress,
        completedContentIds: completedContentIds,
        totalContentItems: curriculum.totalContentItems,
        completedContentItems: completedContentIds.length,
      );
    } catch (e, stack) {
      _logger.error('Failed to get curriculum progress', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === CACHE MANAGEMENT ===

  /// Clear all caches
  void clearCache() {
    _contentCache.clear();
    _curriculumCache.clear();
    _contentByTypeCache.clear();
    _logger.info('Content cache cleared');
  }

  /// Clear specific content from cache
  void clearContentFromCache(String contentId) {
    _contentCache.remove(contentId);
    // Also clear type caches that might contain this content
    _contentByTypeCache.clear();
  }

  /// Clear specific curriculum from cache
  void clearCurriculumFromCache(String curriculumId) {
    _curriculumCache.remove(curriculumId);
  }

  // === UTILITY METHODS ===

  /// Calculate recommendation score for content item
  int _calculateRecommendationScore(
    ContentItem content,
    List<String>? preferredTags,
    DifficultyLevel? currentLevel,
  ) {
    int score = 0;

    // Tag overlap score (most important)
    if (preferredTags != null) {
      final tagOverlap = content.tags.where((tag) => preferredTags.contains(tag)).length;
      score += tagOverlap * 10;
    }

    // Difficulty match score
    if (currentLevel != null) {
      if (content.difficulty == currentLevel) {
        score += 5;
      } else {
        // Slight penalty for difficulty mismatch
        final difficultyDiff = (content.difficulty.index - currentLevel.index).abs();
        score -= difficultyDiff * 2;
      }
    }

    // Content type bonus (interactive content gets boost)
    if (content.type == ContentType.interactive || content.type == ContentType.quiz) {
      score += 3;
    }

    // Recency bonus
    final daysSinceCreation = DateTime.now().difference(content.createdAt).inDays;
    if (daysSinceCreation < 30) {
      score += 2;
    }

    return score;
  }

  /// Calculate curriculum recommendation score
  int _calculateCurriculumScore(
    Curriculum curriculum,
    List<String>? interests,
    CurriculumLevel? currentLevel,
  ) {
    int score = 0;

    // Level match
    if (currentLevel != null && curriculum.level == currentLevel) {
      score += 10;
    }

    // Interest overlap (check curriculum metadata)
    if (interests != null) {
      final curriculumTags = curriculum.metadata['tags'] as List<String>? ?? [];
      final overlap = curriculumTags.where((tag) => 
          interests.any((interest) => 
              tag.toLowerCase().contains(interest.toLowerCase()))).length;
      score += overlap * 5;
    }

    // Completion time preference (moderate duration gets bonus)
    final durationHours = curriculum.estimatedTotalDuration.inHours;
    if (durationHours >= 10 && durationHours <= 40) {
      score += 3;
    }

    return score;
  }
}

/// Helper class for curriculum with populated content
class CurriculumWithContent {
  final Curriculum curriculum;
  final List<ContentItem> content;

  const CurriculumWithContent({
    required this.curriculum,
    required this.content,
  });

  /// Get content items for a specific module
  List<ContentItem> getContentForModule(String moduleId) {
    final module = curriculum.getModule(moduleId);
    if (module == null) return [];

    return content.where((item) => module.contentItems.contains(item.id)).toList();
  }
}

/// Helper class for curriculum progress tracking
class CurriculumProgress {
  final String curriculumId;
  final double totalProgress;
  final Map<String, double> moduleProgress;
  final List<String> completedContentIds;
  final int totalContentItems;
  final int completedContentItems;

  const CurriculumProgress({
    required this.curriculumId,
    required this.totalProgress,
    required this.moduleProgress,
    required this.completedContentIds,
    required this.totalContentItems,
    required this.completedContentItems,
  });

  /// Check if curriculum is completed
  bool get isCompleted => totalProgress >= 1.0;

  /// Get completion percentage as integer
  int get completionPercentage => (totalProgress * 100).round();

  /// Get next incomplete module
  String? get nextIncompleteModule {
    for (final entry in moduleProgress.entries) {
      if (entry.value < 1.0) {
        return entry.key;
      }
    }
    return null;
  }
}
