import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../shared/models/result.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/api_keys.dart';

/// Production-grade ElevenLabs API service for premium voice synthesis
class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  static Map<String, String> get _headers => {
    'xi-api-key': ApiKeys.elevenLabsApiKey,
    'Content-Type': 'application/json',
  };

  /// Generate speech using ElevenLabs API
  Future<Result<Uint8List>> generateSpeech({
    required String text,
    required String voiceId,
    VoiceSettings? voiceSettings,
    String model = 'eleven_multilingual_v2',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: _headers,
        body: jsonEncode({
          'text': text,
          'voice_settings': voiceSettings?.toJson() ?? VoiceSettings.defaults().toJson(),
          'model_id': model,
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.info('✅ Generated speech using ElevenLabs: ${text.length} characters');
        return Result.success(response.bodyBytes);
      } else {
        AppLogger.error('❌ ElevenLabs API failed: ${response.statusCode} - ${response.body}');
        return Result.failure('ElevenLabs API failed: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error generating speech with ElevenLabs: $e');
      return Result.failure('Error generating speech: $e');
    }
  }

  /// Get available voices from ElevenLabs
  Future<Result<List<ElevenLabsVoice>>> getAvailableVoices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices'),
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
  Future<bool> validateApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
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
        Uri.parse('$_baseUrl/user/subscription'),
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

  /// Get voice settings for a specific voice
  Future<Result<VoiceSettings>> getVoiceSettings(String voiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices/$voiceId/settings'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final settings = VoiceSettings.fromJson(data);
        return Result.success(settings);
      } else {
        AppLogger.error('❌ Failed to get voice settings: ${response.statusCode}');
        return Result.failure('Failed to get voice settings: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error getting voice settings: $e');
      return Result.failure('Error getting voice settings: $e');
    }
  }

  /// Clone a voice (requires premium subscription)
  Future<Result<String>> cloneVoice({
    required String name,
    required String description,
    required List<Uint8List> audioSamples,
    List<String>? labels,
  }) async {
    try {
      // This is a simplified implementation
      // In production, you'd handle multipart/form-data uploads
      final response = await http.post(
        Uri.parse('$_baseUrl/voices/add'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
        // Note: Real implementation would use multipart form data
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final voiceId = data['voice_id'] as String;
        AppLogger.info('✅ Voice cloned successfully: $voiceId');
        return Result.success(voiceId);
      } else {
        AppLogger.error('❌ Voice cloning failed: ${response.statusCode}');
        return Result.failure('Voice cloning failed: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error cloning voice: $e');
      return Result.failure('Error cloning voice: $e');
    }
  }

  /// Delete a cloned voice
  Future<Result<void>> deleteVoice(String voiceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/voices/$voiceId'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.info('✅ Voice deleted successfully: $voiceId');
        return Result.success(null);
      } else {
        AppLogger.error('❌ Voice deletion failed: ${response.statusCode}');
        return Result.failure('Voice deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error deleting voice: $e');
      return Result.failure('Error deleting voice: $e');
    }
  }
}

/// Voice settings for ElevenLabs voices
class VoiceSettings {
  final double stability;
  final double similarityBoost;
  final double style;
  final bool useSpeakerBoost;

  const VoiceSettings({
    required this.stability,
    required this.similarityBoost,
    required this.style,
    required this.useSpeakerBoost,
  });

  factory VoiceSettings.defaults() {
    return const VoiceSettings(
      stability: 0.6,
      similarityBoost: 0.7,
      style: 0.2,
      useSpeakerBoost: true,
    );
  }

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    return VoiceSettings(
      stability: (json['stability'] as num?)?.toDouble() ?? 0.6,
      similarityBoost: (json['similarity_boost'] as num?)?.toDouble() ?? 0.7,
      style: (json['style'] as num?)?.toDouble() ?? 0.2,
      useSpeakerBoost: json['use_speaker_boost'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stability': stability,
      'similarity_boost': similarityBoost,
      'style': style,
      'use_speaker_boost': useSpeakerBoost,
    };
  }
}

/// ElevenLabs voice model
class ElevenLabsVoice {
  final String voiceId;
  final String name;
  final String category;
  final String description;
  final List<String> labels;
  final String previewUrl;
  final VoiceSettings settings;

  const ElevenLabsVoice({
    required this.voiceId,
    required this.name,
    required this.category,
    required this.description,
    required this.labels,
    required this.previewUrl,
    required this.settings,
  });

  factory ElevenLabsVoice.fromJson(Map<String, dynamic> json) {
    return ElevenLabsVoice(
      voiceId: json['voice_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      labels: List<String>.from(json['labels'] ?? []),
      previewUrl: json['preview_url'] ?? '',
      settings: VoiceSettings.fromJson(json['settings'] ?? {}),
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
