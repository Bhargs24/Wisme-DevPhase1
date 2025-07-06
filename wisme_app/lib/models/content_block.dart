import '../shared/models/base_model.dart';

/// Represents a modular audio content block in the Wisme learning system
/// These are reusable audio segments that can be combined into lessons
class ContentBlock extends BaseModel {
  /// Unique identifier for this content block
  final String id;
  
  /// Human-readable title of the content
  final String title;
  
  /// Detailed description of what this block covers
  final String description;
  
  /// Duration of the audio content
  final Duration duration;
  
  /// URL/path to the audio file
  final String audioUrl;
  
  /// Local file path if downloaded for offline use
  final String? localAudioPath;
  
  /// Main category this content belongs to
  final String category;
  
  /// Knowledge level (Fundamentals, Case Studies, etc.)
  final String knowledgeLevel;
  
  /// Tags for content matching and retrieval
  final List<String> tags;
  
  /// Content type (intro, case-study, actionable, summary, etc.)
  final String contentType;
  
  /// Difficulty level (1-5)
  final int difficultyLevel;
  
  /// Coach personality that narrates this content
  final String coachPersonality;
  
  /// Voice ID used for TTS generation
  final String voiceId;
  
  /// Script/transcript of the audio content
  final String transcript;
  
  /// Keywords for search and matching
  final List<String> keywords;
  
  /// Prerequisites needed before this content
  final List<String> prerequisites;
  
  /// What the user will learn from this block
  final List<String> learningOutcomes;
  
  /// Usage statistics
  final int playCount;
  final double averageRating;
  final DateTime lastPlayed;
  
  /// Creation and update metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  
  /// Whether this content is available offline
  final bool isDownloaded;
  
  /// File size information
  final int fileSizeBytes;
  
  /// Additional metadata for personalization
  final Map<String, dynamic> metadata;

  const ContentBlock({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.audioUrl,
    this.localAudioPath,
    required this.category,
    required this.knowledgeLevel,
    required this.tags,
    required this.contentType,
    required this.difficultyLevel,
    required this.coachPersonality,
    required this.voiceId,
    required this.transcript,
    required this.keywords,
    required this.prerequisites,
    required this.learningOutcomes,
    this.playCount = 0,
    this.averageRating = 0.0,
    required this.lastPlayed,
    required this.createdAt,
    required this.updatedAt,
    this.isDownloaded = false,
    this.fileSizeBytes = 0,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    duration,
    audioUrl,
    localAudioPath,
    category,
    knowledgeLevel,
    tags,
    contentType,
    difficultyLevel,
    coachPersonality,
    voiceId,
    transcript,
    keywords,
    prerequisites,
    learningOutcomes,
    playCount,
    averageRating,
    lastPlayed,
    createdAt,
    updatedAt,
    isDownloaded,
    fileSizeBytes,
    metadata,
  ];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration.inSeconds,
      'audioUrl': audioUrl,
      'localAudioPath': localAudioPath,
      'category': category,
      'knowledgeLevel': knowledgeLevel,
      'tags': tags,
      'contentType': contentType,
      'difficultyLevel': difficultyLevel,
      'coachPersonality': coachPersonality,
      'voiceId': voiceId,
      'transcript': transcript,
      'keywords': keywords,
      'prerequisites': prerequisites,
      'learningOutcomes': learningOutcomes,
      'playCount': playCount,
      'averageRating': averageRating,
      'lastPlayed': lastPlayed.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDownloaded': isDownloaded,
      'fileSizeBytes': fileSizeBytes,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      audioUrl: json['audioUrl'] ?? '',
      localAudioPath: json['localAudioPath'],
      category: json['category'] ?? '',
      knowledgeLevel: json['knowledgeLevel'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      contentType: json['contentType'] ?? 'general',
      difficultyLevel: json['difficultyLevel'] ?? 1,
      coachPersonality: json['coachPersonality'] ?? 'kai',
      voiceId: json['voiceId'] ?? 'default',
      transcript: json['transcript'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      learningOutcomes: List<String>.from(json['learningOutcomes'] ?? []),
      playCount: json['playCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      lastPlayed: DateTime.parse(json['lastPlayed'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isDownloaded: json['isDownloaded'] ?? false,
      fileSizeBytes: json['fileSizeBytes'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Copy with modifications
  ContentBlock copyWith({
    String? id,
    String? title,
    String? description,
    Duration? duration,
    String? audioUrl,
    String? localAudioPath,
    String? category,
    String? knowledgeLevel,
    List<String>? tags,
    String? contentType,
    int? difficultyLevel,
    String? coachPersonality,
    String? voiceId,
    String? transcript,
    List<String>? keywords,
    List<String>? prerequisites,
    List<String>? learningOutcomes,
    int? playCount,
    double? averageRating,
    DateTime? lastPlayed,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDownloaded,
    int? fileSizeBytes,
    Map<String, dynamic>? metadata,
  }) {
    return ContentBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      category: category ?? this.category,
      knowledgeLevel: knowledgeLevel ?? this.knowledgeLevel,
      tags: tags ?? this.tags,
      contentType: contentType ?? this.contentType,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      coachPersonality: coachPersonality ?? this.coachPersonality,
      voiceId: voiceId ?? this.voiceId,
      transcript: transcript ?? this.transcript,
      keywords: keywords ?? this.keywords,
      prerequisites: prerequisites ?? this.prerequisites,
      learningOutcomes: learningOutcomes ?? this.learningOutcomes,
      playCount: playCount ?? this.playCount,
      averageRating: averageRating ?? this.averageRating,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get formatted duration string
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if content matches given tags
  bool matchesTags(List<String> searchTags) {
    return searchTags.any((tag) => 
      tags.contains(tag.toLowerCase()) || 
      keywords.contains(tag.toLowerCase()) ||
      title.toLowerCase().contains(tag.toLowerCase())
    );
  }

  /// Get difficulty emoji
  String get difficultyEmoji {
    switch (difficultyLevel) {
      case 1: return '🟢';
      case 2: return '🟡';
      case 3: return '🟠';
      case 4: return '🔴';
      case 5: return '⚫';
      default: return '⚪';
    }
  }

  /// Get content type emoji
  String get contentTypeEmoji {
    const typeMap = {
      'intro': '🎯',
      'case-study': '💼',
      'theory': '📚',
      'practical': '🛠',
      'summary': '📝',
      'actionable': '⚡',
      'story': '📖',
      'interview': '🎤',
    };
    
    return typeMap[contentType.toLowerCase()] ?? '🎓';
  }

  /// Get audio file path (local if available, otherwise URL)
  String get effectiveAudioPath => isDownloaded && localAudioPath != null ? localAudioPath! : audioUrl;

  /// Topic/subject matter (for backward compatibility)
  String get topic => category;
  
  /// Script content (alias for transcript)
  String get script => transcript;

  /// Check if this content block is ready to play
  bool get isPlayable => audioUrl.isNotEmpty || (isDownloaded && localAudioPath != null);
}
