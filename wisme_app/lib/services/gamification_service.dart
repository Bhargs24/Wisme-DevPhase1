/// Gamification Service
/// 
/// Manages user achievements, rewards, and challenges to increase
/// engagement and motivation in the learning experience.
library;

import '../utils/logger.dart';

/// Service for managing achievements and gamification features
class GamificationService {
  static final Map<String, UserAchievements> _userAchievements = {};

  /// Award achievement to user
  static AchievementResult awardAchievement({
    required String userId,
    required String achievementId,
    required String reason,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final achievement = _getAchievementDefinition(achievementId);
      if (achievement == null) {
        return AchievementResult.notFound(achievementId);
      }

      final userAchievements = _userAchievements[userId] ?? UserAchievements.empty(userId);
      
      if (userAchievements.hasAchievement(achievementId)) {
        return AchievementResult.alreadyAwarded(achievement);
      }

      userAchievements.addAchievement(achievement, reason);
      _userAchievements[userId] = userAchievements;

      AppLogger.info('Achievement awarded: $achievementId to $userId');
      
      return AchievementResult.success(achievement, _calculateReward(achievement));
    } catch (e) {
      AppLogger.error('Achievement award failed: $e');
      return AchievementResult.error(e.toString());
    }
  }

  /// Check for new achievements based on user activity
  static List<AchievementResult> checkForNewAchievements({
    required String userId,
    required Map<String, dynamic> userStats,
  }) {
    final newAchievements = <AchievementResult>[];
    
    // Content consumption achievements
    final contentCount = userStats['contentCount'] as int? ?? 0;
    if (contentCount >= 10) {
      newAchievements.add(awardAchievement(
        userId: userId,
        achievementId: 'explorer',
        reason: 'Consumed 10+ pieces of content',
      ));
    }
    
    // Streak achievements
    final streakDays = userStats['streakDays'] as int? ?? 0;
    if (streakDays >= 7) {
      newAchievements.add(awardAchievement(
        userId: userId,
        achievementId: 'week_warrior',
        reason: 'Maintained 7-day learning streak',
      ));
    }

    return newAchievements.where((r) => r.isSuccess).toList();
  }

  /// Get user's achievements
  static UserAchievements? getUserAchievements(String userId) {
    return _userAchievements[userId];
  }

  static Achievement? _getAchievementDefinition(String achievementId) {
    final definitions = {
      'explorer': Achievement(
        id: 'explorer',
        name: 'Content Explorer',
        description: 'Explore diverse learning content',
        iconUrl: '🗺️',
        rarity: AchievementRarity.common,
        points: 100,
      ),
      'week_warrior': Achievement(
        id: 'week_warrior', 
        name: 'Week Warrior',
        description: 'Maintain a 7-day learning streak',
        iconUrl: '🔥',
        rarity: AchievementRarity.uncommon,
        points: 250,
      ),
    };
    
    return definitions[achievementId];
  }

  static Reward _calculateReward(Achievement achievement) {
    return Reward(
      type: RewardType.points,
      value: achievement.points,
      description: 'Earned ${achievement.points} points',
    );
  }
}

/// Achievement rarity levels
enum AchievementRarity { common, uncommon, rare, epic, legendary }

/// Types of rewards
enum RewardType { points, badge, unlock, discount }

/// Individual achievement definition
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final AchievementRarity rarity;
  final int points;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.rarity,
    required this.points,
  });
}

/// User's achievement collection
class UserAchievements {
  final String userId;
  final List<Achievement> achievements;
  final int totalPoints;

  UserAchievements({
    required this.userId,
    required this.achievements,
    required this.totalPoints,
  });

  factory UserAchievements.empty(String userId) {
    return UserAchievements(
      userId: userId,
      achievements: [],
      totalPoints: 0,
    );
  }

  bool hasAchievement(String achievementId) {
    return achievements.any((a) => a.id == achievementId);
  }

  void addAchievement(Achievement achievement, String reason) {
    achievements.add(achievement);
  }
}

/// Result of an achievement operation
class AchievementResult {
  final bool isSuccess;
  final Achievement? achievement;
  final Reward? reward;
  final String? error;

  AchievementResult.success(this.achievement, this.reward) 
      : isSuccess = true, error = null;
  
  AchievementResult.notFound(String id) 
      : isSuccess = false, achievement = null, reward = null, error = 'Achievement not found: $id';
  
  AchievementResult.alreadyAwarded(this.achievement) 
      : isSuccess = false, reward = null, error = 'Already awarded';
  
  AchievementResult.error(this.error) 
      : isSuccess = false, achievement = null, reward = null;
}

/// Reward given for achievements
class Reward {
  final RewardType type;
  final int value;
  final String description;

  Reward({
    required this.type,
    required this.value,
    required this.description,
  });
}
