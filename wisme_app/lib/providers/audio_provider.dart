import 'package:flutter/foundation.dart';
import '../models/lesson_model.dart';

class AudioProvider extends ChangeNotifier {
  // Current state
  LessonModel? _currentLesson;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;
  String _error = '';

  // Getters
  LessonModel? get currentLesson => _currentLesson;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get playbackSpeed => _playbackSpeed;
  String get error => _error;
  bool get hasCurrentLesson => _currentLesson != null;

  // Set current lesson
  void setCurrentLesson(LessonModel lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }

  // Basic audio controls
  Future<void> play() async {
    try {
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Switch voice for current lesson
  Future<void> switchVoice(String voiceId) async {
    if (_currentLesson == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      // Create new lesson with different voice
      final updatedLesson = LessonModel(
        lessonId: _currentLesson!.lessonId,
        topic: _currentLesson!.topic,
        subtopic: _currentLesson!.subtopic,
        summary: _currentLesson!.summary,
        title: _currentLesson!.title,
        text: _currentLesson!.text,
        wordCount: _currentLesson!.wordCount,
        durationSeconds: _currentLesson!.durationSeconds,
        length: _currentLesson!.length,
        coachVoice: voiceId,
        audioUrl: _currentLesson!.audioUrl,
        tags: _currentLesson!.tags,
        accessCount: _currentLesson!.accessCount,
        createdAt: _currentLesson!.createdAt,
        lastAccessedAt: _currentLesson!.lastAccessedAt,
        fileSize: _currentLesson!.fileSize,
        storagePath: _currentLesson!.storagePath,
      );

      _currentLesson = updatedLesson;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get available voices
  Future<List<String>> getAvailableVoices() async {
    try {
      // Return default available voices
      return [
        'zen_coach',
        'startup_buddy', 
        'science_guide',
        'motivational',
        'storyteller',
        'default'
      ];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
