import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/logger.dart';
import '../models/content_episode_model.dart';
import '../models/background_generation_task_model.dart';
import '../models/content_matching_model.dart';
import '../models/content_segment_model.dart';
import 'content_reuse_service.dart';
import '../../audio/services/audio_segment_library_service.dart';

/// ⚡ Instant content delivery with sub-second response times
/// Handles progressive content streaming, background generation, and instant caching
class InstantDeliveryService {
  final ContentReuseService _contentReuse;
  final AudioSegmentLibraryService _audioLibrary;
  
  // Background generation queue with priority handling
  final List<BackgroundGenerationTask> _backgroundQueue = [];
  final Map<String, ContentEpisode> _instantCache = {};
  
  Timer? _backgroundProcessor;
  bool _isProcessing = false;

  InstantDeliveryService({
    required ContentReuseService contentReuseService,
    required AudioSegmentLibraryService audioLibraryService,
  }) : _contentReuse = contentReuseService,
       _audioLibrary = audioLibraryService {
    _startBackgroundGeneration();
  }

  /// Generate content with instant delivery (sub-second response)
  /// Uses multi-phase delivery: cache -> reuse -> progressive -> background
  Future<ContentEpisode> generateInstantContent({
    required String userId,
    required String topic,
    required String category,
    required String level,
    Duration? targetDuration,
    Map<String, dynamic>? userContext,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // Phase 1: Check instant cache (< 10ms)
      final cacheKey = _generateCacheKey(userId, topic, category, level);
      if (_instantCache.containsKey(cacheKey)) {
        final episode = _instantCache[cacheKey]!;
        AppLogger.info('⚡ INSTANT delivery from cache: ${DateTime.now().difference(startTime).inMilliseconds}ms');
        return episode;
      }

      // Phase 2: Fast content assembly (< 200ms)
      final contentTags = await _generateFastHashtags(topic, category, level);
      final userHistory = await _getUserContentHistory(userId);
      
      final reusableSegments = await _contentReuse.findReusableSegments(
        searchTags: contentTags,
        excludeIds: userHistory,
        maxSegments: 3,
        minimumSimilarity: 0.6,
      );

      // Phase 3: Instant audio assembly if segments available
      if (reusableSegments.isNotEmpty) {
        final assembly = await _contentReuse.assembleContent(
          segments: reusableSegments,
          topic: topic,
          targetDuration: targetDuration ?? const Duration(minutes: 10),
          userId: userId,
        );

        final audioSegments = await _audioLibrary.getAudioSegments(assembly.contentIds);
        
        if (audioSegments.length == assembly.contentIds.length) {
          final userVoice = await _getUserPreferredVoice(userId);
          final assembledAudio = await _audioLibrary.assembleAudio(
            segments: audioSegments,
            voiceId: userVoice,
            addTransitions: true,
          );

          final episode = ContentEpisode(
            id: _generateEpisodeId(),
            title: 'Custom Episode: $topic',
            topic: topic,
            category: category,
            level: level,
            contentBlocks: reusableSegments.map((s) => s.toContentBlock()).toList(),
            audioData: assembledAudio,
            estimatedDuration: assembly.estimatedDuration,
            reuseRate: assembly.customization['reuseRate'] ?? 0.0,
            deliveryTime: DateTime.now().difference(startTime),
            metadata: {
              'delivery_method': 'instant_reuse',
              'assembly_type': assembly.assemblyType,
              'confidence_score': assembly.confidenceScore,
            },
          );

          AppLogger.info('⚡ INSTANT delivery via reuse: ${episode.deliveryTime.inMilliseconds}ms (${((assembly.customization['reuseRate'] ?? 0.0) * 100).toStringAsFixed(1)}% reuse)');
          
          // Cache for future instant delivery
          _instantCache[cacheKey] = episode;
          
          return episode;
        }
      }

      // Phase 4: Progressive delivery (start with cached, enhance in background)
      final progressiveEpisode = await _generateProgressiveContent(
        userId: userId,
        topic: topic,
        category: category,
        level: level,
        targetDuration: targetDuration,
        partialSegments: reusableSegments,
      );

      AppLogger.info('⚡ Progressive delivery: ${DateTime.now().difference(startTime).inMilliseconds}ms');

      // Queue full generation for future instant delivery
      _queueBackgroundGeneration(userId, topic, category, level, targetDuration);

      return progressiveEpisode;
    } catch (e) {
      AppLogger.error('Instant delivery failed: $e');
      rethrow;
    }
  }

  /// Queue a background generation task for future instant delivery
  void queueBackgroundGeneration({
    required String userId,
    required String topic,
    required String category,
    required String level,
    Duration? targetDuration,
    int priority = 1,
  }) {
    final task = BackgroundGenerationTask(
      id: 'bg_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      topic: topic,
      category: category,
      level: level,
      targetDuration: targetDuration,
      priority: priority,
      queuedAt: DateTime.now(),
    );
    
    _backgroundQueue.add(task);
    _backgroundQueue.sort((a, b) => b.priority.compareTo(a.priority)); // High priority first
    
    AppLogger.info('🔄 Queued background generation: $topic (priority: $priority)');
  }

  /// Get background generation queue status
  Map<String, dynamic> getQueueStatus() {
    return {
      'queue_length': _backgroundQueue.length,
      'is_processing': _isProcessing,
      'cache_size': _instantCache.length,
      'next_task': _backgroundQueue.isNotEmpty 
          ? _backgroundQueue.first.topic 
          : null,
    };
  }

