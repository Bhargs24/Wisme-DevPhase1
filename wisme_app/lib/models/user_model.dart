class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String preferredVoice;
  final List<String> learningGoals;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final int totalLessonsCompleted;
  final int streakDays;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.preferredVoice = 'default',
    this.learningGoals = const [],
    this.preferences = const {},
    required this.createdAt,
    required this.lastActiveAt,
    this.totalLessonsCompleted = 0,
    this.streakDays = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profile_image_url'],
      preferredVoice: map['preferred_voice'] ?? 'default',
      learningGoals: List<String>.from(map['learning_goals'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      lastActiveAt: DateTime.parse(map['last_active_at'] ?? DateTime.now().toIso8601String()),
      totalLessonsCompleted: map['total_lessons_completed'] ?? 0,
      streakDays: map['streak_days'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'preferred_voice': preferredVoice,
      'learning_goals': learningGoals,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
      'total_lessons_completed': totalLessonsCompleted,
      'streak_days': streakDays,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? preferredVoice,
    List<String>? learningGoals,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? totalLessonsCompleted,
    int? streakDays,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredVoice: preferredVoice ?? this.preferredVoice,
      learningGoals: learningGoals ?? this.learningGoals,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
