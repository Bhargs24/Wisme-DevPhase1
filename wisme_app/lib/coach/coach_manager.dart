import 'dart:async';
import 'models/ai_coach.dart';
import 'models/coaching_session.dart';
import 'models/coach_relationship.dart';
import 'data/coach_data_service.dart';
import 'services/ai_coaching_service.dart';
import '../core/utils/logger.dart';
import '../core/exceptions/app_exceptions.dart';

/// Unified manager for all coaching-related operations
/// Provides a single interface for AI coaches, sessions, and relationships
class CoachManager {
  static CoachManager? _instance;
  
  final CoachDataService _dataService;
  final AICoachingService _aiService;
  final AppLogger _logger;

  // Session state management
  CoachingSession? _currentSession;
  final StreamController<CoachingSession?> _sessionController = 
      StreamController<CoachingSession?>.broadcast();

  // Coach state management
  List<AICoach>? _availableCoaches;
  final StreamController<List<AICoach>> _coachesController = 
      StreamController<List<AICoach>>.broadcast();

  CoachManager._internal({
    required CoachDataService dataService,
    required AICoachingService aiService,
    AppLogger? logger,
  }) : _dataService = dataService,
       _aiService = aiService,
       _logger = logger ?? AppLogger();

  /// Get singleton instance
  factory CoachManager.getInstance({
    CoachDataService? dataService,
    AICoachingService? aiService,
    AppLogger? logger,
  }) {
    _instance ??= CoachManager._internal(
      dataService: dataService ?? CoachDataService(),
      aiService: aiService ?? AICoachingService(
        apiKey: 'your-openai-api-key', // This should come from secure config
      ),
      logger: logger,
    );
    return _instance!;
  }

  /// Stream of current coaching session updates
  Stream<CoachingSession?> get sessionStream => _sessionController.stream;

  /// Stream of available coaches updates
  Stream<List<AICoach>> get coachesStream => _coachesController.stream;

  /// Current active coaching session
  CoachingSession? get currentSession => _currentSession;

  /// Check if there's an active coaching session
  bool get hasActiveSession => _currentSession?.isActive ?? false;

  // === COACH OPERATIONS ===

