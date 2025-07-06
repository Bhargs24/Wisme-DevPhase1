import '../../shared/models/shared_models.dart';
import '../../core/data/firestore_data_service.dart';
import '../../utils/logger.dart';

/// Production-grade gamification service for the new architecture
/// Manages achievements, rewards, and user engagement features
class GamificationServiceV2 {
  final FirestoreDataService _firestoreService;

  // Achievement definitions and user achievements cache
  static final Map<String, Achievement> _achievementDefinitions = {};
  final Map<String, UserAchievements> _userAchievements = {};

  GamificationServiceV2({
    required FirestoreDataService firestoreService,
  }) : _firestoreService = firestoreService {
    _initializeAchievements();
  }

  /// Initialize achievement definitions
  void _initializeAchievements() {
    _achievementDefinitions.addAll({
      'first_lesson': Achievement(
        id: 'first_lesson',
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: '🎯',
        category: AchievementCategory.learning,
        difficulty: AchievementDifficulty.easy,
        points: 10,
        requirements: {'lessons_completed': 1},
      ),
      'streak_3': Achievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Maintain a 3-day learning streak',
        icon: '🔥',
        category: AchievementCategory.consistency,
        difficulty: AchievementDifficulty.easy,
        points: 25,
        requirements: {'streak_days': 3},
      ),
      'streak_7': Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day learning streak',
        icon: '⚡',
        category: AchievementCategory.consistency,
        difficulty: AchievementDifficulty.medium,
        points: 50,
        requirements: {'streak_days': 7},
      ),
      'streak_30': Achievement(
        id: 'streak_30',
        title: 'Dedication Master',
        description: 'Maintain a 30-day learning streak',
        icon: '🏆',
        category: AchievementCategory.consistency,
        difficulty: AchievementDifficulty.hard,
        points: 200,
        requirements: {'streak_days': 30},
      ),
      'content_explorer': Achievement(
        id: 'content_explorer',
        title: 'Content Explorer',
        description: 'Complete 10 different topics',
        icon: '🗺️',
        category: AchievementCategory.exploration,
        difficulty: AchievementDifficulty.medium,
        points: 75,
        requirements: {'unique_topics': 10},
      ),
      'time_master': Achievement(
        id: 'time_master',
        title: 'Time Master',
        description: 'Accumulate 10 hours of learning time',
        icon: '⏰',
        category: AchievementCategory.dedication,
        difficulty: AchievementDifficulty.medium,
        points: 100,
        requirements: {'total_learning_time': 600}, // 10 hours in minutes
      ),
    });

    AppLogger.info('✅ GamificationServiceV2: Initialized ${_achievementDefinitions.length} achievement definitions');
  }

  /// Check for new achievements based on user activity
  Future<List<AchievementResult>> checkForNewAchievements({
    required String userId,
    required Map<String, dynamic> userStats,
  }) async {
    final newAchievements = <AchievementResult>[];
    
    try {
      // Get current user achievements
      final userAchievements = await _getUserAchievements(userId);
      
      // Check each achievement definition
      for (final achievement in _achievementDefinitions.values) {
        // Skip if user already has this achievement
        if (userAchievements.hasAchievement(achievement.id)) {
          continue;
        }

        // Check if requirements are met
        if (_checkAchievementRequirements(achievement, userStats)) {
          final result = await _awardAchievement(
            userId: userId,
            achievement: achievement,
            reason: 'Requirements met: ${achievement.description}',
          );
          
          if (result.isSuccess) {
            newAchievements.add(result);
          }
        }
      }

      AppLogger.info('✅ GamificationServiceV2: Found ${newAchievements.length} new achievements for $userId');
      return newAchievements;
    } catch (e) {
      AppLogger.error('❌ GamificationServiceV2: Failed to check achievements: $e');
      return [];
    }
  }

  /// Award specific achievement to user
  Future<AchievementResult> awardAchievement({
    required String userId,
    required String achievementId,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final achievement = _achievementDefinitions[achievementId];
      if (achievement == null) {
        return AchievementResult.notFound(achievementId);
      }

      return await _awardAchievement(
        userId: userId,
        achievement: achievement,
        reason: reason,
        metadata: metadata,
      );
    } catch (e) {
      AppLogger.error('❌ GamificationServiceV2: Failed to award achievement: $e');
      return AchievementResult.error(e.toString());
    }
  }

  /// Internal method to award achievement
  Future<AchievementResult> _awardAchievement({
    required String userId,
    required Achievement achievement,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userAchievements = await _getUserAchievements(userId);
      
      if (userAchievements.hasAchievement(achievement.id)) {
        return AchievementResult.alreadyAwarded(achievement);
      }

      // Create awarded achievement
      final awardedAchievement = AwardedAchievement(
        achievementId: achievement.id,
        awardedAt: DateTime.now(),
        reason: reason,
        metadata: metadata ?? {},
      );

      // Add to user achievements
      userAchievements.addAchievement(awardedAchievement);
      
      // Save to Firestore
      final result = await _firestoreService.update(
        collection: 'user_achievements',
        documentId: userId,
        data: userAchievements.toJson(),
      );

      if (result.isSuccess) {
        // Update cache
        _userAchievements[userId] = userAchievements;

        // Calculate reward
        final reward = _calculateReward(achievement);

        AppLogger.info('✅ GamificationServiceV2: Awarded achievement ${achievement.id} to $userId');
        return AchievementResult.success(achievement, reward);
      } else {
        return AchievementResult.error('Failed to save achievement: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ GamificationServiceV2: Failed to award achievement: $e');
      return AchievementResult.error(e.toString());
    }
  }

  /// Get user's current achievements
  Future<UserAchievements> _getUserAchievements(String userId) async {
    // Check cache first
    if (_userAchievements.containsKey(userId)) {
      return _userAchievements[userId]!;
    }

    try {
      // Fetch from Firestore
      final result = await _firestoreService.read(
        collection: 'user_achievements',
        documentId: userId,
      );

      UserAchievements userAchievements;
      if (result.isSuccess && result.data != null) {
        userAchievements = UserAchievements.fromJson(result.data!);
      } else {
        // Create empty achievements record
        userAchievements = UserAchievements.empty(userId);
        
        // Save to Firestore
        await _firestoreService.create(
          collection: 'user_achievements',
          documentId: userId,
          data: userAchievements.toJson(),
        );
      }

      // Update cache
      _userAchievements[userId] = userAchievements;
      return userAchievements;
    } catch (e) {
      AppLogger.error('❌ GamificationServiceV2: Failed to get user achievements: $e');
      final emptyAchievements = UserAchievements.empty(userId);
      _userAchievements[userId] = emptyAchievements;
      return emptyAchievements;
    }
  }

  /// Check if achievement requirements are met
  bool _checkAchievementRequirements(Achievement achievement, Map<String, dynamic> userStats) {
    for (final requirement in achievement.requirements.entries) {
      final requiredValue = requirement.value;
      final userValue = userStats[requirement.key];

      if (userValue == null) return false;

      // Handle different types of comparisons
      if (requiredValue is int && userValue is int) {
        if (userValue < requiredValue) return false;
      } else if (requiredValue is double && userValue is num) {
        if (userValue.toDouble() < requiredValue) return false;
      } else if (requiredValue is String && userValue is String) {
        if (userValue != requiredValue) return false;
      } else {
        // Try to convert and compare
        try {
          final reqNum = double.parse(requiredValue.toString());
          final userNum = double.parse(userValue.toString());
          if (userNum < reqNum) return false;
        } catch (e) {
          return false;
        }
      }
    }

    return true;
  }

  /// Calculate reward for achievement
  AchievementReward _calculateReward(Achievement achievement) {
    int bonusPoints = 0;
    List<String> unlocks = [];

    // Bonus points based on difficulty
    switch (achievement.difficulty) {
      case AchievementDifficulty.easy:
        bonusPoints = 5;
        break;
      case AchievementDifficulty.medium:
        bonusPoints = 15;
        break;
      case AchievementDifficulty.hard:
        bonusPoints = 25;
        break;
      case AchievementDifficulty.legendary:
        bonusPoints = 50;
        break;
    }

    // Special unlocks for certain achievements
    if (achievement.id == 'streak_30') {
      unlocks.add('premium_content_preview');
    }

    return AchievementReward(
      points: achievement.points,
      bonusPoints: bonusPoints,
      unlocks: unlocks,
      badgeUrl: achievement.badgeUrl,
    );
  }

  /// Get all achievement definitions
  Map<String, Achievement> getAchievementDefinitions() {
    return Map.unmodifiable(_achievementDefinitions);
  }

  /// Get user achievements (public method)
  Future<Result<UserAchievements>> getUserAchievements(String userId) async {
    try {
      final achievements = await _getUserAchievements(userId);
      return Result.success(achievements);
    } catch (e) {
      return Result.failure('Failed to get user achievements: $e');
    }
  }

  /// Get user's total points
  Future<Result<int>> getUserTotalPoints(String userId) async {
    try {
      final userAchievements = await _getUserAchievements(userId);
      int totalPoints = 0;

      for (final awardedAchievement in userAchievements.achievements) {
        final achievement = _achievementDefinitions[awardedAchievement.achievementId];
        if (achievement != null) {
          totalPoints += achievement.points;
          // Add bonus points from metadata if any
          final bonusPoints = awardedAchievement.metadata['bonusPoints'] as int? ?? 0;
          totalPoints += bonusPoints;
        }
      }

      return Result.success(totalPoints);
    } catch (e) {
      return Result.failure('Failed to calculate total points: $e');
    }
  }

  /// Get leaderboard data
  Future<Result<List<LeaderboardEntry>>> getLeaderboard({int limit = 50}) async {
    try {
      final query = FirestoreQuery(
        orderBy: [
          OrderByCondition(field: 'totalPoints', descending: true),
        ],
        limit: limit,
      );

      final result = await _firestoreService.query(
        collection: 'user_achievements',
        query: query,
      );

      if (result.isSuccess) {
        final leaderboard = (result.data ?? [])
            .map((data) => LeaderboardEntry.fromJson(data))
            .toList();

        return Result.success(leaderboard);
      } else {
        return Result.failure('Failed to get leaderboard: ${result.message}');
      }
    } catch (e) {
      return Result.failure('Failed to get leaderboard: $e');
    }
  }

  /// Clear user cache
  void clearUserCache(String userId) {
    _userAchievements.remove(userId);
  }

  /// Dispose resources
  void dispose() {
    _userAchievements.clear();
    AppLogger.info('✅ GamificationServiceV2: Disposed successfully');
  }
}

