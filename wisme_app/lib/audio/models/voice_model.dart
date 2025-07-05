/// Model for ElevenLabs voice data
library;

class ElevenLabsVoice {
  final String voiceId;
  final String name;
  final String description;
  final String category;
  final String? previewUrl;
  final Map<String, dynamic> settings;
  final bool isAvailable;

  ElevenLabsVoice({
    required this.voiceId,
    required this.name,
    required this.description,
    this.category = 'general',
    this.previewUrl,
    this.settings = const {},
    this.isAvailable = true,
  });

  factory ElevenLabsVoice.fromJson(Map<String, dynamic> json) {
    return ElevenLabsVoice(
      voiceId: json['voice_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      previewUrl: json['preview_url'],
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      isAvailable: json['available_for_tiers']?.contains('free') ?? true,
    );
  }

  factory ElevenLabsVoice.fromMap(Map<String, dynamic> data) {
    return ElevenLabsVoice(
      voiceId: data['voiceId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'general',
      previewUrl: data['previewUrl'],
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'voice_id': voiceId,
        'name': name,
        'description': description,
        'category': category,
        'preview_url': previewUrl,
        'settings': settings,
        'available_for_tiers': isAvailable ? ['free'] : [],
      };

  Map<String, dynamic> toMap() => {
        'voiceId': voiceId,
        'name': name,
        'description': description,
        'category': category,
        'previewUrl': previewUrl,
        'settings': settings,
        'isAvailable': isAvailable,
      };

  ElevenLabsVoice copyWith({
    String? voiceId,
    String? name,
    String? description,
    String? category,
    String? previewUrl,
    Map<String, dynamic>? settings,
    bool? isAvailable,
  }) {
    return ElevenLabsVoice(
      voiceId: voiceId ?? this.voiceId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      previewUrl: previewUrl ?? this.previewUrl,
      settings: settings ?? this.settings,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevenLabsVoice && other.voiceId == voiceId;
  }

  @override
  int get hashCode => voiceId.hashCode;

  @override
  String toString() {
    return 'ElevenLabsVoice(voiceId: $voiceId, name: $name, category: $category)';
  }
}
