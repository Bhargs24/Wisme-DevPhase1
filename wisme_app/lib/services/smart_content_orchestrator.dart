import '../core/exports.dart';
import 'dart:async';
import 'dart:typed_data';
class SmartContentOrchestrator {
  final ContentMatchingService _matchingService;
  final ContentReuseService _reuseService;
  final AudioAssemblyService _audioService;
  final FirestoreService _firestoreService;
  final GPTService _gptService;
  final TTSService _ttsService;

  // Performance metrics
  final Map<String, int> _operationCounts = {};
  final Map<String, double> _costSavings = {};
  DateTime _lastResetTime = DateTime.now();

  SmartContentOrchestrator({
    required ContentMatchingService matchingService,
    required ContentReuseService reuseService,
    required AudioAssemblyService audioService,
    required FirestoreService firestoreService,
    required GPTService gptService,
    required TTSService ttsService,
  }) : _matchingService = matchingService,
       _reuseService = reuseService,
       _audioService = audioService,
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
      // Phase 1: Intelligent content analysis and matching
      final searchTags = await _generateSearchTags(
        topic: topic,
        category: category,
        level: level,
        contentType: contentType,
        userContext: userContext,
      );

      // Phase 2: Find reusable content with advanced ranking
      final rankedMatches = await _reuseService.findRankedMatches(
        searchTags: searchTags,
        userId: userId,
        excludeIds: await _getUserRecentContent(userId),
        maxResults: 10,
        minimumSimilarity: 0.6,
      );

      // Phase 3: Determine optimal content strategy
      final strategy = _determineContentStrategy(rankedMatches, targetDuration);
      AppLogger.info('📊 Content strategy: $strategy (${rankedMatches.length} matches found)');

      // Phase 4: Execute content assembly based on strategy
      final result = await _executeContentStrategy(
        strategy: strategy,
        topic: topic,
        category: category,
        level: level,
        contentType: contentType,
        rankedMatches: rankedMatches,
        userId: userId,
        targetDuration: targetDuration,
        preferredVoice: preferredVoice,
        userContext: userContext,
      );

      // Phase 5: Track performance and update metrics
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

  Future<ContentTags> _generateSearchTags({
    required String topic,
    required String category,
    required String level,
    String? contentType,
    Map<String, dynamic>? userContext,
  }) async {
    // Generate basic search tags using existing matching service
    // In a real implementation, this would be more sophisticated
    return ContentTags(
      topic: [ContentHashtag(type: 'topic', value: topic.toLowerCase().replaceAll(' ', '_'), weight: 3.0)],
      category: [ContentHashtag(type: 'category', value: category.toLowerCase().replaceAll(' ', '_'), weight: 2.0)],
      level: [ContentHashtag(type: 'level', value: level.toLowerCase(), weight: 1.8)],
      format: contentType != null 
          ? [ContentHashtag(type: 'format', value: contentType, weight: 1.5)]
          : [],
    );
  }

  Future<List<String>> _getUserRecentContent(String userId) async {
    try {
      final history = await _firestoreService.getUserListeningHistory(userId);
      
      // Exclude content played in last 7 days
      final recentCutoff = DateTime.now().subtract(Duration(days: 7));
      final recentContent = <String>[];
      
      for (final entry in history?.lastPlayedDates.entries ?? <MapEntry<String, DateTime>>[]) {
        if (entry.value.isAfter(recentCutoff)) {
          recentContent.add(entry.key);
        }
      }
      
      return recentContent;
    } catch (e) {
      AppLogger.error('Failed to get user recent content: $e');
      return [];
    }
  }

