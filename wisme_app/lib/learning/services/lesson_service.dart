import '../models/lesson.dart';
import '../models/learning_path.dart';
import '../data/learning_data_service.dart';
import '../../core/utils/logger.dart';
import '../../core/exceptions/app_exceptions.dart';

/// Service for managing lessons and learning content
class LessonService {
  final LearningDataService _dataService;
  final AppLogger _logger;

  LessonService({
    required LearningDataService dataService,
    AppLogger? logger,
  }) : _dataService = dataService,
       _logger = logger ?? AppLogger();

  /// Get lesson by ID
  Future<Lesson?> getLesson(String lessonId) async {
    try {
      return await _dataService.getLesson(lessonId);
    } catch (e, stack) {
      _logger.error('Failed to get lesson', error: e, stackTrace: stack);
      throw ServiceException('Failed to get lesson: $e');
    }
  }

  /// Get multiple lessons by IDs
  Future<List<Lesson>> getLessons(List<String> lessonIds) async {
    try {
      return await _dataService.getLessons(lessonIds);
    } catch (e, stack) {
      _logger.error('Failed to get lessons', error: e, stackTrace: stack);
      throw ServiceException('Failed to get lessons: $e');
    }
  }

  /// Get lessons by tags
  Future<List<Lesson>> getLessonsByTags(List<String> tags) async {
    try {
      return await _dataService.getLessonsByTags(tags);
    } catch (e, stack) {
      _logger.error('Failed to get lessons by tags', error: e, stackTrace: stack);
      throw ServiceException('Failed to get lessons by tags: $e');
    }
  }

  /// Get lessons by difficulty level
  Future<List<Lesson>> getLessonsByDifficulty(DifficultyLevel difficulty) async {
    try {
      return await _dataService.getLessonsByDifficulty(difficulty);
    } catch (e, stack) {
      _logger.error('Failed to get lessons by difficulty', error: e, stackTrace: stack);
      throw ServiceException('Failed to get lessons by difficulty: $e');
    }
  }

  /// Get lessons for a learning path
  Future<List<Lesson>> getLessonsForPath(LearningPath path) async {
    try {
      return await _dataService.getLessons(path.lessonIds);
    } catch (e, stack) {
      _logger.error('Failed to get lessons for path', error: e, stackTrace: stack);
      throw ServiceException('Failed to get lessons for path: $e');
    }
  }

