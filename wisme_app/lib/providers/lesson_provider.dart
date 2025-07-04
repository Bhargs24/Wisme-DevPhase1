import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../services/gpt_service.dart';
import '../services/tts_service.dart';
import '../models/lesson_model.dart';
import '../models/topic_model.dart';
import '../utils/logger.dart';

class LessonProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final GPTService _gptService;
  final TTSService _ttsService;

  List<ContentBlock> _contentBlocks = [];
  List<LearningJourney> _userJourneys = [];
  List<TopicAnalysis> _availableTopics = [];
  ContentBlock? _currentBlock;
  LearningJourney? _currentJourney;
  List<BlockProgress> _currentProgress = [];
  
  bool _isLoading = false;
  bool _isGenerating = false;
  bool _isCreatingJourney = false;
  String? _error;

  LessonProvider({
    required FirestoreService firestoreService,
    required GPTService gptService,
    required TTSService ttsService,
  }) : _firestoreService = firestoreService,
       _gptService = gptService,
       _ttsService = ttsService;

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
}
