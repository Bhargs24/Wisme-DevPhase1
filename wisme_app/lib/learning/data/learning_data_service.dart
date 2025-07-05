import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';
import '../models/learning_session.dart';
import '../models/learning_path.dart';
import '../models/learning_progress.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';

/// Data service for learning-related operations with Firestore
class LearningDataService {
  static const String _lessonsCollection = 'lessons';
  static const String _pathsCollection = 'learning_paths';
  static const String _progressCollection = 'learning_progress';
  static const String _sessionsCollection = 'learning_sessions';

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  LearningDataService({
    FirebaseFirestore? firestore,
    AppLogger? logger,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _logger = logger ?? AppLogger();

  // === LESSON OPERATIONS ===

  /// Get lesson by ID
  Future<Lesson?> getLesson(String lessonId) async {
    try {
      final doc = await _firestore
          .collection(_lessonsCollection)
          .doc(lessonId)
          .get();

      if (!doc.exists) return null;

      return Lesson.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e, stack) {
      _logger.error('Failed to get lesson: $lessonId', error: e, stackTrace: stack);
      throw DataException('Failed to fetch lesson: $e');
    }
  }

  /// Get lessons by IDs
  Future<List<Lesson>> getLessons(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return [];

    try {
      final lessons = <Lesson>[];
      
      // Firestore 'in' queries are limited to 10 items
      final chunks = _chunkList(lessonIds, 10);
      
      for (final chunk in chunks) {
        final query = await _firestore
            .collection(_lessonsCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        lessons.addAll(
          query.docs.map((doc) => Lesson.fromJson({
            'id': doc.id,
            ...doc.data(),
          }))
        );
      }

      return lessons;
    } catch (e, stack) {
      _logger.error('Failed to get lessons', error: e, stackTrace: stack);
      throw DataException('Failed to fetch lessons: $e');
    }
  }

  /// Get lessons by tags
  Future<List<Lesson>> getLessonsByTags(List<String> tags) async {
    try {
      final query = await _firestore
          .collection(_lessonsCollection)
          .where('tags', arrayContainsAny: tags)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      return query.docs.map((doc) => Lesson.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get lessons by tags', error: e, stackTrace: stack);
      throw DataException('Failed to fetch lessons by tags: $e');
    }
  }

  /// Get lessons by difficulty
  Future<List<Lesson>> getLessonsByDifficulty(DifficultyLevel difficulty) async {
    try {
      final query = await _firestore
          .collection(_lessonsCollection)
          .where('difficulty', isEqualTo: difficulty.name)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      return query.docs.map((doc) => Lesson.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get lessons by difficulty', error: e, stackTrace: stack);
      throw DataException('Failed to fetch lessons by difficulty: $e');
    }
  }

  // === LEARNING PATH OPERATIONS ===

  /// Get learning path by ID
  Future<LearningPath?> getLearningPath(String pathId) async {
    try {
      final doc = await _firestore
          .collection(_pathsCollection)
          .doc(pathId)
          .get();

      if (!doc.exists) return null;

      return LearningPath.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e, stack) {
      _logger.error('Failed to get learning path: $pathId', error: e, stackTrace: stack);
      throw DataException('Failed to fetch learning path: $e');
    }
  }

  /// Get all published learning paths
  Future<List<LearningPath>> getPublishedPaths() async {
    try {
      final query = await _firestore
          .collection(_pathsCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => LearningPath.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get published paths', error: e, stackTrace: stack);
      throw DataException('Failed to fetch published paths: $e');
    }
  }

  /// Get learning paths by difficulty
  Future<List<LearningPath>> getPathsByDifficulty(DifficultyLevel difficulty) async {
    try {
      final query = await _firestore
          .collection(_pathsCollection)
          .where('difficulty', isEqualTo: difficulty.name)
          .where('isPublished', isEqualTo: true)
          .get();

      return query.docs.map((doc) => LearningPath.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get paths by difficulty', error: e, stackTrace: stack);
      throw DataException('Failed to fetch paths by difficulty: $e');
    }
  }

  // === PROGRESS OPERATIONS ===

  /// Get user's progress for a lesson
  Future<LearningProgress?> getUserProgress(String userId, String lessonId) async {
    try {
      final query = await _firestore
          .collection(_progressCollection)
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return LearningProgress.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    } catch (e, stack) {
      _logger.error('Failed to get user progress', error: e, stackTrace: stack);
      throw DataException('Failed to fetch user progress: $e');
    }
  }

  /// Get all user progress
  Future<List<LearningProgress>> getAllUserProgress(String userId) async {
    try {
      final query = await _firestore
          .collection(_progressCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return query.docs.map((doc) => LearningProgress.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get all user progress', error: e, stackTrace: stack);
      throw DataException('Failed to fetch all user progress: $e');
    }
  }

  /// Save or update user progress
  Future<void> saveUserProgress(LearningProgress progress) async {
    try {
      final data = progress.toJson();
      data.remove('id'); // Remove ID from data

      await _firestore
          .collection(_progressCollection)
          .doc(progress.id)
          .set(data, SetOptions(merge: true));

      _logger.info('User progress saved: ${progress.id}');
    } catch (e, stack) {
      _logger.error('Failed to save user progress', error: e, stackTrace: stack);
      throw DataException('Failed to save user progress: $e');
    }
  }

  // === SESSION OPERATIONS ===

  /// Save learning session
  Future<void> saveLearningSession(LearningSession session) async {
    try {
      final data = session.toJson();
      data.remove('id'); // Remove ID from data

      await _firestore
          .collection(_sessionsCollection)
          .doc(session.id)
          .set(data, SetOptions(merge: true));

      _logger.info('Learning session saved: ${session.id}');
    } catch (e, stack) {
      _logger.error('Failed to save learning session', error: e, stackTrace: stack);
      throw DataException('Failed to save learning session: $e');
    }
  }

  /// Get user's learning sessions for a lesson
  Future<List<LearningSession>> getUserSessions(String userId, String lessonId) async {
    try {
      final query = await _firestore
          .collection(_sessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .orderBy('startTime', descending: true)
          .get();

      return query.docs.map((doc) => LearningSession.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get user sessions', error: e, stackTrace: stack);
      throw DataException('Failed to fetch user sessions: $e');
    }
  }

  /// Get user's recent learning sessions
  Future<List<LearningSession>> getRecentSessions(String userId, {int limit = 20}) async {
    try {
      final query = await _firestore
          .collection(_sessionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => LearningSession.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get recent sessions', error: e, stackTrace: stack);
      throw DataException('Failed to fetch recent sessions: $e');
    }
  }

  // === UTILITY METHODS ===

  /// Helper method to chunk lists for Firestore 'in' queries
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, 
          i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
