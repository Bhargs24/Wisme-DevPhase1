class LessonModel {
  final String lessonId;
  final String topic;
  final String subtopic;
  final String title;
  final String audioUrl;
  final String text;
  final String summary;
  final int wordCount;
  final int durationSeconds;
  final String length;
  final List<String> tags;
  final String coachVoice;
  final DateTime createdAt;
  final int accessCount;
  final DateTime? lastAccessedAt;
  final int fileSize;
  final String storagePath;

  const LessonModel({
    required this.lessonId,
    required this.topic,
    required this.subtopic,
    required this.title,
    required this.audioUrl,
    required this.text,
    required this.summary,
    required this.wordCount,
    required this.durationSeconds,
    required this.length,
    required this.tags,
    required this.coachVoice,
    required this.createdAt,
    this.accessCount = 0,
    this.lastAccessedAt,
    required this.fileSize,
    required this.storagePath,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lesson_id'] as String,
      topic: json['topic'] as String,
      subtopic: json['subtopic'] as String,
      title: json['title'] as String,
      audioUrl: json['audio_url'] as String,
      text: json['text'] as String,
      summary: json['summary'] as String,
      wordCount: json['word_count'] as int,
      durationSeconds: json['duration_seconds'] as int,
      length: json['length'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      coachVoice: json['coach_voice'] as String? ?? 'default',
      createdAt: (json['created_at'] as dynamic).toDate() as DateTime,
      accessCount: json['access_count'] as int? ?? 0,
      lastAccessedAt: json['last_accessed_at'] != null 
          ? (json['last_accessed_at'] as dynamic).toDate() as DateTime
          : null,
      fileSize: json['file_size'] as int,
      storagePath: json['storage_path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'topic': topic,
      'subtopic': subtopic,
      'title': title,
      'audio_url': audioUrl,
      'text': text,
      'summary': summary,
      'word_count': wordCount,
      'duration_seconds': durationSeconds,
      'length': length,
      'tags': tags,
      'coach_voice': coachVoice,
      'created_at': createdAt,
      'access_count': accessCount,
      'last_accessed_at': lastAccessedAt,
      'file_size': fileSize,
      'storage_path': storagePath,
    };
  }

  LessonModel copyWith({
    String? lessonId,
    String? topic,
    String? subtopic,
    String? title,
    String? audioUrl,
    String? text,
    String? summary,
    int? wordCount,
    int? durationSeconds,
    String? length,
    List<String>? tags,
    String? coachVoice,
    DateTime? createdAt,
    int? accessCount,
    DateTime? lastAccessedAt,
    int? fileSize,
    String? storagePath,
  }) {
    return LessonModel(
      lessonId: lessonId ?? this.lessonId,
      topic: topic ?? this.topic,
      subtopic: subtopic ?? this.subtopic,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      text: text ?? this.text,
      summary: summary ?? this.summary,
      wordCount: wordCount ?? this.wordCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      length: length ?? this.length,
      tags: tags ?? this.tags,
      coachVoice: coachVoice ?? this.coachVoice,
      createdAt: createdAt ?? this.createdAt,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      fileSize: fileSize ?? this.fileSize,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  /// Get file size in human-readable format
  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get duration in MM:SS format
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if lesson was accessed recently (within last 7 days)
  bool get isRecentlyAccessed {
    if (lastAccessedAt == null) return false;
    final daysSinceAccess = DateTime.now().difference(lastAccessedAt!).inDays;
    return daysSinceAccess <= 7;
  }

  /// Check if lesson is popular (access count > 10)
  bool get isPopular => accessCount > 10;

  /// Get hierarchical storage path with voice-first structure
  String get hierarchicalPath => 'generated_audio/$coachVoice/${_normalizeTopicName(topic)}/${_normalizeTopicName(subtopic)}/$lessonId.mp3';

  /// Normalize topic name for consistent storage
  String _normalizeTopicName(String topic) {
    return topic
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonModel && other.lessonId == lessonId;
  }

  @override
  int get hashCode => lessonId.hashCode;

  @override
  String toString() {
    return 'LessonModel(id: $lessonId, topic: $topic, subtopic: $subtopic, duration: $length)';
  }
}

/// Topic organization model
class TopicModel {
  final String topicName;
  final String normalizedName;
  final List<String> subtopics;
  final List<String> lessonIds;
  final int lessonCount;
  final DateTime updatedAt;

  const TopicModel({
    required this.topicName,
    required this.normalizedName,
    required this.subtopics,
    required this.lessonIds,
    required this.lessonCount,
    required this.updatedAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      topicName: json['topic_name'] as String,
      normalizedName: json['normalized_name'] as String,
      subtopics: List<String>.from(json['subtopics'] ?? []),
      lessonIds: List<String>.from(json['lesson_ids'] ?? []),
      lessonCount: json['lesson_count'] as int? ?? 0,
      updatedAt: (json['updated_at'] as dynamic).toDate() as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic_name': topicName,
      'normalized_name': normalizedName,
      'subtopics': subtopics,
      'lesson_ids': lessonIds,
      'lesson_count': lessonCount,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'TopicModel(name: $topicName, lessons: $lessonCount, subtopics: ${subtopics.length})';
  }
}