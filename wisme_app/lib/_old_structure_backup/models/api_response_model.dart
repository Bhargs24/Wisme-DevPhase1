// Data models for API responses

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(
      success: true,
      data: data,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

class GPTResponse {
  final String content;
  final String title;
  final String summary;
  final List<String> tags;
  final int wordCount;

  GPTResponse({
    required this.content,
    required this.title,
    required this.summary,
    required this.tags,
    required this.wordCount,
  });

  factory GPTResponse.fromMap(Map<String, dynamic> map) {
    return GPTResponse(
      content: map['content'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      wordCount: map['word_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'title': title,
      'summary': summary,
      'tags': tags,
      'word_count': wordCount,
    };
  }
}

class TTSResponse {
  final List<int> audioData;
  final int durationSeconds;
  final String format;
  final int sampleRate;

  TTSResponse({
    required this.audioData,
    required this.durationSeconds,
    required this.format,
    required this.sampleRate,
  });

  factory TTSResponse.fromMap(Map<String, dynamic> map) {
    return TTSResponse(
      audioData: List<int>.from(map['audio_data'] ?? []),
      durationSeconds: map['duration_seconds'] ?? 0,
      format: map['format'] ?? 'mp3',
      sampleRate: map['sample_rate'] ?? 22050,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'audio_data': audioData,
      'duration_seconds': durationSeconds,
      'format': format,
      'sample_rate': sampleRate,
    };
  }
}
