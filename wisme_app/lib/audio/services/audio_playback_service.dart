import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import '../models/stored_audio_file.dart';
import '../services/audio_cache_manager.dart';

/// Production-grade audio playback service
/// Manages audio playback with advanced controls and state management
class AudioPlaybackService {
  final AudioCacheManager _cacheManager;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Playback state
  AudioPlaybackState _state = AudioPlaybackState.stopped;
  StoredAudioFile? _currentFile;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;

  // Stream controllers for state changes
  final StreamController<AudioPlaybackState> _stateController = StreamController.broadcast();
  final StreamController<Duration> _positionController = StreamController.broadcast();
  final StreamController<Duration> _durationController = StreamController.broadcast();
  final StreamController<StoredAudioFile?> _currentFileController = StreamController.broadcast();

  // Subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  AudioPlaybackService({required AudioCacheManager cacheManager})
      : _cacheManager = cacheManager {
    _initializePlayer();
  }

  // Public getters for current state
  AudioPlaybackState get state => _state;
  StoredAudioFile? get currentFile => _currentFile;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get playbackSpeed => _playbackSpeed;
  double get volume => _volume;

  // Streams for listening to state changes
  Stream<AudioPlaybackState> get stateStream => _stateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<StoredAudioFile?> get currentFileStream => _currentFileController.stream;

  /// Play audio file by ID
  Future<bool> playAudioFile(String fileId) async {
    try {
      // Get audio file and data from cache manager
      final audioFile = await _cacheManager.getAudioFile(fileId);
      if (audioFile == null) {
        print('Audio file not found: $fileId');
        return false;
      }

      final audioData = await _cacheManager.getAudioData(fileId);
      if (audioData == null) {
        print('Audio data not available: $fileId');
        return false;
      }

      // Stop current playback if any
      await stop();

      // Set current file
      _currentFile = audioFile;
      _currentFileController.add(_currentFile);

      // Play audio from bytes
      await _audioPlayer.play(BytesSource(audioData));
      
      _updateState(AudioPlaybackState.playing);
      return true;
    } catch (e) {
      print('Error playing audio file: $e');
      _updateState(AudioPlaybackState.error);
      return false;
    }
  }

  /// Play audio from raw data
  Future<bool> playAudioData(Uint8List audioData, {String? fileName}) async {
    try {
      await stop();

      // Create temporary stored file for tracking
      if (fileName != null) {
        _currentFile = StoredAudioFile(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          fileName: fileName,
          localPath: '',
          fileSize: audioData.length,
          dataHash: '',
          metadata: {},
          hashtags: [],
          createdAt: DateTime.now(),
          lastAccessedAt: DateTime.now(),
        );
        _currentFileController.add(_currentFile);
      }

      await _audioPlayer.play(BytesSource(audioData));
      _updateState(AudioPlaybackState.playing);
      return true;
    } catch (e) {
      print('Error playing audio data: $e');
      _updateState(AudioPlaybackState.error);
      return false;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _updateState(AudioPlaybackState.paused);
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
      _updateState(AudioPlaybackState.playing);
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
      _positionController.add(_currentPosition);
      _updateState(AudioPlaybackState.stopped);
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _currentPosition = position;
      _positionController.add(_currentPosition);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setPlaybackRate(speed);
      _playbackSpeed = speed;
    } catch (e) {
      print('Error setting playback speed: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      _volume = clampedVolume;
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  /// Skip forward by specified duration
  Future<void> skipForward(Duration duration) async {
    final newPosition = _currentPosition + duration;
    final maxPosition = _totalDuration;
    
    if (newPosition <= maxPosition) {
      await seekTo(newPosition);
    } else {
      await seekTo(maxPosition);
    }
  }

  /// Skip backward by specified duration
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _currentPosition - duration;
    
    if (newPosition >= Duration.zero) {
      await seekTo(newPosition);
    } else {
      await seekTo(Duration.zero);
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_state == AudioPlaybackState.playing) {
      await pause();
    } else if (_state == AudioPlaybackState.paused) {
      await resume();
    }
  }

  /// Get playback progress (0.0 to 1.0)
  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  /// Get remaining time
  Duration get remainingTime {
    return _totalDuration - _currentPosition;
  }

  /// Check if audio is currently playing
  bool get isPlaying => _state == AudioPlaybackState.playing;

  /// Check if audio is paused
  bool get isPaused => _state == AudioPlaybackState.paused;

  /// Check if audio is stopped
  bool get isStopped => _state == AudioPlaybackState.stopped;

  /// Get formatted current position string
  String get formattedPosition => _formatDuration(_currentPosition);

  /// Get formatted total duration string
  String get formattedDuration => _formatDuration(_totalDuration);

  /// Get formatted remaining time string
  String get formattedRemainingTime => _formatDuration(remainingTime);

  /// Dispose resources
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    
    _stateController.close();
    _positionController.close();
    _durationController.close();
    _currentFileController.close();
    
    _audioPlayer.dispose();
  }

  // Private helper methods

  void _initializePlayer() {
    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          _updateState(AudioPlaybackState.playing);
          break;
        case PlayerState.paused:
          _updateState(AudioPlaybackState.paused);
          break;
        case PlayerState.stopped:
          _updateState(AudioPlaybackState.stopped);
          break;
        case PlayerState.completed:
          _updateState(AudioPlaybackState.completed);
          break;
        case PlayerState.disposed:
          _updateState(AudioPlaybackState.stopped);
          break;
      }
    });

    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      _positionController.add(_currentPosition);
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      _durationController.add(_totalDuration);
    });
  }

  void _updateState(AudioPlaybackState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(_state);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }
}

/// Audio playback states
enum AudioPlaybackState {
  stopped,
  playing,
  paused,
  completed,
  buffering,
  error,
}

/// Extension for AudioPlaybackState enum
extension AudioPlaybackStateExtension on AudioPlaybackState {
  String get displayName {
    switch (this) {
      case AudioPlaybackState.stopped:
        return 'Stopped';
      case AudioPlaybackState.playing:
        return 'Playing';
      case AudioPlaybackState.paused:
        return 'Paused';
      case AudioPlaybackState.completed:
        return 'Completed';
      case AudioPlaybackState.buffering:
        return 'Buffering';
      case AudioPlaybackState.error:
        return 'Error';
    }
  }

  bool get isActive {
    return this == AudioPlaybackState.playing || 
           this == AudioPlaybackState.paused ||
           this == AudioPlaybackState.buffering;
  }
}
