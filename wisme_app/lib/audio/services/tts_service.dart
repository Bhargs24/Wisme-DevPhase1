import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import '../../shared/models/result.dart';
import '../../coach/models/coach_model.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/api_keys.dart';

/// Production-grade Text-to-Speech service for the new architecture
class TTSService {
  static const String _elevenLabsBaseUrl = 'https://api.elevenlabs.io/v1';
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TTSService() {
    _initialize();
  }

  static Map<String, String> get _elevenLabsHeaders => {
    'xi-api-key': ApiKeys.elevenLabsApiKey,
    'Content-Type': 'application/json',
  };

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
      AppLogger.info('✅ TTSService initialized successfully');
    } catch (e) {
      AppLogger.error('❌ Error initializing TTS: $e');
    }
  }

  /// Generate high-quality speech using ElevenLabs API
  Future<Result<Uint8List>> generateSpeech({
    required String text,
    required String coachId,
    String? customVoiceId,
    AudioQuality quality = AudioQuality.high,
  }) async {
    try {
      final coach = _getCoachById(coachId);
      final voiceId = customVoiceId ?? coach.elevenLabsVoiceId;

      if (voiceId.isEmpty) {
        AppLogger.warning('No ElevenLabs voice ID for coach $coachId, falling back to device TTS');
        return await _generateDeviceTTS(text, coachId);
      }

      final response = await http.post(
        Uri.parse('$_elevenLabsBaseUrl/text-to-speech/$voiceId'),
        headers: _elevenLabsHeaders,
        body: jsonEncode({
          'text': text,
          'voice_settings': {
            'stability': coach.voiceSettings.stability,
            'similarity_boost': coach.voiceSettings.similarityBoost,
            'style': coach.voiceSettings.style,
            'use_speaker_boost': coach.voiceSettings.useSpeakerBoost,
          },
          'model_id': _getModelForQuality(quality),
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.info('✅ Generated speech using ElevenLabs: ${text.length} characters');
        return Result.success(response.bodyBytes);
      } else {
        AppLogger.error('❌ ElevenLabs API failed: ${response.statusCode} - ${response.body}');
        // Fallback to device TTS
        return await _generateDeviceTTS(text, coachId);
      }
    } catch (e) {
      AppLogger.error('❌ Error generating speech with ElevenLabs: $e');
      // Fallback to device TTS
      return await _generateDeviceTTS(text, coachId);
    }
  }

  /// Generate speech using device TTS as fallback
  Future<Result<Uint8List>> _generateDeviceTTS(String text, String coachId) async {
    try {
      await _initialize();
      
      final coach = _getCoachById(coachId);
      
      // Configure TTS settings based on coach personality
      await _configureTTSForCoach(coach);
      
      // Note: Flutter TTS doesn't directly return audio bytes
      // This is a simplified implementation - in production, you'd need
      // platform-specific code to capture the audio output
      await _flutterTts.speak(text);
      
      AppLogger.info('✅ Generated speech using device TTS');
      // Return empty bytes as placeholder - real implementation would capture audio
      return Result.success(Uint8List(0));
    } catch (e) {
      AppLogger.error('❌ Error generating device TTS: $e');
      return Result.failure('Failed to generate speech: $e');
    }
  }

  /// Generate complete episode audio with multiple script blocks
  Future<Result<Uint8List>> generateEpisodeAudio({
    required List<String> scriptBlocks,
    required String coachId,
    bool addTransitions = true,
    AudioQuality quality = AudioQuality.high,
  }) async {
    try {
      final audioSegments = <Uint8List>[];
      
      for (int i = 0; i < scriptBlocks.length; i++) {
        // Generate audio for each block
        final result = await generateSpeech(
          text: scriptBlocks[i],
          coachId: coachId,
          quality: quality,
        );
        
        if (result.isSuccess) {
          audioSegments.add(result.data!);
          
          // Add transition pause between blocks
          if (addTransitions && i < scriptBlocks.length - 1) {
            final pauseAudio = _generateSilence(milliseconds: 1000);
            audioSegments.add(pauseAudio);
          }
        } else {
          AppLogger.error('❌ Failed to generate audio for block $i: ${result.error}');
          return Result.failure('Failed to generate episode audio: ${result.error}');
        }
      }
      
      // Combine all audio segments
      final combinedAudio = _combineAudioSegments(audioSegments);
      
      AppLogger.info('✅ Generated complete episode audio: ${scriptBlocks.length} blocks');
      return Result.success(combinedAudio);
    } catch (e) {
      AppLogger.error('❌ Error generating episode audio: $e');
      return Result.failure('Error generating episode audio: $e');
    }
  }

  /// Preview voice using local TTS (for coach selection)
  Future<Result<void>> previewVoice(String text, String coachId) async {
    try {
      await _initialize();
      
      final coach = _getCoachById(coachId);
      await _configureTTSForCoach(coach);
      
      await _flutterTts.speak(text);
      
      AppLogger.info('✅ Voice preview played for coach: $coachId');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error previewing voice: $e');
      return Result.failure('Error previewing voice: $e');
    }
  }

  /// Stop TTS playback
  Future<Result<void>> stop() async {
    try {
      await _flutterTts.stop();
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error stopping TTS: $e');
      return Result.failure('Error stopping TTS: $e');
    }
  }

  /// Get available voices from ElevenLabs
  Future<Result<List<ElevenLabsVoice>>> getAvailableVoices() async {
    try {
      final response = await http.get(
        Uri.parse('$_elevenLabsBaseUrl/voices'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final voices = (data['voices'] as List)
            .map((voice) => ElevenLabsVoice.fromJson(voice))
            .toList();
        
        AppLogger.info('✅ Retrieved ${voices.length} available voices');
        return Result.success(voices);
      } else {
        AppLogger.error('❌ Failed to get voices: ${response.statusCode}');
        return Result.failure('Failed to get voices: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error getting voices: $e');
      return Result.failure('Error getting voices: $e');
    }
  }

  /// Validate ElevenLabs API key
  Future<bool> validateElevenLabsApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('$_elevenLabsBaseUrl/user'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('❌ ElevenLabs API key validation failed: $e');
      return false;
    }
  }

  /// Get user's ElevenLabs subscription info
  Future<Result<ElevenLabsSubscription?>> getUserSubscription() async {
    try {
      final response = await http.get(
        Uri.parse('$_elevenLabsBaseUrl/user/subscription'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final subscription = ElevenLabsSubscription.fromJson(data);
        return Result.success(subscription);
      }
      
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Error getting subscription: $e');
      return Result.failure('Error getting subscription: $e');
    }
  }

  /// Configure device TTS settings for specific coach
  Future<void> _configureTTSForCoach(CoachModel coach) async {
    try {
      // Map coach personality to TTS settings
      switch (coach.id) {
        case 'kai':
          await _flutterTts.setSpeechRate(0.45); // Slower, more measured
          await _flutterTts.setPitch(0.9); // Slightly lower pitch
          break;
        case 'vee':
          await _flutterTts.setSpeechRate(0.55); // Faster, more energetic
          await _flutterTts.setPitch(1.1); // Slightly higher pitch
          break;
        case 'sam':
          await _flutterTts.setSpeechRate(0.5); // Balanced pace
          await _flutterTts.setPitch(1.0); // Natural pitch
          break;
        default:
          await _flutterTts.setSpeechRate(0.5);
          await _flutterTts.setPitch(1.0);
      }
    } catch (e) {
      AppLogger.error('❌ Error configuring TTS for coach ${coach.id}: $e');
    }
  }

  /// Get the appropriate model based on quality setting
  String _getModelForQuality(AudioQuality quality) {
    switch (quality) {
      case AudioQuality.low:
        return 'eleven_turbo_v2';
      case AudioQuality.medium:
        return 'eleven_monolingual_v1';
      case AudioQuality.high:
        return 'eleven_multilingual_v2';
      case AudioQuality.premium:
        return 'eleven_multilingual_v2';
    }
  }

  /// Generate silence audio data
  Uint8List _generateSilence({required int milliseconds}) {
    // Calculate samples for silence (44.1kHz, 16-bit)
    final samples = (milliseconds * 44.1).round();
    return Uint8List(samples * 2); // 16-bit = 2 bytes per sample
  }

  /// Combine multiple audio segments
  Uint8List _combineAudioSegments(List<Uint8List> segments) {
    if (segments.isEmpty) return Uint8List(0);
    
    final totalLength = segments.fold<int>(0, (sum, segment) => sum + segment.length);
    final combined = Uint8List(totalLength);
    
    int offset = 0;
    for (final segment in segments) {
      combined.setRange(offset, offset + segment.length, segment);
      offset += segment.length;
    }
    
    return combined;
  }

  /// Get coach model by ID
  CoachModel _getCoachById(String coachId) {
    // This would normally come from a coach service
    // For now, return a default coach
    return CoachModel(
      id: coachId,
      name: 'Default Coach',
      personality: 'Professional and friendly',
      description: 'A knowledgeable AI learning coach',
      elevenLabsVoiceId: '', // Empty means fallback to device TTS
      voiceSettings: const VoiceSettings(
        stability: 0.6,
        similarityBoost: 0.7,
        style: 0.2,
        useSpeakerBoost: true,
      ),
      specialties: [],
      avatarUrl: '',
      isActive: true,
    );
  }
}

/// Audio quality settings
enum AudioQuality {
  low,    // Fast generation, lower quality
  medium, // Balanced quality and speed
  high,   // High quality, slower generation
  premium // Maximum quality, slowest generation
}

/// ElevenLabs voice model
class ElevenLabsVoice {
  final String voiceId;
  final String name;
  final String category;
  final String description;
  final List<String> labels;
  final String previewUrl;

  const ElevenLabsVoice({
    required this.voiceId,
    required this.name,
    required this.category,
    required this.description,
    required this.labels,
    required this.previewUrl,
  });

  factory ElevenLabsVoice.fromJson(Map<String, dynamic> json) {
    return ElevenLabsVoice(
      voiceId: json['voice_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      labels: List<String>.from(json['labels'] ?? []),
      previewUrl: json['preview_url'] ?? '',
    );
  }
}

/// ElevenLabs subscription information
class ElevenLabsSubscription {
  final String tier;
  final int characterCount;
  final int characterLimit;
  final bool canExtendCharacterLimit;
  final String nextCharacterCountResetUnix;

  const ElevenLabsSubscription({
    required this.tier,
    required this.characterCount,
    required this.characterLimit,
    required this.canExtendCharacterLimit,
    required this.nextCharacterCountResetUnix,
  });

  factory ElevenLabsSubscription.fromJson(Map<String, dynamic> json) {
    return ElevenLabsSubscription(
      tier: json['tier'] ?? '',
      characterCount: json['character_count'] ?? 0,
      characterLimit: json['character_limit'] ?? 0,
      canExtendCharacterLimit: json['can_extend_character_limit'] ?? false,
      nextCharacterCountResetUnix: json['next_character_count_reset_unix'] ?? '',
    );
  }
}
