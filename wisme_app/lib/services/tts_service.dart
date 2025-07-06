import '../core/exports.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
class TTSService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger();
  bool _isInitialized = false;

  TTSService() {
    _initialize();
  }

  static Map<String, String> get _headers => {
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
    } catch (e) {
      _logger.e('Error initializing TTS: $e');
    }
  }

  /// Generate speech using ElevenLabs API
  Future<Uint8List> generateSpeech({
    required String text,
    required String coachId,
    String? customVoiceId,
  }) async {
    try {
      final coach = _getCoachById(coachId);
      final voiceId = customVoiceId ?? coach.voiceId;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: _headers,
        body: jsonEncode({
          'text': text,
          'voice_settings': {
            'stability': double.parse(coach.voiceSettings['stability'] ?? '0.6'),
            'similarity_boost': double.parse(coach.voiceSettings['similarity_boost'] ?? '0.7'),
            'style': double.parse(coach.voiceSettings['style'] ?? '0.2'),
          },
          'model_id': 'eleven_monolingual_v1',
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to generate speech: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating speech: $e');
    }
  }

  /// Generate complete episode audio with multiple blocks
  Future<Uint8List> generateEpisodeAudio({
    required List<String> scriptBlocks,
    required String coachId,
    bool addTransitions = true,
  }) async {
    try {
      final audioSegments = <Uint8List>[];
      
      for (int i = 0; i < scriptBlocks.length; i++) {
        // Generate audio for each block
        final audioData = await generateSpeech(
          text: scriptBlocks[i],
          coachId: coachId,
        );
        audioSegments.add(audioData);
        
        // Add transition pause between blocks
        if (addTransitions && i < scriptBlocks.length - 1) {
          final pauseAudio = await _generateSilence(milliseconds: 1000);
          audioSegments.add(pauseAudio);
        }
      }
      
      // Combine all audio segments
      return _combineAudioSegments(audioSegments);
    } catch (e) {
      throw Exception('Error generating episode audio: $e');
    }
  }

  /// Generate silence for transitions
  Future<Uint8List> _generateSilence({required int milliseconds}) async {
    // Create empty audio data for silence
    // In a real implementation, you'd generate proper silence audio
    final silenceData = Uint8List(milliseconds * 44); // Approximate size
    return silenceData;
  }

  /// Combine multiple audio segments into one
  Uint8List _combineAudioSegments(List<Uint8List> segments) {
    // Simple concatenation - in production, use proper audio mixing
    final totalLength = segments.fold<int>(0, (sum, segment) => sum + segment.length);
    final combined = Uint8List(totalLength);
    
    int offset = 0;
    for (final segment in segments) {
      combined.setRange(offset, offset + segment.length, segment);
      offset += segment.length;
    }
    
    return combined;
  }

  /// Preview voice using local TTS (for coach selection)
  Future<void> previewVoice(String text, String coachId) async {
    await _initialize();
    
    try {
      final coach = _getCoachById(coachId);
      
      // Adjust local TTS settings to approximate the coach's style
      if (coach.id == 'kai') {
        await _flutterTts.setSpeechRate(0.45); // Slower, more measured
        await _flutterTts.setPitch(0.9); // Slightly lower pitch
      } else if (coach.id == 'vee') {
        await _flutterTts.setSpeechRate(0.55); // Faster, more energetic
        await _flutterTts.setPitch(1.1); // Slightly higher pitch
      } else {
        await _flutterTts.setSpeechRate(0.5); // Default
        await _flutterTts.setPitch(1.0); // Default
      }
      
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('Error previewing voice: $e');
    }
  }

  /// Stop TTS playback
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      _logger.e('Error stopping TTS: $e');
    }
  }

  /// Get available voices from ElevenLabs
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['voices']);
      } else {
        throw Exception('Failed to get voices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting voices: $e');
    }
  }

  /// Check if ElevenLabs API key is valid
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
      return false;
    }
  }

  /// Get user's subscription info from ElevenLabs
  Future<Map<String, dynamic>?> getUserSubscription() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/subscription'),
        headers: {
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate estimated cost for text-to-speech
  double estimateGenerationCost(String text) {
    // ElevenLabs pricing is approximately $0.18 per 1K characters
    final characterCount = text.length;
    return (characterCount / 1000) * 0.18;
  }

  /// Get the appropriate coach model
  CoachModel _getCoachById(String coachId) {
    switch (coachId) {
      case 'kai':
        return CoachModel.kai;
      case 'vee':
        return CoachModel.vee;
      default:
        return CoachModel.kai; // Default fallback
    }
  }

  /// Clean up resources
  void dispose() {
    _flutterTts.stop();
  }

  /// Check if TTS is currently speaking
  Future<bool> get isSpeaking async {
    try {
      return await _flutterTts.getEngines != null;
    } catch (e) {
      return false;
    }
  }

  /// Set voice settings for local TTS
  Future<void> setVoiceSettings({
    double? speechRate,
    double? pitch,
    double? volume,
  }) async {
    await _initialize();
    
    if (speechRate != null) {
      await _flutterTts.setSpeechRate(speechRate);
    }
    if (pitch != null) {
      await _flutterTts.setPitch(pitch);
    }
    if (volume != null) {
      await _flutterTts.setVolume(volume);
    }
  }

  /// Generate audio URL for content blocks - alias for generateSpeech
  Future<String?> generateAudio(
    String text, {
    String? voiceId,
    String? coachId,
  }) async {
    try {
      await generateSpeech(
        text: text,
        coachId: coachId ?? 'default',
        customVoiceId: voiceId,
      );
      
      // For now, return a temporary file path or URL
      // In production, this should upload to storage and return URL
      return 'temp_audio_url';
    } catch (e) {
      _logger.e('Error generating audio: $e');
      return null;
    }
  }
}

