import 'dart:async';
import 'models/lesson.dart';
import 'models/learning_session.dart';
import 'models/learning_path.dart';
import 'models/learning_progress.dart';
import 'data/learning_data_service.dart';
import 'services/learning_session_service.dart';
import 'services/learning_progress_service.dart';
import 'services/lesson_service.dart';
import '../core/utils/logger.dart';
import '../core/exceptions/app_exceptions.dart';

/// Unified manager for all learning-related operations
/// Provides a single interface for lessons, progress, sessions, and paths
class LearningManager {
  static LearningManager? _instance;
  
  final LearningDataService _dataService;
  final LearningSessionService _sessionService;
  final LearningProgressService _progressService;
  final LessonService _lessonService;
  final AppLogger _logger;

  // State management
  final StreamController<LearningState> _stateController = 
      StreamController<LearningState>.broadcast();

  LearningManager._internal({
    required LearningDataService dataService,
    required LearningSessionService sessionService,
    required LearningProgressService progressService,
    required LessonService lessonService,
    AppLogger? logger,
  }) : _dataService = dataService,
       _sessionService = sessionService,
       _progressService = progressService,
       _lessonService = lessonService,
       _logger = logger ?? AppLogger() {
    
    // Listen to session changes and update state
    _sessionService.sessionStream.listen((session) {
      _updateState(currentSession: session);
    });
  }

  /// Get singleton instance
  factory LearningManager.getInstance({
    LearningDataService? dataService,
    LearningSessionService? sessionService,
    LearningProgressService? progressService,
    LessonService? lessonService,
    AppLogger? logger,
  }) {
    _instance ??= LearningManager._internal(
      dataService: dataService ?? LearningDataService(),
      sessionService: sessionService ?? LearningSessionService(
        dataService: dataService ?? LearningDataService(),
      ),
      progressService: progressService ?? LearningProgressService(
        dataService: dataService ?? LearningDataService(),
      ),
      lessonService: lessonService ?? LessonService(
        dataService: dataService ?? LearningDataService(),
      ),
      logger: logger,
    );
    return _instance!;
  }

  /// Stream of learning state changes
  Stream<LearningState> get stateStream => _stateController.stream;

  /// Current learning session
  LearningSession? get currentSession => _sessionService.currentSession;

  /// Check if there's an active learning session
  bool get hasActiveSession => _sessionService.hasActiveSession;

  // === LESSON OPERATIONS ===

