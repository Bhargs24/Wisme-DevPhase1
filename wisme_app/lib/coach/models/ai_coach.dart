/// AI Coach model representing intelligent tutoring system
class AICoach {
  final String id;
  final String name;
  final String description;
  final CoachType type;
  final List<String> specializations;
  final CoachPersonality personality;
  final Map<String, dynamic> configuration;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;
  final Map<String, dynamic> metadata;

  const AICoach({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.specializations,
    required this.personality,
    required this.configuration,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'specializations': specializations,
    'personality': personality.toJson(),
    'configuration': configuration,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'avatarUrl': avatarUrl,
    'metadata': metadata,
  };

  factory AICoach.fromJson(Map<String, dynamic> json) => AICoach(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    type: CoachType.values.byName(json['type'] as String),
    specializations: List<String>.from(json['specializations'] as List),
    personality: CoachPersonality.fromJson(json['personality'] as Map<String, dynamic>),
    configuration: json['configuration'] as Map<String, dynamic>,
    isActive: json['isActive'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    avatarUrl: json['avatarUrl'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  AICoach copyWith({
    String? name,
    String? description,
    CoachType? type,
    List<String>? specializations,
    CoachPersonality? personality,
    Map<String, dynamic>? configuration,
    bool? isActive,
    DateTime? updatedAt,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) => AICoach(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    type: type ?? this.type,
    specializations: specializations ?? this.specializations,
    personality: personality ?? this.personality,
    configuration: configuration ?? this.configuration,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    avatarUrl: avatarUrl ?? this.avatarUrl,
    metadata: metadata ?? this.metadata,
  );
}

enum CoachType {
  mentor,
  tutor,
  motivator,
  assessor,
  companion,
  specialist,
}

class CoachPersonality {
  final String tone;
  final String style;
  final double formality;
  final double encouragement;
  final double directness;
  final double patience;
  final List<String> characteristics;

  const CoachPersonality({
    required this.tone,
    required this.style,
    required this.formality,
    required this.encouragement,
    required this.directness,
    required this.patience,
    required this.characteristics,
  });

  Map<String, dynamic> toJson() => {
    'tone': tone,
    'style': style,
    'formality': formality,
    'encouragement': encouragement,
    'directness': directness,
    'patience': patience,
    'characteristics': characteristics,
  };

  factory CoachPersonality.fromJson(Map<String, dynamic> json) => CoachPersonality(
    tone: json['tone'] as String,
    style: json['style'] as String,
    formality: (json['formality'] as num).toDouble(),
    encouragement: (json['encouragement'] as num).toDouble(),
    directness: (json['directness'] as num).toDouble(),
    patience: (json['patience'] as num).toDouble(),
    characteristics: List<String>.from(json['characteristics'] as List),
  );

  CoachPersonality copyWith({
    String? tone,
    String? style,
    double? formality,
    double? encouragement,
    double? directness,
    double? patience,
    List<String>? characteristics,
  }) => CoachPersonality(
    tone: tone ?? this.tone,
    style: style ?? this.style,
    formality: formality ?? this.formality,
    encouragement: encouragement ?? this.encouragement,
    directness: directness ?? this.directness,
    patience: patience ?? this.patience,
    characteristics: characteristics ?? this.characteristics,
  );
}
