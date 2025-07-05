import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import '../../shared/models/result.dart';
import '../../core/utils/logger.dart';

/// Production-grade Audio Player service for the new architecture
class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  // State management
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;

  // Event streams
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  AudioPlayerService() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Set up listeners
      _audioPlayer.onPlayerStateChanged.listen((state) {
        _playerState = state;
        AppLogger.info('🎵 Player state changed: $state');
      });

      _audioPlayer.onPositionChanged.listen((position) {
        _position = position;
      });

      _audioPlayer.onDurationChanged.listen((duration) {
        _duration = duration;
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        AppLogger.info('🎵 Playback completed');
      });

      _isInitialized = true;
      AppLogger.info('✅ AudioPlayerService initialized successfully');
    } catch (e) {
      AppLogger.error('❌ Error initializing AudioPlayerService: $e');
    }
  }

  /// Play audio from URL
  Future<Result<void>> playFromUrl(String url) async {
    try {
      await _initialize();
      
      await _audioPlayer.play(UrlSource(url));
      
      AppLogger.info('✅ Started playing audio from URL');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error playing from URL: $e');
      return Result.failure('Error playing audio: $e');
    }
  }

  /// Play audio from bytes
  Future<Result<void>> playFromBytes(Uint8List bytes) async {
    try {
      await _initialize();
      
      await _audioPlayer.play(BytesSource(bytes));
      
      AppLogger.info('✅ Started playing audio from bytes');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error playing from bytes: $e');
      return Result.failure('Error playing audio: $e');
    }
  }

  /// Play audio from local file path
  Future<Result<void>> playFromFile(String filePath) async {
    try {
      await _initialize();
      
      await _audioPlayer.play(DeviceFileSource(filePath));
      
      AppLogger.info('✅ Started playing audio from file: $filePath');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error playing from file: $e');
      return Result.failure('Error playing audio: $e');
    }
  }

  /// Pause playback
  Future<Result<void>> pause() async {
    try {
      await _audioPlayer.pause();
      
      AppLogger.info('✅ Audio playback paused');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error pausing audio: $e');
      return Result.failure('Error pausing audio: $e');
    }
  }

  /// Resume playback
  Future<Result<void>> resume() async {
    try {
      await _audioPlayer.resume();
      
      AppLogger.info('✅ Audio playback resumed');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error resuming audio: $e');
      return Result.failure('Error resuming audio: $e');
    }
  }

  /// Stop playback
  Future<Result<void>> stop() async {
    try {
      await _audioPlayer.stop();
      
      AppLogger.info('✅ Audio playback stopped');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error stopping audio: $e');
      return Result.failure('Error stopping audio: $e');
    }
  }

  /// Seek to specific position
  Future<Result<void>> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      
      AppLogger.info('✅ Seeked to position: ${position.inSeconds}s');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error seeking: $e');
      return Result.failure('Error seeking: $e');
    }
  }

  /// Set playback speed
  Future<Result<void>> setPlaybackSpeed(double speed) async {
    try {
      // Clamp speed between 0.5x and 2.0x
      speed = speed.clamp(0.5, 2.0);
      
      await _audioPlayer.setPlaybackRate(speed);
      _playbackSpeed = speed;
      
      AppLogger.info('✅ Playback speed set to: ${speed}x');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error setting playback speed: $e');
      return Result.failure('Error setting playback speed: $e');
    }
  }

  /// Set volume
  Future<Result<void>> setVolume(double volume) async {
    try {
      // Clamp volume between 0.0 and 1.0
      volume = volume.clamp(0.0, 1.0);
      
      await _audioPlayer.setVolume(volume);
      _volume = volume;
      
      AppLogger.info('✅ Volume set to: ${(volume * 100).round()}%');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error setting volume: $e');
      return Result.failure('Error setting volume: $e');
    }
  }

  /// Skip forward by specified duration
  Future<Result<void>> skipForward(Duration duration) async {
    try {
      final newPosition = _position + duration;
      final clampedPosition = newPosition > _duration ? _duration : newPosition;
      
      return await seekTo(clampedPosition);
    } catch (e) {
      AppLogger.error('❌ Error skipping forward: $e');
      return Result.failure('Error skipping forward: $e');
    }
  }

  /// Skip backward by specified duration
  Future<Result<void>> skipBackward(Duration duration) async {
    try {
      final newPosition = _position - duration;
      final clampedPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
      
      return await seekTo(clampedPosition);
    } catch (e) {
      AppLogger.error('❌ Error skipping backward: $e');
      return Result.failure('Error skipping backward: $e');
    }
  }

  /// Add bookmark at current position
  Future<Result<AudioBookmark>> addBookmark({
    String? note,
    String? title,
  }) async {
    try {
      final bookmark = AudioBookmark(
        id: _generateBookmarkId(),
        position: _position,
        title: title ?? 'Bookmark at ${_formatDuration(_position)}',
        note: note,
        createdAt: DateTime.now(),
      );
      
      AppLogger.info('✅ Bookmark added at: ${_formatDuration(_position)}');
      return Result.success(bookmark);
    } catch (e) {
      AppLogger.error('❌ Error adding bookmark: $e');
      return Result.failure('Error adding bookmark: $e');
    }
  }

  /// Get current player state
  PlayerState get playerState => _playerState;

  /// Get current position
  Duration get position => _position;

  /// Get total duration
  Duration get duration => _duration;

  /// Get current playback speed
  double get playbackSpeed => _playbackSpeed;

  /// Get current volume
  double get volume => _volume;

  /// Check if currently playing
  bool get isPlaying => _playerState == PlayerState.playing;

  /// Check if paused
  bool get isPaused => _playerState == PlayerState.paused;

  /// Check if stopped
  bool get isStopped => _playerState == PlayerState.stopped;

  /// Get progress as percentage (0.0 to 1.0)
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  /// Get remaining time
  Duration get remainingTime => _duration - _position;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      AppLogger.info('✅ AudioPlayerService disposed');
    } catch (e) {
      AppLogger.error('❌ Error disposing AudioPlayerService: $e');
    }
  }

  /// Generate unique bookmark ID
  String _generateBookmarkId() {
    return 'bookmark_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Format duration as MM:SS
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Audio bookmark model
class AudioBookmark {
  final String id;
  final Duration position;
  final String title;
  final String? note;
  final DateTime createdAt;

  const AudioBookmark({
    required this.id,
    required this.position,
    required this.title,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position_ms': position.inMilliseconds,
      'title': title,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AudioBookmark.fromMap(Map<String, dynamic> map) {
    return AudioBookmark(
      id: map['id'] ?? '',
      position: Duration(milliseconds: map['position_ms'] ?? 0),
      title: map['title'] ?? '',
      note: map['note'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Audio session configuration
class AudioSessionConfig {
  final AudioSessionCategory category;
  final AudioSessionMode mode;
  final bool allowBluetooth;
  final bool allowAirPlay;

  const AudioSessionConfig({
    this.category = AudioSessionCategory.playback,
    this.mode = AudioSessionMode.spokenAudio,
    this.allowBluetooth = true,
    this.allowAirPlay = true,
  });
}

/// Audio session categories
enum AudioSessionCategory {
  ambient,
  soloAmbient,
  playback,
  record,
  playAndRecord,
  multiRoute,
}

/// Audio session modes
enum AudioSessionMode {
  defaultMode,
  voiceChat,
  gameChat,
  videoRecording,
  measurement,
  moviePlayback,
  videoChat,
  spokenAudio,
}
