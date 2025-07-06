import '../core/exports.dart';
import 'dart:async';
import 'dart:typed_data';

/// Extension of ContentMatch with additional ranking information
class RankedContentMatch {
  final ContentMatch contentMatch;
  final ContentBlock content;
  final double totalScore;
  final double semanticScore;
  final String matchReason;

  RankedContentMatch({
    required this.contentMatch,
    required this.content,
    required this.totalScore,
    required this.semanticScore,
    required this.matchReason,
  });
}

class SmartContentOrchestrator {
  final ContentMatchingService _matchingService;
  final ContentReuseEngine _reuseEngine;
  final FirestoreService _firestoreService;
  final GPTService _gptService;
  final TTSService _ttsService;

  // Performance metrics
  final Map<String, int> _operationCounts = {};
  final Map<String, double> _costSavings = {};
  DateTime _lastResetTime = DateTime.now();

  SmartContentOrchestrator({
    required ContentMatchingService matchingService,
    required ContentReuseEngine reuseEngine,
    required FirestoreService firestoreService,
    required GPTService gptService,
    required TTSService ttsService,
  }) : _matchingService = matchingService,
       _reuseEngine = reuseEngine,
       _firestoreService = firestoreService,
       _gptService = gptService,
       _ttsService = ttsService;

  /// Generate content with intelligent reuse - Main API method
  Future<SmartContentResult> generateSmartContent({
    required String userId,
    required String topic,
    required String category,
    required String level,
    String? contentType,
    Duration? targetDuration,
    String? preferredVoice,
    Map<String, dynamic>? userContext,
  }) async {
    final startTime = DateTime.now();
    AppLogger.info('🚀 Starting smart content generation for: $topic');

    try {
      // Phase 1: Find reusable content
      final contentMatches = await _reuseEngine.findReusableContent(
        topic: topic,
        category: category,
        level: level,
        userId: userId,
        excludeContentIds: await _getUserRecentContent(userId),
        maxResults: 10,
        minimumSimilarity: 0.6,
      );

      // Phase 2: Determine optimal content strategy
      final strategy = _determineContentStrategy(contentMatches, targetDuration);
      AppLogger.info('📊 Content strategy: $strategy (${contentMatches.length} matches found)');

      // Phase 3: Execute content strategy
      final result = await _executeContentStrategy(
        strategy: strategy,
        topic: topic,
        category: category,
        level: level,
        contentType: contentType,
        contentMatches: contentMatches,
        userId: userId,
        targetDuration: targetDuration,
        preferredVoice: preferredVoice,
        userContext: userContext,
      );

      // Phase 4: Track performance
      await _trackOperationSuccess(
        strategy: strategy,
        reuseRate: result.reuseRate,
        processingTime: DateTime.now().difference(startTime),
      );

      AppLogger.info('✅ Smart content generation complete: ${DateTime.now().difference(startTime).inMilliseconds}ms (${(result.reuseRate * 100).toStringAsFixed(1)}% reuse)');

      return result;

    } catch (e) {
      AppLogger.error('❌ Smart content generation failed: $e');
      
      // Fallback to basic generation
      return await _fallbackContentGeneration(
        topic: topic,
        category: category,
        level: level,
        contentType: contentType,
        targetDuration: targetDuration,
        preferredVoice: preferredVoice,
      );
    }
  }

  /// Get performance analytics
  ContentGenerationAnalytics getAnalytics() {
    final totalOperations = _operationCounts.values.fold(0, (a, b) => a + b);
    final totalSavings = _costSavings.values.fold(0.0, (a, b) => a + b);
    
    return ContentGenerationAnalytics(
      totalOperations: totalOperations,
      reuseOperations: _operationCounts['reuse'] ?? 0,
      hybridOperations: _operationCounts['hybrid'] ?? 0,
      newGenerations: _operationCounts['new'] ?? 0,
      totalCostSavings: totalSavings,
      avgReuseRate: _calculateAverageReuseRate(),
      periodStart: _lastResetTime,
      periodEnd: DateTime.now(),
    );
  }

  /// Reset analytics counters
  void resetAnalytics() {
    _operationCounts.clear();
    _costSavings.clear();
    _lastResetTime = DateTime.now();
    AppLogger.info('📊 Analytics counters reset');
  }

  // Private implementation methods

  Future<List<String>> _getUserRecentContent(String userId) async {
    try {
      // Get user's recent content to avoid repetition
      // This is a simplified implementation
      return [];
    } catch (e) {
      AppLogger.error('Failed to get user recent content: $e');
      return [];
    }
  }

