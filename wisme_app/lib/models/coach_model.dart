class CoachModel {
  final String id;
  final String name;
  final String description;
  final String personality;
  final String voiceId;
  final Map<String, String> voiceSettings;
  final String avatarUrl;
  final List<String> specialties; // Categories this coach is best for
  final Map<String, dynamic> traits;
  final bool isCustom;
  final String? userId; // For custom coaches
  final DateTime createdAt;

  CoachModel({
    required this.id,
    required this.name,
    required this.description,
    required this.personality,
    required this.voiceId,
    this.voiceSettings = const {},
    this.avatarUrl = '',
    this.specialties = const [],
    this.traits = const {},
    this.isCustom = false,
    this.userId,
    required this.createdAt,
  });

  // Predefined coaches
  static final CoachModel kai = CoachModel(
    id: 'kai',
    name: 'Kai',
    description: 'Strategic, calm mentor-like',
    personality: 'Professional and analytical, perfect for business and technical topics. Kai breaks down complex concepts with clarity and uses real-world examples.',
    voiceId: '21m00Tcm4TlvDq8ikWAM',
    voiceSettings: {
      'stability': '0.7',
      'similarity_boost': '0.6',
      'style': '0.2',
    },
    avatarUrl: 'assets/images/kai_avatar.png',
    specialties: ['Business', 'Technology', 'Career', 'Science'],
    traits: {
      'tone': 'calm',
      'style': 'analytical',
      'pace': 'measured',
      'examples': 'business_focused',
    },
    createdAt: DateTime.now(),
  );

  static final CoachModel vee = CoachModel(
    id: 'vee',
    name: 'Vee',
    description: 'Bold, energetic friend-like',
    personality: 'Enthusiastic and creative, great for motivational and creative content. Vee makes learning fun with stories and engaging delivery.',
    voiceId: '2EiwWnXFnvU5JabPnv8n',
    voiceSettings: {
      'stability': '0.5',
      'similarity_boost': '0.8',
      'style': '0.4',
    },
    avatarUrl: 'assets/images/vee_avatar.png',
    specialties: ['Creativity', 'Self-Growth', 'Psychology', 'History'],
    traits: {
      'tone': 'energetic',
      'style': 'storytelling',
      'pace': 'dynamic',
      'examples': 'creative_focused',
    },
    createdAt: DateTime.now(),
  );

  static List<CoachModel> get predefinedCoaches => [kai, vee];

  factory CoachModel.fromMap(Map<String, dynamic> map) {
    return CoachModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      personality: map['personality'] ?? '',
      voiceId: map['voiceId'] ?? '',
      voiceSettings: Map<String, String>.from(map['voiceSettings'] ?? {}),
      avatarUrl: map['avatarUrl'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      traits: Map<String, dynamic>.from(map['traits'] ?? {}),
      isCustom: map['isCustom'] ?? false,
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'personality': personality,
      'voiceId': voiceId,
      'voiceSettings': voiceSettings,
      'avatarUrl': avatarUrl,
      'specialties': specialties,
      'traits': traits,
      'isCustom': isCustom,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CoachModel copyWith({
    String? name,
    String? description,
    String? personality,
    String? voiceId,
    Map<String, String>? voiceSettings,
    String? avatarUrl,
    List<String>? specialties,
    Map<String, dynamic>? traits,
  }) {
    return CoachModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      voiceId: voiceId ?? this.voiceId,
      voiceSettings: voiceSettings ?? this.voiceSettings,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      specialties: specialties ?? this.specialties,
      traits: traits ?? this.traits,
      isCustom: isCustom,
      userId: userId,
      createdAt: createdAt,
    );
  }

  bool isGoodForCategory(String category) {
    return specialties.contains(category);
  }

  @override
  String toString() {
    return 'CoachModel(id: $id, name: $name, description: $description)';
  }
}
