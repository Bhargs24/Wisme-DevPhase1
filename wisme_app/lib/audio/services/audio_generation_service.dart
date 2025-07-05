import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/audio_metadata.dart';
import '../services/audio_cache_manager.dart';

/// Production-grade audio generation service
/// Integrates with Text-to-Speech APIs and manages audio generation
class AudioGenerationService {
  final AudioCacheManager _cacheManager;
  final String _apiKey;
  final String _baseUrl;

  // Generation settings
  AudioGenerationSettings _defaultSettings = const AudioGenerationSettings();

  AudioGenerationService({
    required AudioCacheManager cacheManager,
    required String apiKey,
    String baseUrl = 'https://api.openai.com/v1/audio/speech',
  }) : _cacheManager = cacheManager,
       _apiKey = apiKey,
       _baseUrl = baseUrl;

  /// Generate audio from text using OpenAI TTS
  Future<AudioGenerationResult> generateAudioFromText({
    required String text,
    AudioGenerationSettings? settings,
    List<String> hashtags = const [],
    Map<String, dynamic> customMetadata = const {},
  }) async {
    final generationSettings = settings ?? _defaultSettings;
    
    try {
      // Prepare request
      final requestBody = {
        'model': generationSettings.model,
        'input': text,
        'voice': generationSettings.voice,
        'response_format': generationSettings.format,
        'speed': generationSettings.speed,
      };

      // Make API request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw AudioGenerationException(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }

      // Get audio data
      final audioData = response.bodyBytes;
      
      // Create metadata
      final metadata = AudioMetadata(
        title: _generateTitleFromText(text),
        description: 'Generated audio from text',
        language: generationSettings.language,
        contentType: 'generated_speech',
        sourceText: text,
        generationSettings: generationSettings.toJson(),
        customFields: customMetadata,
      );

      // Generate filename
      final fileName = _generateFileName(text, generationSettings);

      // Store in cache
      final storedFile = await _cacheManager.storeAudioFile(
        audioData: audioData,
        fileName: fileName,
        metadata: metadata.toJson(),
        hashtags: hashtags,
      );

      return AudioGenerationResult(
        success: true,
        audioFile: storedFile,
        audioData: audioData,
        metadata: metadata,
        generationTime: DateTime.now(),
        settings: generationSettings,
      );

    } catch (e) {
      return AudioGenerationResult(
        success: false,
        error: e.toString(),
        generationTime: DateTime.now(),
        settings: generationSettings,
      );
    }
  }

  /// Generate audio with custom voice settings
  Future<AudioGenerationResult> generateWithCustomVoice({
    required String text,
    required String voiceId,
    double speed = 1.0,
    String format = 'mp3',
    List<String> hashtags = const [],
    Map<String, dynamic> customMetadata = const {},
  }) async {
    final customSettings = AudioGenerationSettings(
      voice: voiceId,
      speed: speed,
      format: format,
    );

    return await generateAudioFromText(
      text: text,
      settings: customSettings,
      hashtags: hashtags,
      customMetadata: customMetadata,
    );
  }

  /// Batch generate multiple audio files
  Future<List<AudioGenerationResult>> batchGenerateAudio({
    required List<String> texts,
    AudioGenerationSettings? settings,
    List<String> commonHashtags = const [],
    Duration delayBetweenRequests = const Duration(milliseconds: 500),
  }) async {
    final results = <AudioGenerationResult>[];

    for (int i = 0; i < texts.length; i++) {
      final text = texts[i];
      
      try {
        final result = await generateAudioFromText(
          text: text,
          settings: settings,
          hashtags: [...commonHashtags, 'batch_$i'],
        );
        results.add(result);

        // Add delay between requests to avoid rate limiting
        if (i < texts.length - 1) {
          await Future.delayed(delayBetweenRequests);
        }
      } catch (e) {
        results.add(AudioGenerationResult(
          success: false,
          error: 'Batch generation error for item $i: $e',
          generationTime: DateTime.now(),
          settings: settings ?? _defaultSettings,
        ));
      }
    }

    return results;
  }

