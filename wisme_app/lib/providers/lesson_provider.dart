// Lesson content and AI coach state management
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/gpt_service.dart';
import '../models/lesson_model.dart';
import 'dart:typed_data';

class LessonProvider extends ChangeNotifier {
  final StorageService _storageService;
  final GPTService _gptService;

  List<LessonModel> _lessons = [];
  List<String> _topics = [];
  LessonModel? _currentLesson;
  bool _isLoading = false;
  String? _error;

  LessonProvider({
    required StorageService storageService,
    required GPTService gptService,
  }) : _storageService = storageService,
       _gptService = gptService {
    _loadTopics();
  }

  // Getters
  List<LessonModel> get lessons => _lessons;
  List<String> get topics => _topics;
  LessonModel? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadTopics() async {
    try {
      final topicsData = await _storageService.getAllTopics();
      _topics = topicsData.map((topic) => topic['topic_name'] as String).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load topics: $e';
      notifyListeners();
    }
  }

  Future<void> loadLessonsByTopic(String topic) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lessonsData = await _storageService.getLessonsByTopic(topic);
      _lessons = lessonsData.map((data) => LessonModel.fromJson(data)).toList();
    } catch (e) {
      _error = 'Failed to load lessons: $e';
      if (kDebugMode) {
        print('Error loading lessons: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchLessons(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lessonsData = await _storageService.searchLessons(query);
      _lessons = lessonsData.map((data) => LessonModel.fromJson(data)).toList();
    } catch (e) {
      _error = 'Search failed: $e';
      if (kDebugMode) {
        print('Error searching lessons: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LessonModel?> generateLesson({
    required String topic,
    required String subtopic,
    required String userQuery,
    String coachVoice = 'default',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if lesson already exists
      final existingLesson = await _storageService.findExistingLesson(
        subtopic,
        userQuery,
        coachVoice: coachVoice,
      );

      if (existingLesson != null) {
        final lesson = LessonModel.fromJson(existingLesson);
        _currentLesson = lesson;
        await _storageService.incrementLessonAccess(lesson.lessonId, coachVoice);
        notifyListeners();
        return lesson;
      }

      // Generate new lesson content
      final lessonContent = await _gptService.generateLessonContent(
        topic: topic,
        subtopic: subtopic,
        title: userQuery,
      );
      
      if (lessonContent.isEmpty) {
        _error = 'Failed to generate lesson content';
        return null;
      }

      // For now, we'll use mock audio data since TTS integration is complex
      final mockAudioData = List.generate(1000, (index) => index % 256);
      
      // Store the lesson
      await _storageService.storeNewLesson(
        topic: topic,
        subtopic: subtopic,
        title: userQuery,
        lessonContent: lessonContent,
        audioData: Uint8List.fromList(mockAudioData),
        durationSeconds: 120,
        tags: [topic.toLowerCase(), subtopic.toLowerCase()],
        summary: lessonContent.length > 100 ? lessonContent.substring(0, 100) + '...' : lessonContent,
        coachVoice: coachVoice,
      );

      // Create lesson model from stored data
      final storedLessonData = await _storageService.findExistingLesson(
        subtopic,
        userQuery,
        coachVoice: coachVoice,
      );

      if (storedLessonData != null) {
        final lesson = LessonModel.fromJson(storedLessonData);
        _currentLesson = lesson;
        notifyListeners();
        return lesson;
      }

    } catch (e) {
      _error = 'Failed to generate lesson: $e';
      if (kDebugMode) {
        print('Error generating lesson: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  void setCurrentLesson(LessonModel lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshLessons() async {
    if (_topics.isNotEmpty) {
      await loadLessonsByTopic(_topics.first);
    }
  }
}
