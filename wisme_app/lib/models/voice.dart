/// Industrial-grade Voice model for ElevenLabs voice synthesis
class Voice {
  final String id;
  final String name;
  final String description;
  final VoiceGender gender;
  final VoiceAccent accent;
  final VoiceAge ageRange;
  final Map<String, double> settings;
  final List<String> categories;
  final bool isAvailable;
  final bool isPremium;
  final String? previewUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double qualityScore;
  final List<String> supportedLanguages;
  final VoiceType type;
  final String? coachId;

  const Voice({
    required this.id,
    required this.name,
    required this.description,
    required this.gender,
    required this.accent,
    required this.ageRange,
    this.settings = const {},
    this.categories = const [],
    this.isAvailable = true,
    this.isPremium = false,
    this.previewUrl,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.qualityScore = 1.0,
    this.supportedLanguages = const ['en'],
    this.type = VoiceType.synthetic,
    this.coachId,
  });

  /// Create from ElevenLabs API response
  factory Voice.fromElevenLabsAPI(Map<String, dynamic> apiData) {
    return Voice(
      id: apiData['voice_id'],
      name: apiData['name'],
      description: apiData['description'] ?? '',
      gender: _parseGender(apiData['labels']?['gender']),
      accent: _parseAccent(apiData['labels']?['accent']),
      ageRange: _parseAge(apiData['labels']?['age']),
      settings: {
        'stability': apiData['settings']?['stability'] ?? 0.75,
        'similarity_boost': apiData['settings']?['similarity_boost'] ?? 0.75,
        'style': apiData['settings']?['style'] ?? 0.0,
        'use_speaker_boost': apiData['settings']?['use_speaker_boost'] ?? true,
      },
      categories: List<String>.from(apiData['category'] != null ? [apiData['category']] : []),
      isAvailable: apiData['available_for_tiers']?.contains('free') ?? false,
      isPremium: !(apiData['available_for_tiers']?.contains('free') ?? false),
      previewUrl: apiData['preview_url'],
      metadata: apiData,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      qualityScore: (apiData['fine_tuning']?['is_allowed_to_fine_tune'] == true) ? 1.0 : 0.8,
      supportedLanguages: List<String>.from(apiData['labels']?['language'] != null 
          ? [apiData['labels']['language']] 
          : ['en']),
      type: VoiceType.synthetic,
    );
  }

  /// Create from JSON
  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      gender: VoiceGender.values.firstWhere(
        (e) => e.toString().split('.').last == json['gender'],
        orElse: () => VoiceGender.neutral,
      ),
      accent: VoiceAccent.values.firstWhere(
        (e) => e.toString().split('.').last == json['accent'],
        orElse: () => VoiceAccent.american,
      ),
      ageRange: VoiceAge.values.firstWhere(
        (e) => e.toString().split('.').last == json['age_range'],
        orElse: () => VoiceAge.adult,
      ),
      settings: Map<String, double>.from(json['settings'] ?? {}),
      categories: List<String>.from(json['categories'] ?? []),
      isAvailable: json['is_available'] ?? true,
      isPremium: json['is_premium'] ?? false,
      previewUrl: json['preview_url'],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      qualityScore: json['quality_score']?.toDouble() ?? 1.0,
      supportedLanguages: List<String>.from(json['supported_languages'] ?? ['en']),
      type: VoiceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => VoiceType.synthetic,
      ),
      coachId: json['coach_id'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gender': gender.toString().split('.').last,
      'accent': accent.toString().split('.').last,
      'age_range': ageRange.toString().split('.').last,
      'settings': settings,
      'categories': categories,
      'is_available': isAvailable,
      'is_premium': isPremium,
      'preview_url': previewUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'quality_score': qualityScore,
      'supported_languages': supportedLanguages,
      'type': type.toString().split('.').last,
      'coach_id': coachId,
    };
  }

  /// Copy with modifications
  Voice copyWith({
    String? id,
    String? name,
    String? description,
    VoiceGender? gender,
    VoiceAccent? accent,
    VoiceAge? ageRange,
    Map<String, double>? settings,
    List<String>? categories,
    bool? isAvailable,
    bool? isPremium,
    String? previewUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? qualityScore,
    List<String>? supportedLanguages,
    VoiceType? type,
    String? coachId,
  }) {
    return Voice(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      gender: gender ?? this.gender,
      accent: accent ?? this.accent,
      ageRange: ageRange ?? this.ageRange,
      settings: settings ?? this.settings,
      categories: categories ?? this.categories,
      isAvailable: isAvailable ?? this.isAvailable,
      isPremium: isPremium ?? this.isPremium,
      previewUrl: previewUrl ?? this.previewUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      qualityScore: qualityScore ?? this.qualityScore,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      type: type ?? this.type,
      coachId: coachId ?? this.coachId,
    );
  }

  // Helper methods for parsing ElevenLabs data
  static VoiceGender _parseGender(String? gender) {
    if (gender == null) return VoiceGender.neutral;
    switch (gender.toLowerCase()) {
      case 'male':
        return VoiceGender.male;
      case 'female':
        return VoiceGender.female;
      default:
        return VoiceGender.neutral;
    }
  }

  static VoiceAccent _parseAccent(String? accent) {
    if (accent == null) return VoiceAccent.american;
    switch (accent.toLowerCase()) {
      case 'american':
        return VoiceAccent.american;
      case 'british':
        return VoiceAccent.british;
      case 'australian':
        return VoiceAccent.australian;
      case 'indian':
        return VoiceAccent.indian;
      default:
        return VoiceAccent.american;
    }
  }

  static VoiceAge _parseAge(String? age) {
    if (age == null) return VoiceAge.adult;
    switch (age.toLowerCase()) {
      case 'young':
        return VoiceAge.young;
      case 'middle aged':
      case 'middle_aged':
        return VoiceAge.middleAged;
      case 'old':
        return VoiceAge.elderly;
      default:
        return VoiceAge.adult;
    }
  }

  // Business Logic Methods

  /// Check if voice is suitable for coach personality
  bool isSuitableForCoach(String coachPersonality) {
    switch (coachPersonality.toLowerCase()) {
      case 'kai':
      case 'strategic':
        return gender == VoiceGender.male && 
               ageRange == VoiceAge.adult &&
               qualityScore >= 0.8;
      case 'vee':
      case 'energetic':
        return gender == VoiceGender.female && 
               (ageRange == VoiceAge.young || ageRange == VoiceAge.adult) &&
               qualityScore >= 0.8;
      default:
        return qualityScore >= 0.7;
    }
  }

  /// Get optimal settings for content type
  Map<String, double> getOptimalSettings(String contentType) {
    final baseSettings = Map<String, double>.from(settings);
    
    switch (contentType.toLowerCase()) {
      case 'educational':
      case 'lesson':
        return {
          ...baseSettings,
          'stability': 0.8,
          'similarity_boost': 0.7,
          'style': 0.1,
        };
      case 'motivational':
      case 'energetic':
        return {
          ...baseSettings,
          'stability': 0.6,
          'similarity_boost': 0.8,
          'style': 0.3,
        };
      case 'calm':
      case 'meditation':
        return {
          ...baseSettings,
          'stability': 0.9,
          'similarity_boost': 0.6,
          'style': 0.0,
        };
      default:
        return baseSettings;
    }
  }

  /// Get display name with accent info
  String get displayName {
    final accentSuffix = accent != VoiceAccent.american ? ' (${accent.displayName})' : '';
    return '$name$accentSuffix';
  }

  /// Check if voice supports language
  bool supportsLanguage(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Voice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Voice{id: $id, name: $name, gender: $gender, accent: $accent}';
  }
}

