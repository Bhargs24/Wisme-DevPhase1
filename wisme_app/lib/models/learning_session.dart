/// Industrial-grade LearningSession model for tracking learning progress
class LearningSession {
  final String id;
  final String userId;
  final String topicId;
  final List<String> contentBlockIds;
  final Duration totalDuration;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double progressPercentage;
  final Map<String, dynamic> analytics;
  final bool isCompleted;
  final double? userRating;
  final String? userFeedback;
  final Map<String, Duration> contentBlockProgress;
  final List<String> completedContentBlocks;
  final String? currentContentBlockId;
  final Map<String, dynamic> interactionData;
  final Duration pausedDuration;
  final int resumeCount;
  final double averagePlaybackSpeed;
  final List<String> skippedContentBlocks;
  final Map<String, dynamic> metadata;

  const LearningSession({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.contentBlockIds,
    required this.totalDuration,
    required this.startedAt,
    this.completedAt,
    required this.progressPercentage,
    this.analytics = const {},
    required this.isCompleted,
    this.userRating,
    this.userFeedback,
    this.contentBlockProgress = const {},
    this.completedContentBlocks = const [],
    this.currentContentBlockId,
    this.interactionData = const {},
    this.pausedDuration = Duration.zero,
    this.resumeCount = 0,
    this.averagePlaybackSpeed = 1.0,
    this.skippedContentBlocks = const [],
    this.metadata = const {},
  });

