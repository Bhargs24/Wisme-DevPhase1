import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/gpt_service.dart';
import '../services/tts_service.dart';
import '../services/content_matching_service.dart';
import '../services/cache_service.dart';
import '../models/topic_model.dart';
import '../models/content_block.dart';
import '../utils/logger.dart';

/// Industrial-grade LessonProvider for AI-powered content management
class LessonProvider extends ChangeNotifier {
  // ignore: unused_field
  final FirestoreService _firestoreService; // For future Firestore integration
  final GPTService _gptService;
  final TTSService _ttsService;
  // ignore: unused_field
  final ContentMatchingService _contentMatchingService; // For future content matching
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
          // Convert cached data to ContentBlock objects
          _contentBlocks = cached.map((data) => ContentBlock.fromFirestore(data)).toList();
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

  int _mapDifficultyToLevel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 3;
      case 'advanced':
        return 5;
      default:
        return 3;
    }
  }

  String _getVoiceIdForCoach(String coach) {
    switch (coach.toLowerCase()) {
      case 'kai':
        return 'voice_kai_strategic';
      case 'vee':
        return 'voice_vee_energetic';
      default:
        return 'voice_default';
    }
  }

  List<String> _extractKeywords(String topic, String script) {
    // Simple keyword extraction - in production this would be more sophisticated
    final words = script.toLowerCase().split(' ');
    return words.take(10).toList();
  }

  List<String> _generateLearningOutcomes(String topic) {
    return [
      'Understand key concepts of $topic',
      'Apply knowledge practically',
      'Develop expertise in the field',
    ];
  }

  Future<void> _generateAudioForBlock(ContentBlock block) async {
    try {
      if (block.transcript.isNotEmpty) {
        await _ttsService.generateAudio(
          block.transcript,
          voiceId: block.voiceId,
        );
        
        // Audio URL would be updated in the block in a real implementation
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
    clearData();
    await loadContentBlocks();
  }
}
