/// Comprehensive audio metadata for detailed file information
class AudioMetadata {
  final String audioId;
  final String title;
  final String description;
  final Duration duration;
  final int fileSizeBytes;
  final String format; // mp3, wav, m4a
  final int bitrate; // kbps
  final int sampleRate; // Hz
  final int channels; // 1 = mono, 2 = stereo
  final double averageVolume; // 0.0 - 1.0
  final double peakVolume; // 0.0 - 1.0
  final Map<String, dynamic> technicalData;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;

  const AudioMetadata({
    required this.audioId,
    required this.title,
    required this.description,
    required this.duration,
    required this.fileSizeBytes,
    this.format = 'mp3',
    this.bitrate = 128,
    this.sampleRate = 44100,
    this.channels = 1,
    this.averageVolume = 0.7,
    this.peakVolume = 1.0,
    this.technicalData = const {},
    required this.createdAt,
    this.lastModifiedAt,
  });

  /// Get formatted duration string
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get audio quality description
  String get qualityDescription {
    if (bitrate >= 320) return 'High Quality';
    if (bitrate >= 192) return 'Good Quality';
    if (bitrate >= 128) return 'Standard Quality';
    return 'Basic Quality';
  }

  /// Check if audio is stereo
  bool get isStereo => channels == 2;

  /// Check if audio is high quality
  bool get isHighQuality => bitrate >= 192 && sampleRate >= 44100;

  /// Estimate streaming time needed to buffer
  Duration get estimatedBufferTime {
    final bytesPerSecond = (bitrate * 1000) / 8; // Convert kbps to bytes per second
    final bufferSeconds = fileSizeBytes / bytesPerSecond / 10; // 10% buffer
    return Duration(milliseconds: (bufferSeconds * 1000).round());
  }

  Map<String, dynamic> toJson() {
    return {
      'audioId': audioId,
      'title': title,
      'description': description,
      'duration': duration.inMilliseconds,
      'fileSizeBytes': fileSizeBytes,
      'format': format,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
      'channels': channels,
      'averageVolume': averageVolume,
      'peakVolume': peakVolume,
      'technicalData': technicalData,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
    };
  }

  factory AudioMetadata.fromJson(Map<String, dynamic> json) {
    return AudioMetadata(
      audioId: json['audioId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      fileSizeBytes: json['fileSizeBytes'] as int,
      format: json['format'] as String? ?? 'mp3',
      bitrate: json['bitrate'] as int? ?? 128,
      sampleRate: json['sampleRate'] as int? ?? 44100,
      channels: json['channels'] as int? ?? 1,
      averageVolume: (json['averageVolume'] as num?)?.toDouble() ?? 0.7,
      peakVolume: (json['peakVolume'] as num?)?.toDouble() ?? 1.0,
      technicalData: Map<String, dynamic>.from(json['technicalData'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModifiedAt: json['lastModifiedAt'] != null 
          ? DateTime.parse(json['lastModifiedAt'] as String)
          : null,
    );
  }

  AudioMetadata copyWith({
    String? audioId,
    String? title,
    String? description,
    Duration? duration,
    int? fileSizeBytes,
    String? format,
    int? bitrate,
    int? sampleRate,
    int? channels,
    double? averageVolume,
    double? peakVolume,
    Map<String, dynamic>? technicalData,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  }) {
    return AudioMetadata(
      audioId: audioId ?? this.audioId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      format: format ?? this.format,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      averageVolume: averageVolume ?? this.averageVolume,
      peakVolume: peakVolume ?? this.peakVolume,
      technicalData: technicalData ?? this.technicalData,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  String toString() {
    return 'AudioMetadata(title: $title, duration: $formattedDuration, size: $formattedFileSize, quality: $qualityDescription)';
  }
}

/// Audio processing queue item for background operations
class AudioProcessingTask {
  final String taskId;
  final String audioId;
  final AudioProcessingType type;
  final Map<String, dynamic> parameters;
  final AudioProcessingStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final double progress; // 0.0 - 1.0

  const AudioProcessingTask({
    required this.taskId,
    required this.audioId,
    required this.type,
    this.parameters = const {},
    this.status = AudioProcessingStatus.pending,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.progress = 0.0,
  });

  /// Check if task is completed
  bool get isCompleted => status == AudioProcessingStatus.completed;

  /// Check if task failed
  bool get isFailed => status == AudioProcessingStatus.failed;

  /// Check if task is running
  bool get isRunning => status == AudioProcessingStatus.processing;

  /// Get estimated completion time
  DateTime? get estimatedCompletion {
    if (!isRunning || startedAt == null || progress <= 0) return null;
    
    final elapsed = DateTime.now().difference(startedAt!);
    final totalTime = elapsed.inMilliseconds / progress;
    return startedAt!.add(Duration(milliseconds: totalTime.round()));
  }

  AudioProcessingTask copyWith({
    String? taskId,
    String? audioId,
    AudioProcessingType? type,
    Map<String, dynamic>? parameters,
    AudioProcessingStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    double? progress,
  }) {
    return AudioProcessingTask(
      taskId: taskId ?? this.taskId,
      audioId: audioId ?? this.audioId,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() {
    return 'AudioProcessingTask(id: $taskId, type: $type, status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}

enum AudioProcessingType {
  generation,
  compression,
  normalization,
  hashtagging,
  transcription,
  analysis,
}

enum AudioProcessingStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}