  /// Create new learning session
  factory LearningSession.create({
    required String userId,
    required String topicId,
    required List<String> contentBlockIds,
  }) {
    return LearningSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      topicId: topicId,
      contentBlockIds: contentBlockIds,
      totalDuration: Duration.zero,
      startedAt: DateTime.now(),
      progressPercentage: 0.0,
      isCompleted: false,
      currentContentBlockId: contentBlockIds.isNotEmpty ? contentBlockIds.first : null,
    );
  }

  /// Create from JSON
  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'],
      userId: json['user_id'],
      topicId: json['topic_id'],
      contentBlockIds: List<String>.from(json['content_block_ids']),
      totalDuration: Duration(milliseconds: json['total_duration_ms']),
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      progressPercentage: json['progress_percentage'].toDouble(),
      analytics: json['analytics'] ?? {},
      isCompleted: json['is_completed'],
      userRating: json['user_rating']?.toDouble(),
      userFeedback: json['user_feedback'],
      contentBlockProgress: Map<String, Duration>.from(
        (json['content_block_progress'] ?? {}).map(
          (key, value) => MapEntry(key, Duration(milliseconds: value)),
        ),
      ),
      completedContentBlocks: List<String>.from(json['completed_content_blocks'] ?? []),
      currentContentBlockId: json['current_content_block_id'],
      interactionData: json['interaction_data'] ?? {},
      pausedDuration: Duration(milliseconds: json['paused_duration_ms'] ?? 0),
      resumeCount: json['resume_count'] ?? 0,
      averagePlaybackSpeed: json['average_playback_speed']?.toDouble() ?? 1.0,
      skippedContentBlocks: List<String>.from(json['skipped_content_blocks'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'topic_id': topicId,
      'content_block_ids': contentBlockIds,
      'total_duration_ms': totalDuration.inMilliseconds,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'progress_percentage': progressPercentage,
      'analytics': analytics,
      'is_completed': isCompleted,
      'user_rating': userRating,
      'user_feedback': userFeedback,
      'content_block_progress': contentBlockProgress.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'completed_content_blocks': completedContentBlocks,
      'current_content_block_id': currentContentBlockId,
      'interaction_data': interactionData,
      'paused_duration_ms': pausedDuration.inMilliseconds,
      'resume_count': resumeCount,
      'average_playback_speed': averagePlaybackSpeed,
      'skipped_content_blocks': skippedContentBlocks,
      'metadata': metadata,
    };
  }

  /// Copy with modifications
  LearningSession copyWith({
    String? id,
    String? userId,
    String? topicId,
    List<String>? contentBlockIds,
    Duration? totalDuration,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progressPercentage,
    Map<String, dynamic>? analytics,
    bool? isCompleted,
    double? userRating,
    String? userFeedback,
    Map<String, Duration>? contentBlockProgress,
    List<String>? completedContentBlocks,
    String? currentContentBlockId,
    Map<String, dynamic>? interactionData,
    Duration? pausedDuration,
    int? resumeCount,
    double? averagePlaybackSpeed,
    List<String>? skippedContentBlocks,
    Map<String, dynamic>? metadata,
  }) {
    return LearningSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      contentBlockIds: contentBlockIds ?? this.contentBlockIds,
      totalDuration: totalDuration ?? this.totalDuration,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      analytics: analytics ?? this.analytics,
      isCompleted: isCompleted ?? this.isCompleted,
      userRating: userRating ?? this.userRating,
      userFeedback: userFeedback ?? this.userFeedback,
      contentBlockProgress: contentBlockProgress ?? this.contentBlockProgress,
      completedContentBlocks: completedContentBlocks ?? this.completedContentBlocks,
      currentContentBlockId: currentContentBlockId ?? this.currentContentBlockId,
      interactionData: interactionData ?? this.interactionData,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      resumeCount: resumeCount ?? this.resumeCount,
      averagePlaybackSpeed: averagePlaybackSpeed ?? this.averagePlaybackSpeed,
      skippedContentBlocks: skippedContentBlocks ?? this.skippedContentBlocks,
      metadata: metadata ?? this.metadata,
    );
  }

  // Business Logic Methods

  /// Check if session is currently in progress
  bool get isInProgress => !isCompleted && completedAt == null;

  /// Get estimated time remaining
  Duration get timeRemaining {
    if (isCompleted) return Duration.zero;
    final remaining = 1.0 - progressPercentage;
    return Duration(milliseconds: (totalDuration.inMilliseconds * remaining).round());
  }

  /// Get actual listening time (excluding pauses)
  Duration get activeListeningTime => totalDuration - pausedDuration;

  /// Get completion percentage as string
  String get formattedProgress => '${(progressPercentage * 100).toStringAsFixed(0)}%';

  /// Check if session was abandoned (started but not completed in reasonable time)
  bool get isAbandoned {
    if (isCompleted) return false;
    final now = DateTime.now();
    final daysSinceStart = now.difference(startedAt).inDays;
    return daysSinceStart > 7 && progressPercentage < 0.1;
  }

  /// Get session quality score based on completion and engagement
  double get qualityScore {
    if (!isCompleted) return 0.0;
    
    double score = 0.5; // Base score for completion
    
    // Bonus for high progress without skipping
    if (progressPercentage > 0.9) score += 0.2;
    
    // Penalty for too many skipped blocks
    final skipRatio = skippedContentBlocks.length / contentBlockIds.length;
    score -= skipRatio * 0.3;
    
    // Bonus for providing feedback
    if (userRating != null) score += 0.1;
    if (userFeedback != null && userFeedback!.isNotEmpty) score += 0.1;
    
    // Bonus for consistent playback speed
    if (averagePlaybackSpeed >= 0.8 && averagePlaybackSpeed <= 1.5) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// Get next content block to play
  String? get nextContentBlockId {
    if (currentContentBlockId == null || contentBlockIds.isEmpty) return null;
    
    final currentIndex = contentBlockIds.indexOf(currentContentBlockId!);
    if (currentIndex == -1 || currentIndex >= contentBlockIds.length - 1) return null;
    
    return contentBlockIds[currentIndex + 1];
  }

  /// Check if content block is completed
  bool isContentBlockCompleted(String contentBlockId) {
    return completedContentBlocks.contains(contentBlockId);
  }

  /// Get progress for specific content block
  Duration getContentBlockProgress(String contentBlockId) {
    return contentBlockProgress[contentBlockId] ?? Duration.zero;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LearningSession{id: $id, topicId: $topicId, progress: $formattedProgress, completed: $isCompleted}';
  }
}