  String _determineContentStrategy(List<ContentMatch> matches, Duration? targetDuration) {
    if (matches.isEmpty) {
      return 'generate_new';
    }

    final bestScore = matches.first.similarityScore;
    final hasMultipleGoodMatches = matches.where((m) => m.similarityScore > 0.7).length >= 2;

    if (bestScore > 0.85) {
      return 'direct_reuse';
    } else if (bestScore > 0.7 && hasMultipleGoodMatches) {
      return 'multi_segment_reuse';
    } else if (bestScore > 0.5) {
      return 'hybrid_reuse';
    } else {
      return 'generate_new';
    }
  }

  Future<SmartContentResult> _executeContentStrategy({
    required String strategy,
    required String topic,
    required String category,
    required String level,
    String? contentType,
    required List<ContentMatch> contentMatches,
    required String userId,
    Duration? targetDuration,
    String? preferredVoice,
    Map<String, dynamic>? userContext,
  }) async {
    switch (strategy) {
      case 'direct_reuse':
        return await _executeDirectReuse(contentMatches.first, preferredVoice);
      
      case 'multi_segment_reuse':
        return await _executeMultiSegmentReuse(
          contentMatches, 
          targetDuration ?? Duration(minutes: 10),
          preferredVoice,
        );
      
      case 'hybrid_reuse':
        return await _executeHybridReuse(
          contentMatches.first,
          topic,
          category,
          level,
          contentType,
          targetDuration,
          preferredVoice,
        );
      
      case 'generate_new':
      default:
        return await _executeNewGeneration(
          topic: topic,
          category: category,
          level: level,
          contentType: contentType,
          targetDuration: targetDuration,
          preferredVoice: preferredVoice,
          userId: userId,
        );
    }
  }

  Future<SmartContentResult> _executeDirectReuse(ContentMatch match, String? voiceId) async {
    // For direct reuse, we would fetch the existing content
    // For now, create a placeholder result
    
    final content = ContentBlock(
      id: match.contentId,
      title: 'Reused Content',
      description: 'Content reused from previous generation',
      duration: Duration(minutes: 10),
      audioUrl: '',
      category: '',
      knowledgeLevel: '',
      tags: [],
      contentType: 'lesson',
      difficultyLevel: 1,
      coachPersonality: 'friendly',
      voiceId: voiceId ?? 'default',
      transcript: '',
      keywords: [],
      prerequisites: [],
      learningOutcomes: [],
      playCount: 0,
      averageRating: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDownloaded: false,
      fileSizeBytes: 0,
      metadata: {},
    );

    return SmartContentResult(
      strategy: 'direct_reuse',
      contentBlocks: [content],
      audioData: null,
      estimatedDuration: content.duration,
      reuseRate: 1.0,
      confidenceScore: match.similarityScore,
      metadata: {
        'match_reason': match.isExactMatch ? 'exact_match' : 'similarity_match',
        'semantic_score': match.semanticScore,
        'reused_content_id': match.contentId,
      },
    );
  }

  Future<SmartContentResult> _executeMultiSegmentReuse(
    List<ContentMatch> matches,
    Duration targetDuration,
    String? voiceId,
  ) async {
    // Select optimal combination of segments
    final selectedMatches = matches.take(3).toList();
    final contentBlocks = selectedMatches.map((match) {
      return ContentBlock(
        id: match.contentId,
        title: 'Segment ${match.contentId}',
        description: 'Content segment',
        duration: Duration(minutes: 3),
        audioUrl: '',
        category: '',
        knowledgeLevel: '',
        tags: [],
        contentType: 'lesson',
        difficultyLevel: 1,
        coachPersonality: 'friendly',
        voiceId: voiceId ?? 'default',
        transcript: '',
        keywords: [],
        prerequisites: [],
        learningOutcomes: [],
        playCount: 0,
        averageRating: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDownloaded: false,
        fileSizeBytes: 0,
        metadata: {},
      );
    }).toList();

    final avgScore = selectedMatches.fold(0.0, (sum, m) => sum + m.similarityScore) / selectedMatches.length;
    final totalDuration = contentBlocks.fold(Duration.zero, (sum, c) => sum + c.duration);

    return SmartContentResult(
      strategy: 'multi_segment_reuse',
      contentBlocks: contentBlocks,
      audioData: null,
      estimatedDuration: totalDuration,
      reuseRate: 0.85,
      confidenceScore: avgScore,
      metadata: {
        'segment_count': selectedMatches.length,
        'assembly_type': 'multi_segment',
      },
    );
  }

