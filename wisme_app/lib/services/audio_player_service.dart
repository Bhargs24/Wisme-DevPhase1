import '../core/exports.dart';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart' as ap;
class AudioPlayerService {
  static AudioPlayerService? _instance;
  static AudioPlayerService get instance => _instance ??= AudioPlayerService._internal();
  
  AudioPlayerService._internal();

  final ap.AudioPlayer _player = ap.AudioPlayer();
  final String _serviceName = 'AudioPlayerService';
  
  // State tracking
  ContentBlock? _currentContentBlock;
  LearningSession? _currentSession;
  List<ContentBlock> _queue = [];
  int _currentIndex = 0;
  
  // Streams
  final StreamController<ap.PlayerState> _playerStateController = StreamController<ap.PlayerState>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<ContentBlock?> _currentContentController = StreamController<ContentBlock?>.broadcast();
  final StreamController<List<ContentBlock>> _queueController = StreamController<List<ContentBlock>>.broadcast();
  final StreamController<double> _playbackSpeedController = StreamController<double>.broadcast();
  
  // Configuration
  double _playbackSpeed = 1.0;
  final bool _isRepeatMode = false;
  final bool _isShuffleMode = false;
  
  // Getters for streams
  Stream<ap.PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<ContentBlock?> get currentContentStream => _currentContentController.stream;
  Stream<List<ContentBlock>> get queueStream => _queueController.stream;
  Stream<double> get playbackSpeedStream => _playbackSpeedController.stream;
  
  // Getters for current state
  ContentBlock? get currentContentBlock => _currentContentBlock;
  LearningSession? get currentSession => _currentSession;
  List<ContentBlock> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  double get playbackSpeed => _playbackSpeed;
  bool get isRepeatMode => _isRepeatMode;
  bool get isShuffleMode => _isShuffleMode;
  bool get isPlaying => _player.state == ap.PlayerState.playing;
  bool get isPaused => _player.state == ap.PlayerState.paused;
  bool get isStopped => _player.state == ap.PlayerState.stopped;

  /// Initialize the audio player service
  Future<void> initialize() async {
    try {
      AppLogger.info('$_serviceName: Initializing audio player service');
      
      // Set up event listeners
      _setupEventListeners();
      
      AppLogger.info('$_serviceName: Audio player service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Failed to initialize audio player service', e, stackTrace);
      rethrow;
    }
  }

  /// Set up event listeners for the audio player
  void _setupEventListeners() {
    // Player state changes
    _player.onPlayerStateChanged.listen((state) {
      AppLogger.debug('$_serviceName: Player state changed to: $state');
      _playerStateController.add(state);
      
      // Handle automatic next track
      if (state == ap.PlayerState.completed) {
        _handleTrackCompleted();
      }
    });
    
    // Position changes
    _player.onPositionChanged.listen((position) {
      _positionController.add(position);
    });
    
    // Duration changes
    _player.onDurationChanged.listen((duration) {
      _durationController.add(duration);
    });
    
    // Player errors
    _player.onPlayerComplete.listen((_) {
      AppLogger.info('$_serviceName: Playback completed');
    });
  }

