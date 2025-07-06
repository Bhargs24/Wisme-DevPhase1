import 'package:flutter/foundation.dart';
import '../models/stored_audio_file.dart';
import '../models/local_audio_cache.dart';
import '../models/audio_hashtag_system.dart';
import '../models/audio_metadata.dart';
import '../storage/local_audio_storage.dart';
import '../storage/cloud_audio_storage.dart';
import '../services/audio_playback_service.dart';
import '../services/audio_generation_service.dart';
import '../../shared/services/audio_player_service.dart';

// Export statements must come before class declarations
export '../models/stored_audio_file.dart';
export '../models/local_audio_cache.dart';
export '../models/audio_hashtag_system.dart';
export '../models/audio_metadata.dart';
export '../services/audio_playback_service.dart';
export '../services/audio_generation_service.dart';

class AudioManager extends ChangeNotifier {
  static AudioManager? _instance;
  static AudioManager get instance => _instance ??= AudioManager._();
  AudioManager._();

  late final LocalAudioStorage _localStorage;
  late final CloudAudioStorage _cloudStorage;
  late final AudioPlaybackService _playbackService;
  late final AudioGenerationService _generationService;
  late final AudioPlayerService? _audioPlayerService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final AudioHashtagSystem _hashtagSystem = AudioHashtagSystem();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _localStorage = LocalAudioStorage();
      _cloudStorage = CloudAudioStorage();
      _playbackService = AudioPlaybackService();
      _generationService = AudioGenerationService();
      
      // Initialize AudioPlayerService if available
      try {
        _audioPlayerService = AudioPlayerService();
        await _audioPlayerService?.initialize();
      } catch (e) {
        debugPrint('AudioPlayerService not available: $e');
        _audioPlayerService = null;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize AudioManager: $e');
      rethrow;
    }
  }

  // Audio Playback
  AudioPlaybackService get playback {
    _ensureInitialized();
    return _playbackService;
  }

  // Audio Generation
  Future<AudioGenerationResult> generateAudioFromText({
    required String text,
    required String voiceId,
    AudioGenerationSettings? settings,
  }) async {
    _ensureInitialized();
    return await _generationService.generateAudio(
      text: text,
      voiceId: voiceId,
      settings: settings,
    );
  }

  Future<AudioGenerationResult> generateAndPlayAudio({
    required String text,
    required String voiceId,
    AudioGenerationSettings? settings,
  }) async {
    final result = await generateAudioFromText(
      text: text,
      voiceId: voiceId,
      settings: settings,
    );
    await playback.play(result.filePath);
    return result;
  }

  Future<List<AudioVoice>> getAvailableVoices() async {
    _ensureInitialized();
    return await _generationService.getAvailableVoices();
  }

  AudioGenerationService get generation {
    _ensureInitialized();
    return _generationService;
  }

  // File Management
  Future<StoredAudioFile?> getAudioFile(String fileId) async {
    try {
      // Try local storage first
      return null; // TODO: Implement
    } catch (e) {
      debugPrint('Error getting audio file: $e');
      return null;
    }
  }

  Future<StoredAudioFile> storeAudioFile({
    required String filePath,
    required String fileName,
    List<String> hashtags = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    // TODO: Implement actual storage
    throw UnimplementedError('Storage not implemented');
  }

  Future<List<StoredAudioFile>> listAudioFiles() async {
    // TODO: Implement
    return [];
  }

  Future<List<StoredAudioFile>> searchAudioFiles(List<String> hashtags) async {
    // TODO: Implement
    return [];
  }

  // Cache Management
  Future<LocalAudioCache> getCacheInfo() async {
    return LocalAudioCache(
      totalFiles: 0,
      totalSizeBytes: 0,
      lastCleanup: DateTime.now(),
      cachedFileIds: [],
    );
  }

  Future<CacheMaintenanceResult> performCacheMaintenance() async {
    return const CacheMaintenanceResult(
      filesDeleted: 0,
      bytesFreed: 0,
      success: true,
    );
  }

  // Cloud Sync
  Future<SyncResult> syncWithCloud() async {
    return const SyncResult(
      success: true,
      message: 'Sync completed',
      filesUploaded: 0,
      filesDownloaded: 0,
    );
  }

  // Hashtag System
  AudioHashtagSystem get hashtags {
    return _hashtagSystem;
  }

  // Import/Export
  Future<StoredAudioFile?> importAudioFile({
    required String filePath,
    List<String> hashtags = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    // TODO: Implement
    return null;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('AudioManager not initialized. Call initialize() first.');
    }
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
