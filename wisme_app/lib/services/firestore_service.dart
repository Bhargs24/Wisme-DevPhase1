import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _lessonsCollection = 'lessons';
  static const String _topicsCollection = 'topics';
  static const String _userProgressCollection = 'user_progress';

  // User methods
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
    return null;
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Lesson methods
  Future<List<LessonModel>> getLessonsByTopic(String topic) async {
    try {
      final query = await _firestore
          .collection(_lessonsCollection)
          .where('topic', isEqualTo: topic)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => LessonModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  Future<List<LessonModel>> searchLessons(String searchQuery) async {
    try {
      final keywords = searchQuery.toLowerCase().split(' ');
      final query = await _firestore
          .collection(_lessonsCollection)
          .where('tags', arrayContainsAny: keywords)
          .limit(20)
          .get();

      return query.docs
          .map((doc) => LessonModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search lessons: $e');
    }
  }

  Future<LessonModel?> getLesson(String lessonId, String coachVoice) async {
    try {
      final docId = '${coachVoice}_${lessonId}';
      final doc = await _firestore.collection(_lessonsCollection).doc(docId).get();
      
      if (doc.exists && doc.data() != null) {
        return LessonModel.fromJson(doc.data()!);
      }
    } catch (e) {
      throw Exception('Failed to get lesson: $e');
    }
    return null;
  }

  // User progress tracking
  Future<void> recordLessonCompletion(String userId, String lessonId, String coachVoice) async {
    try {
      final progressData = {
        'user_id': userId,
        'lesson_id': lessonId,
        'coach_voice': coachVoice,
        'completed_at': FieldValue.serverTimestamp(),
        'progress': 100,
      };

      await _firestore
          .collection(_userProgressCollection)
          .doc('${userId}_${lessonId}_${coachVoice}')
          .set(progressData);

      // Update user stats
      await _firestore.collection(_usersCollection).doc(userId).update({
        'total_lessons_completed': FieldValue.increment(1),
        'last_active_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to record lesson completion: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    try {
      final query = await _firestore
          .collection(_userProgressCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('completed_at', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

  Future<List<String>> getCompletedLessonIds(String userId) async {
    try {
      final query = await _firestore
          .collection(_userProgressCollection)
          .where('user_id', isEqualTo: userId)
          .where('progress', isEqualTo: 100)
          .get();

      return query.docs
          .map((doc) => doc.data()['lesson_id'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to get completed lessons: $e');
    }
  }

  // Topic methods
  Future<List<Map<String, dynamic>>> getAllTopics() async {
    try {
      final query = await _firestore
          .collection(_topicsCollection)
          .orderBy('lesson_count', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get topics: $e');
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final progressQuery = await _firestore
          .collection(_userProgressCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final completedLessons = progressQuery.docs.length;
      final thisWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      
      final thisWeekProgress = progressQuery.docs.where((doc) {
        final completedAt = (doc.data()['completed_at'] as Timestamp).toDate();
        return completedAt.isAfter(thisWeekStart);
      }).length;

      return {
        'total_lessons_completed': completedLessons,
        'lessons_this_week': thisWeekProgress,
        'streak_days': await _calculateStreak(userId),
        'favorite_topics': await _getFavoriteTopics(userId),
      };
    } catch (e) {
      throw Exception('Failed to get user analytics: $e');
    }
  }

  Future<int> _calculateStreak(String userId) async {
    // Implementation for calculating learning streak
    // This is a simplified version
    try {
      final query = await _firestore
          .collection(_userProgressCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('completed_at', descending: true)
          .limit(30)
          .get();

      if (query.docs.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (final doc in query.docs) {
        final completedAt = (doc.data()['completed_at'] as Timestamp).toDate();
        final dateOnly = DateTime(completedAt.year, completedAt.month, completedAt.day);

        if (lastDate == null) {
          lastDate = dateOnly;
          streak = 1;
        } else {
          final daysDifference = lastDate.difference(dateOnly).inDays;
          if (daysDifference == 1) {
            streak++;
            lastDate = dateOnly;
          } else {
            break;
          }
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  Future<List<String>> _getFavoriteTopics(String userId) async {
    try {
      final query = await _firestore
          .collection(_userProgressCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final topicCounts = <String, int>{};
      
      for (final doc in query.docs) {
        final lessonId = doc.data()['lesson_id'] as String;
        // Get the lesson to find its topic
        final lessonDoc = await _firestore
            .collection(_lessonsCollection)
            .where('lesson_id', isEqualTo: lessonId)
            .limit(1)
            .get();
        
        if (lessonDoc.docs.isNotEmpty) {
          final topic = lessonDoc.docs.first.data()['topic'] as String;
          topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
        }
      }

      final sortedTopics = topicCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTopics.take(5).map((e) => e.key).toList();
    } catch (e) {
      return [];
    }
  }
}
