class CachedAudio {
  final String topicHash;
  final String originalTopic;
  final String coachVoice;
  final String audioUrl;
  final String? localFilePath;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;
  final int durationSeconds;
  final int fileSize;
  final int accessCount;
  final AudioStatus status;

  const CachedAudio({
    required this.topicHash,
    required this.originalTopic,
    required this.coachVoice,
    required this.audioUrl,
    this.localFilePath,
    required this.createdAt,
    this.lastAccessedAt,
    required this.durationSeconds,
    required this.fileSize,
    this.accessCount = 0,
    this.status = AudioStatus.available,
  });

  factory CachedAudio.fromJson(Map<String, dynamic> json) {
    return CachedAudio(
      topicHash: json['topicHash'] as String,
      originalTopic: json['originalTopic'] as String,
      coachVoice: json['coachVoice'] as String,
      audioUrl: json['audioUrl'] as String,
      localFilePath: json['localFilePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: json['lastAccessedAt'] != null 
          ? DateTime.parse(json['lastAccessedAt'] as String) 
          : null,
      durationSeconds: json['durationSeconds'] as int,
      fileSize: json['fileSize'] as int,
      accessCount: json['accessCount'] as int? ?? 0,
      status: AudioStatus.values.byName(json['status'] as String? ?? 'available'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topicHash': topicHash,
      'originalTopic': originalTopic,
      'coachVoice': coachVoice,
      'audioUrl': audioUrl,
      'localFilePath': localFilePath,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'fileSize': fileSize,
      'accessCount': accessCount,
      'status': status.name,
    };
  }

  CachedAudio copyWith({
    String? topicHash,
    String? originalTopic,
    String? coachVoice,
    String? audioUrl,
    String? localFilePath,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    int? durationSeconds,
    int? fileSize,
    int? accessCount,
    AudioStatus? status,
  }) {
    return CachedAudio(
      topicHash: topicHash ?? this.topicHash,
      originalTopic: originalTopic ?? this.originalTopic,
      coachVoice: coachVoice ?? this.coachVoice,
      audioUrl: audioUrl ?? this.audioUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSize: fileSize ?? this.fileSize,
      accessCount: accessCount ?? this.accessCount,
      status: status ?? this.status,
    );
  }

  /// Check if this audio is cached locally
  bool get isCachedLocally => localFilePath != null;

  /// Get file size in a human-readable format
  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get duration in a human-readable format
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CachedAudio && other.topicHash == topicHash;
  }

  @override
  int get hashCode => topicHash.hashCode;

  @override
  String toString() {
    return 'CachedAudio(topic: $originalTopic, coach: $coachVoice, duration: $formattedDuration, size: $formattedFileSize)';
  }
}

enum AudioStatus {
  generating,
  available,
  error,
  expired,
}
