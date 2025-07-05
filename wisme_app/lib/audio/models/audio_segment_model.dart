import 'dart:typed_data';
import '../../shared/models/base_model.dart';

/// Represents an audio segment with processing metadata
class AudioSegment extends BaseModel {
  final String contentId;
  final String voiceId;
  final String script;
  final Uint8List audioData;
  final Duration duration;
  final String audioFormat;
  final Map<String, dynamic> processingMetadata;

  const AudioSegment({
    required super.id,
    required this.contentId,
    required this.voiceId,
    required this.script,
    required this.audioData,
    required this.duration,
    this.audioFormat = 'mp3',
    this.processingMetadata = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'contentId': contentId,
        'voiceId': voiceId,
        'script': script,
        'audioData': audioData,
        'duration': duration.inMilliseconds,
        'audioFormat': audioFormat,
        'processingMetadata': processingMetadata,
      };

  factory AudioSegment.fromJson(Map<String, dynamic> json) => AudioSegment(
        id: json['id'] as String,
        contentId: json['contentId'] as String,
        voiceId: json['voiceId'] as String,
        script: json['script'] as String,
        audioData: json['audioData'] as Uint8List,
        duration: Duration(milliseconds: json['duration'] as int),
        audioFormat: json['audioFormat'] as String? ?? 'mp3',
        processingMetadata: json['processingMetadata'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  AudioSegment copyWith({
    String? id,
    String? contentId,
    String? voiceId,
    String? script,
    Uint8List? audioData,
    Duration? duration,
    String? audioFormat,
    Map<String, dynamic>? processingMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AudioSegment(
        id: id ?? this.id,
        contentId: contentId ?? this.contentId,
        voiceId: voiceId ?? this.voiceId,
        script: script ?? this.script,
        audioData: audioData ?? this.audioData,
        duration: duration ?? this.duration,
        audioFormat: audioFormat ?? this.audioFormat,
        processingMetadata: processingMetadata ?? this.processingMetadata,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// Represents an audio transition between segments
class AudioTransition extends BaseModel {
  final String type;
  final Duration duration;
  final Uint8List audioData;
  final Map<String, dynamic> effects;

  const AudioTransition({
    required super.id,
    required this.type,
    required this.duration,
    required this.audioData,
    this.effects = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': type,
        'duration': duration.inMilliseconds,
        'audioData': audioData,
        'effects': effects,
      };

  factory AudioTransition.fromJson(Map<String, dynamic> json) => AudioTransition(
        id: json['id'] as String,
        type: json['type'] as String,
        duration: Duration(milliseconds: json['duration'] as int),
        audioData: json['audioData'] as Uint8List,
        effects: json['effects'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  AudioTransition copyWith({
    String? id,
    String? type,
    Duration? duration,
    Uint8List? audioData,
    Map<String, dynamic>? effects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      AudioTransition(
        id: id ?? this.id,
        type: type ?? this.type,
        duration: duration ?? this.duration,
        audioData: audioData ?? this.audioData,
        effects: effects ?? this.effects,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
