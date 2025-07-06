import '../models/learning_progress.dart';
import '../models/lesson.dart';
import '../models/learning_session.dart';
import '../data/learning_data_service.dart';
import '../../core/utils/logger.dart';
import '../../core/exceptions/app_exceptions.dart';

/// Service for managing user learning progress and achievements
class LearningProgressService {
  final LearningDataService _dataService;
  final AppLogger _logger;

  LearningProgressService({
    required LearningDataService dataService,
    AppLogger? logger,
  }) : _dataService = dataService,
       _logger = logger ?? AppLogger();

  /// Get user's progress for a specific lesson
  Future<LearningProgress?> getLessonProgress(String userId, String lessonId) async {
    try {
      return await _dataService.getUserProgress(userId, lessonId);
    } catch (e, stack) {
      _logger.error('Failed to get lesson progress', error: e, stackTrace: stack);
      throw ServiceException('Failed to get lesson progress: $e');
    }
  }

  /// Get all progress for a user
  Future<List<LearningProgress>> getAllUserProgress(String userId) async {
    try {
      return await _dataService.getAllUserProgress(userId);
    } catch (e, stack) {
      _logger.error('Failed to get user progress', error: e, stackTrace: stack);
      throw ServiceException('Failed to get user progress: $e');
    }
  }

  /// Initialize progress for a lesson when user starts
  Future<LearningProgress> initializeLessonProgress({
    required String userId,
    required String lessonId,
    String? pathId,
  }) async {
    try {
      // Check if progress already exists
      final existingProgress = await getLessonProgress(userId, lessonId);
      if (existingProgress != null) {
        return existingProgress;
      }

      final progressId = _generateProgressId(userId, lessonId);
      final now = DateTime.now();

      final progress = LearningProgress(
        id: progressId,
        userId: userId,
        lessonId: lessonId,
        pathId: pathId,
        status: ProgressStatus.notStarted,
        completionPercentage: 0.0,
        completedObjectives: [],
        timeSpent: Duration.zero,
        attempts: 0,
        createdAt: now,
        updatedAt: now,
        metadata: {},
      );

      await _dataService.saveUserProgress(progress);

      _logger.info('Progress initialized for lesson: $lessonId');
      return progress;
    } catch (e, stack) {
      _logger.error('Failed to initialize progress', error: e, stackTrace: stack);
      throw ServiceException('Failed to initialize progress: $e');
    }
  }

  /// Start learning progress (mark as in progress)
  Future<LearningProgress> startLessonProgress(String userId, String lessonId) async {
    try {
      final progress = await getLessonProgress(userId, lessonId) ??
          await initializeLessonProgress(userId: userId, lessonId: lessonId);

      final updatedProgress = progress.copyWith(
        status: ProgressStatus.inProgress,
        lastAccessedAt: DateTime.now(),
        attempts: progress.attempts + 1,
        updatedAt: DateTime.now(),
      );

      await _dataService.saveUserProgress(updatedProgress);

      _logger.info('Progress started for lesson: $lessonId');
      return updatedProgress;
    } catch (e, stack) {
      _logger.error('Failed to start progress', error: e, stackTrace: stack);
      throw ServiceException('Failed to start progress: $e');
    }
  }

