import 'package:cloud_firestore/cloud_firestore.dart';

class ContentBlock {
  final String id;
  final String category;
  final String topic;
  final String contentType; // story, concept, tool, example
  final String difficulty;  // beginner, intermediate, advanced
  final String title;
  final String script;      // Text content for TTS
  final String? audioUrl;   // Generated audio file URL
  final String? transcript; // Full transcript with timestamps
  final List<String> tags;  // Hashtags for content discovery
  final List<String> prerequisites; // Required prior knowledge
  final Duration duration;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final int accessCount;
  final DateTime? lastAccessedAt;

  ContentBlock({
    required this.id,
    required this.category,
    required this.topic,
    required this.contentType,
    required this.difficulty,
    required this.title,
    required this.script,
    this.audioUrl,
    this.transcript,
    this.tags = const [],
    this.prerequisites = const [],
    required this.duration,
    this.metadata = const {},
    required this.createdAt,
    this.accessCount = 0,
    this.lastAccessedAt,
  });

  factory ContentBlock.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentBlock(
      id: doc.id,
      category: data['category'] ?? '',
      topic: data['topic'] ?? '',
      contentType: data['contentType'] ?? '',
      difficulty: data['difficulty'] ?? '',
      title: data['title'] ?? '',
      script: data['script'] ?? '',
      audioUrl: data['audioUrl'],
      transcript: data['transcript'],
      tags: List<String>.from(data['tags'] ?? []),
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      duration: Duration(seconds: data['durationSeconds'] ?? 0),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      accessCount: data['accessCount'] ?? 0,
      lastAccessedAt: data['lastAccessedAt'] != null 
          ? (data['lastAccessedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'category': category,
        'topic': topic,
        'contentType': contentType,
        'difficulty': difficulty,
        'title': title,
        'script': script,
        'audioUrl': audioUrl,
        'transcript': transcript,
        'tags': tags,
        'prerequisites': prerequisites,
        'durationSeconds': duration.inSeconds,
        'metadata': metadata,
        'createdAt': Timestamp.fromDate(createdAt),
        'accessCount': accessCount,
        'lastAccessedAt': lastAccessedAt != null 
            ? Timestamp.fromDate(lastAccessedAt!) 
            : null,
      };

  ContentBlock copyWith({
    String? id,
    String? category,
    String? topic,
    String? contentType,
    String? difficulty,
    String? title,
    String? script,
    String? audioUrl,
    String? transcript,
    List<String>? tags,
    List<String>? prerequisites,
    Duration? duration,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    int? accessCount,
    DateTime? lastAccessedAt,
  }) {
    return ContentBlock(
      id: id ?? this.id,
      category: category ?? this.category,
      topic: topic ?? this.topic,
      contentType: contentType ?? this.contentType,
      difficulty: difficulty ?? this.difficulty,
      title: title ?? this.title,
      script: script ?? this.script,
      audioUrl: audioUrl ?? this.audioUrl,
      transcript: transcript ?? this.transcript,
      tags: tags ?? this.tags,
      prerequisites: prerequisites ?? this.prerequisites,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return 'ContentBlock(id: $id, title: $title, category: $category, type: $contentType)';
  }
}

class LearningJourney {
  final String id;
  final String userId;
  final String topic;
  final String category;
  final String level;
  final String title;
  final String description;
  final List<String> blockIds; // ContentBlock IDs in order
  final Duration estimatedDuration;
  final int totalBlocks;
  final int completedBlocks;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;

  LearningJourney({
    required this.id,
    required this.userId,
    required this.topic,
    required this.category,
    required this.level,
    required this.title,
    required this.description,
    required this.blockIds,
    required this.estimatedDuration,
    required this.totalBlocks,
    this.completedBlocks = 0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.metadata = const {},
  });

  factory LearningJourney.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LearningJourney(
      id: doc.id,
      userId: data['userId'] ?? '',
      topic: data['topic'] ?? '',
      category: data['category'] ?? '',
      level: data['level'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      blockIds: List<String>.from(data['blockIds'] ?? []),
      estimatedDuration: Duration(seconds: data['estimatedDurationSeconds'] ?? 0),
      totalBlocks: data['totalBlocks'] ?? 0,
      completedBlocks: data['completedBlocks'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null 
          ? (data['startedAt'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'topic': topic,
        'category': category,
        'level': level,
        'title': title,
        'description': description,
        'blockIds': blockIds,
        'estimatedDurationSeconds': estimatedDuration.inSeconds,
        'totalBlocks': totalBlocks,
        'completedBlocks': completedBlocks,
        'createdAt': Timestamp.fromDate(createdAt),
        'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'metadata': metadata,
      };

  double get progressPercentage => 
      totalBlocks > 0 ? completedBlocks / totalBlocks : 0.0;

  bool get isCompleted => completedBlocks >= totalBlocks;

  bool get isStarted => startedAt != null;

  LearningJourney copyWith({
    int? completedBlocks,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return LearningJourney(
      id: id,
      userId: userId,
      topic: topic,
      category: category,
      level: level,
      title: title,
      description: description,
      blockIds: blockIds,
      estimatedDuration: estimatedDuration,
      totalBlocks: totalBlocks,
      completedBlocks: completedBlocks ?? this.completedBlocks,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'LearningJourney(id: $id, title: $title, progress: ${(progressPercentage * 100).toStringAsFixed(1)}%)';
  }
}

class UserProgress {
  final String id;
  final String userId;
  final String blockId;
  final String journeyId;
  final String episodeId;
  final DateTime completedAt;
  final Duration listenTime;
  final double completionPercentage;
  final Map<String, dynamic> engagementData;
  final DateTime lastAccessed;

  UserProgress({
    required this.id,
    required this.userId,
    required this.blockId,
    required this.journeyId,
    required this.episodeId,
    required this.completedAt,
    required this.listenTime,
    this.completionPercentage = 1.0,
    this.engagementData = const {},
    required this.lastAccessed,
  });

  factory UserProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      blockId: data['blockId'] ?? '',
      journeyId: data['journeyId'] ?? '',
      episodeId: data['episodeId'] ?? '',
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      listenTime: Duration(seconds: data['listenTimeSeconds'] ?? 0),
      completionPercentage: (data['completionPercentage'] ?? 1.0).toDouble(),
      engagementData: Map<String, dynamic>.from(data['engagementData'] ?? {}),
      lastAccessed: (data['lastAccessed'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'blockId': blockId,
        'journeyId': journeyId,
        'episodeId': episodeId,
        'completedAt': Timestamp.fromDate(completedAt),
        'listenTimeSeconds': listenTime.inSeconds,
        'completionPercentage': completionPercentage,
        'engagementData': engagementData,
        'lastAccessed': Timestamp.fromDate(lastAccessed),
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'blockId': blockId,
        'journeyId': journeyId,
        'episodeId': episodeId,
        'completedAt': completedAt.toIso8601String(),
        'listenTimeSeconds': listenTime.inSeconds,
        'completionPercentage': completionPercentage,
        'engagementData': engagementData,
        'lastAccessed': lastAccessed.toIso8601String(),
      };

  factory UserProgress.fromMap(Map<String, dynamic> data) {
    return UserProgress(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      blockId: data['blockId'] ?? '',
      journeyId: data['journeyId'] ?? '',
      episodeId: data['episodeId'] ?? '',
      completedAt: DateTime.parse(data['completedAt'] ?? DateTime.now().toIso8601String()),
      listenTime: Duration(seconds: data['listenTimeSeconds'] ?? 0),
      completionPercentage: (data['completionPercentage'] ?? 1.0).toDouble(),
      engagementData: Map<String, dynamic>.from(data['engagementData'] ?? {}),
      lastAccessed: DateTime.parse(data['lastAccessed'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'UserProgress(blockId: $blockId, completion: ${(completionPercentage * 100).toStringAsFixed(1)}%)';
  }
}

class BlockProgress {
  final String userId;
  final String blockId;
  final String journeyId;
  final bool isCompleted;
  final DateTime? completedAt;
  final Duration listeningTime;
  final Duration lastPosition;
  final double completionPercentage;
  final Map<String, dynamic> metadata;

  BlockProgress({
    required this.userId,
    required this.blockId,
    required this.journeyId,
    this.isCompleted = false,
    this.completedAt,
    this.listeningTime = const Duration(),
    this.lastPosition = const Duration(),
    this.completionPercentage = 0.0,
    this.metadata = const {},
  });

  factory BlockProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlockProgress(
      userId: data['userId'] ?? '',
      blockId: data['blockId'] ?? '',
      journeyId: data['journeyId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      listeningTime: Duration(seconds: data['listeningTimeSeconds'] ?? 0),
      lastPosition: Duration(seconds: data['lastPositionSeconds'] ?? 0),
      completionPercentage: (data['completionPercentage'] ?? 0.0).toDouble(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'blockId': blockId,
        'journeyId': journeyId,
        'isCompleted': isCompleted,
        'completedAt': completedAt != null 
            ? Timestamp.fromDate(completedAt!) 
            : null,
        'listeningTimeSeconds': listeningTime.inSeconds,
        'lastPositionSeconds': lastPosition.inSeconds,
        'completionPercentage': completionPercentage,
        'metadata': metadata,
      };

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'blockId': blockId,
        'journeyId': journeyId,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'listeningTimeSeconds': listeningTime.inSeconds,
        'lastPositionSeconds': lastPosition.inSeconds,
        'completionPercentage': completionPercentage,
        'metadata': metadata,
      };

  factory BlockProgress.fromMap(Map<String, dynamic> data) {
    return BlockProgress(
      userId: data['userId'] ?? '',
      blockId: data['blockId'] ?? '',
      journeyId: data['journeyId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? DateTime.parse(data['completedAt']) 
          : null,
      listeningTime: Duration(seconds: data['listeningTimeSeconds'] ?? 0),
      lastPosition: Duration(seconds: data['lastPositionSeconds'] ?? 0),
      completionPercentage: (data['completionPercentage'] ?? 0.0).toDouble(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  BlockProgress copyWith({
    bool? isCompleted,
    DateTime? completedAt,
    Duration? listeningTime,
    Duration? lastPosition,
    double? completionPercentage,
    Map<String, dynamic>? metadata,
  }) {
    return BlockProgress(
      userId: userId,
      blockId: blockId,
      journeyId: journeyId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      listeningTime: listeningTime ?? this.listeningTime,
      lastPosition: lastPosition ?? this.lastPosition,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'BlockProgress(blockId: $blockId, completion: ${(completionPercentage * 100).toStringAsFixed(1)}%)';
  }
}
