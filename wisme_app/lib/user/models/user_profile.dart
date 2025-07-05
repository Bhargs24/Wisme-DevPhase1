import 'package:equatable/equatable.dart';

/// Production-grade user profile model
/// Represents a complete user profile with all personal and preference data
class UserProfile extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? bio;
  final String? location;
  final String? timezone;
  final String preferredLanguage;
  final UserSettings settings;
  final LearningPreferences learningPreferences;
  final UserSubscription subscription;
  final UserStats stats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;
  final bool isActive;
  final bool isVerified;
  final List<String> roles;
  final Map<String, dynamic> customFields;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
    this.location,
    this.timezone,
    this.preferredLanguage = 'en',
    required this.settings,
    required this.learningPreferences,
    required this.subscription,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
    this.isActive = true,
    this.isVerified = false,
    this.roles = const ['user'],
    this.customFields = const {},
  });

  /// Get user's full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return displayName;
  }

  /// Get user's initials
  String get initials {
    final name = fullName.trim();
    if (name.isEmpty) return 'U';
    
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
    }
  }

  /// Check if user has premium subscription
  bool get isPremium => subscription.type == SubscriptionType.premium;

  /// Check if subscription is active
  bool get hasActiveSubscription => subscription.isActive;

  /// Get user's age
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if user has specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is coach
  bool get isCoach => hasRole('coach');

  /// Get days since last active
  int get daysSinceLastActive {
    if (lastActiveAt == null) return 0;
    return DateTime.now().difference(lastActiveAt!).inDays;
  }

  /// Check if user is considered active (active within last 7 days)
  bool get isRecentlyActive => daysSinceLastActive <= 7;

  /// Create copy with updated fields
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
    String? location,
    String? timezone,
    String? preferredLanguage,
    UserSettings? settings,
    LearningPreferences? learningPreferences,
    UserSubscription? subscription,
    UserStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    bool? isActive,
    bool? isVerified,
    List<String>? roles,
    Map<String, dynamic>? customFields,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      timezone: timezone ?? this.timezone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      settings: settings ?? this.settings,
      learningPreferences: learningPreferences ?? this.learningPreferences,
      subscription: subscription ?? this.subscription,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      roles: roles ?? this.roles,
      customFields: customFields ?? this.customFields,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'location': location,
      'timezone': timezone,
      'preferredLanguage': preferredLanguage,
      'settings': settings.toJson(),
      'learningPreferences': learningPreferences.toJson(),
      'subscription': subscription.toJson(),
      'stats': stats.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isActive': isActive,
      'isVerified': isVerified,
      'roles': roles,
      'customFields': customFields,
    };
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImageUrl: json['profileImageUrl'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      bio: json['bio'],
      location: json['location'],
      timezone: json['timezone'],
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      settings: UserSettings.fromJson(json['settings']),
      learningPreferences: LearningPreferences.fromJson(json['learningPreferences']),
      subscription: UserSubscription.fromJson(json['subscription']),
      stats: UserStats.fromJson(json['stats']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.parse(json['lastActiveAt']) 
          : null,
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      roles: List<String>.from(json['roles'] ?? ['user']),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    id, email, displayName, firstName, lastName, profileImageUrl,
    phoneNumber, dateOfBirth, bio, location, timezone, preferredLanguage,
    settings, learningPreferences, subscription, stats, createdAt, updatedAt,
    lastActiveAt, isActive, isVerified, roles, customFields,
  ];
}

/// User settings model
class UserSettings extends Equatable {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool lessonReminders;
  final bool progressUpdates;
  final bool marketingEmails;
  final String theme; // 'light', 'dark', 'system'
  final double fontSize;
  final bool autoPlayAudio;
  final bool downloadOverWifiOnly;
  final int dailyGoalMinutes;
  final List<int> reminderTimes; // Hours in 24h format
  final Map<String, dynamic> customSettings;

