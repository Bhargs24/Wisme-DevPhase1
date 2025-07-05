import 'dart:io';
import 'dart:typed_data';
import '../models/stored_audio_file.dart';
import '../models/local_audio_cache.dart';
import '../models/audio_hashtag_system.dart';
import '../models/cached_audio_model.dart';
import '../models/voice_model.dart';
import '../storage/local_audio_storage.dart';
import '../storage/cloud_audio_storage.dart';
import '../services/audio_cache_manager.dart';
import '../services/audio_playback_service.dart';
import '../services/audio_generation_service.dart';
import '../services/tts_service.dart';
import '../services/audio_player_service.dart';
import '../../core/cache/cache_service.dart';

/// Production-grade main audio manager
/// Orchestrates all audio services and provides a unified interface
class AudioManager {
  // Core services
  late final LocalAudioStorage _localStorage;
  late final CloudAudioStorage _cloudStorage;
  late final AudioCacheManager _cacheManager;
  late final AudioPlaybackService _playbackService;
  late final AudioGenerationService _generationService;
  late final TTSService _ttsService;
  late final AudioPlayerService _audioPlayerService;
  late final CacheService _cacheService;

  // Initialization state
  bool _isInitialized = false;

  // Configuration
  final AudioManagerConfig _config;

  AudioManager({AudioManagerConfig? config}) 
      : _config = config ?? const AudioManagerConfig();

  /// Initialize all audio services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize advanced cache service first
      _cacheService = CacheService();

      // Initialize storage services
      _localStorage = LocalAudioStorage();
      await _localStorage.initialize();

      _cloudStorage = CloudAudioStorage(
        bucketName: _config.cloudBucketName,
        apiKey: _config.cloudApiKey,
      );

      // Initialize cache manager
      _cacheManager = AudioCacheManager(
        localStorage: _localStorage,
        cloudStorage: _cloudStorage,
        maxAge: _config.cacheMaxAge,
        maxFiles: _config.cacheMaxFiles,
        maxSizeBytes: _config.cacheMaxSizeBytes,
      );
      await _cacheManager.initialize();

      // Initialize playback service
      _playbackService = AudioPlaybackService(cacheManager: _cacheManager);

      // Initialize generation service
      _generationService = AudioGenerationService(
        cacheManager: _cacheManager,
        apiKey: _config.ttsApiKey,
      );

