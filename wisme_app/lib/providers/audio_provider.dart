import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../models/lesson_model.dart';
import '../services/firestore_service.dart';
import '../services/cache_service.dart';
import '../services/performance_service.dart';
import '../services/analytics_service.dart';
import '../utils/logger.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirestoreService _firestoreService;
  final CacheService? _cacheService;

  // Current state
  Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model? _currentBlock;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;
  String? _error;
  String? _userId;

  // Progress tracking
  BlockProgress? _currentProgress;
  DateTime? _sessionStartTime;
  
  // Performance tracking
  DateTime? _loadStartTime;

  AudioProvider({
    required FirestoreService firestoreService,
    CacheService? cacheService,
  }) : _firestoreService = firestoreService,
       _cacheService = cacheService {
    _initializeAudioPlayer();
  }

  // Getters
  Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model? get currentBlock => _currentBlock;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get playbackSpeed => _playbackSpeed;
  String? get error => _error;
  bool get hasCurrentBlock => _currentBlock != null;
  double get progress => _totalDuration.inMilliseconds > 0 
      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds 
      : 0.0;

  void _initializeAudioPlayer() {
    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      _updateProgress();
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _isLoading = state == PlayerState.playing && _currentPosition == Duration.zero;
      notifyListeners();
    });

    // Listen to playback completion
    _audioPlayer.onPlayerComplete.listen((_) {
      _onPlaybackComplete();
    });
  }

  // Set current block and user
  Future<void> setCurrentBlock(Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model block, String userId) async {
    _currentBlock = block;
    _userId = userId;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _error = null;

    // Load existing progress
    try {
      _currentProgress = await _firestoreService.getBlockProgress(userId, block.id);
      if (_currentProgress != null) {
        // Resume from last position
        _currentPosition = _currentProgress!.lastPosition;
      }
    } catch (e) {
      AppLogger.error('Failed to load progress: $e');
    }

    notifyListeners();
  }

  // Load and prepare audio
  Future<void> loadAudio() async {
    if (_currentBlock?.audioUrl == null) {
      _error = 'No audio available for this content';
      notifyListeners();
      return;
    }

    _loadStartTime = DateTime.now();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check cache first
      File? cachedFile;
      if (_cacheService != null) {
        cachedFile = await _cacheService.getCachedAudio(
          _currentBlock!.title, 
          'default' // Use default coach voice for now
        );
      }

      if (cachedFile != null) {
        // Load from cache
        await _audioPlayer.setSource(DeviceFileSource(cachedFile.path));
        AppLogger.info('Audio loaded from cache for block: ${_currentBlock!.id}');
        
        // Track cache hit
        PerformanceService.recordMetric('cache_hit', 1.0);
      } else {
        // Load from network
        await _audioPlayer.setSource(UrlSource(_currentBlock!.audioUrl!));
        AppLogger.info('Audio loaded from network for block: ${_currentBlock!.id}');
        
        // Track cache miss
        PerformanceService.recordMetric('cache_miss', 1.0);
      }
      
      // Set playback speed
      await _audioPlayer.setPlaybackRate(_playbackSpeed);

      // Seek to last position if resuming
      if (_currentProgress != null && _currentProgress!.lastPosition > Duration.zero) {
        await _audioPlayer.seek(_currentProgress!.lastPosition);
      }

      // Track load time
      if (_loadStartTime != null) {
        final loadTime = DateTime.now().difference(_loadStartTime!);
        PerformanceService.recordMetric('audio_load_time_ms', loadTime.inMilliseconds.toDouble());
      }

      // Track analytics
      AnalyticsService.trackEvent('audio_loaded', {
        'block_id': _currentBlock!.id,
        'cached': cachedFile != null,
        'load_time_ms': _loadStartTime != null 
            ? DateTime.now().difference(_loadStartTime!).inMilliseconds 
            : 0,
      });

    } catch (e) {
      _error = 'Failed to load audio: $e';
      AppLogger.error('Failed to load audio: $e');
      
      // Track error
      AnalyticsService.trackEvent('audio_load_error', {
        'error': e.toString(),
        'block_id': _currentBlock?.id,
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Play audio
  Future<void> play() async {
    if (_currentBlock?.audioUrl == null) {
      _error = 'No audio available';
      notifyListeners();
      return;
    }

    try {
      if (_audioPlayer.state == PlayerState.stopped) {
        await loadAudio();
      }
      
      await _audioPlayer.resume();
      _sessionStartTime = DateTime.now();
      AppLogger.info('Audio playback started');
    } catch (e) {
      _error = 'Failed to play audio: $e';
      AppLogger.error('Failed to play audio: $e');
      notifyListeners();
    }
  }

  // Pause audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _updateProgress();
      AppLogger.info('Audio playback paused');
    } catch (e) {
      _error = 'Failed to pause audio: $e';
      AppLogger.error('Failed to pause audio: $e');
      notifyListeners();
    }
  }

  // Stop audio
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
      _updateProgress();
      AppLogger.info('Audio playback stopped');
    } catch (e) {
      _error = 'Failed to stop audio: $e';
      AppLogger.error('Failed to stop audio: $e');
      notifyListeners();
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _currentPosition = position;
      _updateProgress();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to seek: $e';
      AppLogger.error('Failed to seek: $e');
      notifyListeners();
    }
  }

  // Skip forward by specified duration
  Future<void> skipForward(Duration duration) async {
    final newPosition = _currentPosition + duration;
    final maxPosition = _totalDuration;
    await seekTo(newPosition > maxPosition ? maxPosition : newPosition);
  }

  // Skip backward by specified duration
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _currentPosition - duration;
    await seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  // Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      _playbackSpeed = speed;
      await _audioPlayer.setPlaybackRate(speed);
      notifyListeners();
      AppLogger.info('Playback speed set to ${speed}x');
    } catch (e) {
      _error = 'Failed to set playback speed: $e';
      AppLogger.error('Failed to set playback speed: $e');
      notifyListeners();
    }
  }

  // Update progress in database
  void _updateProgress() {
    if (_currentBlock == null || _userId == null) return;

    final completionPercentage = _totalDuration.inMilliseconds > 0
        ? (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds) * 100
        : 0.0;

    final listeningTime = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    _currentProgress = BlockProgress(
      userId: _userId!,
      blockId: _currentBlock!.id,
      journeyId: _currentProgress?.journeyId ?? '',
      isCompleted: completionPercentage >= 95.0, // Consider 95% as completed
      completedAt: completionPercentage >= 95.0 ? DateTime.now() : null,
      listeningTime: (_currentProgress?.listeningTime ?? Duration.zero) + listeningTime,
      lastPosition: _currentPosition,
      completionPercentage: completionPercentage,
    );

    // Save progress periodically (every 10 seconds or on significant changes)
    _saveProgressDebounced();
  }

  DateTime? _lastProgressSave;
  Future<void> _saveProgressDebounced() async {
    final now = DateTime.now();
    if (_lastProgressSave == null || 
        now.difference(_lastProgressSave!).inSeconds >= 10) {
      _lastProgressSave = now;
      await _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    if (_currentProgress == null) return;

    try {
      await _firestoreService.saveBlockProgress(
        _currentProgress!.userId,
        _currentProgress!.blockId,
        _currentProgress!,
      );
    } catch (e) {
      AppLogger.error('Failed to save progress: $e');
    }
  }

  void _onPlaybackComplete() {
    _currentPosition = _totalDuration;
    _updateProgress();
    
    // Mark as completed
    if (_currentProgress != null) {
      _currentProgress = _currentProgress!.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        completionPercentage: 100.0,
      );
      _saveProgress();
    }

    AppLogger.info('Audio playback completed for block: ${_currentBlock?.id}');
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get formatted position string
  String get formattedPosition {
    return _formatDuration(_currentPosition);
  }

  // Get formatted duration string
  String get formattedDuration {
    return _formatDuration(_totalDuration);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Cleanup
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}