  const UserSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.lessonReminders = true,
    this.progressUpdates = true,
    this.marketingEmails = false,
    this.theme = 'system',
    this.fontSize = 1.0,
    this.autoPlayAudio = true,
    this.downloadOverWifiOnly = true,
    this.dailyGoalMinutes = 30,
    this.reminderTimes = const [9, 18], // 9 AM and 6 PM
    this.customSettings = const {},
  });

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? lessonReminders,
    bool? progressUpdates,
    bool? marketingEmails,
    String? theme,
    double? fontSize,
    bool? autoPlayAudio,
    bool? downloadOverWifiOnly,
    int? dailyGoalMinutes,
    List<int>? reminderTimes,
    Map<String, dynamic>? customSettings,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      lessonReminders: lessonReminders ?? this.lessonReminders,
      progressUpdates: progressUpdates ?? this.progressUpdates,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      downloadOverWifiOnly: downloadOverWifiOnly ?? this.downloadOverWifiOnly,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'lessonReminders': lessonReminders,
      'progressUpdates': progressUpdates,
      'marketingEmails': marketingEmails,
      'theme': theme,
      'fontSize': fontSize,
      'autoPlayAudio': autoPlayAudio,
      'downloadOverWifiOnly': downloadOverWifiOnly,
      'dailyGoalMinutes': dailyGoalMinutes,
      'reminderTimes': reminderTimes,
      'customSettings': customSettings,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      lessonReminders: json['lessonReminders'] ?? true,
      progressUpdates: json['progressUpdates'] ?? true,
      marketingEmails: json['marketingEmails'] ?? false,
      theme: json['theme'] ?? 'system',
      fontSize: (json['fontSize'] ?? 1.0).toDouble(),
      autoPlayAudio: json['autoPlayAudio'] ?? true,
      downloadOverWifiOnly: json['downloadOverWifiOnly'] ?? true,
      dailyGoalMinutes: json['dailyGoalMinutes'] ?? 30,
      reminderTimes: List<int>.from(json['reminderTimes'] ?? [9, 18]),
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled, emailNotifications, pushNotifications,
    lessonReminders, progressUpdates, marketingEmails, theme,
    fontSize, autoPlayAudio, downloadOverWifiOnly, dailyGoalMinutes,
    reminderTimes, customSettings,
  ];
}

/// Learning preferences model
class LearningPreferences extends Equatable {
  final List<String> preferredTopics;
  final String learningStyle; // 'visual', 'auditory', 'kinesthetic', 'mixed'
  final String difficultyLevel; // 'beginner', 'intermediate', 'advanced'
  final int sessionDurationMinutes;
  final List<String> availableDays; // ['monday', 'tuesday', etc.]
  final String preferredTimeOfDay; // 'morning', 'afternoon', 'evening', 'night'
  final bool adaptiveDifficulty;
  final bool repeatIncorrectItems;
  final int maxDailyLessons;
  final List<String> interests;
  final Map<String, dynamic> customPreferences;

  const LearningPreferences({
    this.preferredTopics = const [],
    this.learningStyle = 'mixed',
    this.difficultyLevel = 'beginner',
    this.sessionDurationMinutes = 15,
    this.availableDays = const ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
    this.preferredTimeOfDay = 'evening',
    this.adaptiveDifficulty = true,
    this.repeatIncorrectItems = true,
    this.maxDailyLessons = 5,
    this.interests = const [],
    this.customPreferences = const {},
  });

  LearningPreferences copyWith({
    List<String>? preferredTopics,
    String? learningStyle,
    String? difficultyLevel,
    int? sessionDurationMinutes,
    List<String>? availableDays,
    String? preferredTimeOfDay,
    bool? adaptiveDifficulty,
    bool? repeatIncorrectItems,
    int? maxDailyLessons,
    List<String>? interests,
    Map<String, dynamic>? customPreferences,
  }) {
    return LearningPreferences(
      preferredTopics: preferredTopics ?? this.preferredTopics,
      learningStyle: learningStyle ?? this.learningStyle,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      sessionDurationMinutes: sessionDurationMinutes ?? this.sessionDurationMinutes,
      availableDays: availableDays ?? this.availableDays,
      preferredTimeOfDay: preferredTimeOfDay ?? this.preferredTimeOfDay,
      adaptiveDifficulty: adaptiveDifficulty ?? this.adaptiveDifficulty,
      repeatIncorrectItems: repeatIncorrectItems ?? this.repeatIncorrectItems,
      maxDailyLessons: maxDailyLessons ?? this.maxDailyLessons,
      interests: interests ?? this.interests,
      customPreferences: customPreferences ?? this.customPreferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredTopics': preferredTopics,
      'learningStyle': learningStyle,
      'difficultyLevel': difficultyLevel,
      'sessionDurationMinutes': sessionDurationMinutes,
      'availableDays': availableDays,
      'preferredTimeOfDay': preferredTimeOfDay,
      'adaptiveDifficulty': adaptiveDifficulty,
      'repeatIncorrectItems': repeatIncorrectItems,
      'maxDailyLessons': maxDailyLessons,
      'interests': interests,
      'customPreferences': customPreferences,
    };
  }