      _isInitialized = true;
      print('AudioManager initialized successfully');
    } catch (e) {
      print('Failed to initialize AudioManager: $e');
      rethrow;
    }
  }

  /// Ensure AudioManager is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // === PLAYBACK INTERFACE ===

  /// Play audio file by ID
  Future<bool> playAudio(String fileId) async {
    await _ensureInitialized();
    return await _playbackService.playAudioFile(fileId);
  }

  /// Play audio from raw data
  Future<bool> playAudioData(Uint8List audioData, {String? fileName}) async {
    await _ensureInitialized();
    return await _playbackService.playAudioData(audioData, fileName: fileName);
  }

  /// Pause current playback
  Future<void> pauseAudio() async {
    await _ensureInitialized();
    await _playbackService.pause();
  }

  /// Resume paused playback
  Future<void> resumeAudio() async {
    await _ensureInitialized();
    await _playbackService.resume();
  }

  /// Stop current playback
  Future<void> stopAudio() async {
    await _ensureInitialized();
    await _playbackService.stop();
  }

  /// Seek to position in current audio
  Future<void> seekAudio(Duration position) async {
    await _ensureInitialized();
    await _playbackService.seekTo(position);
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    await _ensureInitialized();
    await _playbackService.setPlaybackSpeed(speed);
  }

  /// Set playback volume
  Future<void> setVolume(double volume) async {
    await _ensureInitialized();
    await _playbackService.setVolume(volume);
  }

  /// Get playback service for advanced controls
  AudioPlaybackService get playback {
    if (!_isInitialized) {
      throw StateError('AudioManager not initialized. Call initialize() first.');
    }
    return _playbackService;
  }

  // === GENERATION INTERFACE ===

  /// Generate audio from text
  Future<AudioGenerationResult> generateAudioFromText({
    required String text,
    AudioGenerationSettings? settings,
    List<String> hashtags = const [],
    Map<String, dynamic> customMetadata = const {},
  }) async {
    await _ensureInitialized();
    return await _generationService.generateAudioFromText(
      text: text,
      settings: settings,
      hashtags: hashtags,
      customMetadata: customMetadata,
    );
  }

  /// Generate and immediately play audio
  Future<AudioGenerationResult> generateAndPlayAudio({
    required String text,
    AudioGenerationSettings? settings,
    List<String> hashtags = const [],
    Map<String, dynamic> customMetadata = const {},
  }) async {
    await _ensureInitialized();
    
    final result = await _generationService.generateAudioFromText(
      text: text,
      settings: settings,
      hashtags: hashtags,
      customMetadata: customMetadata,
    );

    if (result.success && result.audioFile != null) {
      await _playbackService.playAudioFile(result.audioFile!.id);
    }

    return result;
  }

  /// Get available voices for generation
  Future<List<AudioVoice>> getAvailableVoices() async {
    await _ensureInitialized();
    return await _generationService.getAvailableVoices();
  }

  /// Get audio generation service for advanced operations
  AudioGenerationService get generation {
    if (!_isInitialized) {
      throw StateError('AudioManager not initialized. Call initialize() first.');
    }
    return _generationService;
  }

  // === STORAGE INTERFACE ===

  /// Get audio file by ID
  Future<StoredAudioFile?> getAudioFile(String fileId) async {
    await _ensureInitialized();
    return await _cacheManager.getAudioFile(fileId);
  }

  /// Get audio data by ID
  Future<Uint8List?> getAudioData(String fileId) async {
    await _ensureInitialized();
    return await _cacheManager.getAudioData(fileId);
  }

  /// Store audio file
  Future<StoredAudioFile> storeAudioFile({
    required Uint8List audioData,
    required String fileName,
    required Map<String, dynamic> metadata,
    List<String> hashtags = const [],
  }) async {
    await _ensureInitialized();
    return await _cacheManager.storeAudioFile(
      audioData: audioData,
      fileName: fileName,
      metadata: metadata,
      hashtags: hashtags,
    );
  }

  /// List all audio files
  Future<List<StoredAudioFile>> listAudioFiles() async {
    await _ensureInitialized();
    return await _localStorage.listAudioFiles();
  }

  /// Search audio files by hashtags
  Future<List<StoredAudioFile>> searchAudioFiles(List<String> hashtags) async {
    await _ensureInitialized();
    return await _localStorage.searchByHashtags(hashtags);
  }

  /// Delete audio file
  Future<bool> deleteAudioFile(String fileId) async {
    await _ensureInitialized();
    
    // Stop playback if this file is currently playing
    if (_playbackService.currentFile?.id == fileId) {
      await _playbackService.stop();
    }

    // Delete from storage
    final localDeleted = await _localStorage.deleteAudioFile(fileId);
    final cloudDeleted = await _cloudStorage.deleteAudioFile(fileId);

    return localDeleted && cloudDeleted;
  }

  // === CACHE INTERFACE ===

  /// Get cache information
  Future<LocalAudioCache> getCacheInfo() async {
    await _ensureInitialized();
    return await _cacheManager.getCacheInfo();
  }

  /// Perform cache maintenance
  Future<CacheMaintenanceResult> performCacheMaintenance() async {
    await _ensureInitialized();
    return await _cacheManager.performMaintenance();
  }

  /// Clear cache
  Future<int> clearCache() async {
    await _ensureInitialized();
    return await _cacheManager.clearAllCache();
  }

  /// Precache audio files for offline use
  Future<void> precacheAudioFiles(List<String> fileIds) async {
    await _ensureInitialized();
    await _cacheManager.precacheAudioFiles(fileIds);
  }

  /// Sync cache with cloud
  Future<SyncResult> syncWithCloud() async {
    await _ensureInitialized();
    return await _cacheManager.syncWithCloud();
  }

  /// Check if file is cached locally
  Future<bool> isCached(String fileId) async {
    await _ensureInitialized();
    return await _cacheManager.isCached(fileId);
  }

  /// Get cached audio for topic and coach voice
  Future<File?> getCachedAudio(String topic, String coachVoice) async {
    await _ensureInitialized();
    return await _cacheService.getCachedAudio(topic, coachVoice);
  }

  /// Cache generated audio
  Future<void> cacheGeneratedAudio({
    required String topic,
    required String coachVoice,
    required Uint8List audioData,
    required int durationSeconds,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();
    
    final audioMetadata = {
      'topic': topic,
      'coachVoice': coachVoice,
      'durationSeconds': durationSeconds,
      'generatedAt': DateTime.now().toIso8601String(),
      ...?metadata,
    };

    await _cacheService.cacheAudio(
      topic: topic,
      coachVoice: coachVoice,
      audioData: audioData,
      metadata: audioMetadata,
    );
  }

  /// Get advanced cache statistics
  Future<Map<String, dynamic>> getAdvancedCacheStats() async {
    await _ensureInitialized();
    return await _cacheService.getCacheStats();
  }

  /// Clear all cached audio
  Future<void> clearAudioCache() async {
    await _ensureInitialized();
    await _cacheService.clearCache();
  }

  // === STATISTICS AND MONITORING ===

  /// Get comprehensive audio statistics
  Future<AudioManagerStats> getStats() async {
    await _ensureInitialized();
    
    final cacheInfo = await getCacheInfo();
    final generationStats = await _generationService.getGenerationStats();
    final allFiles = await listAudioFiles();
    
    return AudioManagerStats(
      totalFiles: allFiles.length,
      cachedFiles: cacheInfo.totalFiles,
      totalSizeBytes: cacheInfo.totalSizeBytes,
      generatedFiles: generationStats.totalGeneratedFiles,
      estimatedGenerationCost: generationStats.estimatedCost,
      cacheHitRate: await _cacheManager.getCacheHitRate(),
    );
  }

  /// Get hashtag system for advanced hashtag operations
  AudioHashtagSystem get hashtags {
    if (!_isInitialized) {
      throw StateError('AudioManager not initialized. Call initialize() first.');
    }
    return _localStorage.hashtagSystem;
  }

  // === UTILITY METHODS ===

  /// Export audio file to external storage
  Future<String?> exportAudioFile(String fileId, String destinationPath) async {
    await _ensureInitialized();
    
    final audioData = await getAudioData(fileId);
    if (audioData == null) return null;

    try {
      final file = File(destinationPath);
      await file.writeAsBytes(audioData);
      return destinationPath;
    } catch (e) {
      print('Error exporting audio file: $e');
      return null;
    }
  }

  /// Import audio file from external storage
  Future<StoredAudioFile?> importAudioFile({
    required String filePath,
    Map<String, dynamic> metadata = const {},
    List<String> hashtags = const [],
  }) async {
    await _ensureInitialized();
    
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final audioData = await file.readAsBytes();
      final fileName = file.path.split('/').last;

      return await storeAudioFile(
        audioData: audioData,
        fileName: fileName,
        metadata: {...metadata, 'imported_from': filePath},
        hashtags: [...hashtags, 'imported'],
      );
    } catch (e) {
      print('Error importing audio file: $e');
      return null;
    }
  }

  /// Dispose all resources
  Future<void> dispose() async {
    if (_isInitialized) {
      _playbackService.dispose();
      _isInitialized = false;
    }
  }
}

