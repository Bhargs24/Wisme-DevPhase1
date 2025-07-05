/// Advanced Audio Assembly Service
/// 
/// Intelligent audio segment assembly, processing, and optimization
library;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../../shared/models/base_model.dart';
import '../../shared/models/result.dart';
import '../../core/utils/logger.dart';
import '../../core/error/app_exceptions.dart';
import '../models/audio_models.dart';

/// Audio processing metadata
class AudioProcessingMetadata extends BaseModel {
  final String processingId;
  final DateTime startTime;
  final DateTime? endTime;
  final String processingType;
  final Map<String, dynamic> parameters;
  final List<String> appliedEffects;
  final double qualityScore;

  const AudioProcessingMetadata({
    required this.processingId,
    required this.startTime,
    this.endTime,
    required this.processingType,
    this.parameters = const {},
    this.appliedEffects = const [],
    this.qualityScore = 1.0,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'processingId': processingId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'processingType': processingType,
      'parameters': parameters,
      'appliedEffects': appliedEffects,
      'qualityScore': qualityScore,
    };
  }

  factory AudioProcessingMetadata.fromMap(Map<String, dynamic> map) {
    return AudioProcessingMetadata(
      processingId: map['processingId'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      processingType: map['processingType'] ?? '',
      parameters: Map<String, dynamic>.from(map['parameters'] ?? {}),
      appliedEffects: List<String>.from(map['appliedEffects'] ?? []),
      qualityScore: map['qualityScore']?.toDouble() ?? 1.0,
    );
  }

  @override
  List<Object?> get props => [
    processingId,
    startTime,
    endTime,
    processingType,
    parameters,
    appliedEffects,
    qualityScore,
  ];
}

/// Audio assembly result
class AudioAssemblyResult extends BaseModel {
  final String assemblyId;
  final Uint8List audioData;
  final Duration totalDuration;
  final String format;
  final AudioQuality quality;
  final List<AudioSegmentInfo> segments;
  final AudioProcessingMetadata processingMetadata;
  final Map<String, dynamic> assemblyStats;

  const AudioAssemblyResult({
    required this.assemblyId,
    required this.audioData,
    required this.totalDuration,
    required this.format,
    required this.quality,
    required this.segments,
    required this.processingMetadata,
    this.assemblyStats = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'assemblyId': assemblyId,
      'totalDuration': totalDuration.inMilliseconds,
      'format': format,
      'quality': quality.name,
      'segments': segments.map((s) => s.toMap()).toList(),
      'processingMetadata': processingMetadata.toMap(),
      'assemblyStats': assemblyStats,
    };
  }

