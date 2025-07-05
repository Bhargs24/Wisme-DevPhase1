import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final UserPreferences preferences;
  final LearningProfile learningProfile;
  final UserProgress progress;
  final List<String> favoriteTopics;
  final List<String> completedJourneys;
  final Map<String, dynamic> metadata;
  final bool hasCompletedOnboarding;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.createdAt,
    required this.lastLoginAt,
    required this.preferences,
    required this.learningProfile,
    required this.progress,
    this.favoriteTopics = const [],
    this.completedJourneys = const [],
    this.metadata = const {},
    this.hasCompletedOnboarding = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      learningProfile: LearningProfile.fromMap(data['learningProfile'] ?? {}),
      progress: UserProgress.fromMap(data['progress'] ?? {}),
      favoriteTopics: List<String>.from(data['favoriteTopics'] ?? []),
      completedJourneys: List<String>.from(data['completedJourneys'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: data['lastLoginAt'] is Timestamp 
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : DateTime.parse(data['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      learningProfile: LearningProfile.fromMap(data['learningProfile'] ?? {}),
      progress: UserProgress.fromMap(data['progress'] ?? {}),
      favoriteTopics: List<String>.from(data['favoriteTopics'] ?? []),
      completedJourneys: List<String>.from(data['completedJourneys'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'phoneNumber': phoneNumber,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLoginAt': Timestamp.fromDate(lastLoginAt),
        'preferences': preferences.toMap(),
        'learningProfile': learningProfile.toMap(),
        'progress': progress.toMap(),
        'favoriteTopics': favoriteTopics,
        'completedJourneys': completedJourneys,
        'metadata': metadata,
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'phoneNumber': phoneNumber,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt.toIso8601String(),
        'preferences': preferences.toMap(),
        'learningProfile': learningProfile.toMap(),
        'progress': progress.toMap(),
        'favoriteTopics': favoriteTopics,
        'completedJourneys': completedJourneys,
        'metadata': metadata,
        'hasCompletedOnboarding': hasCompletedOnboarding,
      };

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    LearningProfile? learningProfile,
    UserProgress? progress,
    List<String>? favoriteTopics,
    List<String>? completedJourneys,
    Map<String, dynamic>? metadata,
    bool? hasCompletedOnboarding,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      learningProfile: learningProfile ?? this.learningProfile,
      progress: progress ?? this.progress,
      favoriteTopics: favoriteTopics ?? this.favoriteTopics,
      completedJourneys: completedJourneys ?? this.completedJourneys,
      metadata: metadata ?? this.metadata,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class UserPreferences {
  final String preferredLanguage;
  final String voiceId; // ElevenLabs voice ID
  final double speechSpeed;
  final String learningGoal;
  final List<String> interests;
  final String difficultyPreference;
  final Duration sessionDuration;
  final bool notificationsEnabled;
  final String timezone;
  final Map<String, dynamic> customSettings;

  UserPreferences({
    this.preferredLanguage = 'en',
    this.voiceId = 'default',
    this.speechSpeed = 1.0,
    this.learningGoal = 'general',
    this.interests = const [],
    this.difficultyPreference = 'intermediate',
    this.sessionDuration = const Duration(minutes: 15),
    this.notificationsEnabled = true,
    this.timezone = 'UTC',
    this.customSettings = const {},
  });

  factory UserPreferences.fromMap(Map<String, dynamic> data) {
    return UserPreferences(
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      voiceId: data['voiceId'] ?? 'default',
      speechSpeed: (data['speechSpeed'] ?? 1.0).toDouble(),
      learningGoal: data['learningGoal'] ?? 'general',
      interests: List<String>.from(data['interests'] ?? []),
      difficultyPreference: data['difficultyPreference'] ?? 'intermediate',
      sessionDuration: Duration(minutes: data['sessionDurationMinutes'] ?? 15),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      timezone: data['timezone'] ?? 'UTC',
      customSettings: Map<String, dynamic>.from(data['customSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'preferredLanguage': preferredLanguage,
        'voiceId': voiceId,
        'speechSpeed': speechSpeed,
        'learningGoal': learningGoal,
        'interests': interests,
        'difficultyPreference': difficultyPreference,
        'sessionDurationMinutes': sessionDuration.inMinutes,
        'notificationsEnabled': notificationsEnabled,
        'timezone': timezone,
        'customSettings': customSettings,
      };

  UserPreferences copyWith({
    String? preferredLanguage,
    String? voiceId,
    double? speechSpeed,
    String? learningGoal,
    List<String>? interests,
    String? difficultyPreference,
    Duration? sessionDuration,
    bool? notificationsEnabled,
    String? timezone,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      voiceId: voiceId ?? this.voiceId,
      speechSpeed: speechSpeed ?? this.speechSpeed,
      learningGoal: learningGoal ?? this.learningGoal,
      interests: interests ?? this.interests,
      difficultyPreference: difficultyPreference ?? this.difficultyPreference,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      timezone: timezone ?? this.timezone,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}

class LearningProfile {
  final List<String> completedTopics;
  final Map<String, int> categoryProgress; // category -> completion percentage
  final String currentLevel; // beginner, intermediate, advanced
  final List<String> strengths;
  final List<String> areasForImprovement;
  final Duration totalLearningTime;
  final int streakDays;
  final DateTime lastActiveDate;
  final Map<String, double> performanceMetrics;

  LearningProfile({
    this.completedTopics = const [],
    this.categoryProgress = const {},
    this.currentLevel = 'beginner',
    this.strengths = const [],
    this.areasForImprovement = const [],
    this.totalLearningTime = const Duration(),
    this.streakDays = 0,
    required this.lastActiveDate,
    this.performanceMetrics = const {},
  });

  factory LearningProfile.fromMap(Map<String, dynamic> data) {
    return LearningProfile(
      completedTopics: List<String>.from(data['completedTopics'] ?? []),
      categoryProgress: Map<String, int>.from(data['categoryProgress'] ?? {}),
      currentLevel: data['currentLevel'] ?? 'beginner',
      strengths: List<String>.from(data['strengths'] ?? []),
      areasForImprovement: List<String>.from(data['areasForImprovement'] ?? []),
      totalLearningTime: Duration(seconds: data['totalLearningTimeSeconds'] ?? 0),
      streakDays: data['streakDays'] ?? 0,
      lastActiveDate: data['lastActiveDate'] is Timestamp
          ? (data['lastActiveDate'] as Timestamp).toDate()
          : DateTime.parse(data['lastActiveDate'] ?? DateTime.now().toIso8601String()),
      performanceMetrics: Map<String, double>.from(data['performanceMetrics'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'completedTopics': completedTopics,
        'categoryProgress': categoryProgress,
        'currentLevel': currentLevel,
        'strengths': strengths,
        'areasForImprovement': areasForImprovement,
        'totalLearningTimeSeconds': totalLearningTime.inSeconds,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate.toIso8601String(),
        'performanceMetrics': performanceMetrics,
      };

  LearningProfile copyWith({
    List<String>? completedTopics,
    Map<String, int>? categoryProgress,
    String? currentLevel,
    List<String>? strengths,
    List<String>? areasForImprovement,
    Duration? totalLearningTime,
    int? streakDays,
    DateTime? lastActiveDate,
    Map<String, double>? performanceMetrics,
  }) {
    return LearningProfile(
      completedTopics: completedTopics ?? this.completedTopics,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      currentLevel: currentLevel ?? this.currentLevel,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      totalLearningTime: totalLearningTime ?? this.totalLearningTime,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }
}

class UserProgress {
  final int totalBlocks;
  final int completedBlocks;
  final int totalJourneys;
  final int completedJourneys;
  final Duration totalListeningTime;
  final Map<String, dynamic> achievements;
  final List<String> unlockedContent;
  final DateTime lastProgressUpdate;

  UserProgress({
    this.totalBlocks = 0,
    this.completedBlocks = 0,
    this.totalJourneys = 0,
    this.completedJourneys = 0,
    this.totalListeningTime = const Duration(),
    this.achievements = const {},
    this.unlockedContent = const [],
    required this.lastProgressUpdate,
  });

  factory UserProgress.fromMap(Map<String, dynamic> data) {
    return UserProgress(
      totalBlocks: data['totalBlocks'] ?? 0,
      completedBlocks: data['completedBlocks'] ?? 0,
      totalJourneys: data['totalJourneys'] ?? 0,
      completedJourneys: data['completedJourneys'] ?? 0,
      totalListeningTime: Duration(seconds: data['totalListeningTimeSeconds'] ?? 0),
      achievements: Map<String, dynamic>.from(data['achievements'] ?? {}),
      unlockedContent: List<String>.from(data['unlockedContent'] ?? []),
      lastProgressUpdate: data['lastProgressUpdate'] is Timestamp
          ? (data['lastProgressUpdate'] as Timestamp).toDate()
          : DateTime.parse(data['lastProgressUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'totalBlocks': totalBlocks,
        'completedBlocks': completedBlocks,
        'totalJourneys': totalJourneys,
        'completedJourneys': completedJourneys,
        'totalListeningTimeSeconds': totalListeningTime.inSeconds,
        'achievements': achievements,
        'unlockedContent': unlockedContent,
        'lastProgressUpdate': lastProgressUpdate.toIso8601String(),
      };

  UserProgress copyWith({
    int? totalBlocks,
    int? completedBlocks,
    int? totalJourneys,
    int? completedJourneys,
    Duration? totalListeningTime,
    Map<String, dynamic>? achievements,
    List<String>? unlockedContent,
    DateTime? lastProgressUpdate,
  }) {
    return UserProgress(
      totalBlocks: totalBlocks ?? this.totalBlocks,
      completedBlocks: completedBlocks ?? this.completedBlocks,
      totalJourneys: totalJourneys ?? this.totalJourneys,
      completedJourneys: completedJourneys ?? this.completedJourneys,
      totalListeningTime: totalListeningTime ?? this.totalListeningTime,
      achievements: achievements ?? this.achievements,
      unlockedContent: unlockedContent ?? this.unlockedContent,
      lastProgressUpdate: lastProgressUpdate ?? this.lastProgressUpdate,
    );
  }

  double get completionPercentage {
    if (totalBlocks == 0) return 0.0;
    return (completedBlocks / totalBlocks) * 100;
  }
}