/// Voice gender enumeration
enum VoiceGender {
  male,
  female,
  neutral,
}

/// Voice accent enumeration
enum VoiceAccent {
  american,
  british,
  australian,
  indian,
  canadian,
  other,
}

/// Voice age range enumeration
enum VoiceAge {
  young,      // 18-30
  adult,      // 30-50
  middleAged, // 50-65
  elderly,    // 65+
}

/// Voice type enumeration
enum VoiceType {
  synthetic,  // AI-generated voice
  cloned,     // Cloned from real person
  custom,     // User-created voice
}

/// Extension methods for enum display
extension VoiceAccentExtension on VoiceAccent {
  String get displayName {
    switch (this) {
      case VoiceAccent.american:
        return 'American';
      case VoiceAccent.british:
        return 'British';
      case VoiceAccent.australian:
        return 'Australian';
      case VoiceAccent.indian:
        return 'Indian';
      case VoiceAccent.canadian:
        return 'Canadian';
      case VoiceAccent.other:
        return 'Other';
    }
  }
}

extension VoiceGenderExtension on VoiceGender {
  String get displayName {
    switch (this) {
      case VoiceGender.male:
        return 'Male';
      case VoiceGender.female:
        return 'Female';
      case VoiceGender.neutral:
        return 'Neutral';
    }
  }
}

extension VoiceAgeExtension on VoiceAge {
  String get displayName {
    switch (this) {
      case VoiceAge.young:
        return 'Young Adult';
      case VoiceAge.adult:
        return 'Adult';
      case VoiceAge.middleAged:
        return 'Middle Aged';
      case VoiceAge.elderly:
        return 'Elderly';
    }
  }
}

/// Predefined voices for Wisme coaches
class WismeVoices {
  static Voice get kaiVoice => Voice(
    id: '21m00Tcm4TlvDq8ikWAM',
    name: 'Kai',
    description: 'Strategic and analytical coach voice',
    gender: VoiceGender.male,
    accent: VoiceAccent.american,
    ageRange: VoiceAge.adult,
    settings: const {
      'stability': 0.8,
      'similarity_boost': 0.7,
      'style': 0.1,
    },
    categories: const ['educational', 'business', 'technology'],
    isAvailable: true,
    isPremium: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    qualityScore: 0.95,
    supportedLanguages: const ['en'],
    type: VoiceType.synthetic,
    coachId: 'kai',
  );

  static Voice get veeVoice => Voice(
    id: 'EXAVITQu4vr4xnSDxMaL',
    name: 'Vee',
    description: 'Energetic and encouraging coach voice',
    gender: VoiceGender.female,
    accent: VoiceAccent.american,
    ageRange: VoiceAge.young,
    settings: const {
      'stability': 0.6,
      'similarity_boost': 0.8,
      'style': 0.3,
    },
    categories: const ['motivational', 'lifestyle', 'wellness'],
    isAvailable: true,
    isPremium: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    qualityScore: 0.93,
    supportedLanguages: const ['en'],
    type: VoiceType.synthetic,
    coachId: 'vee',
  );
}