  factory AudioAssemblyResult.fromMap(Map<String, dynamic> map) {
    return AudioAssemblyResult(
      assemblyId: map['assemblyId'] ?? '',
      audioData: Uint8List(0), // Cannot deserialize binary data
      totalDuration: Duration(milliseconds: map['totalDuration'] ?? 0),
      format: map['format'] ?? '',
      quality: AudioQuality.values.firstWhere(
        (q) => q.name == map['quality'],
        orElse: () => AudioQuality.medium,
      ),
      segments: List<AudioSegmentInfo>.from(
        map['segments']?.map((s) => AudioSegmentInfo.fromMap(s)) ?? [],
      ),
      processingMetadata: AudioProcessingMetadata.fromMap(map['processingMetadata'] ?? {}),
      assemblyStats: Map<String, dynamic>.from(map['assemblyStats'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    assemblyId,
    audioData,
    totalDuration,
    format,
    quality,
    segments,
    processingMetadata,
    assemblyStats,
  ];
}

/// Audio segment information for assembly
class AudioSegmentInfo extends BaseModel {
  final String segmentId;
  final Duration startTime;
  final Duration duration;
  final double volume;
  final String transitionType;
  final Map<String, dynamic> metadata;

  const AudioSegmentInfo({
    required this.segmentId,
    required this.startTime,
    required this.duration,
    this.volume = 1.0,
    this.transitionType = 'none',
    this.metadata = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'segmentId': segmentId,
      'startTime': startTime.inMilliseconds,
      'duration': duration.inMilliseconds,
      'volume': volume,
      'transitionType': transitionType,
      'metadata': metadata,
    };
  }

  factory AudioSegmentInfo.fromMap(Map<String, dynamic> map) {
    return AudioSegmentInfo(
      segmentId: map['segmentId'] ?? '',
      startTime: Duration(milliseconds: map['startTime'] ?? 0),
      duration: Duration(milliseconds: map['duration'] ?? 0),
      volume: map['volume']?.toDouble() ?? 1.0,
      transitionType: map['transitionType'] ?? 'none',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    segmentId,
    startTime,
    duration,
    volume,
    transitionType,
    metadata,
  ];
}

/// Audio assembly configuration
class AudioAssemblyConfig extends BaseModel {
  final String outputFormat; // mp3, wav, aac
  final AudioQuality targetQuality;
  final int sampleRate;
  final int bitRate;
  final bool enableNormalization;
  final bool enableCrossfade;
  final Duration crossfadeDuration;
  final bool enableNoiseReduction;
  final double targetVolume;
  final Map<String, dynamic> advancedSettings;

  const AudioAssemblyConfig({
    this.outputFormat = 'mp3',
    this.targetQuality = AudioQuality.high,
    this.sampleRate = 44100,
    this.bitRate = 128000,
    this.enableNormalization = true,
    this.enableCrossfade = true,
    this.crossfadeDuration = const Duration(milliseconds: 500),
    this.enableNoiseReduction = false,
    this.targetVolume = 0.8,
    this.advancedSettings = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'outputFormat': outputFormat,
      'targetQuality': targetQuality.name,
      'sampleRate': sampleRate,
      'bitRate': bitRate,
      'enableNormalization': enableNormalization,
      'enableCrossfade': enableCrossfade,
      'crossfadeDuration': crossfadeDuration.inMilliseconds,
      'enableNoiseReduction': enableNoiseReduction,
      'targetVolume': targetVolume,
      'advancedSettings': advancedSettings,
    };
  }

  factory AudioAssemblyConfig.fromMap(Map<String, dynamic> map) {
    return AudioAssemblyConfig(
      outputFormat: map['outputFormat'] ?? 'mp3',
      targetQuality: AudioQuality.values.firstWhere(
        (q) => q.name == map['targetQuality'],
        orElse: () => AudioQuality.high,
      ),
      sampleRate: map['sampleRate'] ?? 44100,
      bitRate: map['bitRate'] ?? 128000,
      enableNormalization: map['enableNormalization'] ?? true,
      enableCrossfade: map['enableCrossfade'] ?? true,
      crossfadeDuration: Duration(milliseconds: map['crossfadeDuration'] ?? 500),
      enableNoiseReduction: map['enableNoiseReduction'] ?? false,
      targetVolume: map['targetVolume']?.toDouble() ?? 0.8,
      advancedSettings: Map<String, dynamic>.from(map['advancedSettings'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    outputFormat,
    targetQuality,
    sampleRate,
    bitRate,
    enableNormalization,
    enableCrossfade,
    crossfadeDuration,
    enableNoiseReduction,
    targetVolume,
    advancedSettings,
  ];
}

/// Advanced audio assembly service
class AudioAssemblyService {
  static final Map<String, AudioAssemblyResult> _assemblyCache = {};
  static final Map<String, Timer> _processingTimers = {};
  
  static const int _maxCacheSize = 100;
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Assemble audio segments into a complete audio track
  static Future<Result<AudioAssemblyResult>> assembleAudioSegments({
    required List<AudioSegment> segments,
    AudioAssemblyConfig? config,
    String? userId,
    String? sessionId,
  }) async {
    try {
      config ??= const AudioAssemblyConfig();
      
      final assemblyId = _generateAssemblyId();
      final startTime = DateTime.now();

      AppLogger.info('🎵 Starting audio assembly: $assemblyId (${segments.length} segments)');

      // Validate segments
      final validationResult = _validateSegments(segments);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error);
      }

      // Prepare segments for assembly
      final preparedSegments = await _prepareSegments(segments, config);

      // Perform assembly
      final assemblyResult = await _performAssembly(
        assemblyId: assemblyId,
        segments: preparedSegments,
        config: config,
        startTime: startTime,
      );

      if (assemblyResult.isSuccess) {
        // Cache result
        _cacheAssemblyResult(assemblyResult.data!);
        
        AppLogger.info('✅ Audio assembly completed: $assemblyId');
      }

      return assemblyResult;
    } catch (e) {
      AppLogger.error('❌ Audio assembly failed: $e');
      return Result.failure(AudioException('Audio assembly failed: $e'));
    }
  }

  /// Validate audio segments before assembly
  static Result<void> _validateSegments(List<AudioSegment> segments) {
    if (segments.isEmpty) {
      return Result.failure(const AudioException('No audio segments provided'));
    }

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      
      if (segment.audioData == null || segment.audioData!.isEmpty) {
        return Result.failure(AudioException('Segment $i has no audio data'));
      }
      
      if (segment.duration == Duration.zero) {
        return Result.failure(AudioException('Segment $i has zero duration'));
      }
    }

    return Result.success(null);
  }

  /// Prepare segments for assembly
  static Future<List<AudioSegment>> _prepareSegments(
    List<AudioSegment> segments,
    AudioAssemblyConfig config,
  ) async {
    final preparedSegments = <AudioSegment>[];

    for (final segment in segments) {
      var preparedSegment = segment;

      // Apply normalization if enabled
      if (config.enableNormalization) {
        preparedSegment = await _normalizeSegment(preparedSegment, config.targetVolume);
      }

      // Apply noise reduction if enabled
      if (config.enableNoiseReduction) {
        preparedSegment = await _reduceNoise(preparedSegment);
      }

      // Convert format if needed
      if (segment.format != config.outputFormat) {
        preparedSegment = await _convertFormat(preparedSegment, config.outputFormat);
      }

      preparedSegments.add(preparedSegment);
    }

    return preparedSegments;
  }

  /// Perform the actual audio assembly
  static Future<Result<AudioAssemblyResult>> _performAssembly({
    required String assemblyId,
    required List<AudioSegment> segments,
    required AudioAssemblyConfig config,
    required DateTime startTime,
  }) async {
    try {
      final assembledData = <int>[];
      final segmentInfos = <AudioSegmentInfo>[];
      Duration currentTime = Duration.zero;

      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];
        final segmentData = segment.audioData!;

        // Apply crossfade between segments
        if (i > 0 && config.enableCrossfade) {
          final crossfadeData = _applyCrossfade(
            previousData: segments[i - 1].audioData!,
            currentData: segmentData,
            crossfadeDuration: config.crossfadeDuration,
          );
          assembledData.addAll(crossfadeData);
        } else {
          assembledData.addAll(segmentData);
        }

        // Record segment info
        segmentInfos.add(AudioSegmentInfo(
          segmentId: segment.id,
          startTime: currentTime,
          duration: segment.duration,
          volume: segment.volume,
          metadata: segment.metadata,
        ));

        currentTime += segment.duration;
      }

      final totalDuration = currentTime;
      final finalAudioData = Uint8List.fromList(assembledData);

      // Apply final processing
      final processedData = await _applyFinalProcessing(
        audioData: finalAudioData,
        config: config,
      );

      final processingMetadata = AudioProcessingMetadata(
        processingId: assemblyId,
        startTime: startTime,
        endTime: DateTime.now(),
        processingType: 'assembly',
        parameters: config.toMap(),
        appliedEffects: _getAppliedEffects(config),
        qualityScore: _calculateQualityScore(config, segments.length),
      );

      final assemblyStats = _generateAssemblyStats(
        segments: segments,
        totalDuration: totalDuration,
        finalSize: processedData.length,
      );

      final result = AudioAssemblyResult(
        assemblyId: assemblyId,
        audioData: processedData,
        totalDuration: totalDuration,
        format: config.outputFormat,
        quality: config.targetQuality,
        segments: segmentInfos,
        processingMetadata: processingMetadata,
        assemblyStats: assemblyStats,
      );

      return Result.success(result);
    } catch (e) {
      return Result.failure(AudioException('Assembly processing failed: $e'));
    }
  }

  /// Normalize audio segment volume
  static Future<AudioSegment> _normalizeSegment(
    AudioSegment segment,
    double targetVolume,
  ) async {
    // Simplified normalization (in production, use proper audio processing)
    final normalizedData = segment.audioData!.map((byte) {
      return (byte * targetVolume).round().clamp(0, 255);
    }).toList();

    return AudioSegment(
      id: segment.id,
      audioData: Uint8List.fromList(normalizedData),
      duration: segment.duration,
      format: segment.format,
      quality: segment.quality,
      volume: targetVolume,
      pitch: segment.pitch,
      speed: segment.speed,
      metadata: {...segment.metadata, 'normalized': true},
    );
  }

  /// Apply noise reduction to audio segment
  static Future<AudioSegment> _reduceNoise(AudioSegment segment) async {
    // Simplified noise reduction (in production, use proper audio processing)
    final processedData = segment.audioData!.map((byte) {
      // Simple noise gate - remove low-amplitude noise
      return byte < 10 ? 0 : byte;
    }).toList();

    return AudioSegment(
      id: segment.id,
      audioData: Uint8List.fromList(processedData),
      duration: segment.duration,
      format: segment.format,
      quality: segment.quality,
      volume: segment.volume,
      pitch: segment.pitch,
      speed: segment.speed,
      metadata: {...segment.metadata, 'noiseReduced': true},
    );
  }

  /// Convert audio format
  static Future<AudioSegment> _convertFormat(
    AudioSegment segment,
    String targetFormat,
  ) async {
    // Simplified format conversion (in production, use proper audio codecs)
    // For now, just update the format metadata
    return AudioSegment(
      id: segment.id,
      audioData: segment.audioData,
      duration: segment.duration,
      format: targetFormat,
      quality: segment.quality,
      volume: segment.volume,
      pitch: segment.pitch,
      speed: segment.speed,
      metadata: {...segment.metadata, 'convertedFrom': segment.format},
    );
  }

  /// Apply crossfade between audio segments
  static List<int> _applyCrossfade({
    required Uint8List previousData,
    required Uint8List currentData,
    required Duration crossfadeDuration,
  }) {
    // Simplified crossfade implementation
    final fadeLength = min(
      (crossfadeDuration.inMilliseconds * 44.1).round(), // Assuming 44.1kHz
      min(previousData.length, currentData.length) ~/ 2,
    );

    if (fadeLength <= 0) {
      return currentData.toList();
    }

    final result = currentData.toList();
    
    for (int i = 0; i < fadeLength && i < result.length; i++) {
      final fadeRatio = i / fadeLength;
      final previousIndex = previousData.length - fadeLength + i;
      
      if (previousIndex >= 0 && previousIndex < previousData.length) {
        final previousValue = previousData[previousIndex] * (1.0 - fadeRatio);
        final currentValue = result[i] * fadeRatio;
        result[i] = (previousValue + currentValue).round().clamp(0, 255);
      }
    }

    return result;
  }

  /// Apply final processing to assembled audio
  static Future<Uint8List> _applyFinalProcessing({
    required Uint8List audioData,
    required AudioAssemblyConfig config,
  }) async {
    var processedData = audioData;

    // Apply final normalization
    if (config.enableNormalization) {
      processedData = _applyFinalNormalization(processedData, config.targetVolume);
    }

    // Apply compression if needed
    if (config.targetQuality == AudioQuality.low) {
      processedData = _applyCompression(processedData);
    }

    return processedData;
  }

  /// Apply final normalization to the complete track
  static Uint8List _applyFinalNormalization(Uint8List data, double targetVolume) {
    // Find peak amplitude
    int peak = 0;
    for (final byte in data) {
      if (byte > peak) peak = byte;
    }

    if (peak == 0) return data;

    // Calculate normalization factor
    final factor = (255 * targetVolume) / peak;

    // Apply normalization
    return Uint8List.fromList(
      data.map((byte) => (byte * factor).round().clamp(0, 255)).toList(),
    );
  }

  /// Apply compression for smaller file size
  static Uint8List _applyCompression(Uint8List data) {
    // Simplified compression (in production, use proper audio compression)
    // For now, just reduce bit depth slightly
    return Uint8List.fromList(
      data.map((byte) => (byte * 0.9).round().clamp(0, 255)).toList(),
    );
  }

  /// Get list of applied effects
  static List<String> _getAppliedEffects(AudioAssemblyConfig config) {
    final effects = <String>[];
    
    if (config.enableNormalization) effects.add('normalization');
    if (config.enableCrossfade) effects.add('crossfade');
    if (config.enableNoiseReduction) effects.add('noise_reduction');
    
    return effects;
  }

  /// Calculate quality score for the assembly
  static double _calculateQualityScore(AudioAssemblyConfig config, int segmentCount) {
    double score = 1.0;
    
    // Quality based on settings
    switch (config.targetQuality) {
      case AudioQuality.low:
        score *= 0.7;
        break;
      case AudioQuality.medium:
        score *= 0.85;
        break;
      case AudioQuality.high:
        score *= 1.0;
        break;
    }
    
    // Penalty for too many segments (potential quality loss)
    if (segmentCount > 10) {
      score *= 0.95;
    }
    
    // Bonus for advanced features
    if (config.enableNormalization) score *= 1.05;
    if (config.enableNoiseReduction) score *= 1.03;
    
    return score.clamp(0.0, 1.0);
  }

  /// Generate assembly statistics
  static Map<String, dynamic> _generateAssemblyStats({
    required List<AudioSegment> segments,
    required Duration totalDuration,
    required int finalSize,
  }) {
    final originalSize = segments.fold(0, (sum, segment) => sum + (segment.audioData?.length ?? 0));
    final compressionRatio = originalSize > 0 ? finalSize / originalSize : 1.0;
    
    return {
      'segmentCount': segments.length,
      'totalDurationMs': totalDuration.inMilliseconds,
      'originalSizeBytes': originalSize,
      'finalSizeBytes': finalSize,
      'compressionRatio': compressionRatio,
      'averageSegmentDuration': segments.isEmpty ? 0 : 
          segments.map((s) => s.duration.inMilliseconds).reduce((a, b) => a + b) / segments.length,
    };
  }

  /// Generate unique assembly ID
  static String _generateAssemblyId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'assembly_${timestamp}_$random';
  }

  /// Cache assembly result
  static void _cacheAssemblyResult(AudioAssemblyResult result) {
    if (_assemblyCache.length >= _maxCacheSize) {
      // Remove oldest entries
      final oldestKey = _assemblyCache.keys.first;
      _assemblyCache.remove(oldestKey);
    }
    
    _assemblyCache[result.assemblyId] = result;
    
    // Set expiry timer
    _processingTimers[result.assemblyId] = Timer(_cacheExpiry, () {
      _assemblyCache.remove(result.assemblyId);
      _processingTimers.remove(result.assemblyId);
    });
  }

  /// Get cached assembly result
  static AudioAssemblyResult? getCachedResult(String assemblyId) {
    return _assemblyCache[assemblyId];
  }

  /// Process audio segments in parallel
  static Future<Result<List<AudioAssemblyResult>>> assembleMultipleAudio({
    required List<List<AudioSegment>> segmentGroups,
    AudioAssemblyConfig? config,
    String? userId,
  }) async {
    try {
      final futures = segmentGroups.map((segments) => 
        assembleAudioSegments(
          segments: segments,
          config: config,
          userId: userId,
        )).toList();
      
      final results = await Future.wait(futures);
      final assemblyResults = <AudioAssemblyResult>[];
      
      for (final result in results) {
        if (result.isSuccess) {
          assemblyResults.add(result.data!);
        } else {
          return Result.failure(result.error);
        }
      }
      
      return Result.success(assemblyResults);
    } catch (e) {
      return Result.failure(AudioException('Parallel assembly failed: $e'));
    }
  }

  /// Get service metrics
  static Map<String, dynamic> getMetrics() {
    return {
      'cacheSize': _assemblyCache.length,
      'activeTimers': _processingTimers.length,
      'maxCacheSize': _maxCacheSize,
      'cacheExpiry': _cacheExpiry.inHours,
    };
  }

  /// Clear cache
  static void clearCache() {
    _assemblyCache.clear();
    for (final timer in _processingTimers.values) {
      timer.cancel();
    }
    _processingTimers.clear();
    AppLogger.info('🧹 Audio assembly cache cleared');
  }

  /// Dispose service
  static void dispose() {
    clearCache();
    AppLogger.info('🎵 Audio assembly service disposed');
  }
}
