/// Industrial-grade Achievement model for gamification system
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final AchievementType type;
  final AchievementRarity rarity;
  final Map<String, dynamic> criteria;
  final int points;
  final List<String> prerequisites;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final double progress;
  final Map<String, dynamic> metadata;
  final List<String> categories;
  final String? celebrationMessage;
  final Duration? timeLimit;
  final bool isExpired;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.rarity,
    required this.criteria,
    required this.points,
    this.prerequisites = const [],
    this.unlockedAt,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.metadata = const {},
    this.categories = const [],
    this.celebrationMessage,
    this.timeLimit,
    this.isExpired = false,
  });

  /// Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['icon_path'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AchievementType.milestone,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString().split('.').last == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      criteria: json['criteria'] ?? {},
      points: json['points'],
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      unlockedAt: json['unlocked_at'] != null ? DateTime.parse(json['unlocked_at']) : null,
      isUnlocked: json['is_unlocked'] ?? false,
      progress: json['progress']?.toDouble() ?? 0.0,
      metadata: json['metadata'] ?? {},
      categories: List<String>.from(json['categories'] ?? []),
      celebrationMessage: json['celebration_message'],
      timeLimit: json['time_limit_ms'] != null ? Duration(milliseconds: json['time_limit_ms']) : null,
      isExpired: json['is_expired'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_path': iconPath,
      'type': type.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
      'criteria': criteria,
      'points': points,
      'prerequisites': prerequisites,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'is_unlocked': isUnlocked,
      'progress': progress,
      'metadata': metadata,
      'categories': categories,
      'celebration_message': celebrationMessage,
      'time_limit_ms': timeLimit?.inMilliseconds,
      'is_expired': isExpired,
    };
  }

  /// Copy with modifications
  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? iconPath,
    AchievementType? type,
    AchievementRarity? rarity,
    Map<String, dynamic>? criteria,
    int? points,
    List<String>? prerequisites,
    DateTime? unlockedAt,
    bool? isUnlocked,
    double? progress,
    Map<String, dynamic>? metadata,
    List<String>? categories,
    String? celebrationMessage,
    Duration? timeLimit,
    bool? isExpired,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      criteria: criteria ?? this.criteria,
      points: points ?? this.points,
      prerequisites: prerequisites ?? this.prerequisites,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
      categories: categories ?? this.categories,
      celebrationMessage: celebrationMessage ?? this.celebrationMessage,
      timeLimit: timeLimit ?? this.timeLimit,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  // Business Logic Methods

  /// Check if achievement can be unlocked (prerequisites met)
  bool canBeUnlocked(List<String> unlockedAchievementIds) {
    if (isUnlocked) return false;
    if (isExpired) return false;
    
    return prerequisites.every((prereq) => unlockedAchievementIds.contains(prereq));
  }

  /// Get progress percentage as string
  String get formattedProgress => '${(progress * 100).toStringAsFixed(0)}%';

  /// Check if achievement is close to unlocking (80%+ progress)
  bool get isNearUnlock => !isUnlocked && progress >= 0.8;

  /// Get display color based on rarity
  String get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return '#9CA3AF'; // Gray
      case AchievementRarity.uncommon:
        return '#10B981'; // Green
      case AchievementRarity.rare:
        return '#3B82F6'; // Blue
      case AchievementRarity.epic:
        return '#8B5CF6'; // Purple
      case AchievementRarity.legendary:
        return '#F59E0B'; // Gold
    }
  }

  /// Get rarity display name
  String get rarityDisplayName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  /// Check if achievement has time limit and is still valid
  bool get isTimeValid {
    if (timeLimit == null) return true;
    if (unlockedAt == null) return true;
    
    final deadline = unlockedAt!.add(timeLimit!);
    return DateTime.now().isBefore(deadline);
  }

  /// Get time remaining for time-limited achievements
  Duration? get timeRemaining {
    if (timeLimit == null || unlockedAt == null) return null;
    
    final deadline = unlockedAt!.add(timeLimit!);
    final remaining = deadline.difference(DateTime.now());
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Achievement{id: $id, name: $name, unlocked: $isUnlocked, progress: $formattedProgress}';
  }
}