  /// Generate audio with SSML (Speech Synthesis Markup Language)
  Future<AudioGenerationResult> generateWithSSML({
    required String ssmlText,
    AudioGenerationSettings? settings,
    List<String> hashtags = const [],
    Map<String, dynamic> customMetadata = const {},
  }) async {
    // Add SSML hashtag
    final ssmlHashtags = [...hashtags, 'ssml'];
    
    return await generateAudioFromText(
      text: ssmlText,
      settings: settings,
      hashtags: ssmlHashtags,
      customMetadata: {
        ...customMetadata,
        'is_ssml': true,
      },
    );
  }

  /// Regenerate audio with different settings
  Future<AudioGenerationResult> regenerateAudio({
    required String originalFileId,
    required AudioGenerationSettings newSettings,
    List<String> additionalHashtags = const [],
  }) async {
    try {
      // Get original audio file
      final originalFile = await _cacheManager.getAudioFile(originalFileId);
      if (originalFile == null) {
        throw AudioGenerationException('Original file not found: $originalFileId');
      }

      // Extract original text from metadata
      final originalText = originalFile.metadata['sourceText'] as String?;
      if (originalText == null) {
        throw AudioGenerationException('Source text not found in original file metadata');
      }

      // Generate with new settings
      final result = await generateAudioFromText(
        text: originalText,
        settings: newSettings,
        hashtags: [...originalFile.hashtags, ...additionalHashtags, 'regenerated'],
        customMetadata: {
          ...originalFile.metadata,
          'regenerated_from': originalFileId,
          'regenerated_at': DateTime.now().toIso8601String(),
        },
      );

      return result;
    } catch (e) {
      return AudioGenerationResult(
        success: false,
        error: 'Regeneration error: $e',
        generationTime: DateTime.now(),
        settings: newSettings,
      );
    }
  }

  /// Get available voices
  Future<List<AudioVoice>> getAvailableVoices() async {
    // This would typically call an API to get available voices
    // For now, return OpenAI TTS voices
    return [
      const AudioVoice(id: 'alloy', name: 'Alloy', description: 'Neutral voice'),
      const AudioVoice(id: 'echo', name: 'Echo', description: 'Clear voice'),
      const AudioVoice(id: 'fable', name: 'Fable', description: 'Expressive voice'),
      const AudioVoice(id: 'onyx', name: 'Onyx', description: 'Deep voice'),
      const AudioVoice(id: 'nova', name: 'Nova', description: 'Energetic voice'),
      const AudioVoice(id: 'shimmer', name: 'Shimmer', description: 'Bright voice'),
    ];
  }

  /// Estimate generation cost
  double estimateGenerationCost(String text, {String model = 'tts-1'}) {
    // OpenAI TTS pricing (as of 2024)
    const pricePerCharacter = 0.000015; // $0.015 per 1K characters
    return text.length * pricePerCharacter;
  }

  /// Get generation statistics
  Future<AudioGenerationStats> getGenerationStats() async {
    final allFiles = await _cacheManager._localStorage.listAudioFiles();
    final generatedFiles = allFiles.where((file) => 
      file.metadata['contentType'] == 'generated_speech'
    ).toList();

    final totalFiles = generatedFiles.length;
    final totalSize = generatedFiles.fold<int>(0, (sum, file) => sum + file.fileSize);
    final totalCharacters = generatedFiles.fold<int>(0, (sum, file) => 
      sum + (file.metadata['sourceText']?.toString().length ?? 0)
    );

    return AudioGenerationStats(
      totalGeneratedFiles: totalFiles,
      totalSizeBytes: totalSize,
      totalCharactersGenerated: totalCharacters,
      estimatedCost: totalCharacters * 0.000015,
    );
  }

