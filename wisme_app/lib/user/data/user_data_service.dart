import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/user_progress.dart';
import '../models/user_auth_state.dart';

/// Production-grade user data service
/// Manages all user data operations with Firestore integration
class UserDataService {
  final FirebaseFirestore _firestore;
  
  // Collection references
  late final CollectionReference _usersCollection;
  late final CollectionReference _progressCollection;
  late final CollectionReference _sessionsCollection;
  late final CollectionReference _achievementsCollection;

  // Stream controllers for real-time updates
  final StreamController<UserProfile?> _userProfileController = StreamController.broadcast();
  final StreamController<UserProgress?> _userProgressController = StreamController.broadcast();
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  UserDataService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _initializeCollections();
  }

  void _initializeCollections() {
    _usersCollection = _firestore.collection('users');
    _progressCollection = _firestore.collection('user_progress');
    _sessionsCollection = _firestore.collection('learning_sessions');
    _achievementsCollection = _firestore.collection('achievements');
  }

  // Streams for real-time updates
  Stream<UserProfile?> get userProfileStream => _userProfileController.stream;
  Stream<UserProgress?> get userProgressStream => _userProgressController.stream;

  // === USER PROFILE OPERATIONS ===

  /// Create a new user profile
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.id).set(profile.toJson());
    } catch (e) {
      throw UserDataException('Failed to create user profile: $e');
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) return null;
      
      return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw UserDataException('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      
      await _usersCollection.doc(userId).update(updatedProfile.toJson());
    } catch (e) {
      throw UserDataException('Failed to update user profile: $e');
    }
  }

  /// Update specific user fields
  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      final updateData = {
        ...fields,
        'updatedAt': DateTime.now().toIso8601String(),
        'lastActiveAt': DateTime.now().toIso8601String(),
      };
      
      await _usersCollection.doc(userId).update(updateData);
    } catch (e) {
      throw UserDataException('Failed to update user fields: $e');
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Delete main profile
      batch.delete(_usersCollection.doc(userId));
      
      // Delete related data
      batch.delete(_progressCollection.doc(userId));
      
      // Delete user sessions
      final sessionsQuery = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in sessionsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw UserDataException('Failed to delete user profile: $e');
    }
  }

  /// Subscribe to user profile real-time updates
  void subscribeToUserProfile(String userId) {
    _activeSubscriptions['profile'] = _usersCollection
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              final profile = UserProfile.fromJson(
                snapshot.data() as Map<String, dynamic>
              );
              _userProfileController.add(profile);
            } else {
              _userProfileController.add(null);
            }
          },
          onError: (error) {
            print('Error in user profile subscription: $error');
            _userProfileController.addError(error);
          },
        );
  }

  // === USER PROGRESS OPERATIONS ===

  /// Create user progress record
  Future<void> createUserProgress(UserProgress progress) async {
    try {
      await _progressCollection.doc(progress.userId).set(progress.toJson());
    } catch (e) {
      throw UserDataException('Failed to create user progress: $e');
    }
  }

  /// Get user progress by user ID
  Future<UserProgress?> getUserProgress(String userId) async {
    try {
      final doc = await _progressCollection.doc(userId).get();
      if (!doc.exists) return null;
      
      return UserProgress.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw UserDataException('Failed to get user progress: $e');
    }
  }

  /// Update user progress
  Future<void> updateUserProgress(UserProgress progress) async {
    try {
      final updatedProgress = progress.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      await _progressCollection.doc(progress.userId).update(updatedProgress.toJson());
    } catch (e) {
      throw UserDataException('Failed to update user progress: $e');
    }
  }

  /// Add learning session to user progress
  Future<void> addLearningSession(String userId, LearningSession session) async {
    try {
      // Store the session in sessions collection
      await _sessionsCollection.doc(session.sessionId).set(session.toJson());
      
      // Update user progress with session data
      final progress = await getUserProgress(userId);
      if (progress != null) {
        final updatedSessions = [session, ...progress.recentSessions]
            .take(20) // Keep only last 20 sessions
            .toList();
        
        final updatedProgress = progress.copyWith(
          recentSessions: updatedSessions,
          lastUpdated: DateTime.now(),
        );
        
        await updateUserProgress(updatedProgress);
      }
    } catch (e) {
      throw UserDataException('Failed to add learning session: $e');
    }
  }

  /// Update topic progress
  Future<void> updateTopicProgress(String userId, String topicId, TopicProgress topicProgress) async {
    try {
      final progress = await getUserProgress(userId);
      if (progress == null) {
        throw UserDataException('User progress not found');
      }
      
      final updatedTopicProgress = Map<String, TopicProgress>.from(progress.topicProgress);
      updatedTopicProgress[topicId] = topicProgress;
      
      final updatedProgress = progress.copyWith(
        topicProgress: updatedTopicProgress,
        lastUpdated: DateTime.now(),
      );
      
      await updateUserProgress(updatedProgress);
    } catch (e) {
      throw UserDataException('Failed to update topic progress: $e');
    }
  }

  /// Update skill progress
  Future<void> updateSkillProgress(String userId, String skillId, SkillProgress skillProgress) async {
    try {
      final progress = await getUserProgress(userId);
      if (progress == null) {
        throw UserDataException('User progress not found');
      }
      
      final updatedSkillProgress = Map<String, SkillProgress>.from(progress.skillProgress);
      updatedSkillProgress[skillId] = skillProgress;
      
      final updatedProgress = progress.copyWith(
        skillProgress: updatedSkillProgress,
        lastUpdated: DateTime.now(),
      );
      
      await updateUserProgress(updatedProgress);
    } catch (e) {
      throw UserDataException('Failed to update skill progress: $e');
    }
  }

  /// Add achievement to user
  Future<void> addAchievement(String userId, Achievement achievement) async {
    try {
      // Store achievement
      await _achievementsCollection
          .doc('${userId}_${achievement.id}')
          .set({
            'userId': userId,
            'achievement': achievement.toJson(),
          });
      
      // Update user progress
      final progress = await getUserProgress(userId);
      if (progress != null) {
        final updatedAchievements = [...progress.achievements, achievement];
        
        final updatedProgress = progress.copyWith(
          achievements: updatedAchievements,
          lastUpdated: DateTime.now(),
        );
        
        await updateUserProgress(updatedProgress);
      }
    } catch (e) {
      throw UserDataException('Failed to add achievement: $e');
    }
  }

  /// Subscribe to user progress real-time updates
  void subscribeToUserProgress(String userId) {
    _activeSubscriptions['progress'] = _progressCollection
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              final progress = UserProgress.fromJson(
                snapshot.data() as Map<String, dynamic>
              );
              _userProgressController.add(progress);
            } else {
              _userProgressController.add(null);
            }
          },
          onError: (error) {
            print('Error in user progress subscription: $error');
            _userProgressController.addError(error);
          },
        );
  }

  // === USER SETTINGS OPERATIONS ===

  /// Update user settings
  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    try {
      await updateUserFields(userId, {
        'settings': settings.toJson(),
      });
    } catch (e) {
      throw UserDataException('Failed to update user settings: $e');
    }
  }

  /// Update learning preferences
  Future<void> updateLearningPreferences(String userId, LearningPreferences preferences) async {
    try {
      await updateUserFields(userId, {
        'learningPreferences': preferences.toJson(),
      });
    } catch (e) {
      throw UserDataException('Failed to update learning preferences: $e');
    }
  }

  /// Update user subscription
  Future<void> updateUserSubscription(String userId, UserSubscription subscription) async {
    try {
      await updateUserFields(userId, {
        'subscription': subscription.toJson(),
      });
    } catch (e) {
      throw UserDataException('Failed to update user subscription: $e');
    }
  }

  // === QUERY OPERATIONS ===

  /// Get users by email
  Future<List<UserProfile>> getUsersByEmail(String email) async {
    try {
      final query = await _usersCollection
          .where('email', isEqualTo: email)
          .get();
      
      return query.docs
          .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UserDataException('Failed to get users by email: $e');
    }
  }

  /// Get users with premium subscription
  Future<List<UserProfile>> getPremiumUsers() async {
    try {
      final query = await _usersCollection
          .where('subscription.type', isEqualTo: 'SubscriptionType.premium')
          .where('subscription.status', isEqualTo: 'SubscriptionStatus.active')
          .get();
      
      return query.docs
          .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UserDataException('Failed to get premium users: $e');
    }
  }

  /// Get learning sessions for user
  Future<List<LearningSession>> getUserSessions(String userId, {
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _sessionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .limit(limit);
      
      if (startDate != null) {
        query = query.where('startTime', isGreaterThanOrEqualTo: startDate);
      }
      
      if (endDate != null) {
        query = query.where('startTime', isLessThanOrEqualTo: endDate);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => LearningSession.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UserDataException('Failed to get user sessions: $e');
    }
  }

  /// Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final query = await _achievementsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('achievement.unlockedAt', descending: true)
          .get();
      
      return query.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Achievement.fromJson(data['achievement']);
          })
          .toList();
    } catch (e) {
      throw UserDataException('Failed to get user achievements: $e');
    }
  }

  /// Search users by display name
  Future<List<UserProfile>> searchUsersByName(String searchTerm) async {
    try {
      // Firestore doesn't support case-insensitive search, so this is a basic implementation
      final query = await _usersCollection
          .where('displayName', isGreaterThanOrEqualTo: searchTerm)
          .where('displayName', isLessThan: searchTerm + '\uf8ff')
          .limit(20)
          .get();
      
      return query.docs
          .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UserDataException('Failed to search users: $e');
    }
  }

  // === ANALYTICS OPERATIONS ===

  /// Get user activity analytics
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final sessions = await getUserSessions(userId, limit: 100);
      final progress = await getUserProgress(userId);
      
      if (sessions.isEmpty || progress == null) {
        return {};
      }
      
      // Calculate analytics
      final totalSessions = sessions.length;
      final totalTime = sessions.fold<Duration>(
        Duration.zero,
        (sum, session) => sum + session.duration,
      );
      
      final averageScore = sessions.isNotEmpty
          ? sessions.map((s) => s.scorePercentage).reduce((a, b) => a + b) / sessions.length
          : 0.0;
      
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final recentSessions = sessions
          .where((s) => s.startTime.isAfter(lastWeek))
          .length;
      
      return {
        'totalSessions': totalSessions,
        'totalTimeMinutes': totalTime.inMinutes,
        'averageScore': averageScore,
        'recentSessions': recentSessions,
        'currentStreak': progress.overall.currentStreak,
        'totalAchievements': progress.achievements.length,
        'completedTopics': progress.topicProgress.values
            .where((tp) => tp.isCompleted)
            .length,
      };
    } catch (e) {
      throw UserDataException('Failed to get user analytics: $e');
    }
  }

  // === BATCH OPERATIONS ===

  /// Batch update multiple users
  Future<void> batchUpdateUsers(Map<String, Map<String, dynamic>> userUpdates) async {
    try {
      final batch = _firestore.batch();
      
      for (final entry in userUpdates.entries) {
        final userId = entry.key;
        final updates = entry.value;
        batch.update(_usersCollection.doc(userId), updates);
      }
      
      await batch.commit();
    } catch (e) {
      throw UserDataException('Failed to batch update users: $e');
    }
  }

  // === UTILITY METHODS ===

  /// Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw UserDataException('Failed to check user existence: $e');
    }
  }

  /// Get user count
  Future<int> getUserCount() async {
    try {
      final query = await _usersCollection.count().get();
      return query.count;
    } catch (e) {
      throw UserDataException('Failed to get user count: $e');
    }
  }

  /// Cleanup old sessions
  Future<void> cleanupOldSessions({Duration maxAge = const Duration(days: 90)}) async {
    try {
      final cutoffDate = DateTime.now().subtract(maxAge);
      final query = await _sessionsCollection
          .where('startTime', isLessThan: cutoffDate)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw UserDataException('Failed to cleanup old sessions: $e');
    }
  }

  /// Unsubscribe from all real-time updates
  void unsubscribeAll() {
    for (final subscription in _activeSubscriptions.values) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
  }

  /// Dispose resources
  void dispose() {
    unsubscribeAll();
    _userProfileController.close();
    _userProgressController.close();
  }
}

/// User data service exception
class UserDataException implements Exception {
  final String message;
  
  const UserDataException(this.message);
  
  @override
  String toString() => 'UserDataException: $message';
}