/// Achievement type enumeration
enum AchievementType {
  milestone,      // Learning milestones (lessons completed, hours learned)
  streak,         // Consistency achievements (daily streaks, weekly goals)
  exploration,    // Discovery achievements (new categories, topics)
  mastery,        // Skill-based achievements (high scores, perfect sessions)
  social,         // Community achievements (sharing, helping others)
  special,        // Limited-time or special event achievements
}

/// Achievement rarity levels
enum AchievementRarity {
  common,         // Easy to achieve, low point value
  uncommon,       // Moderate effort required
  rare,           // Significant effort or skill required
  epic,           // High dedication or exceptional performance
  legendary,      // Extremely rare, highest point value
}

/// Predefined achievements for the Wisme app
class WismeAchievements {
  static const List<Achievement> predefinedAchievements = [
    // Milestone Achievements
    Achievement(
      id: 'first_lesson',
      name: 'First Steps',
      description: 'Complete your first learning session',
      iconPath: 'assets/icons/achievements/first_steps.png',
      type: AchievementType.milestone,
      rarity: AchievementRarity.common,
      criteria: {'lessons_completed': 1},
      points: 10,
      celebrationMessage: 'Welcome to your learning journey! 🎉',
    ),
    
    Achievement(
      id: 'ten_lessons',
      name: 'Dedicated Learner',
      description: 'Complete 10 learning sessions',
      iconPath: 'assets/icons/achievements/dedicated_learner.png',
      type: AchievementType.milestone,
      rarity: AchievementRarity.uncommon,
      criteria: {'lessons_completed': 10},
      points: 50,
      prerequisites: ['first_lesson'],
    ),
    
    Achievement(
      id: 'hundred_lessons',
      name: 'Learning Master',
      description: 'Complete 100 learning sessions',
      iconPath: 'assets/icons/achievements/learning_master.png',
      type: AchievementType.milestone,
      rarity: AchievementRarity.epic,
      criteria: {'lessons_completed': 100},
      points: 500,
      prerequisites: ['ten_lessons'],
    ),
    
    // Streak Achievements
    Achievement(
      id: 'week_streak',
      name: 'Consistent Week',
      description: 'Learn for 7 consecutive days',
      iconPath: 'assets/icons/achievements/week_streak.png',
      type: AchievementType.streak,
      rarity: AchievementRarity.uncommon,
      criteria: {'daily_streak': 7},
      points: 75,
    ),
    
    Achievement(
      id: 'month_streak',
      name: 'Monthly Commitment',
      description: 'Learn for 30 consecutive days',
      iconPath: 'assets/icons/achievements/month_streak.png',
      type: AchievementType.streak,
      rarity: AchievementRarity.rare,
      criteria: {'daily_streak': 30},
      points: 300,
      prerequisites: ['week_streak'],
    ),
    
    // Exploration Achievements
    Achievement(
      id: 'category_explorer',
      name: 'Category Explorer',
      description: 'Learn from 5 different categories',
      iconPath: 'assets/icons/achievements/category_explorer.png',
      type: AchievementType.exploration,
      rarity: AchievementRarity.uncommon,
      criteria: {'categories_explored': 5},
      points: 100,
    ),
    
    // Mastery Achievements
    Achievement(
      id: 'perfect_session',
      name: 'Perfect Focus',
      description: 'Complete a session without pausing',
      iconPath: 'assets/icons/achievements/perfect_focus.png',
      type: AchievementType.mastery,
      rarity: AchievementRarity.rare,
      criteria: {'session_pause_count': 0, 'session_completed': true},
      points: 150,
    ),
    
    // Social Achievements
    Achievement(
      id: 'first_share',
      name: 'Knowledge Sharer',
      description: 'Share your first learning achievement',
      iconPath: 'assets/icons/achievements/knowledge_sharer.png',
      type: AchievementType.social,
      rarity: AchievementRarity.common,
      criteria: {'shares_count': 1},
      points: 25,
    ),
  ];
}