/// Achievement definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementDifficulty difficulty;
  final int points;
  final Map<String, dynamic> requirements;
  final String? badgeUrl;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.difficulty,
    required this.points,
    required this.requirements,
    this.badgeUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category.toString(),
      'difficulty': difficulty.toString(),
      'points': points,
      'requirements': requirements,
      'badgeUrl': badgeUrl,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => AchievementCategory.learning,
      ),
      difficulty: AchievementDifficulty.values.firstWhere(
        (e) => e.toString() == json['difficulty'],
        orElse: () => AchievementDifficulty.easy,
      ),
      points: json['points'],
      requirements: Map<String, dynamic>.from(json['requirements']),
      badgeUrl: json['badgeUrl'],
    );
  }
}

/// User achievements collection
class UserAchievements {
  final String userId;
  final List<AwardedAchievement> achievements;
  final int totalPoints;
  final DateTime lastUpdated;

  UserAchievements({
    required this.userId,
    required this.achievements,
    required this.totalPoints,
    required this.lastUpdated,
  });

  factory UserAchievements.empty(String userId) {
    return UserAchievements(
      userId: userId,
      achievements: [],
      totalPoints: 0,
      lastUpdated: DateTime.now(),
    );
  }

  bool hasAchievement(String achievementId) {
    return achievements.any((a) => a.achievementId == achievementId);
  }

