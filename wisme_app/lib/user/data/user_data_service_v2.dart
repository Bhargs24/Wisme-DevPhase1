import 'dart:async';
import '../../core/data/firestore_data_service.dart';
import '../../shared/models/shared_models.dart';
import '../../utils/logger.dart';
import '../models/user_profile.dart';
import '../models/user_progress.dart';

/// Production-grade user data service for the new architecture
/// Manages all user-specific data operations using the new FirestoreDataService
class UserDataServiceV2 {
  final FirestoreDataService _firestoreService;

  // Stream controllers for real-time updates
  final StreamController<UserProfile?> _userProfileController = StreamController.broadcast();
  final StreamController<UserProgress?> _userProgressController = StreamController.broadcast();
  
  // Active subscriptions
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  UserDataServiceV2({
    required FirestoreDataService firestoreService,
  }) : _firestoreService = firestoreService;

  // Streams for real-time updates
  Stream<UserProfile?> get userProfileStream => _userProfileController.stream;
  Stream<UserProgress?> get userProgressStream => _userProgressController.stream;

  // === USER PROFILE OPERATIONS ===

  /// Create a new user profile
  Future<Result<void>> createUserProfile(UserProfile profile) async {
    try {
      final result = await _firestoreService.create(
        collection: 'users',
        documentId: profile.id,
        data: profile.toJson(),
      );

      if (result.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Created user profile for ${profile.id}');
        return Result.success(null);
      } else {
        return Result.failure('Failed to create user profile: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to create user profile: $e');
      return Result.failure('Failed to create user profile: $e');
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final result = await _firestoreService.read(
        collection: 'users',
        documentId: userId,
      );

      if (result.isSuccess && result.data != null) {
        final profile = UserProfile.fromJson(result.data!);
        AppLogger.info('✅ UserDataServiceV2: Retrieved user profile for $userId');
        return profile;
      } else {
        AppLogger.warning('⚠️ UserDataServiceV2: User profile not found for $userId');
        return null;
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to get user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<Result<void>> updateUserProfile(String userId, UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      
      final result = await _firestoreService.update(
        collection: 'users',
        documentId: userId,
        data: updatedProfile.toJson(),
      );

      if (result.isSuccess) {
        _userProfileController.add(updatedProfile);
        AppLogger.info('✅ UserDataServiceV2: Updated user profile for $userId');
        return Result.success(null);
      } else {
        return Result.failure('Failed to update user profile: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to update user profile: $e');
      return Result.failure('Failed to update user profile: $e');
    }
  }

  /// Update specific user fields
  Future<Result<void>> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      final updateData = {
        ...fields,
        'updatedAt': DateTime.now().toIso8601String(),
        'lastActiveAt': DateTime.now().toIso8601String(),
      };
      
      final result = await _firestoreService.update(
        collection: 'users',
        documentId: userId,
        data: updateData,
      );

      if (result.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Updated user fields for $userId');
        return Result.success(null);
      } else {
        return Result.failure('Failed to update user fields: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to update user fields: $e');
      return Result.failure('Failed to update user fields: $e');
    }
  }

  /// Delete user profile
  Future<Result<void>> deleteUserProfile(String userId) async {
    try {
      // Delete main profile
      final profileResult = await _firestoreService.delete(
        collection: 'users',
        documentId: userId,
      );

      // Delete related data
      final progressResult = await _firestoreService.delete(
        collection: 'user_progress',
        documentId: userId,
      );

      if (profileResult.isSuccess && progressResult.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Deleted user profile and data for $userId');
        return Result.success(null);
      } else {
        return Result.failure('Failed to completely delete user data');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to delete user profile: $e');
      return Result.failure('Failed to delete user profile: $e');
    }
  }

  // === USER PROGRESS OPERATIONS ===

  /// Create user progress
  Future<Result<void>> createUserProgress(UserProgress progress) async {
    try {
      final result = await _firestoreService.create(
        collection: 'user_progress',
        documentId: progress.userId,
        data: progress.toJson(),
      );

      if (result.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Created user progress for ${progress.userId}');
        return Result.success(null);
      } else {
        return Result.failure('Failed to create user progress: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to create user progress: $e');
      return Result.failure('Failed to create user progress: $e');
    }
  }

  /// Get user progress by ID
  Future<UserProgress?> getUserProgress(String userId) async {
    try {
      final result = await _firestoreService.read(
        collection: 'user_progress',
        documentId: userId,
      );

      if (result.isSuccess && result.data != null) {
        final progress = UserProgress.fromJson(result.data!);
        AppLogger.info('✅ UserDataServiceV2: Retrieved user progress for $userId');
        return progress;
      } else {
        AppLogger.warning('⚠️ UserDataServiceV2: User progress not found for $userId');
        return null;
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to get user progress: $e');
      return null;
    }
  }

  /// Update user progress
  Future<Result<void>> updateUserProgress(String userId, UserProgress progress) async {
    try {
      final updatedProgress = progress.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      final result = await _firestoreService.update(
        collection: 'user_progress',
        documentId: userId,
        data: updatedProgress.toJson(),
      );

      if (result.isSuccess) {
        _userProgressController.add(updatedProgress);
        AppLogger.info('✅ UserDataServiceV2: Updated user progress for $userId');
        return Result.success(null);
      } else {
        return Result.failure('Failed to update user progress: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to update user progress: $e');
      return Result.failure('Failed to update user progress: $e');
    }
  }

  // === LEARNING SESSIONS ===

  /// Add learning session
  Future<Result<void>> addLearningSession(String userId, Map<String, dynamic> session) async {
    try {
      final sessionData = {
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        ...session,
      };

      final result = await _firestoreService.create(
        collection: 'learning_sessions',
        data: sessionData,
      );

      if (result.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Added learning session for $userId');
        return Result.success(null);
      } else {
        return Result.failure('Failed to add learning session: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to add learning session: $e');
      return Result.failure('Failed to add learning session: $e');
    }
  }

  /// Get user learning sessions
  Future<Result<List<Map<String, dynamic>>>> getUserSessions({
    required String userId,
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = FirestoreQuery(
        where: [
          QueryCondition(field: 'userId', isEqualTo: userId),
          if (startDate != null)
            QueryCondition(field: 'timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String()),
          if (endDate != null)
            QueryCondition(field: 'timestamp', isLessThanOrEqualTo: endDate.toIso8601String()),
        ],
        orderBy: [
          OrderByCondition(field: 'timestamp', descending: true),
        ],
        limit: limit,
      );

      final result = await _firestoreService.query(
        collection: 'learning_sessions',
        query: query,
      );

      if (result.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Retrieved ${result.data?.length ?? 0} sessions for $userId');
        return Result.success(result.data ?? []);
      } else {
        return Result.failure('Failed to get user sessions: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to get user sessions: $e');
      return Result.failure('Failed to get user sessions: $e');
    }
  }

  // === ACHIEVEMENTS ===

  /// Add achievement
  Future<Result<void>> addAchievement(String userId, Map<String, dynamic> achievement) async {
    try {
      final achievementData = {
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        ...achievement,
      };

      final result = await _firestoreService.create(
        collection: 'achievements',
        data: achievementData,
      );

      if (result.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Added achievement for $userId');
        return Result.success(null);
      } else {
        return Result.failure('Failed to add achievement: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to add achievement: $e');
      return Result.failure('Failed to add achievement: $e');
    }
  }

  /// Get user achievements
  Future<Result<List<Map<String, dynamic>>>> getUserAchievements(String userId) async {
    try {
      final query = FirestoreQuery(
        where: [
          QueryCondition(field: 'userId', isEqualTo: userId),
        ],
        orderBy: [
          OrderByCondition(field: 'timestamp', descending: true),
        ],
      );

      final result = await _firestoreService.query(
        collection: 'achievements',
        query: query,
      );

      if (result.isSuccess) {
        AppLogger.info('✅ UserDataServiceV2: Retrieved ${result.data?.length ?? 0} achievements for $userId');
        return Result.success(result.data ?? []);
      } else {
        return Result.failure('Failed to get user achievements: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to get user achievements: $e');
      return Result.failure('Failed to get user achievements: $e');
    }
  }

  // === REAL-TIME SUBSCRIPTIONS ===

  /// Subscribe to real-time user profile updates
  void subscribeToUserProfile(String userId) {
    final subscriptionKey = 'profile_$userId';
    
    // Cancel existing subscription if any
    _activeSubscriptions[subscriptionKey]?.cancel();
    
    try {
      final subscription = _firestoreService.streamDocument(
        collection: 'users',
        documentId: userId,
      ).listen(
        (result) {
          if (result.isSuccess && result.data != null) {
            final profile = UserProfile.fromJson(result.data!);
            _userProfileController.add(profile);
          } else {
            _userProfileController.add(null);
          }
        },
        onError: (error) {
          AppLogger.error('❌ UserDataServiceV2: Profile stream error: $error');
          _userProfileController.add(null);
        },
      );
      
      _activeSubscriptions[subscriptionKey] = subscription;
      AppLogger.info('✅ UserDataServiceV2: Subscribed to profile updates for $userId');
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to subscribe to profile: $e');
    }
  }

  /// Subscribe to real-time user progress updates
  void subscribeToUserProgress(String userId) {
    final subscriptionKey = 'progress_$userId';
    
    // Cancel existing subscription if any
    _activeSubscriptions[subscriptionKey]?.cancel();
    
    try {
      final subscription = _firestoreService.streamDocument(
        collection: 'user_progress',
        documentId: userId,
      ).listen(
        (result) {
          if (result.isSuccess && result.data != null) {
            final progress = UserProgress.fromJson(result.data!);
            _userProgressController.add(progress);
          } else {
            _userProgressController.add(null);
          }
        },
        onError: (error) {
          AppLogger.error('❌ UserDataServiceV2: Progress stream error: $error');
          _userProgressController.add(null);
        },
      );
      
      _activeSubscriptions[subscriptionKey] = subscription;
      AppLogger.info('✅ UserDataServiceV2: Subscribed to progress updates for $userId');
    } catch (e) {
      AppLogger.error('❌ UserDataServiceV2: Failed to subscribe to progress: $e');
    }
  }

  /// Unsubscribe from all real-time updates
  void unsubscribeAll() {
    for (final subscription in _activeSubscriptions.values) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
    AppLogger.info('✅ UserDataServiceV2: Unsubscribed from all updates');
  }

  /// Dispose resources
  void dispose() {
    unsubscribeAll();
    _userProfileController.close();
    _userProgressController.close();
    AppLogger.info('✅ UserDataServiceV2: Disposed successfully');
  }
}

/// Exception for user data operations
class UserDataException implements Exception {
  final String message;
  
  const UserDataException(this.message);
  
  @override
  String toString() => 'UserDataException: $message';
}