  /// Search lessons by content
  Future<List<Lesson>> searchLessons({
    String? query,
    List<String>? tags,
    DifficultyLevel? difficulty,
    LessonType? type,
  }) async {
    try {
      List<Lesson> lessons = [];

      // If specific criteria provided, use them
      if (tags != null && tags.isNotEmpty) {
        lessons.addAll(await getLessonsByTags(tags));
      }

      if (difficulty != null) {
        final difficultyLessons = await getLessonsByDifficulty(difficulty);
        if (lessons.isEmpty) {
          lessons.addAll(difficultyLessons);
        } else {
          // Intersect with existing results
          lessons = lessons.where((lesson) => 
              difficultyLessons.any((dl) => dl.id == lesson.id)).toList();
        }
      }

      // Filter by type if specified
      if (type != null) {
        lessons = lessons.where((lesson) => lesson.type == type).toList();
      }

      // Filter by query if specified
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        lessons = lessons.where((lesson) =>
            lesson.title.toLowerCase().contains(queryLower) ||
            lesson.description.toLowerCase().contains(queryLower) ||
            lesson.contentText.toLowerCase().contains(queryLower) ||
            lesson.tags.any((tag) => tag.toLowerCase().contains(queryLower))
        ).toList();
      }

      return lessons;
    } catch (e, stack) {
      _logger.error('Failed to search lessons', error: e, stackTrace: stack);
      throw ServiceException('Failed to search lessons: $e');
    }
  }

  /// Get recommended lessons based on user progress and preferences
  Future<List<Lesson>> getRecommendedLessons({
    required String userId,
    List<String>? completedLessonIds,
    List<String>? preferredTags,
    DifficultyLevel? currentLevel,
    int limit = 10,
  }) async {
    try {
      // Start with user's preferred tags if available
      List<Lesson> candidates = [];

      if (preferredTags != null && preferredTags.isNotEmpty) {
        candidates.addAll(await getLessonsByTags(preferredTags));
      }

      // If no preferred tags or not enough candidates, get by difficulty
      if (candidates.length < limit && currentLevel != null) {
        final difficultyLessons = await getLessonsByDifficulty(currentLevel);
        candidates.addAll(difficultyLessons);
      }

      // Remove already completed lessons
      if (completedLessonIds != null && completedLessonIds.isNotEmpty) {
        candidates = candidates.where((lesson) => 
            !completedLessonIds.contains(lesson.id)).toList();
      }

      // Remove duplicates
      final seenIds = <String>{};
      candidates = candidates.where((lesson) => seenIds.add(lesson.id)).toList();

      // Sort by relevance (difficulty match, tag overlap, creation date)
      candidates.sort((a, b) {
        int scoreA = _calculateRecommendationScore(a, preferredTags, currentLevel);
        int scoreB = _calculateRecommendationScore(b, preferredTags, currentLevel);
        
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        
        // Secondary sort by creation date (newer first)
        return b.createdAt.compareTo(a.createdAt);
      });

      return candidates.take(limit).toList();
    } catch (e, stack) {
      _logger.error('Failed to get recommended lessons', error: e, stackTrace: stack);
      throw ServiceException('Failed to get recommended lessons: $e');
    }
  }

  /// Get prerequisite lessons for a given lesson
  Future<List<Lesson>> getPrerequisites(String lessonId) async {
    try {
      final lesson = await getLesson(lessonId);
      if (lesson == null || lesson.prerequisites.isEmpty) {
        return [];
      }

      return await getLessons(lesson.prerequisites);
    } catch (e, stack) {
      _logger.error('Failed to get prerequisites', error: e, stackTrace: stack);
      throw ServiceException('Failed to get prerequisites: $e');
    }
  }

  /// Check if user meets prerequisites for a lesson
  Future<bool> meetsPrerequisites({
    required String lessonId,
    required List<String> completedLessonIds,
  }) async {
    try {
      final lesson = await getLesson(lessonId);
      if (lesson == null) return false;

      // Check if all prerequisite lessons are completed
      for (final prerequisiteId in lesson.prerequisites) {
        if (!completedLessonIds.contains(prerequisiteId)) {
          return false;
        }
      }

      return true;
    } catch (e, stack) {
      _logger.error('Failed to check prerequisites', error: e, stackTrace: stack);
      throw ServiceException('Failed to check prerequisites: $e');
    }
  }

  /// Get lesson statistics
  Future<LessonStatistics> getLessonStatistics(String lessonId) async {
    try {
      // This would typically come from analytics data
      // For now, return basic statistics
      final lesson = await getLesson(lessonId);
      if (lesson == null) {
        throw ServiceException('Lesson not found: $lessonId');
      }

      return LessonStatistics(
        lessonId: lessonId,
        totalViews: 0, // Would come from analytics
        averageRating: 0.0, // Would come from user ratings
        completionRate: 0.0, // Would come from progress data
        averageTimeSpent: lesson.estimatedDuration,
        difficultyLevel: lesson.difficulty,
        totalObjectives: lesson.objectives.length,
      );
    } catch (e, stack) {
      _logger.error('Failed to get lesson statistics', error: e, stackTrace: stack);
      throw ServiceException('Failed to get lesson statistics: $e');
    }
  }

  /// Calculate recommendation score for a lesson
  int _calculateRecommendationScore(
    Lesson lesson,
    List<String>? preferredTags,
    DifficultyLevel? currentLevel,
  ) {
    int score = 0;

    // Tag overlap score (most important)
    if (preferredTags != null) {
      final tagOverlap = lesson.tags.where((tag) => preferredTags.contains(tag)).length;
      score += tagOverlap * 10;
    }

    // Difficulty match score
    if (currentLevel != null) {
      if (lesson.difficulty == currentLevel) {
        score += 5;
      } else {
        // Slight penalty for difficulty mismatch
        final difficultyDiff = (lesson.difficulty.index - currentLevel.index).abs();
        score -= difficultyDiff * 2;
      }
    }

    // Recency bonus (newer content gets slight boost)
    final daysSinceCreation = DateTime.now().difference(lesson.createdAt).inDays;
    if (daysSinceCreation < 30) {
      score += 2;
    }

    return score;
  }
}

/// Lesson statistics model
class LessonStatistics {
  final String lessonId;
  final int totalViews;
  final double averageRating;
  final double completionRate;
  final Duration averageTimeSpent;
  final DifficultyLevel difficultyLevel;
  final int totalObjectives;

  const LessonStatistics({
    required this.lessonId,
    required this.totalViews,
    required this.averageRating,
    required this.completionRate,
    required this.averageTimeSpent,
    required this.difficultyLevel,
    required this.totalObjectives,
  });

  Map<String, dynamic> toJson() => {
    'lessonId': lessonId,
    'totalViews': totalViews,
    'averageRating': averageRating,
    'completionRate': completionRate,
    'averageTimeSpent': averageTimeSpent.inMinutes,
    'difficultyLevel': difficultyLevel.name,
    'totalObjectives': totalObjectives,
  };
}
