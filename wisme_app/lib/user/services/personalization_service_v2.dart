import 'dart:async';
import '../../shared/models/shared_models.dart';
import '../../core/data/firestore_data_service.dart';
import '../../utils/logger.dart';

/// Production-grade personalization service for the new architecture
/// Manages user preferences, learning adaptations, and content customization
class PersonalizationServiceV2 {
  final FirestoreDataService _firestoreService;

  // Stream controllers for personalization updates
  final StreamController<LearningPreferences> _preferencesController = StreamController.broadcast();
  final StreamController<PersonalizationProfile> _profileController = StreamController.broadcast();

  // Cache for user preferences
  final Map<String, LearningPreferences> _preferencesCache = {};
  final Map<String, PersonalizationProfile> _profilesCache = {};

  PersonalizationServiceV2({
    required FirestoreDataService firestoreService,
  }) : _firestoreService = firestoreService;

  // Streams
  Stream<LearningPreferences> get preferencesStream => _preferencesController.stream;
  Stream<PersonalizationProfile> get profileStream => _profileController.stream;

  /// Get user's learning preferences
  Future<Result<LearningPreferences>> getUserPreferences(String userId) async {
    try {
      // Check cache first
      if (_preferencesCache.containsKey(userId)) {
        return Result.success(_preferencesCache[userId]!);
      }

      // Fetch from Firestore
      final result = await _firestoreService.read(
        collection: 'user_preferences',
        documentId: userId,
      );

      if (result.isSuccess && result.data != null) {
        final preferences = LearningPreferences.fromJson(result.data!);
        _preferencesCache[userId] = preferences;
        _preferencesController.add(preferences);
        AppLogger.info('✅ PersonalizationServiceV2: Retrieved preferences for user $userId');
        return Result.success(preferences);
      } else {
        // Return default preferences if none found
        final defaultPreferences = _createDefaultPreferences();
        await _saveUserPreferences(userId, defaultPreferences);
        return Result.success(defaultPreferences);
      }
    } catch (e) {
      AppLogger.error('❌ PersonalizationServiceV2: Failed to get preferences: $e');
      return Result.failure('Failed to get user preferences: $e');
    }
  }

