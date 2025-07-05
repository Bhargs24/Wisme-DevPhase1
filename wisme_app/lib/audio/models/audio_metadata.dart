class AudioMetadata {
  final String title;
  final String? description;
  final Duration duration;
  final String voiceId;
  final Map<String, dynamic> generationSettings;

  const AudioMetadata({
    required this.title,
    this.description,
    required this.duration,
    required this.voiceId,
    required this.generationSettings,
  });
}