/// Audio manager configuration
class AudioManagerConfig {
  final String cloudBucketName;
  final String cloudApiKey;
  final String ttsApiKey;
  final Duration cacheMaxAge;
  final int cacheMaxFiles;
  final int cacheMaxSizeBytes;

  const AudioManagerConfig({
    this.cloudBucketName = 'wisme-audio-storage',
    this.cloudApiKey = '',
    this.ttsApiKey = '',
    this.cacheMaxAge = const Duration(days: 7),
    this.cacheMaxFiles = 100,
    this.cacheMaxSizeBytes = 500 * 1024 * 1024, // 500MB
  });
}

/// Audio manager statistics
class AudioManagerStats {
  final int totalFiles;
  final int cachedFiles;
  final int totalSizeBytes;
  final int generatedFiles;
  final double estimatedGenerationCost;
  final double cacheHitRate;

  const AudioManagerStats({
    required this.totalFiles,
    required this.cachedFiles,
    required this.totalSizeBytes,
    required this.generatedFiles,
    required this.estimatedGenerationCost,
    required this.cacheHitRate,
  });

  String get formattedSize {
    final sizeInMB = totalSizeBytes / (1024 * 1024);
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  String get formattedCost {
    return '\$${estimatedGenerationCost.toStringAsFixed(4)}';
  }

  double get cacheEfficiency => cachedFiles / totalFiles;

  @override
  String toString() {
    return 'AudioManagerStats(\n'
           '  Total Files: $totalFiles\n'
           '  Cached Files: $cachedFiles\n'
           '  Total Size: $formattedSize\n'
           '  Generated Files: $generatedFiles\n'
           '  Generation Cost: $formattedCost\n'
           '  Cache Hit Rate: ${(cacheHitRate * 100).toStringAsFixed(1)}%\n'
           '  Cache Efficiency: ${(cacheEfficiency * 100).toStringAsFixed(1)}%\n'
           ')';
  }
}

// Re-export commonly used types
export '../models/stored_audio_file.dart';
export '../models/local_audio_cache.dart';
export '../models/audio_hashtag_system.dart';
export '../models/audio_metadata.dart';
export '../services/audio_playback_service.dart';
export '../services/audio_generation_service.dart';
export '../services/audio_cache_manager.dart';
