import 'dart:typed_data';

/// Represents an audio file stored in cloud storage (Firebase Storage)
/// This is the permanent storage record with metadata for content reuse
class StoredAudioFile {
  final String fileId;                    // Unique identifier for the audio file
  final String contentHash;               // Hash of the content for duplicate detection
  final String originalTopic;             // Human-readable topic name
  final String coachVoice;                // Voice/coach identifier
  final String cloudUrl;                  // Firebase Storage download URL
  final DateTime createdAt;               // When the file was first generated
  final DateTime? lastAccessedAt;         // Last time this file was accessed
  final int durationSeconds;              // Audio duration in seconds
  final int fileSizeBytes;                // File size in bytes
  final int totalAccessCount;             // How many times this file has been accessed
  final StorageStatus status;             // Current status of the stored file
  final Map<String, dynamic> metadata;    // Additional metadata (quality, format, etc.)
  final List<String> hashtags;            // AI-generated hashtags for content matching
  final String storagePath;               // Full path in Firebase Storage
  final String? localCachePath;           // Path if cached locally (optional)

  const StoredAudioFile({
    required this.fileId,
    required this.contentHash,
    required this.originalTopic,
    required this.coachVoice,
    required this.cloudUrl,
    required this.createdAt,
    this.lastAccessedAt,
    required this.durationSeconds,
    required this.fileSizeBytes,
    this.totalAccessCount = 0,
    this.status = StorageStatus.available,
    this.metadata = const {},
    this.hashtags = const [],
    required this.storagePath,
    this.localCachePath,
  });

  factory StoredAudioFile.fromJson(Map<String, dynamic> json) {
    return StoredAudioFile(
      fileId: json['fileId'] as String,
      contentHash: json['contentHash'] as String,
      originalTopic: json['originalTopic'] as String,
      coachVoice: json['coachVoice'] as String,
      cloudUrl: json['cloudUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAccessedAt: json['lastAccessedAt'] != null 
          ? DateTime.parse(json['lastAccessedAt'] as String) 
          : null,
      durationSeconds: json['durationSeconds'] as int,
      fileSizeBytes: json['fileSizeBytes'] as int,
      totalAccessCount: json['totalAccessCount'] as int? ?? 0,
      status: StorageStatus.values.byName(json['status'] as String? ?? 'available'),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      storagePath: json['storagePath'] as String,
      localCachePath: json['localCachePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'contentHash': contentHash,
      'originalTopic': originalTopic,
      'coachVoice': coachVoice,
      'cloudUrl': cloudUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'totalAccessCount': totalAccessCount,
      'status': status.name,
      'metadata': metadata,
      'hashtags': hashtags,
      'storagePath': storagePath,
      'localCachePath': localCachePath,
    };
  }

  StoredAudioFile copyWith({
    String? fileId,
    String? contentHash,
    String? originalTopic,
    String? coachVoice,
    String? cloudUrl,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    int? durationSeconds,
    int? fileSizeBytes,
    int? totalAccessCount,
    StorageStatus? status,
    Map<String, dynamic>? metadata,
    List<String>? hashtags,
    String? storagePath,
    String? localCachePath,
  }) {
    return StoredAudioFile(
      fileId: fileId ?? this.fileId,
      contentHash: contentHash ?? this.contentHash,
      originalTopic: originalTopic ?? this.originalTopic,
      coachVoice: coachVoice ?? this.coachVoice,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      totalAccessCount: totalAccessCount ?? this.totalAccessCount,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      hashtags: hashtags ?? this.hashtags,
      storagePath: storagePath ?? this.storagePath,
      localCachePath: localCachePath ?? this.localCachePath,
    );
  }

  /// Check if this audio is available in cloud storage
  bool get isAvailableInCloud => status == StorageStatus.available && cloudUrl.isNotEmpty;

  /// Check if this audio is cached locally
  bool get isCachedLocally => localCachePath != null && localCachePath!.isNotEmpty;

  /// Get file size in a human-readable format
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get duration in a human-readable format
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get age of the file
  String get ageDescription {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    return '${difference.inMinutes} minutes ago';
  }

  /// Get last access description
  String get lastAccessDescription {
    if (lastAccessedAt == null) return 'Never accessed';
    
    final now = DateTime.now();
    final difference = now.difference(lastAccessedAt!);
    
    if (difference.inDays > 0) return 'Last accessed ${difference.inDays} days ago';
    if (difference.inHours > 0) return 'Last accessed ${difference.inHours} hours ago';
    return 'Last accessed ${difference.inMinutes} minutes ago';
  }

  /// Calculate storage efficiency score
  double get storageEfficiencyScore {
    if (totalAccessCount == 0) return 0.0;
    
    final daysSinceCreated = DateTime.now().difference(createdAt).inDays.clamp(1, 365);
    final accessesPerDay = totalAccessCount / daysSinceCreated;
    
    // Score based on usage frequency and file age
    return (accessesPerDay * 10).clamp(0.0, 10.0);
  }

  /// Check if file should be considered for cleanup
  bool get shouldConsiderForCleanup {
    final daysSinceLastAccess = lastAccessedAt != null 
        ? DateTime.now().difference(lastAccessedAt!).inDays
        : DateTime.now().difference(createdAt).inDays;
    
    return daysSinceLastAccess > 30 && totalAccessCount < 5;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoredAudioFile && other.fileId == fileId;
  }

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() {
    return 'StoredAudioFile(topic: $originalTopic, coach: $coachVoice, duration: $formattedDuration, size: $formattedFileSize, accessed: $totalAccessCount times)';
  }
}

/// Status of the audio file in cloud storage
enum StorageStatus {
  uploading,        // Currently being uploaded to cloud storage
  available,        // Available for download and use
  processing,       // Being processed (compression, optimization, etc.)
  error,           // Error occurred during upload or processing
  archived,        // Moved to archival storage for cost optimization
  deleted,         // Marked for deletion
}