  /// Play a single content block
  Future<Result<void>> play(ContentBlock contentBlock, {LearningSession? session}) async {
    try {
      AppLogger.info('$_serviceName: Playing content block: ${contentBlock.title}');
      
      // Check if content is available locally
      String audioPath;
      if (contentBlock.isDownloaded && contentBlock.localAudioPath != null) {
        audioPath = contentBlock.localAudioPath!;
        if (!File(audioPath).existsSync()) {
          return Result.failure(AudioFailure(
            message: 'Local audio file not found',
            code: 'file_not_found',
          ));
        }
      } else if (contentBlock.audioUrl.isNotEmpty) {
        audioPath = contentBlock.audioUrl;
      } else {
        return Result.failure(AudioFailure(
          message: 'No audio source available',
          code: 'no_audio_source',
        ));
      }
      
      // Update current content and session
      _currentContentBlock = contentBlock;
      _currentSession = session;
      _currentContentController.add(contentBlock);
      
      // Play the audio
      if (audioPath.startsWith('http')) {
        await _player.play(ap.UrlSource(audioPath));
      } else {
        await _player.play(ap.DeviceFileSource(audioPath));
      }
      
      // Set playback speed
      await _player.setPlaybackRate(_playbackSpeed);
      
      AppLogger.info('$_serviceName: Successfully started playback');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error playing content block', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to play audio',
        code: 'playback_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Pause playback
  Future<Result<void>> pause() async {
    try {
      await _player.pause();
      AppLogger.info('$_serviceName: Playback paused');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error pausing playback', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to pause playback',
        code: 'pause_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Resume playback
  Future<Result<void>> resume() async {
    try {
      await _player.resume();
      AppLogger.info('$_serviceName: Playback resumed');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error resuming playback', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to resume playback',
        code: 'resume_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Stop playback
  Future<Result<void>> stop() async {
    try {
      await _player.stop();
      _currentContentBlock = null;
      _currentSession = null;
      _currentContentController.add(null);
      AppLogger.info('$_serviceName: Playback stopped');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error stopping playback', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to stop playback',
        code: 'stop_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Seek to specific position
  Future<Result<void>> seekTo(Duration position) async {
    try {
      await _player.seek(position);
      AppLogger.debug('$_serviceName: Seeked to position: ${position.inSeconds}s');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error seeking to position', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to seek to position',
        code: 'seek_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Set playback speed
  Future<Result<void>> setPlaybackSpeed(double speed) async {
    try {
      // Validate speed range
      if (speed < 0.25 || speed > 3.0) {
        return Result.failure(ValidationFailure(
          message: 'Playback speed must be between 0.25x and 3.0x',
          code: 'invalid_speed',
        ));
      }
      
      await _player.setPlaybackRate(speed);
      _playbackSpeed = speed;
      _playbackSpeedController.add(speed);
      
      AppLogger.info('$_serviceName: Playback speed set to: ${speed}x');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error setting playback speed', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to set playback speed',
        code: 'speed_change_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Set audio queue for continuous playback
  Future<Result<void>> setQueue(List<ContentBlock> contentBlocks, {int startIndex = 0}) async {
    try {
      if (contentBlocks.isEmpty) {
        return Result.failure(ValidationFailure(
          message: 'Content queue cannot be empty',
          code: 'empty_queue',
        ));
      }
      
      if (startIndex < 0 || startIndex >= contentBlocks.length) {
        return Result.failure(ValidationFailure(
          message: 'Start index out of range',
          code: 'invalid_start_index',
        ));
      }
      
      _queue = List.from(contentBlocks);
      _currentIndex = startIndex;
      _queueController.add(_queue);
      
      AppLogger.info('$_serviceName: Queue set with ${_queue.length} content blocks');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error setting queue', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to set audio queue',
        code: 'queue_set_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Skip to next track in queue
  Future<Result<void>> skipToNext() async {
    try {
      if (_queue.isEmpty) {
        return Result.failure(ValidationFailure(
          message: 'No content in queue',
          code: 'empty_queue',
        ));
      }
      
      if (_isShuffleMode) {
        _currentIndex = _getRandomIndex();
      } else {
        _currentIndex = (_currentIndex + 1) % _queue.length;
      }
      
      final nextContent = _queue[_currentIndex];
      final result = await play(nextContent, session: _currentSession);
      
      if (result.isSuccess) {
        AppLogger.info('$_serviceName: Skipped to next track: ${nextContent.title}');
      }
      
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error skipping to next track', e, stackTrace);
      return Result.failure(AudioFailure(
        message: 'Failed to skip to next track',
        code: 'skip_next_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle track completion
  void _handleTrackCompleted() {
    if (_isRepeatMode && _currentContentBlock != null) {
      // Repeat current track
      play(_currentContentBlock!, session: _currentSession);
    } else if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
      // Play next track in queue
      skipToNext();
    } else {
      // End of queue
      AppLogger.info('$_serviceName: Reached end of queue');
      _currentContentBlock = null;
      _currentSession = null;
      _currentContentController.add(null);
    }
  }

  /// Get random index for shuffle mode
  int _getRandomIndex() {
    if (_queue.length <= 1) return 0;
    
    int randomIndex;
    do {
      randomIndex = DateTime.now().millisecondsSinceEpoch % _queue.length;
    } while (randomIndex == _currentIndex);
    
    return randomIndex;
  }

  /// Dispose of resources
  void dispose() {
    _player.dispose();
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
    _currentContentController.close();
    _queueController.close();
    _playbackSpeedController.close();
    AppLogger.info('$_serviceName: Audio player service disposed');
  }
}


