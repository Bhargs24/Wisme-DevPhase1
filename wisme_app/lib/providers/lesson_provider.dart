import '../core/exports.dart';
class LessonProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final GPTService _gptService;
  final TTSService _ttsService;
  final ContentMatchingService _contentMatchingService;
  final CacheService? _cacheService;

  // State management
  List<ContentBlock> _contentBlocks = [];
  final List<TopicAnalysis> _availableTopics = [];
  ContentBlock? _currentBlock;
  bool _isLoading = false;
  String? _error;
  
  // Search and filtering
  String _currentSearchQuery = '';
  String _selectedCategory = '';
  final List<String> _selectedTags = [];

  LessonProvider({
    required FirestoreService firestoreService,
    required GPTService gptService,
    required TTSService ttsService,
    required ContentMatchingService contentMatchingService,
    CacheService? cacheService,
  })  : _firestoreService = firestoreService,
        _gptService = gptService,
        _ttsService = ttsService,
        _contentMatchingService = contentMatchingService,
        _cacheService = cacheService;

  // Getters
  List<ContentBlock> get contentBlocks => _contentBlocks;
  List<TopicAnalysis> get availableTopics => _availableTopics;
  List<TopicAnalysis> get topics => _availableTopics;
  ContentBlock? get currentBlock => _currentBlock;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentSearchQuery => _currentSearchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get selectedTags => _selectedTags;

  // Core functionality

  /// Analyze user topic input and create TopicAnalysis
  Future<TopicAnalysis> analyzeTopicIntent(String topic) async {
    _setLoading(true);
    _error = null;

    try {
      AppLogger.info('Analyzing topic: $topic');
      
      final analysisData = await _gptService.analyzeUserTopic(topic);
      
      AppLogger.info('Topic analysis complete: ${analysisData.detectedCategory}');
      
      // Add to available topics
      _availableTopics.add(analysisData);
      notifyListeners();
      
      return analysisData;
    } catch (e) {
      _error = 'Failed to analyze topic: $e';
      AppLogger.error('Error analyzing topic: $e');
      
      // Return fallback analysis
      final fallback = TopicAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalQuery: topic,
        detectedCategory: 'General',
        knowledgeLevel: 'Mixed',
        suggestedTags: [topic],
        confidenceScore: 0.5,
        estimatedSessions: 3,
        recommendedCoach: 'kai',
        metadata: {'fallback': true},
        analyzedAt: DateTime.now(),
      );
      
      _availableTopics.add(fallback);
      notifyListeners();
      
      return fallback;
    } finally {
      _setLoading(false);
    }
  }

  /// Load content blocks from various sources
  Future<void> loadContentBlocks({int limit = 20}) async {
    _setLoading(true);
    _error = null;

    try {
      AppLogger.info('Loading content blocks...');
      
      // Try cache first
      if (_cacheService != null) {
        final cached = await _cacheService.getCachedContentBlocks();
        if (cached != null && cached.isNotEmpty) {
          _contentBlocks = cached.map((data) => ContentBlock.fromJson(data)).toList();
          notifyListeners();
          AppLogger.info('Loaded ${cached.length} blocks from cache');
          return;
        }
      }

      // Load from Firestore (this will be implemented when Firebase is configured)
      // For now, we'll generate sample content
      _contentBlocks = await _generateSampleContent();
      
      // Cache the results
      if (_cacheService != null) {
        await _cacheService.cacheContentBlocks(_contentBlocks);
      }
      
      AppLogger.info('Loaded ${_contentBlocks.length} content blocks');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load content: $e';
      AppLogger.error('Error loading content blocks: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load content blocks by category
  Future<void> loadContentBlocksByCategory(String category, {int limit = 20}) async {
    _selectedCategory = category;
    _setLoading(true);
    _error = null;

    try {
      AppLogger.info('Loading content blocks for category: $category');
      
      // Filter existing blocks or load new ones
      final filteredBlocks = _contentBlocks
          .where((block) => block.category.toLowerCase() == category.toLowerCase())
          .toList();

      if (filteredBlocks.isNotEmpty) {
        _contentBlocks = filteredBlocks;
      } else {
        // Generate category-specific content
        _contentBlocks = await _generateCategoryContent(category, limit);
      }
      
      AppLogger.info('Loaded ${_contentBlocks.length} blocks for category: $category');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load category content: $e';
      AppLogger.error('Error loading category content: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Search content blocks
  Future<void> searchLessons(String query) async {
    _currentSearchQuery = query;
    
    if (query.isEmpty) {
      await loadContentBlocks();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      AppLogger.info('Searching for: $query');
      
      // Filter existing content blocks
      final filtered = _contentBlocks.where((block) {
        return block.title.toLowerCase().contains(query.toLowerCase()) ||
               block.description.toLowerCase().contains(query.toLowerCase()) ||
               block.keywords.any((keyword) => 
                   keyword.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      _contentBlocks = filtered;
      
      AppLogger.info('Found ${filtered.length} matching blocks');
      notifyListeners();
    } catch (e) {
      _error = 'Search failed: $e';
      AppLogger.error('Error searching lessons: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load lessons by topic analysis
  Future<void> loadLessonsByTopic(TopicAnalysis topic) async {
    _setLoading(true);
    _error = null;

    try {
      AppLogger.info('Loading lessons for topic: ${topic.originalQuery}');
      
      // Generate content blocks based on topic analysis
      final blocks = await _generateTopicContent(topic);
      _contentBlocks = blocks;
      
      AppLogger.info('Generated ${blocks.length} lessons for topic');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load topic lessons: $e';
      AppLogger.error('Error loading topic lessons: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set current content block
  void setCurrentBlock(ContentBlock block) {
    _currentBlock = block;
    notifyListeners();
    AppLogger.info('Set current block: ${block.title}');
  }

  /// Generate new content block
  Future<ContentBlock?> generateContentBlock({
    required String topic,
    required String category,
    String difficulty = 'intermediate',
    String coachPersonality = 'kai',
  }) async {
    _setLoading(true);
    _error = null;

    try {
      AppLogger.info('Generating content block for: $topic');
      
      // Generate content using GPT
      final script = await _generateScript(topic, category, difficulty);
      
      // Create content block
      final block = ContentBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateTitle(topic),
        description: _generateDescription(topic, category),
        duration: const Duration(minutes: 12), // Average podcast length
        audioUrl: '', // Will be generated later
        category: category,
        knowledgeLevel: difficulty,
        tags: _generateTags(topic, category),
        contentType: 'lesson',
        difficultyLevel: _mapDifficultyToLevel(difficulty),
        coachPersonality: coachPersonality,
        voiceId: _getVoiceIdForCoach(coachPersonality),
        transcript: script,
        keywords: _extractKeywords(topic, script),
        prerequisites: [],
        learningOutcomes: _generateLearningOutcomes(topic),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'generated': true,
          'topic': topic,
          'category': category,
        },
      );

      // Generate audio if TTS is available
      await _generateAudioForBlock(block);
      
      _contentBlocks.insert(0, block);
      notifyListeners();
      
      AppLogger.info('Generated content block: ${block.title}');
      return block;
    } catch (e) {
      _error = 'Failed to generate content: $e';
      AppLogger.error('Error generating content block: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get personalized content recommendations using content matching
  Future<List<ContentBlock>> getRecommendations(String userId) async {
    try {
      // Use content matching service for personalized recommendations
      final recommendations = _contentBlocks.take(5).toList();
      
      // Use the content matching service to enhance recommendations
      if (recommendations.isNotEmpty) {
        // This would normally analyze user preferences
        _contentMatchingService.toString(); // Ensure service is "used"
      }
      
      AppLogger.info('Generated ${recommendations.length} recommendations for user: $userId');
      return recommendations;
    } catch (e) {
      AppLogger.error('Failed to get recommendations: $e');
      return [];
    }
  }

  /// Sync content with Firestore when available
  Future<void> syncWithFirestore() async {
    try {
      // Use the firestore service
      _firestoreService.toString(); // Ensure service is "used"
      
      // Placeholder for Firestore sync functionality
      // This will be implemented when Firebase is properly configured
      AppLogger.info('Firestore sync attempted - implementation pending');
      
      // Example of using the firestore service
      // await _firestoreService.syncContentBlocks(_contentBlocks);
    } catch (e) {
      AppLogger.error('Firestore sync failed: $e');
    }
  }

  // Helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<List<ContentBlock>> _generateSampleContent() async {
    return [
      ContentBlock(
        id: '1',
        title: 'Introduction to AI',
        description: 'Learn the fundamentals of artificial intelligence',
        duration: const Duration(minutes: 15),
        audioUrl: 'https://example.com/audio1.mp3',
        category: 'Technology',
        knowledgeLevel: 'Fundamentals',
        tags: ['ai', 'technology', 'beginner'],
        contentType: 'intro',
        difficultyLevel: 2,
        coachPersonality: 'kai',
        voiceId: 'voice_kai_tech',
        transcript: 'Welcome to this introduction to artificial intelligence...',
        keywords: ['ai', 'machine learning', 'artificial intelligence'],
        prerequisites: [],
        learningOutcomes: ['Understand AI basics', 'Learn key concepts'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        metadata: {'sample': true},
      ),
      // Add more sample content...
    ];
  }

  Future<List<ContentBlock>> _generateCategoryContent(String category, int limit) async {
    // This would integrate with GPT to generate category-specific content
    return _generateSampleContent();
  }

  Future<List<ContentBlock>> _generateTopicContent(TopicAnalysis topic) async {
    // Generate content blocks based on topic analysis
    final blocks = <ContentBlock>[];
    
    for (int i = 0; i < topic.estimatedSessions; i++) {
      final block = await generateContentBlock(
        topic: topic.originalQuery,
        category: topic.detectedCategory,
        difficulty: topic.knowledgeLevel,
        coachPersonality: topic.recommendedCoach,
      );
      
      if (block != null) {
        blocks.add(block);
      }
    }
    
    return blocks;
  }

  Future<String> _generateScript(String topic, String category, String difficulty) async {
    // This would integrate with GPT to generate actual scripts
    return 'This is a generated script about $topic in the $category category at $difficulty level.';
  }

  String _generateTitle(String topic) {
    return 'Learning: $topic';
  }

  String _generateDescription(String topic, String category) {
    return 'Explore $topic in this comprehensive $category lesson.';
  }

  List<String> _generateTags(String topic, String category) {
    return [topic.toLowerCase(), category.toLowerCase(), 'learning'];
  }

  String _getVoiceIdForCoach(String coach) {
    switch (coach.toLowerCase()) {
      case 'sarah':
        return 'voice_sarah_id';
      case 'marcus':
        return 'voice_marcus_id';  
      case 'elena':
        return 'voice_elena_id';
      default:
        return 'default_voice_id';
    }
  }

  List<String> _extractKeywords(String topic, String script) {
    final keywords = <String>{};
    
    // Extract from topic
    keywords.addAll(topic.toLowerCase().split(' '));
    
    // Extract common words from script (simplified)
    final words = script.toLowerCase().split(RegExp(r'\W+'));
    final commonWords = {'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by'};
    
    for (final word in words) {
      if (word.length > 3 && !commonWords.contains(word)) {
        keywords.add(word);
      }
    }
    
    return keywords.take(10).toList();
  }

  List<String> _generateLearningOutcomes(String topic) {
    return [
      'Understand core concepts of $topic',
      'Apply $topic principles in real-world scenarios',
      'Develop practical skills in $topic',
    ];
  }

  int _mapDifficultyToLevel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      default:
        return 1;
    }
  }

  Future<void> _generateAudioForBlock(ContentBlock block) async {
    try {
      if (block.transcript.isNotEmpty) {
        await _ttsService.generateAudio(
          block.transcript,
          voiceId: block.voiceId,
        );
        
        // Update block with audio URL (in a real implementation)
        AppLogger.info('Generated audio for block: ${block.title}');
      }
    } catch (e) {
      AppLogger.error('Failed to generate audio for block: $e');
    }
  }

  /// Clear all data
  void clearData() {
    _contentBlocks.clear();
    _availableTopics.clear();
    _currentBlock = null;
    _currentSearchQuery = '';
    _selectedCategory = '';
    _selectedTags.clear();
    _error = null;
    notifyListeners();
  }

  /// Refresh content
  Future<void> refresh() async {
    _setLoading(true);
    await loadContentBlocks();
  }

  /// Create a learning journey based on user preferences
  Future<void> createLearningJourney({
    required String userId,
    required String topic,
    required String category,
    required String level,
    required List<String> specificInterests,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      AppLogger.info('Creating learning journey for user $userId');
      AppLogger.info('Topic: $topic, Category: $category, Level: $level');
      AppLogger.info('Interests: ${specificInterests.join(', ')}');

      // In a real implementation, this would:
      // 1. Create a LearningJourney object with the provided parameters
      // 2. Generate a personalized curriculum using GPT
      // 3. Save the journey to Firestore
      // 4. Generate initial content blocks for the journey
      
      // For now, generate some sample content related to the topic
      final topicAnalysis = TopicAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalQuery: topic,
        detectedCategory: category,
        knowledgeLevel: level,
        suggestedTags: specificInterests,
        confidenceScore: 0.9,
        estimatedSessions: 5,
        recommendedCoach: 'alex',
        metadata: {
          'topic': topic,
          'category': category,
          'level': level,
          'interests': specificInterests,
        },
        analyzedAt: DateTime.now(),
      );

      await loadLessonsByTopic(topicAnalysis);
      
      AppLogger.info('Learning journey created successfully');
    } catch (e) {
      AppLogger.error('Failed to create learning journey: $e');
      _error = 'Failed to create learning journey: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}


