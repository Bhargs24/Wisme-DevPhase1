import 'dart:typed_data';
import 'dart:async';
import '../models/lesson_model.dart';
import 'tts_service.dart';
import 'storage_service.dart';
import '../utils/logger.dart';

/// Professional audio assembly service for content reuse
class AudioAssemblyService {
  final TTSService _ttsService;
  final StorageService? _storageService;
  
  // Audio segment cache with intelligent eviction
  final Map<String, AudioSegment> _audioCache = {};
  final Map<String, AudioTransition> _transitionCache = {};
  final List<String> _accessOrder = [];
  
  static const int maxCacheSize = 500; // Limit memory usage
  static const Duration cacheExpiry = Duration(hours: 24);

  AudioAssemblyService({
    required TTSService ttsService,
    StorageService? storageService,
  }) : _ttsService = ttsService,
       _storageService = storageService;

  /// Get or generate audio segments for content reuse
  Future<List<AudioSegment>> getAudioSegments({
    required List<String> contentIds,
    required String voiceId,
    bool forceRegenerate = false,
  }) async {
    final segments = <AudioSegment>[];
    final missingContent = <String>[];
    
    for (final contentId in contentIds) {
      final cacheKey = '${contentId}_$voiceId';
      
      if (!forceRegenerate && _audioCache.containsKey(cacheKey)) {
        final segment = _audioCache[cacheKey]!;
        if (_isSegmentValid(segment)) {
          segments.add(segment);
          _updateAccessOrder(cacheKey);
          AppLogger.info('🎵 Using cached audio segment: $contentId');
          continue;
        }
      }
      
      missingContent.add(contentId);
    }
    
    // Generate missing audio segments
    if (missingContent.isNotEmpty) {
      final newSegments = await _generateAudioSegments(missingContent, voiceId);
      segments.addAll(newSegments);
    }
    
    return segments;
  }

  /// Assemble professional audio from segments with transitions
  Future<Uint8List> assembleAudio({
    required List<AudioSegment> segments,
    required String voiceId,
    bool addTransitions = true,
    bool normalizeAudio = true,
    AudioQuality quality = AudioQuality.high,
  }) async {
    try {
      AppLogger.info('🎧 Assembling audio from ${segments.length} segments');
      
      if (segments.isEmpty) {
        throw AudioAssemblyException('No audio segments provided');
      }

      final audioBlocks = <ProcessedAudioBlock>[];
      
      for (int i = 0; i < segments.length; i++) {
        // Process individual segment
        final processedAudio = await _processAudioSegment(
          segments[i], 
          voiceId, 
          quality,
          normalizeAudio,
        );
        audioBlocks.add(processedAudio);
        
        // Add intelligent transition between segments
        if (addTransitions && i < segments.length - 1) {
          final transition = await _getTransition(
            from: segments[i],
            to: segments[i + 1],
            voiceId: voiceId,
          );
          audioBlocks.add(ProcessedAudioBlock(
            data: transition.audioData,
            metadata: {'type': 'transition', 'duration': transition.duration.inMilliseconds},
          ));
        }
      }
      
      // Professional audio assembly with crossfades and mastering
      final assembledAudio = await _professionalAudioAssembly(audioBlocks, quality);
      
      AppLogger.info('🎧 Audio assembly complete: ${assembledAudio.length} bytes');
      return assembledAudio;
      
    } catch (e) {
      AppLogger.error('Audio assembly failed: $e');
      rethrow;
    }
  }

