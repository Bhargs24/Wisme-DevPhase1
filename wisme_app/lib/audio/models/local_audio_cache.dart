import 'dart:typed_data';

/// Local device cache for audio files with intelligent management
class LocalAudioCache {
  final String audioId;
  final String localFilePath;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  final int fileSizeBytes;
  final int accessCount;
  final LocalCacheStatus status;
  final Map<String, dynamic> metadata;

  const LocalAudioCache({
    required this.audioId,
    required this.localFilePath,
    required this.cachedAt,
    required this.lastAccessedAt,
    required this.fileSizeBytes,
    this.accessCount = 0,
    this.status = LocalCacheStatus.cached,
    this.metadata = const {},
  });

  factory LocalAudioCache.fromJson(Map<String, dynamic> json) {
    return LocalAudioCache(
      audioId: json['audioId'] as String,
      localFilePath: json['localFilePath'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
      fileSizeBytes: json['fileSizeBytes'] as int,
      accessCount: json['accessCount'] as int? ?? 0,
      status: LocalCacheStatus.values.byName(json['status'] as String? ?? 'cached'),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioId': audioId,
      'localFilePath': localFilePath,
      'cachedAt': cachedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'fileSizeBytes': fileSizeBytes,
      'accessCount': accessCount,
      'status': status.name,
      'metadata': metadata,
    };
  }

  LocalAudioCache copyWith({
    String? audioId,
    String? localFilePath,
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
    int? fileSizeBytes,
    int? accessCount,
    LocalCacheStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return LocalAudioCache(
      audioId: audioId ?? this.audioId,
      localFilePath: localFilePath ?? this.localFilePath,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      accessCount: accessCount ?? this.accessCount,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Update access time for LRU cache management
  LocalAudioCache updateAccess() {
    return copyWith(
      lastAccessedAt: DateTime.now(),
      accessCount: accessCount + 1,
    );
  }

  /// Check if cache entry is expired (older than 30 days)
  bool get isExpired => DateTime.now().difference(cachedAt).inDays > 30;

  /// Check if cache is ready for playback
  bool get isPlayable => status == LocalCacheStatus.cached;

  /// Get age of cached file in days
  int get ageInDays => DateTime.now().difference(cachedAt).inDays;

  /// Priority score for cache eviction (lower = evict first)
  double get evictionPriority {
    final daysSinceAccess = DateTime.now().difference(lastAccessedAt).inDays;
    final accessFrequency = accessCount / (ageInDays + 1);
    
    // Higher access frequency and recent access = higher priority to keep
    return accessFrequency / (daysSinceAccess + 1);
  }

  /// Get file size in human-readable format
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalAudioCache && other.audioId == audioId;
  }

  @override
  int get hashCode => audioId.hashCode;

  @override
  String toString() {
    return 'LocalAudioCache(audioId: $audioId, size: $formattedFileSize, age: ${ageInDays}d, accessed: ${accessCount}x)';
  }
}

enum LocalCacheStatus {
  downloading,
  cached,
  error,
  corrupted,
  evicted,
}

/// Audio segment for reusable content assembly
class ReusableAudioSegment {
  final String segmentId;
  final String contentHash;
  final Uint8List audioData;
  final Duration duration;
  final String coachVoice;
  final DateTime createdAt;
  final List<String> hashtags;
  final Map<String, dynamic> metadata;

  const ReusableAudioSegment({
    required this.segmentId,
    required this.contentHash,
    required this.audioData,
    required this.duration,
    required this.coachVoice,
    required this.createdAt,
    this.hashtags = const [],
    this.metadata = const {},
  });

  /// Check if segment can be reused for content with matching hashtags
  bool canReuseFor(List<String> targetHashtags) {
    if (hashtags.isEmpty || targetHashtags.isEmpty) return false;
    
    final matchingTags = hashtags.toSet().intersection(targetHashtags.toSet());
    return matchingTags.length >= 2; // At least 2 matching hashtags
  }

  /// Calculate reuse score for content matching
  double reuseScore(List<String> targetHashtags) {
    if (hashtags.isEmpty || targetHashtags.isEmpty) return 0.0;
    
    final matchingTags = hashtags.toSet().intersection(targetHashtags.toSet());
    return matchingTags.length / hashtags.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReusableAudioSegment && other.segmentId == segmentId;
  }

  @override
  int get hashCode => segmentId.hashCode;

  @override
  String toString() {
    return 'ReusableAudioSegment(id: $segmentId, duration: ${duration.inSeconds}s, voice: $coachVoice)';
  }
}
