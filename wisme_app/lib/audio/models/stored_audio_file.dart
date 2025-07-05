/// Crystal clear model for audio files stored in the cloud
/// Replaces the confusing "CachedAudio" with precise naming
class StoredAudioFile {
  final String id;
  final String topicHash;
  final String originalTopic;
  final String coachVoice;
  final String cloudUrl;
  final String? localCachePath;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;
  final int durationSeconds;
  final int fileSizeBytes;
  final int accessCount;
  final StoredAudioStatus status;
  final List<String> hashtags;
  final Map<String, dynamic> metadata;

  const StoredAudioFile({
    required this.id,
    required this.topicHash,
    required this.originalTopic,
    required this.coachVoice,
    required this.cloudUrl,
    this.localCachePath,
    required this.createdAt,
    this.lastAccessedAt,
    required this.durationSeconds,
    required this.fileSizeBytes,
    this.accessCount = 0,
    this.status = StoredAudioStatus.available,
    this.hashtags = const [],
    this.metadata = const {},
  });

  factory StoredAudioFile.fromJson(Map<String, dynamic> json) {
    return StoredAudioFile(
      id: json['id'] as String,
      topicHash: json['topicHash'] as String,
      originalTopic: json['originalTopic'] as String,
      coachVoice: json['coachVoice'] as String,
      cloudUrl: json['cloudUrl'] as String,
      localCachePath: json['localCachePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: json['lastAccessedAt'] != null 
          ? DateTime.parse(json['lastAccessedAt'] as String) 
          : null,
      durationSeconds: json['durationSeconds'] as int,
      fileSizeBytes: json['fileSizeBytes'] as int,
      accessCount: json['accessCount'] as int? ?? 0,
      status: StoredAudioStatus.values.byName(json['status'] as String? ?? 'available'),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicHash': topicHash,
      'originalTopic': originalTopic,
      'coachVoice': coachVoice,
      'cloudUrl': cloudUrl,
      'localCachePath': localCachePath,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'accessCount': accessCount,
      'status': status.name,
      'hashtags': hashtags,
      'metadata': metadata,
    };
  }

  StoredAudioFile copyWith({
    String? id,
    String? topicHash,
    String? originalTopic,
    String? coachVoice,
    String? cloudUrl,
    String? localCachePath,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    int? durationSeconds,
    int? fileSizeBytes,
    int? accessCount,
    StoredAudioStatus? status,
    List<String>? hashtags,
    Map<String, dynamic>? metadata,
  }) {
    return StoredAudioFile(
      id: id ?? this.id,
      topicHash: topicHash ?? this.topicHash,
      originalTopic: originalTopic ?? this.originalTopic,
      coachVoice: coachVoice ?? this.coachVoice,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      localCachePath: localCachePath ?? this.localCachePath,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      accessCount: accessCount ?? this.accessCount,
      status: status ?? this.status,
      hashtags: hashtags ?? this.hashtags,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if this audio is cached locally on device
  bool get isCachedLocally => localCachePath != null;

  /// Get file size in human-readable format
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get duration in human-readable format
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Storage path for cloud storage organization
  String get cloudStoragePath => 'generated_audio/$coachVoice/${topicHash.substring(0, 8)}/$id.mp3';

  /// Check if audio is ready for playback
  bool get isPlayable => status == StoredAudioStatus.available && cloudUrl.isNotEmpty;

  /// Calculate hashtag match score with another audio file
  double hashtagSimilarity(StoredAudioFile other) {
    if (hashtags.isEmpty || other.hashtags.isEmpty) return 0.0;
    
    final commonTags = hashtags.toSet().intersection(other.hashtags.toSet());
    final totalTags = hashtags.toSet().union(other.hashtags.toSet());
    
    return commonTags.length / totalTags.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoredAudioFile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StoredAudioFile(topic: $originalTopic, coach: $coachVoice, duration: $formattedDuration, size: $formattedFileSize)';
  }
}

enum StoredAudioStatus {
  generating,
  available,
  error,
  expired,
  processing,
}