  /// Clear instant cache (for memory management)
  void clearCache() {
    _instantCache.clear();
    AppLogger.info('🧹 Instant cache cleared');
  }

  /// Dispose resources
  void dispose() {
    _backgroundProcessor?.cancel();
    _backgroundQueue.clear();
    _instantCache.clear();
  }

  // Private methods

  void _startBackgroundGeneration() {
    _backgroundProcessor = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isProcessing && _backgroundQueue.isNotEmpty) {
        _processBackgroundQueue();
      }
    });
  }

  Future<void> _processBackgroundQueue() async {
    if (_backgroundQueue.isEmpty || _isProcessing) return;

    _isProcessing = true;
    final task = _backgroundQueue.removeAt(0);
    
    try {
      AppLogger.info('🔄 Processing background task: ${task.topic}');
      
      // Generate high-quality content in background
      final episode = await _generateFullQualityContent(task);
      
      // Cache for instant future delivery
      final cacheKey = _generateCacheKey(
        task.userId,
        task.topic,
        task.category,
        task.level,
      );
      _instantCache[cacheKey] = episode;
      
      AppLogger.info('✅ Background generation complete: ${task.topic}');
    } catch (e) {
      AppLogger.error('Background generation failed: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<ContentEpisode> _generateProgressiveContent({
    required String userId,
    required String topic,
    required String category,
    required String level,
    Duration? targetDuration,
    List<ContentSegment>? partialSegments,
  }) async {
    // Generate basic content structure immediately for progressive enhancement
    final quickBlock = await _generateQuickContent(topic, category, level);
    
    return ContentEpisode(
      id: _generateEpisodeId(),
      title: 'Progressive Episode: $topic',
      topic: topic,
      category: category,
      level: level,
      contentBlocks: [quickBlock],
      audioData: Uint8List(0), // Empty audio, to be enhanced later
      estimatedDuration: targetDuration ?? const Duration(minutes: 5),
      reuseRate: partialSegments?.isNotEmpty == true ? 0.3 : 0.0,
      deliveryTime: const Duration(milliseconds: 100),
      metadata: {
        'delivery_method': 'progressive',
        'quality': 'quick_start',
        'enhancement_pending': true,
      },
    );
  }

  Future<ContentBlock> _generateQuickContent(String topic, String category, String level) async {
    // Generate basic content structure immediately
    return ContentBlock(
      id: _generateContentId(),
      category: category,
      topic: topic,
      contentType: 'concept',
      difficulty: level,
      title: 'Introduction to $topic',
      script: 'Welcome to learning about $topic. Let\'s dive in and explore this fascinating subject...',
      duration: const Duration(minutes: 2),
      createdAt: DateTime.now(),
      metadata: {
        'generation_method': 'quick_start',
        'quality': 'basic',
      },
    );
  }

  void _queueBackgroundGeneration(String userId, String topic, String category, String level, Duration? targetDuration) {
    queueBackgroundGeneration(
      userId: userId,
      topic: topic,
      category: category,
      level: level,
      targetDuration: targetDuration,
      priority: 1,
    );
  }

  Future<ContentEpisode> _generateFullQualityContent(BackgroundGenerationTask task) async {
    // Generate full quality content with AI and professional audio
    // This is where we'd call the full GPT + TTS pipeline
    // Placeholder for production implementation
    
    return ContentEpisode(
      id: _generateEpisodeId(),
      title: 'Premium Episode: ${task.topic}',
      topic: task.topic,
      category: task.category,
      level: task.level,
      contentBlocks: [],
      audioData: Uint8List(0),
      estimatedDuration: task.targetDuration ?? const Duration(minutes: 10),
      reuseRate: 0.0,
      deliveryTime: const Duration(seconds: 30),
      metadata: {
        'delivery_method': 'background_premium',
        'quality': 'premium',
      },
    );
  }

  Future<ContentTags> _generateFastHashtags(String topic, String category, String level) async {
    // Use local hashtag generation instead of AI for speed
    return ContentTags(
      topic: [ContentHashtag(type: 'topic', value: topic.toLowerCase().replaceAll(' ', '_'), weight: 3.0)],
      subtopic: [],
      category: [ContentHashtag(type: 'category', value: category.toLowerCase(), weight: 2.0)],
      level: [ContentHashtag(type: 'level', value: level.toLowerCase(), weight: 1.0)],
    );
  }

  Future<List<String>> _getUserContentHistory(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userHistoryDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('content_history')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return userHistoryDoc.docs
          .map((doc) => doc.data()['contentId'] as String)
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      AppLogger.warning('Failed to get user content history: $e');
      return [];
    }
  }

  Future<String> _getUserPreferredVoice(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['preferredVoice'] as String? ?? 'default';
      }
      return 'default';
    } catch (e) {
      AppLogger.warning('Failed to get user voice preference: $e');
      return 'default';
    }
  }

  String _generateCacheKey(String userId, String topic, String category, String level) {
    return '${userId}_${topic.toLowerCase()}_${category.toLowerCase()}_$level';
  }

  String _generateEpisodeId() => 'episode_${DateTime.now().millisecondsSinceEpoch}';
  String _generateContentId() => 'content_${DateTime.now().millisecondsSinceEpoch}';
}