  /// Get lesson by ID
  Future<Lesson?> getLesson(String lessonId) async {
    try {
      return await _lessonService.getLesson(lessonId);
    } catch (e, stack) {
      _logger.error('Failed to get lesson', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get multiple lessons
  Future<List<Lesson>> getLessons(List<String> lessonIds) async {
    try {
      return await _lessonService.getLessons(lessonIds);
    } catch (e, stack) {
      _logger.error('Failed to get lessons', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Search lessons
  Future<List<Lesson>> searchLessons({
    String? query,
    List<String>? tags,
    DifficultyLevel? difficulty,
    LessonType? type,
  }) async {
    try {
      return await _lessonService.searchLessons(
        query: query,
        tags: tags,
        difficulty: difficulty,
        type: type,
      );
    } catch (e, stack) {
      _logger.error('Failed to search lessons', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get recommended lessons for user
  Future<List<Lesson>> getRecommendedLessons({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Get user's progress to determine completed lessons and preferences
      final userProgress = await _progressService.getAllUserProgress(userId);
      final completedLessonIds = userProgress
          .where((p) => p.isCompleted)
          .map((p) => p.lessonId)
          .toList();

      // Determine current difficulty level based on recent completions
      DifficultyLevel? currentLevel;
      if (userProgress.isNotEmpty) {
        // Get recent completed lessons and their difficulty
        final recentProgress = userProgress
            .where((p) => p.isCompleted)
            .toList()
          ..sort((a, b) => (b.completedAt ?? b.updatedAt)
              .compareTo(a.completedAt ?? a.updatedAt));

        if (recentProgress.isNotEmpty) {
          // This would ideally look up lesson difficulty from the lessons
          // For now, assume intermediate as default
          currentLevel = DifficultyLevel.intermediate;
        }
      }

      return await _lessonService.getRecommendedLessons(
        userId: userId,
        completedLessonIds: completedLessonIds,
        currentLevel: currentLevel,
        limit: limit,
      );
    } catch (e, stack) {
      _logger.error('Failed to get recommended lessons', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === LEARNING PATH OPERATIONS ===

  /// Get learning path by ID
  Future<LearningPath?> getLearningPath(String pathId) async {
    try {
      return await _dataService.getLearningPath(pathId);
    } catch (e, stack) {
      _logger.error('Failed to get learning path', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get all published learning paths
  Future<List<LearningPath>> getPublishedPaths() async {
    try {
      return await _dataService.getPublishedPaths();
    } catch (e, stack) {
      _logger.error('Failed to get published paths', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get lessons for a learning path
  Future<List<Lesson>> getLessonsForPath(String pathId) async {
    try {
      final path = await getLearningPath(pathId);
      if (path == null) {
        throw ServiceException('Learning path not found: $pathId');
      }

      return await _lessonService.getLessonsForPath(path);
    } catch (e, stack) {
      _logger.error('Failed to get lessons for path', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === PROGRESS OPERATIONS ===

  /// Get user's progress for a lesson
  Future<LearningProgress?> getLessonProgress(String userId, String lessonId) async {
    try {
      return await _progressService.getLessonProgress(userId, lessonId);
    } catch (e, stack) {
      _logger.error('Failed to get lesson progress', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get all user progress
  Future<List<LearningProgress>> getAllUserProgress(String userId) async {
    try {
      return await _progressService.getAllUserProgress(userId);
    } catch (e, stack) {
      _logger.error('Failed to get all user progress', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get learning statistics for user
  Future<LearningStatistics> getLearningStatistics(String userId) async {
    try {
      return await _progressService.getLearningStatistics(userId);
    } catch (e, stack) {
      _logger.error('Failed to get learning statistics', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === SESSION OPERATIONS ===

  /// Start a learning session
  Future<LearningSession> startLearningSession({
    required String userId,
    required String lessonId,
    required SessionType type,
    String? audioFileId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Initialize progress if not exists
      await _progressService.initializeLessonProgress(
        userId: userId,
        lessonId: lessonId,
      );

      // Start progress tracking
      await _progressService.startLessonProgress(userId, lessonId);

      // Start session
      final session = await _sessionService.startSession(
        userId: userId,
        lessonId: lessonId,
        type: type,
        audioFileId: audioFileId,
        metadata: metadata,
      );

      _logger.info('Learning session started: ${session.id}');
      return session;
    } catch (e, stack) {
      _logger.error('Failed to start learning session', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Pause current session
  Future<void> pauseSession() async {
    try {
      await _sessionService.pauseSession();
    } catch (e, stack) {
      _logger.error('Failed to pause session', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Resume current session
  Future<void> resumeSession() async {
    try {
      await _sessionService.resumeSession();
    } catch (e, stack) {
      _logger.error('Failed to resume session', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update session progress
  Future<void> updateSessionProgress(double progressPercentage) async {
    try {
      await _sessionService.updateProgress(progressPercentage);
      
      // Also update progress record
      if (currentSession != null) {
        await _progressService.updateProgressPercentage(
          userId: currentSession!.userId,
          lessonId: currentSession!.lessonId,
          percentage: progressPercentage,
        );
      }
    } catch (e, stack) {
      _logger.error('Failed to update session progress', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Complete current session
  Future<void> completeSession({
    Map<String, dynamic>? performance,
    List<String>? completedObjectives,
    double? score,
  }) async {
    try {
      if (currentSession == null) {
        throw ServiceException('No active session to complete');
      }

      // Complete the session
      await _sessionService.completeSession(
        performance: performance,
        completedObjectives: completedObjectives,
      );

      // Update progress from completed session
      if (currentSession != null) {
        await _progressService.updateProgressFromSession(
          userId: currentSession!.userId,
          session: currentSession!,
        );

        // Mark lesson as completed if score is provided
        if (score != null) {
          await _progressService.completeLessonProgress(
            userId: currentSession!.userId,
            lessonId: currentSession!.lessonId,
            score: score,
            completedObjectives: completedObjectives,
          );
        }
      }

      _logger.info('Learning session completed successfully');
    } catch (e, stack) {
      _logger.error('Failed to complete session', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// End current session
  Future<void> endCurrentSession() async {
    try {
      await _sessionService.endCurrentSession();
    } catch (e, stack) {
      _logger.error('Failed to end current session', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Add milestone to current session
  Future<void> addSessionMilestone(String milestone, Map<String, dynamic> data) async {
    try {
      await _sessionService.addMilestone(milestone, data);
    } catch (e, stack) {
      _logger.error('Failed to add session milestone', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === UTILITY METHODS ===

  /// Check if user can access a lesson (meets prerequisites)
  Future<bool> canAccessLesson({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final userProgress = await getAllUserProgress(userId);
      final completedLessonIds = userProgress
          .where((p) => p.isCompleted)
          .map((p) => p.lessonId)
          .toList();

      return await _lessonService.meetsPrerequisites(
        lessonId: lessonId,
        completedLessonIds: completedLessonIds,
      );
    } catch (e, stack) {
      _logger.error('Failed to check lesson access', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get next recommended lesson for user
  Future<Lesson?> getNextRecommendedLesson(String userId) async {
    try {
      final recommendations = await getRecommendedLessons(
        userId: userId,
        limit: 1,
      );

      return recommendations.isNotEmpty ? recommendations.first : null;
    } catch (e, stack) {
      _logger.error('Failed to get next recommended lesson', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update learning state
  void _updateState({
    LearningSession? currentSession,
    String? currentLessonId,
    LearningProgress? currentProgress,
  }) {
    final state = LearningState(
      currentSession: currentSession ?? this.currentSession,
      currentLessonId: currentLessonId,
      currentProgress: currentProgress,
      isSessionActive: hasActiveSession,
      lastUpdated: DateTime.now(),
    );

    _stateController.add(state);
  }

  /// Dispose resources
  void dispose() {
    _sessionService.dispose();
    _stateController.close();
  }
}

/// Learning state model for state management
class LearningState {
  final LearningSession? currentSession;
  final String? currentLessonId;
  final LearningProgress? currentProgress;
  final bool isSessionActive;
  final DateTime lastUpdated;

  const LearningState({
    this.currentSession,
    this.currentLessonId,
    this.currentProgress,
    required this.isSessionActive,
    required this.lastUpdated,
  });

  LearningState copyWith({
    LearningSession? currentSession,
    String? currentLessonId,
    LearningProgress? currentProgress,
    bool? isSessionActive,
    DateTime? lastUpdated,
  }) => LearningState(
    currentSession: currentSession ?? this.currentSession,
    currentLessonId: currentLessonId ?? this.currentLessonId,
    currentProgress: currentProgress ?? this.currentProgress,
    isSessionActive: isSessionActive ?? this.isSessionActive,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}
