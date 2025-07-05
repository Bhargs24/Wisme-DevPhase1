class AudioPlaybackService {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> play(String filePath) async {
    // TODO: Implement actual audio playback
    _isPlaying = true;
  }

  Future<void> pause() async {
    _isPlaying = false;
  }

  Future<void> stop() async {
    _isPlaying = false;
  }
}