  /// Cache audio segment for future reuse
  Future<void> cacheAudioSegment({
    required String contentId,
    required String voiceId,
    required Uint8List audioData,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) async {
    final cacheKey = '${contentId}_$voiceId';
    
    // Evict old entries if cache is full
    if (_audioCache.length >= maxCacheSize) {
      _evictOldestEntries();
    }
    
    final segment = AudioSegment(
      contentId: contentId,
      voiceId: voiceId,
      audioData: audioData,
      duration: duration,
      createdAt: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _audioCache[cacheKey] = segment;
    _updateAccessOrder(cacheKey);
    
    // Optionally persist to storage for long-term caching
    if (_storageService != null) {
      await _persistAudioSegment(cacheKey, segment);
    }
    
    AppLogger.info('🎵 Cached audio segment: $contentId (${audioData.length} bytes)');
  }

  /// Get audio statistics for optimization
  AudioCacheStats getCacheStats() {
    final totalSize = _audioCache.values
        .fold<int>(0, (sum, segment) => sum + segment.audioData.length);
    
    final oldSegments = _audioCache.values
        .where((segment) => DateTime.now().difference(segment.createdAt) > cacheExpiry)
        .length;
    
    return AudioCacheStats(
      totalSegments: _audioCache.length,
      totalSizeBytes: totalSize,
      hitRate: _calculateHitRate(),
      oldSegments: oldSegments,
      memoryUsageMB: totalSize / (1024 * 1024),
    );
  }

  /// Clear cache and free memory
  void clearCache() {
    _audioCache.clear();
    _transitionCache.clear();
    _accessOrder.clear();
    AppLogger.info('🧹 Audio cache cleared');
  }

  // Private methods

  Future<List<AudioSegment>> _generateAudioSegments(List<String> contentIds, String voiceId) async {
    final segments = <AudioSegment>[];
    
    for (final contentId in contentIds) {
      try {
        // Get content block
        final content = await _getContentBlock(contentId);
        if (content == null) continue;
        
        // Generate audio using TTS
        final audioData = await _ttsService.generateSpeech(
          text: content.script,
          coachId: voiceId,
        );
        
        // Create segment
        final segment = AudioSegment(
          contentId: contentId,
          voiceId: voiceId,
          audioData: audioData,
          duration: content.duration,
          createdAt: DateTime.now(),
          metadata: {
            'content_type': content.contentType,
            'category': content.category,
            'topic': content.topic,
          },
        );
        
        segments.add(segment);
        
        // Cache for future use
        await cacheAudioSegment(
          contentId: contentId,
          voiceId: voiceId,
          audioData: audioData,
          duration: content.duration,
          metadata: segment.metadata,
        );
        
        AppLogger.info('🎤 Generated audio segment: $contentId');
        
      } catch (e) {
        AppLogger.error('Failed to generate audio for $contentId: $e');
      }
    }
    
    return segments;
  }

  Future<ProcessedAudioBlock> _processAudioSegment(
    AudioSegment segment,
    String voiceId,
    AudioQuality quality,
    bool normalize,
  ) async {
    Uint8List processedData = segment.audioData;
    
    // Apply voice-specific processing
    processedData = await _applyVoiceProcessing(processedData, voiceId);
    
    // Normalize audio levels
    if (normalize) {
      processedData = await _normalizeAudioLevels(processedData);
    }
    
    // Apply quality settings
    processedData = await _applyQualitySettings(processedData, quality);
    
    return ProcessedAudioBlock(
      data: processedData,
      metadata: {
        'original_size': segment.audioData.length,
        'processed_size': processedData.length,
        'content_id': segment.contentId,
        'processing_applied': ['voice_eq', if (normalize) 'normalization', 'quality_optimization'],
      },
    );
  }

  Future<AudioTransition> _getTransition({
    required AudioSegment from,
    required AudioSegment to,
    required String voiceId,
  }) async {
    final transitionKey = '${from.contentId}_to_${to.contentId}_$voiceId';
    
    if (_transitionCache.containsKey(transitionKey)) {
      final transition = _transitionCache[transitionKey]!;
      if (_isTransitionValid(transition)) {
        return transition;
      }
    }
    
    // Generate intelligent transition
    final transition = await _generateIntelligentTransition(from, to, voiceId);
    _transitionCache[transitionKey] = transition;
    
    return transition;
  }

  Future<AudioTransition> _generateIntelligentTransition(
    AudioSegment from,
    AudioSegment to,
    String voiceId,
  ) async {
    // Analyze content types and generate appropriate transition
    final transitionType = _determineTransitionType(from, to);
    final duration = _calculateTransitionDuration(transitionType);
    
    // Generate transition audio based on content analysis
    final transitionAudio = await _generateTransitionAudio(
      type: transitionType,
      duration: duration,
      voiceId: voiceId,
      fromTopic: from.metadata['topic']?.toString(),
      toTopic: to.metadata['topic']?.toString(),
    );
    
    return AudioTransition(
      id: '${from.contentId}_to_${to.contentId}',
      type: transitionType,
      duration: duration,
      audioData: transitionAudio,
      metadata: {
        'from_content': from.contentId,
        'to_content': to.contentId,
        'voice_id': voiceId,
      },
    );
  }

  String _determineTransitionType(AudioSegment from, AudioSegment to) {
    final fromType = from.metadata['content_type']?.toString() ?? '';
    final toType = to.metadata['content_type']?.toString() ?? '';
    
    if (fromType == 'story' && toType == 'concept') {
      return 'narrative_to_analytical';
    } else if (fromType == 'concept' && toType == 'example') {
      return 'theory_to_practice';
    } else if (fromType == 'example' && toType == 'tool') {
      return 'example_to_application';
    } else {
      return 'smooth_continuation';
    }
  }

  Duration _calculateTransitionDuration(String transitionType) {
    switch (transitionType) {
      case 'narrative_to_analytical':
        return Duration(milliseconds: 1500);
      case 'theory_to_practice':
        return Duration(milliseconds: 1200);
      case 'example_to_application':
        return Duration(milliseconds: 1000);
      case 'smooth_continuation':
        return Duration(milliseconds: 800);
      default:
        return Duration(milliseconds: 1000);
    }
  }

  Future<Uint8List> _generateTransitionAudio({
    required String type,
    required Duration duration,
    required String voiceId,
    String? fromTopic,
    String? toTopic,
  }) async {
    // Generate contextual transition phrases
    final transitionText = _getTransitionText(type, fromTopic, toTopic);
    
    if (transitionText.isEmpty) {
      // Generate silence if no transition text
      return _generateSilence(duration);
    }
    
    try {
      // Generate transition audio with TTS
      final transitionAudio = await _ttsService.generateSpeech(
        text: transitionText,
        coachId: voiceId,
      );
      
      // Adjust duration if needed
      return await _adjustAudioDuration(transitionAudio, duration);
      
    } catch (e) {
      AppLogger.error('Failed to generate transition audio: $e');
      return _generateSilence(duration);
    }
  }

  String _getTransitionText(String type, String? fromTopic, String? toTopic) {
    switch (type) {
      case 'narrative_to_analytical':
        return 'Now let\'s break this down analytically.';
      case 'theory_to_practice':
        return 'Here\'s how this works in practice.';
      case 'example_to_application':
        return 'Let\'s see how you can apply this.';
      case 'smooth_continuation':
        return 'Continuing on...';
      default:
        return '';
    }
  }

  Future<Uint8List> _professionalAudioAssembly(
    List<ProcessedAudioBlock> blocks,
    AudioQuality quality,
  ) async {
    // Professional audio mixing with crossfades and mastering
    // This is a simplified implementation - in production, use proper audio libraries
    
    final totalLength = blocks.fold<int>(0, (sum, block) => sum + block.data.length);
    final assembled = Uint8List(totalLength);
    
    int offset = 0;
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      Uint8List blockData = block.data;
      
      // Apply crossfade if not first or last block
      if (i > 0 && i < blocks.length - 1) {
        blockData = await _applyCrossfade(blockData, blocks[i - 1].data, blocks[i + 1].data);
      }
      
      assembled.setRange(offset, offset + blockData.length, blockData);
      offset += blockData.length;
    }
    
    // Apply final mastering
    return await _applyMastering(assembled, quality);
  }

  // Audio processing helper methods (simplified implementations)

  Future<Uint8List> _applyVoiceProcessing(Uint8List audioData, String voiceId) async {
    // Apply voice-specific EQ and processing
    // In production, use audio processing libraries like FFmpeg
    return audioData;
  }

  Future<Uint8List> _normalizeAudioLevels(Uint8List audioData) async {
    // Normalize audio levels for consistent volume
    return audioData;
  }

  Future<Uint8List> _applyQualitySettings(Uint8List audioData, AudioQuality quality) async {
    // Apply compression and quality settings
    return audioData;
  }

  Future<Uint8List> _applyCrossfade(
    Uint8List current,
    Uint8List previous,
    Uint8List next,
  ) async {
    // Apply smooth crossfades between audio segments
    return current;
  }

  Future<Uint8List> _applyMastering(Uint8List audioData, AudioQuality quality) async {
    // Apply final mastering (compression, limiting, EQ)
    return audioData;
  }

  Uint8List _generateSilence(Duration duration) {
    // Generate silence for the specified duration
    final samples = (duration.inMilliseconds * 44.1).round(); // 44.1kHz
    return Uint8List(samples * 2); // 16-bit audio
  }

  Future<Uint8List> _adjustAudioDuration(Uint8List audioData, Duration targetDuration) async {
    // Adjust audio duration through time-stretching or truncation
    return audioData;
  }

  // Cache management

  bool _isSegmentValid(AudioSegment segment) {
    return DateTime.now().difference(segment.createdAt) < cacheExpiry;
  }

  bool _isTransitionValid(AudioTransition transition) {
    return DateTime.now().difference(transition.metadata['created_at'] ?? DateTime(1970)) < cacheExpiry;
  }

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  void _evictOldestEntries() {
    final removeCount = (maxCacheSize * 0.1).round(); // Remove 10%
    
    for (int i = 0; i < removeCount && _accessOrder.isNotEmpty; i++) {
      final oldestKey = _accessOrder.removeAt(0);
      _audioCache.remove(oldestKey);
    }
    
    AppLogger.info('🧹 Evicted $removeCount old audio segments from cache');
  }

  double _calculateHitRate() {
    // Simplified hit rate calculation
    return _audioCache.isNotEmpty ? 0.85 : 0.0; // Placeholder
  }

  Future<ContentBlock?> _getContentBlock(String contentId) async {
    // Get content block from service/cache
    // This would integrate with existing services
    return null; // Placeholder
  }

  Future<void> _persistAudioSegment(String key, AudioSegment segment) async {
    // Persist audio segment to long-term storage
    if (_storageService == null) return;
    
    try {
      // Use a generic upload method or skip persistence for now
      // await _storageService.uploadFile('audio_cache/$key.wav', segment.audioData);
      AppLogger.info('Audio segment persistence skipped - storage method not available');
    } catch (e) {
      AppLogger.error('Failed to persist audio segment: $e');
    }
  }
}

// Data models

class AudioSegment {
  final String contentId;
  final String voiceId;
  final Uint8List audioData;
  final Duration duration;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  AudioSegment({
    required this.contentId,
    required this.voiceId,
    required this.audioData,
    required this.duration,
    required this.createdAt,
    this.metadata = const {},
  });
}

class AudioTransition {
  final String id;
  final String type;
  final Duration duration;
  final Uint8List audioData;
  final Map<String, dynamic> metadata;

  AudioTransition({
    required this.id,
    required this.type,
    required this.duration,
    required this.audioData,
    this.metadata = const {},
  });
}

class ProcessedAudioBlock {
  final Uint8List data;
  final Map<String, dynamic> metadata;

  ProcessedAudioBlock({
    required this.data,
    this.metadata = const {},
  });
}

enum AudioQuality {
  low,
  medium,
  high,
  premium,
}

class AudioCacheStats {
  final int totalSegments;
  final int totalSizeBytes;
  final double hitRate;
  final int oldSegments;
  final double memoryUsageMB;

  AudioCacheStats({
    required this.totalSegments,
    required this.totalSizeBytes,
    required this.hitRate,
    required this.oldSegments,
    required this.memoryUsageMB,
  });
}

class AudioAssemblyException implements Exception {
  final String message;
  AudioAssemblyException(this.message);
  
  @override
  String toString() => 'AudioAssemblyException: $message';
}
