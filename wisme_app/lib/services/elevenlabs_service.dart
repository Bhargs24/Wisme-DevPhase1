import '../core/exports.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  static const String _voicesEndpoint = '/voices';
  static const String _ttsEndpoint = '/text-to-speech';
  
  final http.Client _client;
  final String _serviceName = 'ElevenLabsService';
  late String _apiKey;

  ElevenLabsService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Initialize the service with API key
  Future<void> initialize() async {
    try {
      _apiKey = ApiKeys.elevenLabsApiKey;
      if (_apiKey == 'your-elevenlabs-api-key-here') {
        throw Exception('ElevenLabs API key not configured');
      }
      AppLogger.info('$_serviceName: Service initialized successfully');
    } catch (e) {
      AppLogger.error('$_serviceName: Failed to initialize service', e);
      rethrow;
    }
  }

  /// Get all available voices from ElevenLabs
  Future<Result<List<Voice>>> getAvailableVoices() async {
    try {
      AppLogger.info('$_serviceName: Fetching available voices from ElevenLabs');

      final response = await _client.get(
        Uri.parse('$_baseUrl$_voicesEndpoint'),
        headers: {
          'Accept': 'application/json',
          'xi-api-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final voicesData = data['voices'] as List;
        
        final voices = voicesData
            .map((voiceData) => Voice.fromElevenLabsAPI(voiceData))
            .toList();

        AppLogger.info('$_serviceName: Successfully fetched ${voices.length} voices');
        return Result.success(voices);
      } else {
        return _handleErrorResponse(response, 'Failed to fetch voices');
      }
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error fetching voices', e, stackTrace);
      return Result.failure(AIFailure(
        message: 'Failed to fetch available voices',
        code: 'voices_fetch_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Synthesize speech from text using specified voice
  Future<Result<AudioGenerationResult>> synthesizeSpeech({
    required String text,
    required String voiceId,
    Map<String, dynamic>? voiceSettings,
    String? outputPath,
  }) async {
    try {
      AppLogger.info('$_serviceName: Synthesizing speech for voice: $voiceId');

      // Validate input
      if (text.trim().isEmpty) {
        return Result.failure(ValidationFailure(
          message: 'Text cannot be empty',
          code: 'empty_text',
        ));
      }

      if (text.length > 5000) {
        return Result.failure(ValidationFailure(
          message: 'Text too long (max 5000 characters)',
          code: 'text_too_long',
        ));
      }

      final requestBody = {
        'text': text,
        'model_id': 'eleven_turbo_v2',
        'voice_settings': voiceSettings ?? {
          'stability': 0.75,
          'similarity_boost': 0.75,
          'style': 0.0,
          'use_speaker_boost': true,
        },
      };

      final response = await _client.post(
        Uri.parse('$_baseUrl$_ttsEndpoint/$voiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        String filePath;
        
        if (outputPath != null) {
          filePath = outputPath;
        } else {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          filePath = 'audio_${voiceId}_$timestamp.mp3';
        }

        // Save audio file
        final file = File(filePath);
        await file.writeAsBytes(audioBytes);

        final result = AudioGenerationResult(
          audioPath: filePath,
          voiceId: voiceId,
          text: text,
          duration: await _estimateAudioDuration(audioBytes.length),
          fileSizeBytes: audioBytes.length,
          generatedAt: DateTime.now(),
          voiceSettings: Map<String, dynamic>.from(requestBody['voice_settings'] as Map),
        );

        AppLogger.info('$_serviceName: Successfully synthesized speech: ${result.audioPath}');
        return Result.success(result);
      } else {
        return _handleErrorResponse(response, 'Speech synthesis failed');
      }
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error synthesizing speech', e, stackTrace);
      return Result.failure(AIFailure(
        message: 'Failed to synthesize speech',
        code: 'synthesis_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Get voice details by ID
  Future<Result<Voice>> getVoiceById(String voiceId) async {
    try {
      AppLogger.info('$_serviceName: Fetching voice details for ID: $voiceId');

      final response = await _client.get(
        Uri.parse('$_baseUrl$_voicesEndpoint/$voiceId'),
        headers: {
          'Accept': 'application/json',
          'xi-api-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final voiceData = json.decode(response.body);
        final voice = Voice.fromElevenLabsAPI(voiceData);
        
        AppLogger.info('$_serviceName: Successfully fetched voice details');
        return Result.success(voice);
      } else {
        return _handleErrorResponse(response, 'Failed to fetch voice details');
      }
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error fetching voice details', e, stackTrace);
      return Result.failure(AIFailure(
        message: 'Failed to fetch voice details',
        code: 'voice_fetch_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Get account usage and subscription info
  Future<Result<ElevenLabsUsage>> getUsageInfo() async {
    try {
      AppLogger.info('$_serviceName: Fetching ElevenLabs usage information');

      final response = await _client.get(
        Uri.parse('$_baseUrl/user/subscription'),
        headers: {
          'Accept': 'application/json',
          'xi-api-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final usage = ElevenLabsUsage.fromJson(data);
        
        AppLogger.info('$_serviceName: Successfully fetched usage information');
        return Result.success(usage);
      } else {
        return _handleErrorResponse(response, 'Failed to fetch usage info');
      }
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error fetching usage info', e, stackTrace);
      return Result.failure(AIFailure(
        message: 'Failed to fetch usage information',
        code: 'usage_fetch_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Validate API key
  Future<Result<bool>> validateApiKey() async {
    try {
      AppLogger.info('$_serviceName: Validating ElevenLabs API key');

      final response = await _client.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'xi-api-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.info('$_serviceName: API key is valid');
        return Result.success(true);
      } else if (response.statusCode == 401) {
        return Result.failure(AuthFailure(
          message: 'Invalid API key',
          code: 'invalid_api_key',
        ));
      } else {
        return _handleErrorResponse(response, 'API key validation failed');
      }
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error validating API key', e, stackTrace);
      return Result.failure(NetworkFailure(
        message: 'Failed to validate API key',
        code: 'validation_failed',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Handle error responses from API
  Result<T> _handleErrorResponse<T>(http.Response response, String context) {
    final statusCode = response.statusCode;
    String errorMessage = context;
    String errorCode = 'unknown_error';

    try {
      final errorData = json.decode(response.body);
      errorMessage = errorData['detail']?['message'] ?? errorData['message'] ?? context;
      errorCode = errorData['detail']?['status'] ?? 'api_error';
    } catch (e) {
      // If we can't parse the error response, use default values
    }

    AppLogger.error('$_serviceName: API Error [$statusCode]: $errorMessage');

    switch (statusCode) {
      case 401:
        return Result.failure(AuthFailure(
          message: errorMessage,
          code: 'unauthorized',
        ));
      case 402:
        return Result.failure(AIFailure(
          message: 'Insufficient credits or quota exceeded',
          code: 'quota_exceeded',
        ));
      case 422:
        return Result.failure(ValidationFailure(
          message: errorMessage,
          code: 'validation_failed',
        ));
      case 429:
        return Result.failure(AIFailure(
          message: 'Rate limit exceeded',
          code: 'rate_limited',
        ));
      case 500:
        return Result.failure(AIFailure(
          message: 'ElevenLabs server error',
          code: 'server_error',
        ));
      default:
        return Result.failure(AIFailure(
          message: errorMessage,
          code: errorCode,
        ));
    }
  }

  /// Estimate audio duration based on file size (rough approximation)
  Future<Duration> _estimateAudioDuration(int fileSizeBytes) async {
    // Rough estimation: MP3 at 128kbps = ~16KB per second
    const bytesPerSecond = 16 * 1024;
    final seconds = fileSizeBytes / bytesPerSecond;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
    AppLogger.info('$_serviceName: Service disposed');
  }
}

/// Audio generation result
class AudioGenerationResult {
  final String audioPath;
  final String voiceId;
  final String text;
  final Duration duration;
  final int fileSizeBytes;
  final DateTime generatedAt;
  final Map<String, dynamic> voiceSettings;

  const AudioGenerationResult({
    required this.audioPath,
    required this.voiceId,
    required this.text,
    required this.duration,
    required this.fileSizeBytes,
    required this.generatedAt,
    required this.voiceSettings,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'audio_path': audioPath,
      'voice_id': voiceId,
      'text': text,
      'duration_ms': duration.inMilliseconds,
      'file_size_bytes': fileSizeBytes,
      'generated_at': generatedAt.toIso8601String(),
      'voice_settings': voiceSettings,
    };
  }

  /// Create from JSON
  factory AudioGenerationResult.fromJson(Map<String, dynamic> json) {
    return AudioGenerationResult(
      audioPath: json['audio_path'],
      voiceId: json['voice_id'],
      text: json['text'],
      duration: Duration(milliseconds: json['duration_ms']),
      fileSizeBytes: json['file_size_bytes'],
      generatedAt: DateTime.parse(json['generated_at']),
      voiceSettings: json['voice_settings'],
    );
  }
}

/// ElevenLabs usage information
class ElevenLabsUsage {
  final int charactersUsed;
  final int charactersLimit;
  final DateTime nextResetDate;
  final String tier;
  final Map<String, dynamic> voiceUsage;

  const ElevenLabsUsage({
    required this.charactersUsed,
    required this.charactersLimit,
    required this.nextResetDate,
    required this.tier,
    required this.voiceUsage,
  });

  /// Create from JSON
  factory ElevenLabsUsage.fromJson(Map<String, dynamic> json) {
    return ElevenLabsUsage(
      charactersUsed: json['character_count'] ?? 0,
      charactersLimit: json['character_limit'] ?? 0,
      nextResetDate: DateTime.parse(json['next_character_count_reset_unix'].toString()),
      tier: json['tier'] ?? 'free',
      voiceUsage: json['voice_usage'] ?? {},
    );
  }

  /// Get usage percentage
  double get usagePercentage {
    if (charactersLimit == 0) return 0.0;
    return charactersUsed / charactersLimit;
  }

  /// Get remaining characters
  int get charactersRemaining => charactersLimit - charactersUsed;

  /// Check if approaching limit (>80% used)
  bool get isApproachingLimit => usagePercentage > 0.8;
}