  factory LearningPreferences.fromJson(Map<String, dynamic> json) {
    return LearningPreferences(
      preferredTopics: List<String>.from(json['preferredTopics'] ?? []),
      learningStyle: json['learningStyle'] ?? 'mixed',
      difficultyLevel: json['difficultyLevel'] ?? 'beginner',
      sessionDurationMinutes: json['sessionDurationMinutes'] ?? 15,
      availableDays: List<String>.from(json['availableDays'] ?? 
          ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']),
      preferredTimeOfDay: json['preferredTimeOfDay'] ?? 'evening',
      adaptiveDifficulty: json['adaptiveDifficulty'] ?? true,
      repeatIncorrectItems: json['repeatIncorrectItems'] ?? true,
      maxDailyLessons: json['maxDailyLessons'] ?? 5,
      interests: List<String>.from(json['interests'] ?? []),
      customPreferences: Map<String, dynamic>.from(json['customPreferences'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    preferredTopics, learningStyle, difficultyLevel, sessionDurationMinutes,
    availableDays, preferredTimeOfDay, adaptiveDifficulty, repeatIncorrectItems,
    maxDailyLessons, interests, customPreferences,
  ];
}

/// User subscription model
class UserSubscription extends Equatable {
  final SubscriptionType type;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final String? paymentMethodId;
  final double? monthlyPrice;
  final double? yearlyPrice;
  final String currency;
  final bool autoRenew;
  final DateTime? lastPaymentDate;
  final DateTime? nextPaymentDate;
  final int? billingCycle; // in months
  final Map<String, bool> features;
  final String? subscriptionId;
  final Map<String, dynamic> billingInfo;

  const UserSubscription({
    this.type = SubscriptionType.free,
    this.status = SubscriptionStatus.active,
    this.startDate,
    this.endDate,
    this.trialEndDate,
    this.paymentMethodId,
    this.monthlyPrice,
    this.yearlyPrice,
    this.currency = 'USD',
    this.autoRenew = false,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.billingCycle,
    this.features = const {},
    this.subscriptionId,
    this.billingInfo = const {},
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isTrial => trialEndDate != null && DateTime.now().isBefore(trialEndDate!);
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
  
  int get daysUntilExpiry {
    if (endDate == null) return -1;
    return endDate!.difference(DateTime.now()).inDays;
  }

  bool hasFeature(String featureName) => features[featureName] ?? false;

  UserSubscription copyWith({
    SubscriptionType? type,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    String? paymentMethodId,
    double? monthlyPrice,
    double? yearlyPrice,
    String? currency,
    bool? autoRenew,
    DateTime? lastPaymentDate,
    DateTime? nextPaymentDate,
    int? billingCycle,
    Map<String, bool>? features,
    String? subscriptionId,
    Map<String, dynamic>? billingInfo,
  }) {
    return UserSubscription(
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      currency: currency ?? this.currency,
      autoRenew: autoRenew ?? this.autoRenew,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      billingCycle: billingCycle ?? this.billingCycle,
      features: features ?? this.features,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      billingInfo: billingInfo ?? this.billingInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'status': status.toString(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'currency': currency,
      'autoRenew': autoRenew,
      'lastPaymentDate': lastPaymentDate?.toIso8601String(),
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
      'billingCycle': billingCycle,
      'features': features,
      'subscriptionId': subscriptionId,
      'billingInfo': billingInfo,
    };
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SubscriptionType.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      trialEndDate: json['trialEndDate'] != null ? DateTime.parse(json['trialEndDate']) : null,
      paymentMethodId: json['paymentMethodId'],
      monthlyPrice: json['monthlyPrice']?.toDouble(),
      yearlyPrice: json['yearlyPrice']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      autoRenew: json['autoRenew'] ?? false,
      lastPaymentDate: json['lastPaymentDate'] != null ? DateTime.parse(json['lastPaymentDate']) : null,
      nextPaymentDate: json['nextPaymentDate'] != null ? DateTime.parse(json['nextPaymentDate']) : null,
      billingCycle: json['billingCycle'],
      features: Map<String, bool>.from(json['features'] ?? {}),
      subscriptionId: json['subscriptionId'],
      billingInfo: Map<String, dynamic>.from(json['billingInfo'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    type, status, startDate, endDate, trialEndDate, paymentMethodId,
    monthlyPrice, yearlyPrice, currency, autoRenew, lastPaymentDate,
    nextPaymentDate, billingCycle, features, subscriptionId, billingInfo,
  ];
}

/// User statistics model
class UserStats extends Equatable {
  final int totalLessonsCompleted;
  final int totalTimeSpentMinutes;
  final int currentStreak;
  final int longestStreak;
  final double averageScore;
  final int totalPoints;
  final int level;
  final int experiencePoints;
  final DateTime? lastLessonDate;
  final int lessonsThisWeek;
  final int lessonsThisMonth;
  final Map<String, int> topicProgress; // topic -> completed lessons
  final Map<String, double> skillLevels; // skill -> proficiency (0.0-1.0)
  final List<DateTime> activityDates; // for streak calculation
  final Map<String, dynamic> achievements;

  const UserStats({
    this.totalLessonsCompleted = 0,
    this.totalTimeSpentMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageScore = 0.0,
    this.totalPoints = 0,
    this.level = 1,
    this.experiencePoints = 0,
    this.lastLessonDate,
    this.lessonsThisWeek = 0,
    this.lessonsThisMonth = 0,
    this.topicProgress = const {},
    this.skillLevels = const {},
    this.activityDates = const [],
    this.achievements = const {},
  });

  Duration get totalTimeSpent => Duration(minutes: totalTimeSpentMinutes);
  String get formattedTotalTime {
    final hours = totalTimeSpentMinutes ~/ 60;
    final minutes = totalTimeSpentMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  int get pointsToNextLevel {
    final pointsForNextLevel = (level * 1000) + 500;
    return pointsForNextLevel - experiencePoints;
  }

  double get levelProgress {
    final pointsForCurrentLevel = ((level - 1) * 1000) + 500;
    final pointsForNextLevel = (level * 1000) + 500;
    final progressInLevel = experiencePoints - pointsForCurrentLevel;
    final totalPointsInLevel = pointsForNextLevel - pointsForCurrentLevel;
    return progressInLevel / totalPointsInLevel;
  }

  UserStats copyWith({
    int? totalLessonsCompleted,
    int? totalTimeSpentMinutes,
    int? currentStreak,
    int? longestStreak,
    double? averageScore,
    int? totalPoints,
    int? level,
    int? experiencePoints,
    DateTime? lastLessonDate,
    int? lessonsThisWeek,
    int? lessonsThisMonth,
    Map<String, int>? topicProgress,
    Map<String, double>? skillLevels,
    List<DateTime>? activityDates,
    Map<String, dynamic>? achievements,
  }) {
    return UserStats(
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalTimeSpentMinutes: totalTimeSpentMinutes ?? this.totalTimeSpentMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      averageScore: averageScore ?? this.averageScore,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      lastLessonDate: lastLessonDate ?? this.lastLessonDate,
      lessonsThisWeek: lessonsThisWeek ?? this.lessonsThisWeek,
      lessonsThisMonth: lessonsThisMonth ?? this.lessonsThisMonth,
      topicProgress: topicProgress ?? this.topicProgress,
      skillLevels: skillLevels ?? this.skillLevels,
      activityDates: activityDates ?? this.activityDates,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalTimeSpentMinutes': totalTimeSpentMinutes,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'averageScore': averageScore,
      'totalPoints': totalPoints,
      'level': level,
      'experiencePoints': experiencePoints,
      'lastLessonDate': lastLessonDate?.toIso8601String(),
      'lessonsThisWeek': lessonsThisWeek,
      'lessonsThisMonth': lessonsThisMonth,
      'topicProgress': topicProgress,
      'skillLevels': skillLevels,
      'activityDates': activityDates.map((d) => d.toIso8601String()).toList(),
      'achievements': achievements,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      totalTimeSpentMinutes: json['totalTimeSpentMinutes'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
      experiencePoints: json['experiencePoints'] ?? 0,
      lastLessonDate: json['lastLessonDate'] != null ? DateTime.parse(json['lastLessonDate']) : null,
      lessonsThisWeek: json['lessonsThisWeek'] ?? 0,
      lessonsThisMonth: json['lessonsThisMonth'] ?? 0,
      topicProgress: Map<String, int>.from(json['topicProgress'] ?? {}),
      skillLevels: Map<String, double>.from(json['skillLevels'] ?? {}),
      activityDates: (json['activityDates'] as List<dynamic>?)
          ?.map((d) => DateTime.parse(d))
          .toList() ?? [],
      achievements: Map<String, dynamic>.from(json['achievements'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    totalLessonsCompleted, totalTimeSpentMinutes, currentStreak,
    longestStreak, averageScore, totalPoints, level, experiencePoints,
    lastLessonDate, lessonsThisWeek, lessonsThisMonth, topicProgress,
    skillLevels, activityDates, achievements,
  ];
}

/// Subscription types
enum SubscriptionType {
  free,
  premium,
  enterprise,
}

/// Subscription status
enum SubscriptionStatus {
  active,
  inactive,
  cancelled,
  expired,
  paused,
}
