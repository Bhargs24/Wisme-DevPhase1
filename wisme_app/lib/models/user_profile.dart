import '../core/exports.dart';
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final Color color;
  final int points;
  final DateTime unlockedAt;
  final String category;
  final Map<String, dynamic> metadata;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.color,
    required this.points,
    required this.unlockedAt,
    required this.category,
    this.metadata = const {},
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['icon_url'],
      color: Color(json['color']),
      points: json['points'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
      category: json['category'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_url': iconUrl,
      'color': color.value,
      'points': points,
      'unlocked_at': unlockedAt.toIso8601String(),
      'category': category,
      'metadata': metadata,
    };
  }
}

/// Industrial-grade UserProfile model
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final List<String> preferredCategories;
  final String defaultKnowledgeLevel;
  final String preferredCoach;
  final Map<String, dynamic> learningPreferences;
  final int totalLearningTime;
  final int currentStreak;
  final int longestStreak;
  final List<String> completedLessons;
  final Map<String, int> categoryProgress;
  final List<Achievement> achievements;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> settings;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.preferredCategories = const [],
    this.defaultKnowledgeLevel = 'intermediate',
    this.preferredCoach = 'kai',
    this.learningPreferences = const {},
    this.totalLearningTime = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedLessons = const [],
    this.categoryProgress = const {},
    this.achievements = const [],
    required this.createdAt,
    required this.lastActiveAt,
    this.settings = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      preferredCategories: List<String>.from(json['preferred_categories'] ?? []),
      defaultKnowledgeLevel: json['default_knowledge_level'] ?? 'intermediate',
      preferredCoach: json['preferred_coach'] ?? 'kai',
      learningPreferences: json['learning_preferences'] ?? {},
      totalLearningTime: json['total_learning_time'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      completedLessons: List<String>.from(json['completed_lessons'] ?? []),
      categoryProgress: Map<String, int>.from(json['category_progress'] ?? {}),
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((a) => Achievement.fromJson(a))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      lastActiveAt: DateTime.parse(json['last_active_at']),
      settings: json['settings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'preferred_categories': preferredCategories,
      'default_knowledge_level': defaultKnowledgeLevel,
      'preferred_coach': preferredCoach,
      'learning_preferences': learningPreferences,
      'total_learning_time': totalLearningTime,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'completed_lessons': completedLessons,
      'category_progress': categoryProgress,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
      'settings': settings,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    List<String>? preferredCategories,
    String? defaultKnowledgeLevel,
    String? preferredCoach,
    Map<String, dynamic>? learningPreferences,
    int? totalLearningTime,
    int? currentStreak,
    int? longestStreak,
    List<String>? completedLessons,
    Map<String, int>? categoryProgress,
    List<Achievement>? achievements,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? settings,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      defaultKnowledgeLevel: defaultKnowledgeLevel ?? this.defaultKnowledgeLevel,
      preferredCoach: preferredCoach ?? this.preferredCoach,
      learningPreferences: learningPreferences ?? this.learningPreferences,
      totalLearningTime: totalLearningTime ?? this.totalLearningTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedLessons: completedLessons ?? this.completedLessons,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      settings: settings ?? this.settings,
    );
  }

  // Business Logic Methods

  /// Get learning level display
  String get learningLevel {
    if (totalLearningTime < 60) return 'Beginner';
    if (totalLearningTime < 300) return 'Intermediate';
    if (totalLearningTime < 600) return 'Advanced';
    return 'Expert';
  }

  /// Get streak status
  String get streakStatus {
    if (currentStreak == 0) return 'Start your learning streak!';
    if (currentStreak == 1) return '1 day streak - keep it up!';
    return '$currentStreak day streak - amazing!';
  }

  /// Get total achievement points
  int get totalPoints => achievements.fold(0, (sum, achievement) => sum + achievement.points);

  /// Check if user has specific achievement
  bool hasAchievement(String achievementId) {
    return achievements.any((achievement) => achievement.id == achievementId);
  }

  /// Get progress in specific category
  double getCategoryProgress(String category) {
    final progress = categoryProgress[category] ?? 0;
    return progress / 100.0; // Assuming progress is stored as percentage
  }

  /// Get initials for avatar
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    final names = displayName!.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName!.substring(0, 1).toUpperCase();
  }

  /// Check if user is active (last active within 7 days)
  bool get isActive {
    final daysSinceActive = DateTime.now().difference(lastActiveAt).inDays;
    return daysSinceActive <= 7;
  }

  /// Get favorite category (most progress)
  String? get favoriteCategory {
    if (categoryProgress.isEmpty) return null;
    return categoryProgress.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Format total learning time
  String get formattedLearningTime {
    if (totalLearningTime < 60) {
      return '${totalLearningTime}m';
    }
    final hours = totalLearningTime ~/ 60;
    final minutes = totalLearningTime % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