  Future<SmartContentResult> _executeHybridReuse(
    ContentMatch baseMatch,
    String topic,
    String category,
    String level,
    String? contentType,
    Duration? targetDuration,
    String? voiceId,
  ) async {
    // Generate enhanced content using AI based on existing content
    final response = await _gptService.generateContentBlock(
      topic: topic,
      category: category,
      level: level,
      contentType: contentType ?? 'lesson',
    );

    final enhancedContent = ContentBlock(
      id: 'enhanced_${baseMatch.contentId}_${DateTime.now().millisecondsSinceEpoch}',
      title: response['title'] ?? 'Enhanced: $topic',
      description: response['description'] ?? 'Enhanced content based on existing material',
      duration: targetDuration ?? Duration(minutes: 10),
      audioUrl: '',
      category: category,
      knowledgeLevel: level,
      tags: [],
      contentType: contentType ?? 'lesson',
      difficultyLevel: _parseDifficultyLevel(level),
      coachPersonality: 'friendly',
      voiceId: voiceId ?? 'default',
      transcript: response['content'] ?? '',
      keywords: [],
      prerequisites: [],
      learningOutcomes: [],
      playCount: 0,
      averageRating: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDownloaded: false,
      fileSizeBytes: 0,
      metadata: {
        'enhanced_from': baseMatch.contentId,
        'enhancement_type': 'ai_improved',
      },
    );

    // Generate new audio for enhanced content
    Uint8List? audioData;
    try {
      audioData = await _ttsService.generateSpeech(
        text: enhancedContent.transcript,
        coachId: voiceId ?? 'default',
      );
    } catch (e) {
      AppLogger.error('Failed to generate audio: $e');
    }

    return SmartContentResult(
      strategy: 'hybrid_reuse',
      contentBlocks: [enhancedContent],
      audioData: audioData,
      estimatedDuration: enhancedContent.duration,
      reuseRate: 0.6,
      confidenceScore: baseMatch.similarityScore * 0.8,
      metadata: {
        'base_content_id': baseMatch.contentId,
        'enhancement_applied': true,
      },
    );
  }

  Future<SmartContentResult> _executeNewGeneration({
    required String topic,
    required String category,
    required String level,
    String? contentType,
    Duration? targetDuration,
    String? preferredVoice,
    required String userId,
  }) async {
    // Generate completely new content using AI
    final response = await _gptService.generateContentBlock(
      topic: topic,
      category: category,
      level: level,
      contentType: contentType ?? 'lesson',
    );

    final newContent = ContentBlock(
      id: 'generated_${DateTime.now().millisecondsSinceEpoch}',
      title: response['title'] ?? 'Learning: $topic',
      description: response['description'] ?? 'AI generated content about $topic',
      duration: targetDuration ?? Duration(minutes: 10),
      audioUrl: '',
      category: category,
      knowledgeLevel: level,
      tags: [topic.toLowerCase().replaceAll(' ', '_')],
      contentType: contentType ?? 'lesson',
      difficultyLevel: _parseDifficultyLevel(level),
      coachPersonality: 'friendly',
      voiceId: preferredVoice ?? 'default',
      transcript: response['content'] ?? '',
      keywords: [],
      prerequisites: [],
      learningOutcomes: [],
      playCount: 0,
      averageRating: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDownloaded: false,
      fileSizeBytes: 0,
      metadata: {},
    );

    // Generate audio
    Uint8List? audioData;
    try {
      audioData = await _ttsService.generateSpeech(
        text: newContent.transcript,
        coachId: preferredVoice ?? 'default',
      );
    } catch (e) {
      AppLogger.error('Failed to generate audio: $e');
    }

    // Save content for future reuse
    try {
      await _firestoreService.createContentBlock(newContent);
    } catch (e) {
      AppLogger.error('Failed to save content block: $e');
    }

    return SmartContentResult(
      strategy: 'generate_new',
      contentBlocks: [newContent],
      audioData: audioData,
      estimatedDuration: newContent.duration,
      reuseRate: 0.0,
      confidenceScore: 0.7,
      metadata: {
        'newly_generated': true,
        'saved_for_reuse': true,
      },
    );
  }

