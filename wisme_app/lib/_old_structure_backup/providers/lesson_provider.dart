import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/gpt_service.dart';
import '../services/tts_service.dart';
import '../services/content_matching_service.dart';
import '../services/performance_service.dart';
import '../services/analytics_service.dart';
import '../services/cache_service.dart';
import '../models/lesson_model.dart';
import '../models/topic_model.dart';
import '../models/content_matching_model.dart';
import '../utils/logger.dart';

class LessonProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final GPTService _gptService;
  final TTSService _ttsService;
  final ContentMatchingService _contentMatchingService;
  final CacheService? _cacheService;

  List<ContentBlock> _contentBlocks = [];
  List<LearningJourney> _userJourneys = [];
  List<TopicAnalysis> _availableTopics = [];
  ContentBlock? _currentBlock;
  LearningJourney? _currentJourney;
  List<BlockProgress> _currentProgress = [];
  
  // Content matching state
  List<ContentMatch> _lastMatches = [];
  ContentAssembly? _currentAssembly;

  bool _isLoading = false;
  bool _isGenerating = false;
  bool _isCreatingJourney = false;
  String? _error;

  LessonProvider({
    required FirestoreService firestoreService,
    required GPTService gptService,
    required TTSService ttsService,
    required ContentMatchingService contentMatchingService,
    CacheService? cacheService,
  }) : _firestoreService = firestoreService,
       _gptService = gptService,
       _ttsService = ttsService,
       _contentMatchingService = contentMatchingService,
       _cacheService = cacheService;

  // Getters
  List<ContentBlock> get contentBlocks => _contentBlocks;
  List<LearningJourney> get userJourneys => _userJourneys;
  List<TopicAnalysis> get availableTopics => _availableTopics;
  ContentBlock? get currentBlock => _currentBlock;
  LearningJourney? get currentJourney => _currentJourney;
  List<BlockProgress> get currentProgress => _currentProgress;
  
  // Add missing getters and aliases for UI compatibility
  List<TopicAnalysis> get topics => _availableTopics;
  List<ContentBlock> get lessons => _contentBlocks;
  
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  bool get isCreatingJourney => _isCreatingJourney;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Analyze topic intent using AI
  Future<TopicAnalysis> analyzeTopicIntent(String topic) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('Analyzing topic intent: $topic');
      
      // Use GPT service to analyze the topic
      final analysisData = await _gptService.analyzeTopicIntent(topic);
      final analysis = TopicAnalysis.fromGPTResponse(analysisData);
      
      AppLogger.info('Topic analysis complete: ${analysis.suggestedCategory}');
      return analysis;
      
    } catch (e) {
      AppLogger.error('Failed to analyze topic intent: $e');
      _error = 'Failed to analyze topic';
      
      // Return a fallback analysis
      return TopicAnalysis(
        originalTopic: topic,
        category: 'General',
        intent: 'Learn about $topic',
        difficulty: 'beginner',
        keywords: [topic],
        interpretation: 'You want to learn about $topic',
        suggestedCategory: 'General Learning',
        reasoning: 'This is a general learning topic',
        confidence: 0.5,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load content blocks by topic
  Future<void> loadContentBlocksByTopic(String topic, {int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contentBlocks = await _firestoreService.getContentBlocks(limit: limit);
      AppLogger.info('Loaded ${_contentBlocks.length} content blocks for topic: $topic');
    } catch (e) {
      AppLogger.error('Failed to load content blocks: $e');
      _error = 'Failed to load content blocks';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load content blocks by category
  Future<void> loadContentBlocksByCategory(String category, {int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contentBlocks = await _firestoreService.getContentBlocks(category: category, limit: limit);
      AppLogger.info('Loaded ${_contentBlocks.length} content blocks for category: $category');
    } catch (e) {
      AppLogger.error('Failed to load content blocks: $e');
      _error = 'Failed to load content blocks';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's learning journeys
  Future<void> loadUserJourneys(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userJourneys = await _firestoreService.getUserJourneys(userId);
      AppLogger.info('Loaded ${_userJourneys.length} journeys for user: $userId');
    } catch (e) {
      AppLogger.error('Failed to load user journeys: $e');
      _error = 'Failed to load learning journeys';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load topics by category
  Future<void> loadTopicsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, create placeholder topics - in a real app these would come from Firestore
      _availableTopics = [
        TopicAnalysis(
          originalTopic: 'AI & Machine Learning',
          category: category,
          intent: 'learn',
          difficulty: 'intermediate',
          keywords: ['ai', 'ml', 'technology'],
        ),
      ];
      AppLogger.info('Loaded ${_availableTopics.length} topics for category: $category');
    } catch (e) {
      AppLogger.error('Failed to load topics: $e');
      _error = 'Failed to load topics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set current content block
  void setCurrentBlock(ContentBlock block) {
    _currentBlock = block;
    notifyListeners();
    
    // Track access
    // Log block access for analytics
    AppLogger.info('Setting current block: ${block.id}');
  }

  // Set current learning journey
  Future<void> setCurrentJourney(LearningJourney journey, String userId) async {
    _currentJourney = journey;
    
    // Load progress for this journey
    try {
      _currentProgress = await _firestoreService.getUserBlockProgress(userId);
    } catch (e) {
      AppLogger.error('Failed to load journey progress: $e');
    }
    
    notifyListeners();
  }

  // Generate new content block using AI
  Future<ContentBlock?> generateContentBlock({
    required String topic,
    required String category,
    required String contentType,
    required String difficulty,
    String? coachId,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      // Generate content using GPT
      final generatedContent = await _gptService.generateContentBlock(
        topic: topic,
        category: category,
        level: difficulty,
        contentType: contentType,
      );

      // Create content block
      final block = ContentBlock(
        id: '', // Will be set by Firestore
        category: category,
        topic: topic,
        contentType: contentType,
        difficulty: difficulty,
        title: generatedContent['title'] ?? 'Untitled',
        script: generatedContent['script'] ?? '',
        tags: List<String>.from(generatedContent['tags'] ?? []),
        prerequisites: List<String>.from(generatedContent['prerequisites'] ?? []),
        duration: Duration(
          seconds: generatedContent['estimatedDurationSeconds'] ?? 300,
        ),
        metadata: generatedContent['metadata'] ?? {},
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final blockId = await _firestoreService.createContentBlock(block);
      final savedBlock = block.copyWith(metadata: {'id': blockId});
      
      AppLogger.info('Generated and saved content block: $blockId');
      return savedBlock;
    } catch (e) {
      AppLogger.error('Failed to generate content block: $e');
      _error = 'Failed to generate content';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
    return null;
  }

  // Create learning journey using AI
  Future<LearningJourney?> createLearningJourney({
    required String userId,
    required String topic,
    required String category,
    required String level,
    List<String>? specificInterests,
  }) async {
    _isCreatingJourney = true;
    _error = null;
    notifyListeners();

    try {
      // Generate journey using GPT
      final journeyData = await _gptService.createLearningJourney(
        topic: topic,
        category: category,
        level: level,
        durationDays: 7, // Default 7-day journey
        existingKnowledge: specificInterests,
      );

      // Create learning journey
      final journey = LearningJourney(
        id: '', // Will be set by Firestore
        userId: userId,
        topic: topic,
        category: category,
        level: level,
        title: journeyData['title'] ?? 'Learning Journey',
        description: journeyData['description'] ?? '',
        blockIds: List<String>.from(journeyData['blockIds'] ?? []),
        estimatedDuration: Duration(
          minutes: journeyData['estimatedDurationMinutes'] ?? 60,
        ),
        totalBlocks: journeyData['totalBlocks'] ?? 0,
        createdAt: DateTime.now(),
        metadata: journeyData['metadata'] ?? {},
      );

      // Save to Firestore
      final journeyId = await _firestoreService.createLearningJourney(journey);
      
      // Add to user journeys
      _userJourneys.insert(0, journey);
      
      AppLogger.info('Created learning journey: $journeyId');
      return journey;
    } catch (e) {
      AppLogger.error('Failed to create learning journey: $e');
      _error = 'Failed to create learning journey';
    } finally {
      _isCreatingJourney = false;
      notifyListeners();
    }
    return null;
  }

  // Generate audio for content block
  Future<bool> generateAudioForBlock(ContentBlock block, String voiceId) async {
    try {
      final audioData = await _ttsService.generateSpeech(
        text: block.script,
        coachId: voiceId, // Using coachId parameter as it maps to voiceId
      );

      if (audioData.isNotEmpty) {
        // In a real implementation, you would:
        // 1. Upload audioData to cloud storage
        // 2. Get the download URL
        // 3. Update the content block with the URL
        
        // For now, we'll create a placeholder URL
        final audioUrl = 'generated_audio_${block.id}.mp3';
        
        // Update content block with audio URL
        await _firestoreService.updateContentBlock(block.id, {
          'audioUrl': audioUrl,
        });

        // Update local block
        final updatedBlock = block.copyWith(audioUrl: audioUrl);
        final index = _contentBlocks.indexWhere((b) => b.id == block.id);
        if (index != -1) {
          _contentBlocks[index] = updatedBlock;
        }
        
        if (_currentBlock?.id == block.id) {
          _currentBlock = updatedBlock;
        }

        notifyListeners();
        AppLogger.info('Generated audio for block: ${block.id}');
        return true;
      }
    } catch (e) {
      AppLogger.error('Failed to generate audio: $e');
      _error = 'Failed to generate audio';
      notifyListeners();
    }
    return false;
  }

  // Update block progress
  Future<void> updateBlockProgress(BlockProgress progress) async {
    try {
      await _firestoreService.saveBlockProgress(progress.userId, progress.blockId, progress);
      
      // Update local progress
      final index = _currentProgress.indexWhere((p) => 
          p.blockId == progress.blockId && p.userId == progress.userId);
      
      if (index != -1) {
        _currentProgress[index] = progress;
      } else {
        _currentProgress.add(progress);
      }
      
      notifyListeners();
      AppLogger.info('Updated block progress: ${progress.blockId}');
    } catch (e) {
      AppLogger.error('Failed to update block progress: $e');
    }
  }

  // Mark block as completed
  Future<void> completeBlock(String userId, String blockId, String journeyId) async {
    try {
      final progress = BlockProgress(
        userId: userId,
        blockId: blockId,
        journeyId: journeyId,
        isCompleted: true,
        completedAt: DateTime.now(),
        listeningTime: Duration.zero, // Should be updated with actual time
        lastPosition: Duration.zero,
        completionPercentage: 100.0,
      );

      await updateBlockProgress(progress);
      
      // Update journey progress if needed
      if (_currentJourney != null) {
        await _updateJourneyProgress(_currentJourney!, userId);
      }
    } catch (e) {
      AppLogger.error('Failed to complete block: $e');
    }
  }

  // Search content blocks
  Future<void> searchContentBlocks(String query, {int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contentBlocks = await _firestoreService.searchContentBlocks(query);
      AppLogger.info('Found ${_contentBlocks.length} content blocks for query: $query');
    } catch (e) {
      AppLogger.error('Failed to search content blocks: $e');
      _error = 'Failed to search content';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get recommendations based on user preferences
  Future<List<ContentBlock>> getRecommendations(String userId, {int limit = 10}) async {
    try {
      // This could be enhanced with AI-based recommendations
      // For now, return popular content blocks
      return await _firestoreService.getContentBlocks(category: 'popular', limit: limit);
    } catch (e) {
      AppLogger.error('Failed to get recommendations: $e');
      return [];
    }
  }

  // Update journey progress
  Future<void> _updateJourneyProgress(LearningJourney journey, String userId) async {
    try {
      final completedBlocks = _currentProgress.where((p) => p.isCompleted).length;
      
      await _firestoreService.updateLearningJourney(journey.id, {
        'completedBlocks': completedBlocks,
        'completedAt': completedBlocks == journey.totalBlocks ? DateTime.now() : null,
      });

      // Update local journey
      final index = _userJourneys.indexWhere((j) => j.id == journey.id);
      if (index != -1) {
        _userJourneys[index] = journey.copyWith(
          completedBlocks: completedBlocks,
          completedAt: completedBlocks == journey.totalBlocks ? DateTime.now() : null,
        );
      }

      if (_currentJourney?.id == journey.id) {
        _currentJourney = journey.copyWith(
          completedBlocks: completedBlocks,
          completedAt: completedBlocks == journey.totalBlocks ? DateTime.now() : null,
        );
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to update journey progress: $e');
    }
  }

  // Clear all data
  void clear() {
    _contentBlocks.clear();
    _userJourneys.clear();
    _availableTopics.clear();
    _currentBlock = null;
    _currentJourney = null;
    _currentProgress.clear();
    _lastMatches.clear();
    _currentAssembly = null;
    _error = null;
    notifyListeners();
  }

  // Missing methods for UI compatibility
  Future<void> loadLessonsByTopic(TopicAnalysis topic) async {
    await loadContentBlocksByTopic(topic.originalTopic);
  }

  Future<void> refreshLessons() async {
    if (_availableTopics.isNotEmpty) {
      await loadContentBlocksByTopic(_availableTopics.first.originalTopic);
    }
  }

  void searchLessons(String query) {
    if (query.isEmpty) {
      // Reset to all lessons
      return;
    }
    // Filter lessons based on query
    _contentBlocks = _contentBlocks.where((lesson) =>
        lesson.title.toLowerCase().contains(query.toLowerCase()) ||
        lesson.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
    notifyListeners();
  }

  Future<ContentBlock?> generateLesson(String topic, String description) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      // Use GPT service to generate content block
      final lessonData = await _gptService.generateContentBlock(
        topic: topic,
        category: 'Generated',
        level: 'beginner',
        contentType: 'story',
        coachPersonality: 'encouraging',
      );
      
      // Create a new content block
      final newLesson = ContentBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: 'Generated',
        topic: topic,
        contentType: 'story',
        difficulty: 'beginner',
        title: lessonData['title'] ?? topic,
        script: lessonData['script'] ?? description,
        tags: [topic],
        duration: const Duration(minutes: 5),
        createdAt: DateTime.now(),
      );

      // Add to firestore
      await _firestoreService.createContentBlock(newLesson);
      
      // Add to local list
      _contentBlocks.insert(0, newLesson);
      
      AppLogger.info('Generated new lesson: ${newLesson.title}');
      return newLesson;
    } catch (e) {
      AppLogger.error('Failed to generate lesson: $e');
      _error = 'Failed to generate lesson';
      return null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Getters for content matching
  List<ContentMatch> get lastMatches => _lastMatches;
  ContentAssembly? get currentAssembly => _currentAssembly;

  /// Intelligent content generation with reuse optimization
  Future<ContentBlock?> generateSmartContentBlock({
    required String userId,
    required String topic,
    required String category,
    required String level,
    String? contentType,
    String? userContext,
    bool forceGeneration = false,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('Smart content generation for: $topic');

      // Step 1: Generate hashtags for the topic
      final searchTags = await _contentMatchingService.generateHashtagsForTopic(
        topic: topic,
        category: category,
        level: level,
        contentType: contentType,
        userContext: userContext,
      );

      // Step 2: Find matching existing content (unless forced to generate new)
      if (!forceGeneration) {
        _lastMatches = await _contentMatchingService.findMatchingContent(
          searchTags: searchTags,
          userId: userId,
          maxResults: 5,
          minimumSimilarity: 0.4,
        );

        // Step 3: Check if we have good matches
        if (_lastMatches.isNotEmpty && _lastMatches.first.totalScore > 0.7) {
          AppLogger.info('Found high-quality existing content match');
          
          // Assemble custom content from existing blocks
          _currentAssembly = await _contentMatchingService.assembleCustomContent(
            matches: _lastMatches,
            userId: userId,
            targetDuration: const Duration(minutes: 10),
          );

          if (_currentAssembly!.contentIds.isNotEmpty) {
            // Get the first content block for the assembly
            final existingBlock = await _getContentBlockById(_currentAssembly!.contentIds.first);
            
            if (existingBlock != null) {
              // Track usage
              await _contentMatchingService.updateUserHistory(
                userId: userId,
                contentId: existingBlock.id,
              );

              AppLogger.info('✅ Reused existing content: ${existingBlock.id}');
              notifyListeners();
              return existingBlock;
            }
          }
        }
      }

      // Step 4: Generate new content if no good matches found
      AppLogger.info('Generating new content block');
      final newBlock = await _generateNewContentBlock(
        topic: topic,
        category: category,
        level: level,
        contentType: contentType ?? 'concept',
        userContext: userContext,
      );

      if (newBlock != null) {
        // Generate and save hashtags for the new content
        final contentTags = await _contentMatchingService.generateHashtagsForTopic(
          topic: newBlock.topic,
          category: newBlock.category,
          level: newBlock.difficulty,
          contentType: newBlock.contentType,
        );
        
        await _contentMatchingService.saveContentTags(newBlock.id, contentTags);
        
        AppLogger.info('✅ Generated new content with tags: ${newBlock.id}');
      }

      return newBlock;
    } catch (e) {
      AppLogger.error('Failed to generate smart content: $e');
      _error = 'Failed to generate content';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
    return null;
  }

  /// Rate content to improve future recommendations
  Future<void> rateContent({
    required String userId,
    required String contentId,
    required double rating, // 1-5 stars
    bool? isBookmarked,
    bool? isDisliked,
  }) async {
    try {
      await _contentMatchingService.updateUserHistory(
        userId: userId,
        contentId: contentId,
        userRating: rating,
        isBookmarked: isBookmarked,
        isDisliked: isDisliked,
      );
      
      AppLogger.info('Updated content rating: $contentId -> $rating stars');
    } catch (e) {
      AppLogger.error('Failed to rate content: $e');
    }
  }

  /// Get personalized content recommendations
  Future<List<ContentBlock>> getSmartRecommendations({
    required String userId,
    int maxResults = 5,
    List<String>? preferredCategories,
  }) async {
    try {
      // Generate tags based on user's recent activity
      // This is a simplified version - in production, analyze user's complete history
      final searchTags = await _contentMatchingService.generateHashtagsForTopic(
        topic: 'mixed_learning',
        category: preferredCategories?.first ?? 'Technology',
        level: 'intermediate',
        contentType: 'mixed',
      );

      final matches = await _contentMatchingService.findMatchingContent(
        searchTags: searchTags,
        userId: userId,
        maxResults: maxResults,
        minimumSimilarity: 0.2,
        excludeRecentlyPlayed: false, // Include variety for recommendations
      );

      List<ContentBlock> recommendations = [];
      for (final match in matches) {
        final block = await _getContentBlockById(match.contentId);
        if (block != null) {
          recommendations.add(block);
        }
      }

      AppLogger.info('Generated ${recommendations.length} smart recommendations');
      return recommendations;
    } catch (e) {
      AppLogger.error('Failed to get smart recommendations: $e');
      return [];
    }
  }

  // Helper methods
  Future<ContentBlock?> _getContentBlockById(String blockId) async {
    try {
      // Check if we already have it loaded
      final existingBlock = _contentBlocks.firstWhere(
        (block) => block.id == blockId,
        orElse: () => throw StateError('Not found'),
      );
      return existingBlock;
    } catch (e) {
      // Load from Firestore if not in memory
      try {
        final blocks = await _firestoreService.getContentBlocks();
        final block = blocks.firstWhere(
          (block) => block.id == blockId,
          orElse: () => throw StateError('Not found'),
        );
        return block;
      } catch (e) {
        AppLogger.error('Content block not found: $blockId');
        return null;
      }
    }
  }

  Future<ContentBlock?> _generateNewContentBlock({
    required String topic,
    required String category,
    required String level,
    required String contentType,
    String? userContext,
  }) async {
    // Generate content using GPT
    final generatedContent = await _gptService.generateContentBlock(
      topic: topic,
      category: category,
      level: level,
      contentType: contentType,
      userContext: userContext,
    );

    // Create content block
    final block = ContentBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      topic: topic,
      contentType: contentType,
      difficulty: level,
      title: generatedContent['title'] ?? 'Untitled',
      script: generatedContent['script'] ?? '',
      tags: List<String>.from(generatedContent['tags'] ?? []),
      prerequisites: List<String>.from(generatedContent['prerequisites'] ?? []),
      duration: Duration(
        seconds: generatedContent['estimated_duration'] ?? 300,
      ),
      metadata: generatedContent,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    try {
      final blockId = await _firestoreService.createContentBlock(block);
      final savedBlock = block.copyWith(metadata: {'id': blockId});
      
      // Add to local cache
      _contentBlocks.insert(0, savedBlock);
      
      AppLogger.info('Generated and saved new content block: $blockId');
      return savedBlock;
    } catch (e) {
      AppLogger.error('Failed to save new content block: $e');
      return block; // Return unsaved block
    }
  }

  /// Enhanced content generation with intelligent reuse and caching
  Future<void> generateContentWithReuse(String query, String userId) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      // Track analytics
      AnalyticsService.trackEvent('content_generation_started', {
        'user_id': userId,
        'query': query,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Performance tracking
      final startTime = DateTime.now();

      // First check if we have similar content cached
      String? cachedContent;
      if (_cacheService != null) {
        // Check for similar content in cache
        cachedContent = await _checkCachedContent(query);
      }

      List<ContentBlock> newBlocks;
      
      if (cachedContent != null) {
        // Use cached/reused content with adaptation
        AppLogger.info('Found reusable content for query: $query');
        newBlocks = await _adaptCachedContent(cachedContent, query, userId);
        
        // Track reuse
        PerformanceService.recordMetric('content_reuse_success', 1.0);
        AnalyticsService.trackEvent('content_reused', {
          'user_id': userId,
          'original_query': query,
          'reuse_type': 'cached_adaptation',
        });
      } else {
        // Generate new content
        AppLogger.info('Generating new content for query: $query');
        newBlocks = await _generateNewContent(query, userId);
        
        // Cache the generated content for future reuse
        if (_cacheService != null && newBlocks.isNotEmpty) {
          await _cacheGeneratedContent(query, newBlocks);
        }
        
        // Track new generation
        PerformanceService.recordMetric('content_generated_new', 1.0);
      }

      // Add to content blocks
      _contentBlocks.addAll(newBlocks);

      // Track performance
      final generationTime = DateTime.now().difference(startTime);
      PerformanceService.recordMetric('content_generation_time_ms', generationTime.inMilliseconds.toDouble());

      // Analytics
      AnalyticsService.trackEvent('content_generation_completed', {
        'user_id': userId,
        'query': query,
        'blocks_generated': newBlocks.length,
        'generation_time_ms': generationTime.inMilliseconds,
        'used_cache': cachedContent != null,
      });

      AppLogger.info('Generated ${newBlocks.length} content blocks for query: $query');

    } catch (e) {
      _error = 'Failed to generate content: $e';
      AppLogger.error('Content generation error: $e');
      
      // Track error
      AnalyticsService.trackEvent('content_generation_error', {
        'user_id': userId,
        'query': query,
        'error': e.toString(),
      });
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Check for cached/reusable content  
  Future<String?> _checkCachedContent(String query) async {
    try {
      // Use content matching to find similar content
      final tags = await _contentMatchingService.generateHashtagsForTopic(
        topic: query,
        category: 'general',
        level: 'intermediate',
        contentType: 'story',
      );
      
      // Check if we have content with similar tags
      if (tags.allTags.isNotEmpty) {
        // For now, return null - in production this would check the database
        // This is where you'd implement semantic similarity search
        return null;
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Error checking cached content: $e');
      return null;
    }
  }

  /// Adapt cached content to new query
  Future<List<ContentBlock>> _adaptCachedContent(String cachedContent, String query, String userId) async {
    try {
      // Use GPT to adapt the cached content to the new query
      final response = await _gptService.generateContentBlock(
        topic: query,
        category: 'general',
        level: 'intermediate',
        contentType: 'story',
        userContext: 'Adapt this content: $cachedContent',
      );
      
      // Create new content block
      final block = ContentBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: response['category'] ?? 'general',
        topic: query,
        contentType: 'adapted',
        difficulty: response['level'] ?? 'intermediate',
        title: response['title'] ?? 'Adapted: $query',
        script: response['script'] ?? cachedContent,
        duration: Duration(seconds: response['durationSeconds'] ?? 600),
        createdAt: DateTime.now(),
        metadata: {
          'adapted_from_cache': true,
          'original_query': query,
          'user_id': userId,
        },
      );

      return [block];
    } catch (e) {
      AppLogger.error('Error adapting cached content: $e');
      // Fallback to generating new content
      return await _generateNewContent(query, userId);
    }
  }

  /// Generate completely new content
  Future<List<ContentBlock>> _generateNewContent(String query, String userId) async {
    try {
      // Generate content block directly
      final response = await _gptService.generateContentBlock(
        topic: query,
        category: 'general',
        level: 'intermediate',
        contentType: 'story',
        userContext: 'Generate fresh content for: $query',
      );

      final block = ContentBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: response['category'] ?? 'general',
        topic: query,
        contentType: response['contentType'] ?? 'story',
        difficulty: response['level'] ?? 'intermediate',
        title: response['title'] ?? 'Generated: $query',
        script: response['script'] ?? '',
        duration: Duration(seconds: response['durationSeconds'] ?? 600),
        createdAt: DateTime.now(),
        metadata: {
          'generated_fresh': true,
          'user_id': userId,
          'query': query,
        },
      );

      return [block];
    } catch (e) {
      AppLogger.error('Error generating new content: $e');
      return [];
    }
  }

  /// Cache generated content for future reuse
  Future<void> _cacheGeneratedContent(String query, List<ContentBlock> blocks) async {
    try {
      for (final block in blocks) {
        // Store content in database for future reuse
        await _firestoreService.createContentBlock(block);
        
        // Also cache locally if cache service is available
        if (_cacheService != null) {
          // This would be implemented based on cache service interface
          AppLogger.info('Content cached locally for future reuse');
        }
      }
    } catch (e) {
      AppLogger.error('Error caching generated content: $e');
    }
  }
}