  /// Set default generation settings
  void setDefaultSettings(AudioGenerationSettings settings) {
    _defaultSettings = settings;
  }

  // Private helper methods

  String _generateTitleFromText(String text) {
    // Extract first few words as title
    final words = text.trim().split(' ');
    final titleWords = words.take(6).toList();
    String title = titleWords.join(' ');
    
    if (words.length > 6) {
      title += '...';
    }
    
    return title.isEmpty ? 'Generated Audio' : title;
  }

  String _generateFileName(String text, AudioGenerationSettings settings) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedText = text
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    
    final shortText = sanitizedText.length > 20 
        ? sanitizedText.substring(0, 20) 
        : sanitizedText;
    
    return '${shortText}_${settings.voice}_$timestamp.${settings.format}';
  }
}

/// Audio generation settings
class AudioGenerationSettings {
  final String model;
  final String voice;
  final String format;
  final double speed;
  final String language;

  const AudioGenerationSettings({
    this.model = 'tts-1',
    this.voice = 'alloy',
    this.format = 'mp3',
    this.speed = 1.0,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'voice': voice,
      'format': format,
      'speed': speed,
      'language': language,
    };
  }

  factory AudioGenerationSettings.fromJson(Map<String, dynamic> json) {
    return AudioGenerationSettings(
      model: json['model'] ?? 'tts-1',
      voice: json['voice'] ?? 'alloy',
      format: json['format'] ?? 'mp3',
      speed: (json['speed'] ?? 1.0).toDouble(),
      language: json['language'] ?? 'en',
    );
  }

  AudioGenerationSettings copyWith({
    String? model,
    String? voice,
    String? format,
    double? speed,
    String? language,
  }) {
    return AudioGenerationSettings(
      model: model ?? this.model,
      voice: voice ?? this.voice,
      format: format ?? this.format,
      speed: speed ?? this.speed,
      language: language ?? this.language,
    );
  }
}

/// Audio generation result
class AudioGenerationResult {
  final bool success;
  final StoredAudioFile? audioFile;
  final Uint8List? audioData;
  final AudioMetadata? metadata;
  final String? error;
  final DateTime generationTime;
  final AudioGenerationSettings settings;

  const AudioGenerationResult({
    required this.success,
    this.audioFile,
    this.audioData,
    this.metadata,
    this.error,
    required this.generationTime,
    required this.settings,
  });

  Duration get audioDuration {
    // Estimate duration based on text length and speed
    // This is approximate - actual duration would need audio analysis
    if (metadata?.sourceText != null) {
      final textLength = metadata!.sourceText!.length;
      final wordsPerMinute = 150.0; // Average speaking rate
      final charactersPerWord = 5.0; // Average characters per word
      final minutes = (textLength / charactersPerWord) / wordsPerMinute;
      final adjustedMinutes = minutes / settings.speed;
      return Duration(milliseconds: (adjustedMinutes * 60 * 1000).round());
    }
    return Duration.zero;
  }
}

/// Available audio voice
class AudioVoice {
  final String id;
  final String name;
  final String description;

  const AudioVoice({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// Audio generation statistics
class AudioGenerationStats {
  final int totalGeneratedFiles;
  final int totalSizeBytes;
  final int totalCharactersGenerated;
  final double estimatedCost;

  const AudioGenerationStats({
    required this.totalGeneratedFiles,
    required this.totalSizeBytes,
    required this.totalCharactersGenerated,
    required this.estimatedCost,
  });

  String get formattedSize {
    final sizeInMB = totalSizeBytes / (1024 * 1024);
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  String get formattedCost {
    return '\$${estimatedCost.toStringAsFixed(4)}';
  }
}

/// Audio generation exception
class AudioGenerationException implements Exception {
  final String message;
  
  const AudioGenerationException(this.message);
  
  @override
  String toString() => 'AudioGenerationException: $message';
}