  Future<SmartContentResult> _fallbackContentGeneration({
    required String topic,
    required String category,
    required String level,
    String? contentType,
    Duration? targetDuration,
    String? preferredVoice,
  }) async {
    AppLogger.info('🔄 Executing fallback content generation');
    
    // Basic content generation without smart features
    try {
      final response = await _gptService.generateContentBlock(
        topic: topic,
        category: category,
        level: level,
        contentType: contentType ?? 'lesson',
      );

      final basicContent = ContentBlock(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        title: response['title'] ?? 'Learning: $topic',
        description: response['description'] ?? 'Fallback content generation',
        duration: targetDuration ?? Duration(minutes: 10),
        audioUrl: '',
        category: category,
        knowledgeLevel: level,
        tags: [],
        contentType: contentType ?? 'lesson',
        difficultyLevel: _parseDifficultyLevel(level),
        coachPersonality: 'friendly',
        voiceId: preferredVoice ?? 'default',
        transcript: response['content'] ?? 'Content generation temporarily unavailable.',
        keywords: [],
        prerequisites: [],
        learningOutcomes: [],
        playCount: 0,
        averageRating: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDownloaded: false,
        fileSizeBytes: 0,
        metadata: {'fallback_mode': true},
      );

      return SmartContentResult(
        strategy: 'fallback',
        contentBlocks: [basicContent],
        audioData: null,
        estimatedDuration: basicContent.duration,
        reuseRate: 0.0,
        confidenceScore: 0.3,
        metadata: {'fallback_mode': true},
      );
    } catch (e) {
      AppLogger.error('Fallback generation also failed: $e');
      rethrow;
    }
  }

  // Helper methods

  int _parseDifficultyLevel(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 1;
      case 'intermediate':
        return 2;
      case 'advanced':
        return 3;
      default:
        return 1;
    }
  }

  Future<void> _trackOperationSuccess({
    required String strategy,
    required double reuseRate,
    required Duration processingTime,
  }) async {
    // Update operation counts
    _operationCounts[strategy] = (_operationCounts[strategy] ?? 0) + 1;
    
    // Calculate cost savings based on reuse rate
    final baseCost = 0.50; // Estimated cost of full generation
    final savings = baseCost * reuseRate;
    _costSavings[strategy] = (_costSavings[strategy] ?? 0.0) + savings;
    
    AppLogger.info('📊 Operation tracked: $strategy (${(reuseRate * 100).toStringAsFixed(1)}% reuse, \$${savings.toStringAsFixed(3)} saved)');
  }

  double _calculateAverageReuseRate() {
    final reuseOps = _operationCounts['direct_reuse'] ?? 0;
    final multiOps = _operationCounts['multi_segment_reuse'] ?? 0;
    final hybridOps = _operationCounts['hybrid_reuse'] ?? 0;
    final newOps = _operationCounts['generate_new'] ?? 0;
    
    final totalOps = reuseOps + multiOps + hybridOps + newOps;
    if (totalOps == 0) return 0.0;
    
    final weightedReuse = (reuseOps * 1.0) + (multiOps * 0.85) + (hybridOps * 0.6) + (newOps * 0.0);
    return weightedReuse / totalOps;
  }
}

/// Result of smart content generation
class SmartContentResult {
  final String strategy;
  final List<ContentBlock> contentBlocks;
  final Uint8List? audioData;
  final Duration estimatedDuration;
  final double reuseRate;
  final double confidenceScore;
  final Map<String, dynamic> metadata;

  SmartContentResult({
    required this.strategy,
    required this.contentBlocks,
    this.audioData,
    required this.estimatedDuration,
    required this.reuseRate,
    required this.confidenceScore,
    this.metadata = const {},
  });
}

/// Analytics for content generation performance
class ContentGenerationAnalytics {
  final int totalOperations;
  final int reuseOperations;
  final int hybridOperations;
  final int newGenerations;
  final double totalCostSavings;
  final double avgReuseRate;
  final DateTime periodStart;
  final DateTime periodEnd;

  ContentGenerationAnalytics({
    required this.totalOperations,
    required this.reuseOperations,
    required this.hybridOperations,
    required this.newGenerations,
    required this.totalCostSavings,
    required this.avgReuseRate,
    required this.periodStart,
    required this.periodEnd,
  });

  double get reusePercentage => 
      totalOperations > 0 ? (reuseOperations / totalOperations) * 100 : 0.0;

  double get costSavingsPerOperation => 
      totalOperations > 0 ? totalCostSavings / totalOperations : 0.0;
}
