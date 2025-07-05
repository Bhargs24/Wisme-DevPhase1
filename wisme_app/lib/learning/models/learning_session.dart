/// Learning session model tracking user's study sessions
class LearningSession {
  final String id;
  final String userId;
  final String lessonId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final SessionStatus status;
  final double progressPercentage;
  final List<SessionEvent> events;
  final Map<String, dynamic> performance;
  final List<String> completedObjectives;
  final SessionType type;
  final String? audioFileId;
  final Map<String, dynamic> metadata;

  const LearningSession({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.progressPercentage,
    required this.events,
    required this.performance,
    required this.completedObjectives,
    required this.type,
    this.audioFileId,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'lessonId': lessonId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'duration': duration?.inMinutes,
    'status': status.name,
    'progressPercentage': progressPercentage,
    'events': events.map((event) => event.toJson()).toList(),
    'performance': performance,
    'completedObjectives': completedObjectives,
    'type': type.name,
    'audioFileId': audioFileId,
    'metadata': metadata,
  };

  factory LearningSession.fromJson(Map<String, dynamic> json) => LearningSession(
    id: json['id'] as String,
    userId: json['userId'] as String,
    lessonId: json['lessonId'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    duration: json['duration'] != null ? Duration(minutes: json['duration'] as int) : null,
    status: SessionStatus.values.byName(json['status'] as String),
    progressPercentage: (json['progressPercentage'] as num).toDouble(),
    events: (json['events'] as List)
        .map((event) => SessionEvent.fromJson(event as Map<String, dynamic>))
        .toList(),
    performance: json['performance'] as Map<String, dynamic>,
    completedObjectives: List<String>.from(json['completedObjectives'] as List),
    type: SessionType.values.byName(json['type'] as String),
    audioFileId: json['audioFileId'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  LearningSession copyWith({
    DateTime? endTime,
    Duration? duration,
    SessionStatus? status,
    double? progressPercentage,
    List<SessionEvent>? events,
    Map<String, dynamic>? performance,
    List<String>? completedObjectives,
    String? audioFileId,
    Map<String, dynamic>? metadata,
  }) => LearningSession(
    id: id,
    userId: userId,
    lessonId: lessonId,
    startTime: startTime,
    endTime: endTime ?? this.endTime,
    duration: duration ?? this.duration,
    status: status ?? this.status,
    progressPercentage: progressPercentage ?? this.progressPercentage,
    events: events ?? this.events,
    performance: performance ?? this.performance,
    completedObjectives: completedObjectives ?? this.completedObjectives,
    type: type,
    audioFileId: audioFileId ?? this.audioFileId,
    metadata: metadata ?? this.metadata,
  );

  /// Calculate effective learning time (excluding pauses)
  Duration get effectiveLearningTime {
    if (events.isEmpty) return duration ?? Duration.zero;
    
    Duration totalTime = Duration.zero;
    DateTime? lastResumeTime;
    
    for (final event in events) {
      switch (event.type) {
        case SessionEventType.start:
        case SessionEventType.resume:
          lastResumeTime = event.timestamp;
          break;
        case SessionEventType.pause:
        case SessionEventType.complete:
          if (lastResumeTime != null) {
            totalTime += event.timestamp.difference(lastResumeTime);
            lastResumeTime = null;
          }
          break;
        default:
          break;
      }
    }
    
    // If session is still active, add time from last resume to now
    if (lastResumeTime != null && status == SessionStatus.active) {
      totalTime += DateTime.now().difference(lastResumeTime);
    }
    
    return totalTime;
  }
}

enum SessionStatus {
  active,
  paused,
  completed,
  abandoned,
}

enum SessionType {
  reading,
  listening,
  interactive,
  practice,
  review,
}

class SessionEvent {
  final String id;
  final SessionEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const SessionEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };

  factory SessionEvent.fromJson(Map<String, dynamic> json) => SessionEvent(
    id: json['id'] as String,
    type: SessionEventType.values.byName(json['type'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String),
    data: json['data'] as Map<String, dynamic>,
  );
}

enum SessionEventType {
  start,
  pause,
  resume,
  complete,
  abandon,
  milestone,
  interaction,
}