  /// Get all available coaches
  Future<List<AICoach>> getAvailableCoaches({bool refresh = false}) async {
    try {
      if (_availableCoaches == null || refresh) {
        _availableCoaches = await _dataService.getActiveCoaches();
        _coachesController.add(_availableCoaches!);
      }
      return _availableCoaches!;
    } catch (e, stack) {
      _logger.error('Failed to get available coaches', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get coach by ID
  Future<AICoach?> getCoach(String coachId) async {
    try {
      return await _dataService.getCoach(coachId);
    } catch (e, stack) {
      _logger.error('Failed to get coach', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get coaches by type
  Future<List<AICoach>> getCoachesByType(CoachType type) async {
    try {
      return await _dataService.getCoachesByType(type);
    } catch (e, stack) {
      _logger.error('Failed to get coaches by type', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get coaches by specialization
  Future<List<AICoach>> getCoachesBySpecialization(String specialization) async {
    try {
      return await _dataService.getCoachesBySpecialization(specialization);
    } catch (e, stack) {
      _logger.error('Failed to get coaches by specialization', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get recommended coach for user
  Future<AICoach?> getRecommendedCoach({
    required String userId,
    CoachType? preferredType,
    List<String>? interests,
  }) async {
    try {
      // Get user's existing relationships
      final relationships = await getUserCoachRelationships(userId);
      
      // If user has strong relationships, recommend the strongest one
      if (relationships.isNotEmpty) {
        final strongestRelationship = relationships
            .where((r) => r.isStrongRelationship)
            .toList()
          ..sort((a, b) => b.relationshipStrength.compareTo(a.relationshipStrength));
        
        if (strongestRelationship.isNotEmpty) {
          return await getCoach(strongestRelationship.first.coachId);
        }
      }

      // Get available coaches
      final coaches = await getAvailableCoaches();
      if (coaches.isEmpty) return null;

      // Filter by preferred type if specified
      List<AICoach> candidates = coaches;
      if (preferredType != null) {
        candidates = coaches.where((coach) => coach.type == preferredType).toList();
        if (candidates.isEmpty) candidates = coaches; // Fallback to all coaches
      }

      // Score coaches based on various factors
      candidates.sort((a, b) {
        int scoreA = _calculateCoachScore(a, interests, relationships);
        int scoreB = _calculateCoachScore(b, interests, relationships);
        return scoreB.compareTo(scoreA);
      });

      return candidates.first;
    } catch (e, stack) {
      _logger.error('Failed to get recommended coach', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === SESSION OPERATIONS ===

  /// Start a coaching session
  Future<CoachingSession> startCoachingSession({
    required String userId,
    required String coachId,
    String? lessonId,
    SessionType type = SessionType.guidance,
    List<String>? goals,
    Map<String, dynamic>? context,
  }) async {
    try {
      // End any existing session
      if (_currentSession != null) {
        await endCurrentSession();
      }

      // Get coach details
      final coach = await getCoach(coachId);
      if (coach == null) {
        throw ServiceException('Coach not found: $coachId');
      }

      // Create new session
      final sessionId = _generateSessionId();
      final now = DateTime.now();

      _currentSession = CoachingSession(
        id: sessionId,
        userId: userId,
        coachId: coachId,
        lessonId: lessonId,
        type: type,
        status: SessionStatus.active,
        startTime: now,
        messages: [],
        context: context ?? {},
        goals: goals ?? [],
        outcomes: {},
        metadata: {
          'coachName': coach.name,
          'coachType': coach.type.name,
        },
      );

      // Save to database
      await _dataService.saveCoachingSession(_currentSession!);

      // Update relationship if exists
      await _updateOrCreateRelationship(userId, coachId);

      // Notify listeners
      _sessionController.add(_currentSession);

      _logger.info('Coaching session started: $sessionId with coach: $coachId');
      return _currentSession!;
    } catch (e, stack) {
      _logger.error('Failed to start coaching session', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Send message to AI coach and get response
  Future<CoachMessage> sendMessage({
    required String message,
    Map<String, dynamic>? additionalContext,
  }) async {
    if (_currentSession == null) {
      throw ServiceException('No active coaching session');
    }

    try {
      final coach = await getCoach(_currentSession!.coachId);
      if (coach == null) {
        throw ServiceException('Coach not found for current session');
      }

      // Prepare context for AI
      final context = {
        ..._currentSession!.context,
        'sessionType': _currentSession!.type.name,
        'goals': _currentSession!.goals,
        'messageCount': _currentSession!.messages.length,
        ...additionalContext ?? {},
      };

      // Generate AI response
      final coachResponse = await _aiService.generateResponse(
        sessionId: _currentSession!.id,
        userMessage: message,
        coach: coach,
        context: context,
      );

      // Update session with new messages
      final updatedMessages = [
        ..._currentSession!.messages,
        CoachMessage(
          id: _generateMessageId(),
          sender: MessageSender.user,
          content: message,
          type: MessageType.text,
          timestamp: DateTime.now(),
          attachments: {},
          intent: MessageIntent.question,
          metadata: {},
        ),
        coachResponse,
      ];

      _currentSession = _currentSession!.copyWith(messages: updatedMessages);

      // Save updated session
      await _dataService.saveCoachingSession(_currentSession!);

      // Notify listeners
      _sessionController.add(_currentSession);

      _logger.info('Message exchange completed in session: ${_currentSession!.id}');
      return coachResponse;
    } catch (e, stack) {
      _logger.error('Failed to send message', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get coaching suggestions from AI
  Future<List<String>> getCoachingSuggestions({
    required String userId,
    required String coachId,
    Map<String, dynamic>? userContext,
    int maxSuggestions = 3,
  }) async {
    try {
      final coach = await getCoach(coachId);
      if (coach == null) {
        throw ServiceException('Coach not found: $coachId');
      }

      return await _aiService.generateSuggestions(
        coach: coach,
        userContext: userContext ?? {},
        maxSuggestions: maxSuggestions,
      );
    } catch (e, stack) {
      _logger.error('Failed to get coaching suggestions', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Complete current coaching session
  Future<void> completeCoachingSession({
    Map<String, dynamic>? outcomes,
    SessionQuality? quality,
  }) async {
    if (_currentSession == null) {
      throw ServiceException('No active coaching session to complete');
    }

    try {
      final now = DateTime.now();
      
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.completed,
        endTime: now,
        outcomes: outcomes ?? _currentSession!.outcomes,
        quality: quality,
      );

      // Save final session state
      await _dataService.saveCoachingSession(_currentSession!);

      // Update relationship
      await _updateRelationshipFromSession(_currentSession!);

      _logger.info('Coaching session completed: ${_currentSession!.id}');

      // Clear current session
      _currentSession = null;
      _sessionController.add(null);
    } catch (e, stack) {
      _logger.error('Failed to complete coaching session', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// End current coaching session
  Future<void> endCurrentSession() async {
    if (_currentSession == null) return;

    try {
      final now = DateTime.now();
      
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.terminated,
        endTime: now,
      );

      await _dataService.saveCoachingSession(_currentSession!);

      _logger.info('Coaching session ended: ${_currentSession!.id}');

      // Clear current session
      _currentSession = null;
      _sessionController.add(null);
    } catch (e, stack) {
      _logger.error('Failed to end coaching session', error: e, stackTrace: stack);
    }
  }

  // === RELATIONSHIP OPERATIONS ===

  /// Get user's coach relationships
  Future<List<CoachRelationship>> getUserCoachRelationships(String userId) async {
    try {
      return await _dataService.getUserCoachRelationships(userId);
    } catch (e, stack) {
      _logger.error('Failed to get user coach relationships', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get relationship with specific coach
  Future<CoachRelationship?> getCoachRelationship(String userId, String coachId) async {
    try {
      return await _dataService.getCoachRelationship(userId, coachId);
    } catch (e, stack) {
      _logger.error('Failed to get coach relationship', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get user's session history
  Future<List<CoachingSession>> getSessionHistory(String userId, {int? limit}) async {
    try {
      return await _dataService.getUserCoachingSessions(userId, limit: limit);
    } catch (e, stack) {
      _logger.error('Failed to get session history', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get session statistics
  Future<Map<String, dynamic>> getSessionStatistics(String userId) async {
    try {
      return await _dataService.getSessionStatistics(userId);
    } catch (e, stack) {
      _logger.error('Failed to get session statistics', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // === UTILITY METHODS ===

  /// Calculate coach recommendation score
  int _calculateCoachScore(
    AICoach coach,
    List<String>? interests,
    List<CoachRelationship> existingRelationships,
  ) {
    int score = 0;

    // Specialization match
    if (interests != null) {
      final matches = coach.specializations
          .where((spec) => interests.any((interest) => 
              spec.toLowerCase().contains(interest.toLowerCase())))
          .length;
      score += matches * 10;
    }

    // Relationship history (slight penalty for overused coaches)
    final existingRelation = existingRelationships
        .where((rel) => rel.coachId == coach.id)
        .firstOrNull;
    
    if (existingRelation != null) {
      if (existingRelation.relationshipStrength > 0.8) {
        score += 5; // Bonus for strong relationship
      } else if (existingRelation.totalSessions > 20) {
        score -= 3; // Small penalty for overuse
      }
    } else {
      score += 2; // Bonus for trying new coaches
    }

    // Coach type variety bonus
    final coachTypeCount = existingRelationships
        .map((rel) => rel.coachId)
        .toSet()
        .length;
    if (coachTypeCount < 3) {
      score += 3; // Encourage trying different types
    }

    return score;
  }

  /// Update or create coach relationship
  Future<void> _updateOrCreateRelationship(String userId, String coachId) async {
    try {
      final existing = await getCoachRelationship(userId, coachId);
      final now = DateTime.now();

      if (existing != null) {
        // Update existing relationship
        final updated = existing.copyWith(
          totalSessions: existing.totalSessions + 1,
          lastInteraction: now,
        );
        await _dataService.saveCoachRelationship(updated);
      } else {
        // Create new relationship
        final relationshipId = _generateRelationshipId(userId, coachId);
        final newRelationship = CoachRelationship(
          id: relationshipId,
          userId: userId,
          coachId: coachId,
          status: RelationshipStatus.new_,
          trustLevel: 0.5,
          satisfactionLevel: 0.5,
          totalSessions: 1,
          totalInteractionTime: Duration.zero,
          firstInteraction: now,
          lastInteraction: now,
          preferences: [],
          learningStyle: {},
          milestones: [
            RelationshipMilestone(
              id: _generateMilestoneId(),
              type: MilestoneType.firstInteraction,
              title: 'First Interaction',
              description: 'Started coaching relationship',
              achievedAt: now,
              data: {},
            ),
          ],
          personalizations: {},
          metadata: {},
        );
        await _dataService.saveCoachRelationship(newRelationship);
      }
    } catch (e, stack) {
      _logger.error('Failed to update relationship', error: e, stackTrace: stack);
    }
  }

  /// Update relationship from completed session
  Future<void> _updateRelationshipFromSession(CoachingSession session) async {
    try {
      final relationship = await getCoachRelationship(session.userId, session.coachId);
      if (relationship == null) return;

      final sessionDuration = session.duration ?? Duration.zero;
      final qualityRating = session.quality?.overallRating ?? 0.5;

      final updated = relationship.copyWith(
        totalInteractionTime: relationship.totalInteractionTime + sessionDuration,
        satisfactionLevel: (relationship.satisfactionLevel + qualityRating) / 2,
        lastInteraction: session.endTime ?? session.startTime,
      );

      await _dataService.saveCoachRelationship(updated);
    } catch (e, stack) {
      _logger.error('Failed to update relationship from session', error: e, stackTrace: stack);
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'coach_session_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  /// Generate unique relationship ID
  String _generateRelationshipId(String userId, String coachId) {
    return 'rel_${userId}_$coachId';
  }

  /// Generate unique milestone ID
  String _generateMilestoneId() {
    return 'milestone_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt((chars.length * 0.5).round())));
  }

  /// Dispose resources
  void dispose() {
    _sessionController.close();
    _coachesController.close();
  }
}
