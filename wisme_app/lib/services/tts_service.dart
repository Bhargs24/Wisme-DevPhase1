import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_keys.dart';
import '../models/api_response_model.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  TTSService() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  // Local TTS for voice previews
  Future<void> speak(String text, {String voice = 'default'}) async {
    await _initialize();
    
    // Set voice parameters based on voice type
    switch (voice) {
      case 'female':
        await _flutterTts.setPitch(1.2);
        await _flutterTts.setSpeechRate(0.5);
        break;
      case 'male':
        await _flutterTts.setPitch(0.8);
        await _flutterTts.setSpeechRate(0.45);
        break;
      case 'robot':
        await _flutterTts.setPitch(0.6);
        await _flutterTts.setSpeechRate(0.3);
        break;
      case 'child':
        await _flutterTts.setPitch(1.5);
        await _flutterTts.setSpeechRate(0.6);
        break;
      default:
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
    }

    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  // Generate high-quality audio for lessons using external API
  Future<ApiResponse<TTSResponse>> generateAudio(
    String text, {
    String voice = 'default',
    String format = 'mp3',
  }) async {
    try {
      // This would be replaced with actual TTS API integration
      // For now, using a mock implementation
      final response = await _mockTTSAPI(text, voice, format);
      
      if (response.success && response.data != null) {
        return ApiResponse.success(response.data!);
      } else {
        return ApiResponse.error(response.error ?? 'TTS generation failed');
      }
    } catch (e) {
      return ApiResponse.error('TTS service error: $e');
    }
  }

  // Mock TTS API - replace with actual service integration
  Future<ApiResponse<TTSResponse>> _mockTTSAPI(String text, String voice, String format) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock audio data (in real implementation, this would be actual audio)
      final mockAudioData = List.generate(1000, (index) => index % 256);
      final estimatedDuration = (text.length / 10).ceil(); // Rough estimate
      
      final ttsResponse = TTSResponse(
        audioData: mockAudioData,
        durationSeconds: estimatedDuration,
        format: format,
        sampleRate: 22050,
      );
      
      return ApiResponse.success(ttsResponse);
    } catch (e) {
      return ApiResponse.error('Mock TTS error: $e');
    }
  }

  // Real TTS API integration example (commented out)
  /*
  Future<ApiResponse<TTSResponse>> _callExternalTTSAPI(String text, String voice, String format) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': ApiKeys.elevenLabsApiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.5,
          }
        }),
      );

      if (response.statusCode == 200) {
        final audioData = response.bodyBytes;
        final ttsResponse = TTSResponse(
          audioData: audioData,
          durationSeconds: _estimateDuration(text),
          format: format,
          sampleRate: 22050,
        );
        return ApiResponse.success(ttsResponse);
      } else {
        return ApiResponse.error('TTS API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  */

  int _estimateDuration(String text) {
    // Rough estimation: ~150 words per minute, ~5 characters per word
    const wordsPerMinute = 150;
    const charactersPerWord = 5;
    final estimatedWords = text.length / charactersPerWord;
    final estimatedMinutes = estimatedWords / wordsPerMinute;
    return (estimatedMinutes * 60).ceil();
  }

  // Get available voices
  Future<List<String>> getAvailableVoices() async {
    await _initialize();
    return ['default', 'female', 'male', 'robot', 'child'];
  }

  // Set TTS settings
  Future<void> setSettings({
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    await _initialize();
    
    if (speechRate != null) {
      await _flutterTts.setSpeechRate(speechRate);
    }
    if (volume != null) {
      await _flutterTts.setVolume(volume);
    }
    if (pitch != null) {
      await _flutterTts.setPitch(pitch);
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
