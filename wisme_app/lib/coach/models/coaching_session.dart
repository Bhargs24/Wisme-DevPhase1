/// Coaching session model for AI-human interactions
class CoachingSession {
  final String id;
  final String userId;
  final String coachId;
  final String? lessonId;
  final SessionType type;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final List<CoachMessage> messages;
  final Map<String, dynamic> context;
  final List<String> goals;
  final Map<String, dynamic> outcomes;
  final SessionQuality? quality;
  final Map<String, dynamic> metadata;

  const CoachingSession({
    required this.id,
    required this.userId,
    required this.coachId,
    this.lessonId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.messages,
    required this.context,
    required this.goals,
    required this.outcomes,
    this.quality,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'coachId': coachId,
    'lessonId': lessonId,
    'type': type.name,
    'status': status.name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'messages': messages.map((msg) => msg.toJson()).toList(),
    'context': context,
    'goals': goals,
    'outcomes': outcomes,
    'quality': quality?.toJson(),
    'metadata': metadata,
  };

  factory CoachingSession.fromJson(Map<String, dynamic> json) => CoachingSession(
    id: json['id'] as String,
    userId: json['userId'] as String,
    coachId: json['coachId'] as String,
    lessonId: json['lessonId'] as String?,
    type: SessionType.values.byName(json['type'] as String),
    status: SessionStatus.values.byName(json['status'] as String),
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    messages: (json['messages'] as List)
        .map((msg) => CoachMessage.fromJson(msg as Map<String, dynamic>))
        .toList(),
    context: json['context'] as Map<String, dynamic>,
    goals: List<String>.from(json['goals'] as List),
    outcomes: json['outcomes'] as Map<String, dynamic>,
    quality: json['quality'] != null 
        ? SessionQuality.fromJson(json['quality'] as Map<String, dynamic>)
        : null,
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  CoachingSession copyWith({
    SessionType? type,
    SessionStatus? status,
    DateTime? endTime,
    List<CoachMessage>? messages,
    Map<String, dynamic>? context,
    List<String>? goals,
    Map<String, dynamic>? outcomes,
    SessionQuality? quality,
    Map<String, dynamic>? metadata,
  }) => CoachingSession(
    id: id,
    userId: userId,
    coachId: coachId,
    lessonId: lessonId,
    type: type ?? this.type,
    status: status ?? this.status,
    startTime: startTime,
    endTime: endTime ?? this.endTime,
    messages: messages ?? this.messages,
    context: context ?? this.context,
    goals: goals ?? this.goals,
    outcomes: outcomes ?? this.outcomes,
    quality: quality ?? this.quality,
    metadata: metadata ?? this.metadata,
  );

  /// Get session duration
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  /// Check if session is active
  bool get isActive => status == SessionStatus.active;

  /// Check if session is completed
  bool get isCompleted => status == SessionStatus.completed;

  /// Get last message
  CoachMessage? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// Get messages by sender
  List<CoachMessage> getMessagesBySender(MessageSender sender) {
    return messages.where((msg) => msg.sender == sender).toList();
  }
}

enum SessionType {
  onboarding,
  guidance,
  motivation,
  assessment,
  feedback,
  troubleshooting,
  celebration,
}

enum SessionStatus {
  active,
  paused,
  completed,
  terminated,
  failed,
}

class CoachMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic> attachments;
  final String? replyToId;
  final MessageIntent intent;
  final double? confidence;
  final Map<String, dynamic> metadata;

  const CoachMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.attachments,
    this.replyToId,
    required this.intent,
    this.confidence,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender.name,
    'content': content,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'attachments': attachments,
    'replyToId': replyToId,
    'intent': intent.name,
    'confidence': confidence,
    'metadata': metadata,
  };

  factory CoachMessage.fromJson(Map<String, dynamic> json) => CoachMessage(
    id: json['id'] as String,
    sender: MessageSender.values.byName(json['sender'] as String),
    content: json['content'] as String,
    type: MessageType.values.byName(json['type'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String),
    attachments: json['attachments'] as Map<String, dynamic>,
    replyToId: json['replyToId'] as String?,
    intent: MessageIntent.values.byName(json['intent'] as String),
    confidence: json['confidence'] as double?,
    metadata: json['metadata'] as Map<String, dynamic>,
  );
}

enum MessageSender {
  user,
  coach,
  system,
}

enum MessageType {
  text,
  audio,
  image,
  link,
  action,
  suggestion,
}

enum MessageIntent {
  question,
  answer,
  encouragement,
  guidance,
  feedback,
  clarification,
  celebration,
  motivation,
  information,
  instruction,
}

class SessionQuality {
  final double overallRating;
  final double helpfulness;
  final double clarity;
  final double engagement;
  final double relevance;
  final String? feedback;
  final DateTime ratedAt;

  const SessionQuality({
    required this.overallRating,
    required this.helpfulness,
    required this.clarity,
    required this.engagement,
    required this.relevance,
    this.feedback,
    required this.ratedAt,
  });

  Map<String, dynamic> toJson() => {
    'overallRating': overallRating,
    'helpfulness': helpfulness,
    'clarity': clarity,
    'engagement': engagement,
    'relevance': relevance,
    'feedback': feedback,
    'ratedAt': ratedAt.toIso8601String(),
  };

  factory SessionQuality.fromJson(Map<String, dynamic> json) => SessionQuality(
    overallRating: (json['overallRating'] as num).toDouble(),
    helpfulness: (json['helpfulness'] as num).toDouble(),
    clarity: (json['clarity'] as num).toDouble(),
    engagement: (json['engagement'] as num).toDouble(),
    relevance: (json['relevance'] as num).toDouble(),
    feedback: json['feedback'] as String?,
    ratedAt: DateTime.parse(json['ratedAt'] as String),
  );
}