  /// Update progress percentage
  Future<LearningProgress> updateProgressPercentage({
    required String userId,
    required String lessonId,
    required double percentage,
  }) async {
    try {
      final progress = await getLessonProgress(userId, lessonId);
      if (progress == null) {
        throw ServiceException('Progress not found for lesson: $lessonId');
      }

      final clampedPercentage = percentage.clamp(0.0, 100.0);
      final updatedProgress = progress.copyWith(
        completionPercentage: clampedPercentage,
        lastAccessedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dataService.saveUserProgress(updatedProgress);

      _logger.debug('Progress updated: $clampedPercentage% for lesson: $lessonId');
      return updatedProgress;
    } catch (e, stack) {
      _logger.error('Failed to update progress percentage', error: e, stackTrace: stack);
      throw ServiceException('Failed to update progress: $e');
    }
  }

  /// Add completed objective
  Future<LearningProgress> completeObjective({
    required String userId,
    required String lessonId,
    required String objectiveId,
  }) async {
    try {
      final progress = await getLessonProgress(userId, lessonId);
      if (progress == null) {
        throw ServiceException('Progress not found for lesson: $lessonId');
      }

      if (progress.completedObjectives.contains(objectiveId)) {
        return progress; // Already completed
      }

      final updatedObjectives = [...progress.completedObjectives, objectiveId];
      final updatedProgress = progress.copyWith(
        completedObjectives: updatedObjectives,
        lastAccessedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dataService.saveUserProgress(updatedProgress);

      _logger.info('Objective completed: $objectiveId for lesson: $lessonId');
      return updatedProgress;
    } catch (e, stack) {
      _logger.error('Failed to complete objective', error: e, stackTrace: stack);
      throw ServiceException('Failed to complete objective: $e');
    }
  }

  /// Update time spent on lesson
  Future<LearningProgress> updateTimeSpent({
    required String userId,
    required String lessonId,
    required Duration additionalTime,
  }) async {
    try {
      final progress = await getLessonProgress(userId, lessonId);
      if (progress == null) {
        throw ServiceException('Progress not found for lesson: $lessonId');
      }

      final updatedProgress = progress.copyWith(
        timeSpent: progress.timeSpent + additionalTime,
        lastAccessedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dataService.saveUserProgress(updatedProgress);

      _logger.debug('Time updated for lesson: $lessonId');
      return updatedProgress;
    } catch (e, stack) {
      _logger.error('Failed to update time spent', error: e, stackTrace: stack);
      throw ServiceException('Failed to update time spent: $e');
    }
  }

  /// Complete lesson progress
  Future<LearningProgress> completeLessonProgress({
    required String userId,
    required String lessonId,
    double? score,
    List<String>? completedObjectives,
  }) async {
    try {
      final progress = await getLessonProgress(userId, lessonId);
      if (progress == null) {
        throw ServiceException('Progress not found for lesson: $lessonId');
      }

      final now = DateTime.now();
      final updatedProgress = progress.copyWith(
        status: ProgressStatus.completed,
        completionPercentage: 100.0,
        lastScore: score,
        completedObjectives: completedObjectives ?? progress.completedObjectives,
        completedAt: now,
        lastAccessedAt: now,
        updatedAt: now,
      );

      await _dataService.saveUserProgress(updatedProgress);

      _logger.info('Lesson completed: $lessonId with score: ${score ?? 'N/A'}');
      return updatedProgress;
    } catch (e, stack) {
      _logger.error('Failed to complete lesson', error: e, stackTrace: stack);
      throw ServiceException('Failed to complete lesson: $e');
    }
  }

  /// Update progress from learning session
  Future<LearningProgress> updateProgressFromSession({
    required String userId,
    required LearningSession session,
  }) async {
    try {
      final progress = await getLessonProgress(userId, session.lessonId) ??
          await initializeLessonProgress(userId: userId, lessonId: session.lessonId);

      // Calculate time spent from session
      final sessionTime = session.effectiveLearningTime;
      final updatedTimeSpent = progress.timeSpent + sessionTime;

      // Update progress based on session status
      ProgressStatus newStatus = progress.status;
      double newPercentage = progress.progressPercentage;
      DateTime? completedAt = progress.completedAt;

      if (session.status == SessionStatus.completed) {
        newStatus = ProgressStatus.completed;
        newPercentage = 100.0;
        completedAt = session.endTime;
      } else if (session.progressPercentage > progress.progressPercentage) {
        newStatus = ProgressStatus.inProgress;
        newPercentage = session.progressPercentage;
      }

      final updatedProgress = progress.copyWith(
        status: newStatus,
        completionPercentage: newPercentage,
        timeSpent: updatedTimeSpent,
        completedObjectives: session.completedObjectives.isNotEmpty
            ? session.completedObjectives
            : progress.completedObjectives,
        lastAccessedAt: session.endTime ?? session.startTime,
        completedAt: completedAt,
        updatedAt: DateTime.now(),
        metadata: {
          ...progress.metadata,
          'lastSessionId': session.id,
          'lastSessionType': session.type.name,
        },
      );

      await _dataService.saveUserProgress(updatedProgress);

      _logger.info('Progress updated from session: ${session.id}');
      return updatedProgress;
    } catch (e, stack) {
      _logger.error('Failed to update progress from session', error: e, stackTrace: stack);
      throw ServiceException('Failed to update progress from session: $e');
    }
  }

  /// Get learning statistics for user
  Future<LearningStatistics> getLearningStatistics(String userId) async {
    try {
      final allProgress = await getAllUserProgress(userId);

      final completedLessons = allProgress.where((p) => p.isCompleted).length;
      final inProgressLessons = allProgress.where((p) => p.isInProgress).length;
      final totalTimeSpent = allProgress.fold<Duration>(
        Duration.zero,
        (total, progress) => total + progress.timeSpent,
      );

      final averageScore = allProgress
          .where((p) => p.lastScore != null)
          .map((p) => p.lastScore!)
          .fold(0.0, (sum, score) => sum + score) /
          allProgress.where((p) => p.lastScore != null).length;

      final totalLessons = allProgress.length;
      final completionRate = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

      return LearningStatistics(
        totalLessons: totalLessons,
        completedLessons: completedLessons,
        inProgressLessons: inProgressLessons,
        totalTimeSpent: totalTimeSpent,
        averageScore: averageScore.isNaN ? null : averageScore,
        completionRate: completionRate,
        lastActivity: allProgress.isNotEmpty
            ? allProgress
                .map((p) => p.lastAccessedAt ?? p.updatedAt)
                .reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      );
    } catch (e, stack) {
      _logger.error('Failed to get learning statistics', error: e, stackTrace: stack);
      throw ServiceException('Failed to get learning statistics: $e');
    }
  }

  /// Generate unique progress ID
  String _generateProgressId(String userId, String lessonId) {
    return 'progress_${userId}_${lessonId}';
  }
}

/// Learning statistics model
class LearningStatistics {
  final int totalLessons;
  final int completedLessons;
  final int inProgressLessons;
  final Duration totalTimeSpent;
  final double? averageScore;
  final double completionRate;
  final DateTime? lastActivity;

  const LearningStatistics({
    required this.totalLessons,
    required this.completedLessons,
    required this.inProgressLessons,
    required this.totalTimeSpent,
    this.averageScore,
    required this.completionRate,
    this.lastActivity,
  });

  Map<String, dynamic> toJson() => {
    'totalLessons': totalLessons,
    'completedLessons': completedLessons,
    'inProgressLessons': inProgressLessons,
    'totalTimeSpent': totalTimeSpent.inMinutes,
    'averageScore': averageScore,
    'completionRate': completionRate,
    'lastActivity': lastActivity?.toIso8601String(),
  };
}