  void addAchievement(AwardedAchievement achievement) {
    achievements.add(achievement);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'totalPoints': totalPoints,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserAchievements.fromJson(Map<String, dynamic> json) {
    return UserAchievements(
      userId: json['userId'],
      achievements: (json['achievements'] as List? ?? [])
          .map((a) => AwardedAchievement.fromJson(a))
          .toList(),
      totalPoints: json['totalPoints'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Awarded achievement
class AwardedAchievement {
  final String achievementId;
  final DateTime awardedAt;
  final String reason;
  final Map<String, dynamic> metadata;

  const AwardedAchievement({
    required this.achievementId,
    required this.awardedAt,
    required this.reason,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'awardedAt': awardedAt.toIso8601String(),
      'reason': reason,
      'metadata': metadata,
    };
  }

  factory AwardedAchievement.fromJson(Map<String, dynamic> json) {
    return AwardedAchievement(
      achievementId: json['achievementId'],
      awardedAt: DateTime.parse(json['awardedAt']),
      reason: json['reason'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

/// Achievement result
class AchievementResult {
  final bool isSuccess;
  final Achievement? achievement;
  final AchievementReward? reward;
  final String? error;

  const AchievementResult._({
    required this.isSuccess,
    this.achievement,
    this.reward,
    this.error,
  });

  factory AchievementResult.success(Achievement achievement, AchievementReward reward) {
    return AchievementResult._(
      isSuccess: true,
      achievement: achievement,
      reward: reward,
    );
  }

  factory AchievementResult.alreadyAwarded(Achievement achievement) {
    return AchievementResult._(
      isSuccess: false,
      achievement: achievement,
      error: 'Achievement already awarded',
    );
  }

  factory AchievementResult.notFound(String achievementId) {
    return AchievementResult._(
      isSuccess: false,
      error: 'Achievement not found: $achievementId',
    );
  }

  factory AchievementResult.error(String error) {
    return AchievementResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Achievement reward
class AchievementReward {
  final int points;
  final int bonusPoints;
  final List<String> unlocks;
  final String? badgeUrl;

  const AchievementReward({
    required this.points,
    required this.bonusPoints,
    required this.unlocks,
    this.badgeUrl,
  });

  int get totalPoints => points + bonusPoints;
}

/// Leaderboard entry
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int totalPoints;
  final int achievementCount;
  final String? profileImageUrl;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.achievementCount,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'totalPoints': totalPoints,
      'achievementCount': achievementCount,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      displayName: json['displayName'] ?? 'Unknown User',
      totalPoints: json['totalPoints'] ?? 0,
      achievementCount: json['achievementCount'] ?? 0,
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

/// Achievement categories
enum AchievementCategory {
  learning,
  consistency,
  exploration,
  dedication,
  social,
  mastery,
}

/// Achievement difficulties
enum AchievementDifficulty {
  easy,
  medium,
  hard,
  legendary,
}
