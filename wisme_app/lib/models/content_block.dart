import '../core/exports.dart';
import 'dart:io';
class ContentBlock {
  final String id;
  final String title;
  final String description;
  final Duration duration;
  final String audioUrl;
  final String? localAudioPath;
  final String category;
  final String knowledgeLevel;
  final List<String> tags;
  final String contentType;
  final int difficultyLevel;
  final String coachPersonality;
  final String voiceId;
  final String transcript;
  final List<String> keywords;
  final List<String> prerequisites;
  final List<String> learningOutcomes;
  final int playCount;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDownloaded;
  final int fileSizeBytes;
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
    required this.createdAt,
    required this.updatedAt,
    this.isDownloaded = false,
    this.fileSizeBytes = 0,
    this.metadata = const {},
  });

  /// Create from JSON
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: Duration(seconds: json['duration_seconds']),
      audioUrl: json['audio_url'],
      localAudioPath: json['local_audio_path'],
      category: json['category'],
      knowledgeLevel: json['knowledge_level'],
      tags: List<String>.from(json['tags']),
      contentType: json['content_type'],
      difficultyLevel: json['difficulty_level'],
      coachPersonality: json['coach_personality'],
      voiceId: json['voice_id'],
      transcript: json['transcript'],
      keywords: List<String>.from(json['keywords']),
      prerequisites: List<String>.from(json['prerequisites']),
      learningOutcomes: List<String>.from(json['learning_outcomes']),
      playCount: json['play_count'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDownloaded: json['is_downloaded'] ?? false,
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      metadata: json['metadata'] ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_seconds': duration.inSeconds,
      'audio_url': audioUrl,
      'local_audio_path': localAudioPath,
      'category': category,
      'knowledge_level': knowledgeLevel,
      'tags': tags,
      'content_type': contentType,
      'difficulty_level': difficultyLevel,
      'coach_personality': coachPersonality,
      'voice_id': voiceId,
      'transcript': transcript,
      'keywords': keywords,
      'prerequisites': prerequisites,
      'learning_outcomes': learningOutcomes,
      'play_count': playCount,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_downloaded': isDownloaded,
      'file_size_bytes': fileSizeBytes,
      'metadata': metadata,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDownloaded': isDownloaded,
      'fileSizeBytes': fileSizeBytes,
      'metadata': metadata,
    };
  }

  /// Create from Firestore document
  static ContentBlock fromFirestore(Map<String, dynamic> doc) {
    return ContentBlock(
      id: doc['id'] ?? '',
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      duration: Duration(seconds: doc['duration'] ?? 0),
      audioUrl: doc['audioUrl'] ?? '',
      localAudioPath: doc['localAudioPath'],
      category: doc['category'] ?? '',
      knowledgeLevel: doc['knowledgeLevel'] ?? '',
      tags: List<String>.from(doc['tags'] ?? []),
      contentType: doc['contentType'] ?? '',
      difficultyLevel: doc['difficultyLevel'] ?? 1,
      coachPersonality: doc['coachPersonality'] ?? '',
      voiceId: doc['voiceId'] ?? '',
      transcript: doc['transcript'] ?? '',
      keywords: List<String>.from(doc['keywords'] ?? []),
      prerequisites: List<String>.from(doc['prerequisites'] ?? []),
      learningOutcomes: List<String>.from(doc['learningOutcomes'] ?? []),
      playCount: doc['playCount'] ?? 0,
      averageRating: (doc['averageRating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(doc['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(doc['updatedAt'] ?? DateTime.now().toIso8601String()),
      isDownloaded: doc['isDownloaded'] ?? false,
      fileSizeBytes: doc['fileSizeBytes'] ?? 0,
      metadata: Map<String, dynamic>.from(doc['metadata'] ?? {}),
    );
  }

  /// Create copy with modifications
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      metadata: metadata ?? this.metadata,
    );
  }

  // Business Logic Methods

  /// Get formatted duration display (e.g., "12:34")
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if content matches given tags
  bool matchesTags(List<String> searchTags) {
    if (searchTags.isEmpty) return true;
    return searchTags.any((tag) => 
      tags.contains(tag) || 
      keywords.contains(tag.toLowerCase()) ||
      category.toLowerCase().contains(tag.toLowerCase())
    );
  }

  /// Check if content is playable (has audio source)
  bool get isPlayable {
    if (isDownloaded && localAudioPath != null) {
      return File(localAudioPath!).existsSync();
    }
    return audioUrl.isNotEmpty;
  }

  /// Get effective audio source (local if available, otherwise remote)
  String get effectiveAudioSource {
    if (isDownloaded && localAudioPath != null && File(localAudioPath!).existsSync()) {
      return localAudioPath!;
    }
    return audioUrl;
  }

  /// Get content type display with icon
  String get contentTypeDisplay {
    switch (contentType.toLowerCase()) {
      case 'intro':
        return '🎯 Introduction';
      case 'case-study':
        return '📊 Case Study';
      case 'actionable':
        return '⚡ Actionable Tips';
      case 'summary':
        return '📝 Summary';
      case 'deep-dive':
        return '🔍 Deep Dive';
      case 'interview':
        return '🎤 Interview';
      case 'story':
        return '📖 Story';
      default:
        return '🎧 Content';
    }
  }

  /// Get difficulty level display
  String get difficultyDisplay {
    switch (difficultyLevel) {
      case 1:
        return '⭐ Beginner';
      case 2:
        return '⭐⭐ Easy';
      case 3:
        return '⭐⭐⭐ Moderate';
      case 4:
        return '⭐⭐⭐⭐ Advanced';
      case 5:
        return '⭐⭐⭐⭐⭐ Expert';
      default:
        return '⭐⭐⭐ Moderate';
    }
  }

  /// Get coach personality color
  Color get coachColor {
    switch (coachPersonality.toLowerCase()) {
      case 'kai':
        return const Color(0xFF6366F1); // Strategic blue
      case 'vee':
        return const Color(0xFF10B981); // Energetic green
      case 'sage':
        return const Color(0xFF8B5CF6); // Wise purple
      case 'spark':
        return const Color(0xFFF59E0B); // Creative orange
      default:
        return const Color(0xFF6B7280); // Neutral gray
    }
  }

  /// Get file size display (e.g., "2.5 MB")
  String get fileSizeDisplay {
    if (fileSizeBytes == 0) return 'Unknown';
    
    if (fileSizeBytes < 1024) {
      return '${fileSizeBytes}B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// Check if content is suitable for user's knowledge level
  bool isSuitableForLevel(String userKnowledgeLevel) {
    final levelMap = {
      'beginner': 1,
      'intermediate': 3,
      'advanced': 5,
    };
    
    final userLevel = levelMap[userKnowledgeLevel.toLowerCase()] ?? 3;
    return (difficultyLevel - userLevel).abs() <= 1;
  }

  /// Get estimated reading time for transcript
  int get estimatedReadingMinutes {
    const wordsPerMinute = 200;
    final wordCount = transcript.split(' ').length;
    return (wordCount / wordsPerMinute).ceil();
  }

  /// Check if content has been recently updated
  bool get isRecentlyUpdated {
    final daysSinceUpdate = DateTime.now().difference(updatedAt).inDays;
    return daysSinceUpdate <= 7;
  }

  /// Get popularity score based on plays and rating
  double get popularityScore {
    return (playCount * 0.7) + (averageRating * 0.3 * 100);
  }

  @override
  String toString() {
    return 'ContentBlock(id: $id, title: $title, duration: $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentBlock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