  /// Update user's learning preferences
  Future<Result<void>> updateUserPreferences(String userId, LearningPreferences preferences) async {
    try {
      final updatedPreferences = preferences.copyWith(updatedAt: DateTime.now());
      
      final result = await _firestoreService.update(
        collection: 'user_preferences',
        documentId: userId,
        data: updatedPreferences.toJson(),
      );

      if (result.isSuccess) {
        _preferencesCache[userId] = updatedPreferences;
        _preferencesController.add(updatedPreferences);
        AppLogger.info('✅ PersonalizationServiceV2: Updated preferences for user $userId');
        return Result.success(null);
      } else {
        return Result.failure('Failed to update preferences: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ PersonalizationServiceV2: Failed to update preferences: $e');
      return Result.failure('Failed to update user preferences: $e');
    }
  }

  /// Save user preferences to Firestore
  Future<Result<void>> _saveUserPreferences(String userId, LearningPreferences preferences) async {
    try {
      final result = await _firestoreService.create(
        collection: 'user_preferences',
        documentId: userId,
        data: preferences.toJson(),
      );

      if (result.isSuccess) {
        _preferencesCache[userId] = preferences;
        _preferencesController.add(preferences);
        return Result.success(null);
      } else {
        return Result.failure('Failed to save preferences: ${result.message}');
      }
    } catch (e) {
      return Result.failure('Failed to save preferences: $e');
    }
  }

  /// Get personalization profile based on user behavior
  Future<Result<PersonalizationProfile>> getPersonalizationProfile(String userId) async {
    try {
      // Check cache first
      if (_profilesCache.containsKey(userId)) {
        return Result.success(_profilesCache[userId]!);
      }

      // Fetch from Firestore
      final result = await _firestoreService.read(
        collection: 'personalization_profiles',
        documentId: userId,
      );

      if (result.isSuccess && result.data != null) {
        final profile = PersonalizationProfile.fromJson(result.data!);
        _profilesCache[userId] = profile;
        _profileController.add(profile);
        AppLogger.info('✅ PersonalizationServiceV2: Retrieved personalization profile for user $userId');
        return Result.success(profile);
      } else {
        // Create default profile
        final defaultProfile = await _createDefaultProfile(userId);
        return Result.success(defaultProfile);
      }
    } catch (e) {
      AppLogger.error('❌ PersonalizationServiceV2: Failed to get personalization profile: $e');
      return Result.failure('Failed to get personalization profile: $e');
    }
  }

  /// Generate content recommendations based on user preferences and behavior
  Future<Result<List<ContentRecommendation>>> generateRecommendations(String userId) async {
    try {
      final preferencesResult = await getUserPreferences(userId);
      if (preferencesResult.isFailure) {
        return Result.failure('Failed to get user preferences for recommendations');
      }

      final preferences = preferencesResult.data!;
      
      // In a real implementation, this would use ML/AI to generate recommendations
      // For now, generate simple recommendations based on preferences
      final recommendations = await _generateBasicRecommendations(userId, preferences);

      AppLogger.info('✅ PersonalizationServiceV2: Generated ${recommendations.length} recommendations for user $userId');
      return Result.success(recommendations);
    } catch (e) {
      AppLogger.error('❌ PersonalizationServiceV2: Failed to generate recommendations: $e');
      return Result.failure('Failed to generate recommendations: $e');
    }
  }

  /// Adapt content difficulty based on user performance
  Future<Result<DifficultyLevel>> adaptDifficulty(String userId, double performanceScore) async {
    try {
      final preferencesResult = await getUserPreferences(userId);
      if (preferencesResult.isFailure) {
        return Result.failure('Failed to get user preferences for difficulty adaptation');
      }

      final currentLevel = preferencesResult.data!.difficultyLevel;
      DifficultyLevel newLevel = currentLevel;

      // Adaptive difficulty logic
      if (performanceScore > 0.8 && currentLevel != DifficultyLevel.expert) {
        newLevel = DifficultyLevel.values[currentLevel.index + 1];
      } else if (performanceScore < 0.4 && currentLevel != DifficultyLevel.beginner) {
        newLevel = DifficultyLevel.values[currentLevel.index - 1];
      }

      if (newLevel != currentLevel) {
        final updatedPreferences = preferencesResult.data!.copyWith(
          difficultyLevel: newLevel,
          updatedAt: DateTime.now(),
        );
        await updateUserPreferences(userId, updatedPreferences);
      }

      AppLogger.info('✅ PersonalizationServiceV2: Adapted difficulty for user $userId: $newLevel');
      return Result.success(newLevel);
    } catch (e) {
      AppLogger.error('❌ PersonalizationServiceV2: Failed to adapt difficulty: $e');
      return Result.failure('Failed to adapt difficulty: $e');
    }
  }

  /// Track user behavior for personalization
  Future<Result<void>> trackBehavior(String userId, BehaviorEvent event) async {
    try {
      final behaviorData = {
        'userId': userId,
        'type': event.type,
        'data': event.data,
        'timestamp': event.timestamp.toIso8601String(),
      };

      final result = await _firestoreService.create(
        collection: 'user_behavior',
        data: behaviorData,
      );

      if (result.isSuccess) {
        AppLogger.info('✅ PersonalizationServiceV2: Tracked behavior for user $userId: ${event.type}');
        return Result.success(null);
      } else {
        return Result.failure('Failed to track behavior: ${result.message}');
      }
    } catch (e) {
      AppLogger.error('❌ PersonalizationServiceV2: Failed to track behavior: $e');
      return Result.failure('Failed to track behavior: $e');
    }
  }

  /// Create default learning preferences
  LearningPreferences _createDefaultPreferences() {
    return LearningPreferences(
      learningStyle: LearningStyle.mixed,
      difficultyLevel: DifficultyLevel.intermediate,
      contentFormat: ContentFormat.mixed,
      sessionDuration: const Duration(minutes: 15),
      dailyGoal: const Duration(minutes: 30),
      reminderTime: TimeOfDay.morning,
      topics: [],
      languages: ['en'],
      accessibility: const AccessibilitySettings(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create default personalization profile
  Future<PersonalizationProfile> _createDefaultProfile(String userId) async {
    final profile = PersonalizationProfile(
      userId: userId,
      contentRecommendations: [],
      adaptiveSettings: const AdaptiveSettings(),
      behaviorAnalysis: const BehaviorAnalysis(),
      lastAnalyzed: DateTime.now(),
    );

    // Save to Firestore
    try {
      await _firestoreService.create(
        collection: 'personalization_profiles',
        documentId: userId,
        data: profile.toJson(),
      );
      _profilesCache[userId] = profile;
      _profileController.add(profile);
    } catch (e) {
      AppLogger.error('❌ PersonalizationServiceV2: Failed to save default profile: $e');
    }

    return profile;
  }

  /// Generate basic recommendations based on preferences
  Future<List<ContentRecommendation>> _generateBasicRecommendations(
    String userId,
    LearningPreferences preferences,
  ) async {
    final recommendations = <ContentRecommendation>[];

    // Sample recommendations based on learning style
    switch (preferences.learningStyle) {
      case LearningStyle.visual:
        recommendations.add(
          ContentRecommendation(
            contentId: 'visual_1',
            title: 'Visual Learning: Mind Maps',
            description: 'Interactive mind mapping exercises',
            score: 0.9,
            reason: 'Matches your visual learning style',
            contentType: ContentFormat.visual,
          ),
        );
        break;
      case LearningStyle.auditory:
        recommendations.add(
          ContentRecommendation(
            contentId: 'audio_1',
            title: 'Audio Lessons: Leadership Principles',
            description: 'Comprehensive audio course on leadership',
            score: 0.9,
            reason: 'Matches your auditory learning style',
            contentType: ContentFormat.audio,
          ),
        );
        break;
      case LearningStyle.kinesthetic:
        recommendations.add(
          ContentRecommendation(
            contentId: 'interactive_1',
            title: 'Interactive Workshop: Team Building',
            description: 'Hands-on team building exercises',
            score: 0.9,
            reason: 'Matches your kinesthetic learning style',
            contentType: ContentFormat.interactive,
          ),
        );
        break;
      case LearningStyle.mixed:
        recommendations.addAll([
          ContentRecommendation(
            contentId: 'mixed_1',
            title: 'Comprehensive Course: Communication Skills',
            description: 'Multi-format course with visual, audio, and interactive elements',
            score: 0.85,
            reason: 'Designed for mixed learning preferences',
            contentType: ContentFormat.mixed,
          ),
        ]);
        break;
    }

    return recommendations;
  }

  /// Clear cache for user
  void clearUserCache(String userId) {
    _preferencesCache.remove(userId);
    _profilesCache.remove(userId);
  }

  /// Dispose resources
  void dispose() {
    _preferencesController.close();
    _profileController.close();
    _preferencesCache.clear();
    _profilesCache.clear();
    AppLogger.info('✅ PersonalizationServiceV2: Disposed successfully');
  }
}

/// Learning preferences model
class LearningPreferences {
  final LearningStyle learningStyle;
  final DifficultyLevel difficultyLevel;
  final ContentFormat contentFormat;
  final Duration sessionDuration;
  final Duration dailyGoal;
  final TimeOfDay reminderTime;
  final List<String> topics;
  final List<String> languages;
  final AccessibilitySettings accessibility;
  final DateTime updatedAt;

  const LearningPreferences({
    required this.learningStyle,
    required this.difficultyLevel,
    required this.contentFormat,
    required this.sessionDuration,
    required this.dailyGoal,
    required this.reminderTime,
    required this.topics,
    required this.languages,
    required this.accessibility,
    required this.updatedAt,
  });

  LearningPreferences copyWith({
    LearningStyle? learningStyle,
    DifficultyLevel? difficultyLevel,
    ContentFormat? contentFormat,
    Duration? sessionDuration,
    Duration? dailyGoal,
    TimeOfDay? reminderTime,
    List<String>? topics,
    List<String>? languages,
    AccessibilitySettings? accessibility,
    DateTime? updatedAt,
  }) {
    return LearningPreferences(
      learningStyle: learningStyle ?? this.learningStyle,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      contentFormat: contentFormat ?? this.contentFormat,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderTime: reminderTime ?? this.reminderTime,
      topics: topics ?? this.topics,
      languages: languages ?? this.languages,
      accessibility: accessibility ?? this.accessibility,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'learningStyle': learningStyle.toString(),
      'difficultyLevel': difficultyLevel.toString(),
      'contentFormat': contentFormat.toString(),
      'sessionDuration': sessionDuration.inMinutes,
      'dailyGoal': dailyGoal.inMinutes,
      'reminderTime': reminderTime.toString(),
      'topics': topics,
      'languages': languages,
      'accessibility': accessibility.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LearningPreferences.fromJson(Map<String, dynamic> json) {
    return LearningPreferences(
      learningStyle: _parseLearningStyle(json['learningStyle']),
      difficultyLevel: _parseDifficultyLevel(json['difficultyLevel']),
      contentFormat: _parseContentFormat(json['contentFormat']),
      sessionDuration: Duration(minutes: json['sessionDuration'] ?? 15),
      dailyGoal: Duration(minutes: json['dailyGoal'] ?? 30),
      reminderTime: _parseTimeOfDay(json['reminderTime']),
      topics: List<String>.from(json['topics'] ?? []),
      languages: List<String>.from(json['languages'] ?? ['en']),
      accessibility: AccessibilitySettings.fromJson(json['accessibility'] ?? {}),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static LearningStyle _parseLearningStyle(String? value) {
    return LearningStyle.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => LearningStyle.mixed,
    );
  }

  static DifficultyLevel _parseDifficultyLevel(String? value) {
    return DifficultyLevel.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => DifficultyLevel.intermediate,
    );
  }

  static ContentFormat _parseContentFormat(String? value) {
    return ContentFormat.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => ContentFormat.mixed,
    );
  }

  static TimeOfDay _parseTimeOfDay(String? value) {
    return TimeOfDay.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => TimeOfDay.morning,
    );
  }
}

/// Personalization profile containing adaptive settings and recommendations
class PersonalizationProfile {
  final String userId;
  final List<ContentRecommendation> contentRecommendations;
  final AdaptiveSettings adaptiveSettings;
  final BehaviorAnalysis behaviorAnalysis;
  final DateTime lastAnalyzed;

  const PersonalizationProfile({
    required this.userId,
    required this.contentRecommendations,
    required this.adaptiveSettings,
    required this.behaviorAnalysis,
    required this.lastAnalyzed,
  });

  PersonalizationProfile copyWith({
    String? userId,
    List<ContentRecommendation>? contentRecommendations,
    AdaptiveSettings? adaptiveSettings,
    BehaviorAnalysis? behaviorAnalysis,
    DateTime? lastAnalyzed,
  }) {
    return PersonalizationProfile(
      userId: userId ?? this.userId,
      contentRecommendations: contentRecommendations ?? this.contentRecommendations,
      adaptiveSettings: adaptiveSettings ?? this.adaptiveSettings,
      behaviorAnalysis: behaviorAnalysis ?? this.behaviorAnalysis,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'contentRecommendations': contentRecommendations.map((r) => r.toJson()).toList(),
      'adaptiveSettings': adaptiveSettings.toJson(),
      'behaviorAnalysis': behaviorAnalysis.toJson(),
      'lastAnalyzed': lastAnalyzed.toIso8601String(),
    };
  }

  factory PersonalizationProfile.fromJson(Map<String, dynamic> json) {
    return PersonalizationProfile(
      userId: json['userId'],
      contentRecommendations: (json['contentRecommendations'] as List? ?? [])
          .map((r) => ContentRecommendation.fromJson(r))
          .toList(),
      adaptiveSettings: AdaptiveSettings.fromJson(json['adaptiveSettings'] ?? {}),
      behaviorAnalysis: BehaviorAnalysis.fromJson(json['behaviorAnalysis'] ?? {}),
      lastAnalyzed: DateTime.parse(json['lastAnalyzed']),
    );
  }
}

/// Content recommendation with scoring
class ContentRecommendation {
  final String contentId;
  final String title;
  final String description;
  final double score;
  final String reason;
  final ContentFormat contentType;

  const ContentRecommendation({
    required this.contentId,
    required this.title,
    required this.description,
    required this.score,
    required this.reason,
    required this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'title': title,
      'description': description,
      'score': score,
      'reason': reason,
      'contentType': contentType.toString(),
    };
  }

  factory ContentRecommendation.fromJson(Map<String, dynamic> json) {
    return ContentRecommendation(
      contentId: json['contentId'],
      title: json['title'],
      description: json['description'],
      score: json['score']?.toDouble() ?? 0.0,
      reason: json['reason'],
      contentType: ContentFormat.values.firstWhere(
        (e) => e.toString() == json['contentType'],
        orElse: () => ContentFormat.mixed,
      ),
    );
  }
}

/// Adaptive settings based on user behavior
class AdaptiveSettings {
  final double sessionLengthMultiplier;
  final double difficultyMultiplier;
  final bool autoSkipEnabled;
  final bool reminderAdaptation;

  const AdaptiveSettings({
    this.sessionLengthMultiplier = 1.0,
    this.difficultyMultiplier = 1.0,
    this.autoSkipEnabled = false,
    this.reminderAdaptation = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionLengthMultiplier': sessionLengthMultiplier,
      'difficultyMultiplier': difficultyMultiplier,
      'autoSkipEnabled': autoSkipEnabled,
      'reminderAdaptation': reminderAdaptation,
    };
  }

  factory AdaptiveSettings.fromJson(Map<String, dynamic> json) {
    return AdaptiveSettings(
      sessionLengthMultiplier: json['sessionLengthMultiplier']?.toDouble() ?? 1.0,
      difficultyMultiplier: json['difficultyMultiplier']?.toDouble() ?? 1.0,
      autoSkipEnabled: json['autoSkipEnabled'] ?? false,
      reminderAdaptation: json['reminderAdaptation'] ?? true,
    );
  }
}

/// Analysis of user behavior patterns
class BehaviorAnalysis {
  final Map<String, int> topicInteractions;
  final Map<String, double> completionRates;
  final Map<String, Duration> sessionLengths;
  final DateTime lastAnalysis;

  const BehaviorAnalysis({
    this.topicInteractions = const {},
    this.completionRates = const {},
    this.sessionLengths = const {},
    DateTime? lastAnalysis,
  }) : lastAnalysis = lastAnalysis ?? const Duration().inMilliseconds == 0 ? DateTime.now() : DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'topicInteractions': topicInteractions,
      'completionRates': completionRates,
      'sessionLengths': sessionLengths.map((k, v) => MapEntry(k, v.inMinutes)),
      'lastAnalysis': lastAnalysis.toIso8601String(),
    };
  }

  factory BehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    return BehaviorAnalysis(
      topicInteractions: Map<String, int>.from(json['topicInteractions'] ?? {}),
      completionRates: Map<String, double>.from(json['completionRates'] ?? {}),
      sessionLengths: (json['sessionLengths'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, Duration(minutes: v ?? 0))),
      lastAnalysis: DateTime.parse(json['lastAnalysis'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Behavior tracking event
class BehaviorEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  BehaviorEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Learning style enumeration
enum LearningStyle {
  visual,
  auditory,
  kinesthetic,
  mixed,
}

/// Difficulty level enumeration
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Content format enumeration
enum ContentFormat {
  text,
  audio,
  video,
  interactive,
  visual,
  mixed,
}

/// Time of day preferences
enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night,
}

/// Accessibility settings
class AccessibilitySettings {
  final bool highContrast;
  final bool largeText;
  final bool screenReader;
  final bool reducedMotion;

  const AccessibilitySettings({
    this.highContrast = false,
    this.largeText = false,
    this.screenReader = false,
    this.reducedMotion = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'highContrast': highContrast,
      'largeText': largeText,
      'screenReader': screenReader,
      'reducedMotion': reducedMotion,
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      highContrast: json['highContrast'] ?? false,
      largeText: json['largeText'] ?? false,
      screenReader: json['screenReader'] ?? false,
      reducedMotion: json['reducedMotion'] ?? false,
    );
  }
}