  String _determineContentStrategy(List<RankedContentMatch> matches, Duration? targetDuration) {
    if (matches.isEmpty) {
      return 'generate_new';
    }

    final bestScore = matches.first.totalScore;
    final hasMultipleGoodMatches = matches.where((m) => m.totalScore > 0.7).length >= 2;

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
    required List<RankedContentMatch> rankedMatches,
    required String userId,
    Duration? targetDuration,
    String? preferredVoice,
    Map<String, dynamic>? userContext,
  }) async {
    switch (strategy) {
      case 'direct_reuse':
        return await _executeDirectReuse(rankedMatches.first, preferredVoice);
      
      case 'multi_segment_reuse':
        return await _executeMultiSegmentReuse(
          rankedMatches, 
          targetDuration ?? Duration(minutes: 10),
          preferredVoice,
        );
      
      case 'hybrid_reuse':
        return await _executeHybridReuse(
          rankedMatches.first,
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

  Future<SmartContentResult> _executeDirectReuse(RankedContentMatch match, String? voiceId) async {
    final audioSegments = await _audioService.getAudioSegments(
      contentIds: [match.content.id],
      voiceId: voiceId ?? 'default',
    );

    Uint8List? audioData;
    if (audioSegments.isNotEmpty) {
      audioData = await _audioService.assembleAudio(
        segments: audioSegments,
        voiceId: voiceId ?? 'default',
        addTransitions: false,
      );
    }

    return SmartContentResult(
      strategy: 'direct_reuse',
      contentBlocks: [match.content],
      audioData: audioData,
      estimatedDuration: match.content.duration,
      reuseRate: 1.0,
      confidenceScore: match.totalScore,
      metadata: {
        'match_reason': match.matchReason,
        'semantic_score': match.semanticScore,
        'reused_content_id': match.content.id,
      },
    );
  }

  Future<SmartContentResult> _executeMultiSegmentReuse(
    List<RankedContentMatch> matches,
    Duration targetDuration,
    String? voiceId,
  ) async {
    // Select optimal combination of segments
    final selectedMatches = _selectOptimalSegments(matches, targetDuration);
    final contentBlocks = selectedMatches.map((m) => m.content).toList();
    final contentIds = contentBlocks.map((c) => c.id).toList();

    // Get and assemble audio
    final audioSegments = await _audioService.getAudioSegments(
      contentIds: contentIds,
      voiceId: voiceId ?? 'default',
    );

    Uint8List? audioData;
    if (audioSegments.length == contentIds.length) {
      audioData = await _audioService.assembleAudio(
        segments: audioSegments,
        voiceId: voiceId ?? 'default',
        addTransitions: true,
      );
    }

    final avgScore = selectedMatches.fold(0.0, (sum, m) => sum + m.totalScore) / selectedMatches.length;
    final totalDuration = contentBlocks.fold(Duration.zero, (sum, c) => sum + c.duration);

    return SmartContentResult(
      strategy: 'multi_segment_reuse',
      contentBlocks: contentBlocks,
      audioData: audioData,
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
    RankedContentMatch baseMatch,
    String topic,
    String category,
    String level,
    String? contentType,
    Duration? targetDuration,
    String? voiceId,
  ) async {
    // Use existing content as base and enhance with AI
    final baseContent = baseMatch.content;
    
    // Generate enhanced content using AI
    final enhancedContent = await _enhanceContentWithAI(
      baseContent: baseContent,
      topic: topic,
      category: category,
      level: level,
      targetDuration: targetDuration,
    );

    // Generate new audio for enhanced content
    Uint8List? audioData;
    if (enhancedContent != null) {
      audioData = await _ttsService.generateSpeech(
        text: enhancedContent.script,
        coachId: voiceId ?? 'default',
      );

      // Cache the new audio
      await _audioService.cacheAudioSegment(
        contentId: enhancedContent.id,
        voiceId: voiceId ?? 'default',
        audioData: audioData,
        duration: enhancedContent.duration,
      );
    }

    return SmartContentResult(
      strategy: 'hybrid_reuse',
      contentBlocks: enhancedContent != null ? [enhancedContent] : [baseContent],
      audioData: audioData,
      estimatedDuration: enhancedContent?.duration ?? baseContent.duration,
      reuseRate: 0.6,
      confidenceScore: baseMatch.totalScore * 0.8,
      metadata: {
        'base_content_id': baseContent.id,
        'enhancement_applied': enhancedContent != null,
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
      category: category,
      topic: topic,
      contentType: contentType ?? 'lesson',
      difficulty: level,
      title: response['title'] ?? 'Learning: $topic',
      script: response['script'] ?? '',
      duration: targetDuration ?? Duration(minutes: 10),
      createdAt: DateTime.now(),
    );

    // Generate audio
    final audioData = await _ttsService.generateSpeech(
      text: newContent.script,
      coachId: preferredVoice ?? 'default',
    );

    // Generate and save hashtags for future reuse
    final contentTags = await _matchingService.generateHashtagsWithContent(
      topic: topic,
      category: category,
      level: level,
      generatedScript: newContent.script,
      contentType: contentType,
    );

    // Save content and tags for future reuse
    await _firestoreService.createContentBlock(newContent);
    await _matchingService.saveContentTags(newContent.id, contentTags);

    // Cache audio for future reuse
    await _audioService.cacheAudioSegment(
      contentId: newContent.id,
      voiceId: preferredVoice ?? 'default',
      audioData: audioData,
      duration: newContent.duration,
    );

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
        category: category,
        topic: topic,
        contentType: contentType ?? 'lesson',
        difficulty: level,
        title: response['title'] ?? 'Learning: $topic',
        script: response['script'] ?? 'Content generation temporarily unavailable.',
        duration: targetDuration ?? Duration(minutes: 10),
        createdAt: DateTime.now(),
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

  List<RankedContentMatch> _selectOptimalSegments(List<RankedContentMatch> matches, Duration targetDuration) {
    final selected = <RankedContentMatch>[];
    Duration currentDuration = Duration.zero;
    final targetMinutes = targetDuration.inMinutes;

    for (final match in matches) {
      if (currentDuration.inMinutes >= targetMinutes) break;
      if (selected.length >= 3) break; // Limit segments
      
      selected.add(match);
      currentDuration += match.content.duration;
    }

    return selected;
  }

  Future<ContentBlock?> _enhanceContentWithAI({
    required ContentBlock baseContent,
    required String topic,
    required String category,
    required String level,
    Duration? targetDuration,
  }) async {
    try {
      // Use AI to enhance existing content
      final enhancementPrompt = '''
Enhance this existing content for the topic "$topic":

Original Content:
"${baseContent.script}"

Requirements:
- Keep the core concepts but make it more engaging
- Add practical examples or applications
- Ensure it matches the $level level
- Target duration: ${targetDuration?.inMinutes ?? 10} minutes

Generate enhanced version with better flow and additional insights.
''';

      final response = await _gptService.generateContentBlock(
        topic: enhancementPrompt,
        category: category,
        level: level,
        contentType: 'enhanced',
      );

      return ContentBlock(
        id: 'enhanced_${baseContent.id}_${DateTime.now().millisecondsSinceEpoch}',
        category: baseContent.category,
        topic: baseContent.topic,
        contentType: baseContent.contentType,
        difficulty: baseContent.difficulty,
        title: 'Enhanced: ${baseContent.title}',
        script: response['script'] ?? baseContent.script,
        duration: targetDuration ?? baseContent.duration,
        createdAt: DateTime.now(),
        metadata: {
          'enhanced_from': baseContent.id,
          'enhancement_type': 'ai_improved',
        },
      );
    } catch (e) {
      AppLogger.error('Failed to enhance content with AI: $e');
      return null;
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

