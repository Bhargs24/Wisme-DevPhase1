import 'dart:async';
import '../models/learning_session.dart';
import '../models/lesson.dart';
import '../data/learning_data_service.dart';
import '../../core/utils/logger.dart';
import '../../core/exceptions/app_exceptions.dart';

/// Service for managing learning sessions and tracking user activity
class LearningSessionService {
  final LearningDataService _dataService;
  final AppLogger _logger;
  
  // Session state management
  LearningSession? _currentSession;
  Timer? _sessionTimer;
  final StreamController<LearningSession?> _sessionController = 
      StreamController<LearningSession?>.broadcast();

  LearningSessionService({
    required LearningDataService dataService,
    AppLogger? logger,
  }) : _dataService = dataService,
       _logger = logger ?? AppLogger();

  /// Stream of current session updates
  Stream<LearningSession?> get sessionStream => _sessionController.stream;

  /// Current active session
  LearningSession? get currentSession => _currentSession;

  /// Check if there's an active session
  bool get hasActiveSession => _currentSession?.status == SessionStatus.active;

  /// Start a new learning session
  Future<LearningSession> startSession({
    required String userId,
    required String lessonId,
    required SessionType type,
    String? audioFileId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // End any existing session
      if (_currentSession != null) {
        await endCurrentSession();
      }

      final sessionId = _generateSessionId();
      final now = DateTime.now();

      _currentSession = LearningSession(
        id: sessionId,
        userId: userId,
        lessonId: lessonId,
        startTime: now,
        status: SessionStatus.active,
        progressPercentage: 0.0,
        events: [
          SessionEvent(
            id: _generateEventId(),
            type: SessionEventType.start,
            timestamp: now,
            data: {'type': type.name},
          ),
        ],
        performance: {},
        completedObjectives: [],
        type: type,
        audioFileId: audioFileId,
        metadata: metadata ?? {},
      );

      // Start session tracking timer
      _startSessionTimer();

      // Notify listeners
      _sessionController.add(_currentSession);

      // Save to database
      await _dataService.saveLearningSession(_currentSession!);

      _logger.info('Learning session started: $sessionId');
      return _currentSession!;
    } catch (e, stack) {
      _logger.error('Failed to start learning session', error: e, stackTrace: stack);
      throw ServiceException('Failed to start learning session: $e');
    }
  }

  /// Pause the current session
  Future<void> pauseSession() async {
    if (_currentSession == null || _currentSession!.status != SessionStatus.active) {
      throw ServiceException('No active session to pause');
    }

    try {
      final now = DateTime.now();
      final pauseEvent = SessionEvent(
        id: _generateEventId(),
        type: SessionEventType.pause,
        timestamp: now,
        data: {},
      );

      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.paused,
        events: [..._currentSession!.events, pauseEvent],
      );

      // Stop timer
      _sessionTimer?.cancel();

      // Notify listeners
      _sessionController.add(_currentSession);

      // Save to database
      await _dataService.saveLearningSession(_currentSession!);

      _logger.info('Learning session paused: ${_currentSession!.id}');
    } catch (e, stack) {
      _logger.error('Failed to pause session', error: e, stackTrace: stack);
      throw ServiceException('Failed to pause session: $e');
    }
  }

  /// Resume the current session
  Future<void> resumeSession() async {
    if (_currentSession == null || _currentSession!.status != SessionStatus.paused) {
      throw ServiceException('No paused session to resume');
    }

    try {
      final now = DateTime.now();
      final resumeEvent = SessionEvent(
        id: _generateEventId(),
        type: SessionEventType.resume,
        timestamp: now,
        data: {},
      );

      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.active,
        events: [..._currentSession!.events, resumeEvent],
      );

      // Restart timer
      _startSessionTimer();

      // Notify listeners
      _sessionController.add(_currentSession);

      // Save to database
      await _dataService.saveLearningSession(_currentSession!);

      _logger.info('Learning session resumed: ${_currentSession!.id}');
    } catch (e, stack) {
      _logger.error('Failed to resume session', error: e, stackTrace: stack);
      throw ServiceException('Failed to resume session: $e');
    }
  }

  /// Update session progress
  Future<void> updateProgress(double progressPercentage) async {
    if (_currentSession == null) return;

    try {
      _currentSession = _currentSession!.copyWith(
        progressPercentage: progressPercentage.clamp(0.0, 100.0),
      );

      // Notify listeners
      _sessionController.add(_currentSession);

      // Save to database periodically (every 10% progress)
      if (progressPercentage % 10 == 0) {
        await _dataService.saveLearningSession(_currentSession!);
      }

      _logger.debug('Session progress updated: ${progressPercentage.toStringAsFixed(1)}%');
    } catch (e, stack) {
      _logger.error('Failed to update progress', error: e, stackTrace: stack);
    }
  }

  /// Add milestone event to session
  Future<void> addMilestone(String milestone, Map<String, dynamic> data) async {
    if (_currentSession == null) return;

    try {
      final milestoneEvent = SessionEvent(
        id: _generateEventId(),
        type: SessionEventType.milestone,
        timestamp: DateTime.now(),
        data: {'milestone': milestone, ...data},
      );

      _currentSession = _currentSession!.copyWith(
        events: [..._currentSession!.events, milestoneEvent],
      );

      // Notify listeners
      _sessionController.add(_currentSession);

      _logger.info('Milestone added: $milestone');
    } catch (e, stack) {
      _logger.error('Failed to add milestone', error: e, stackTrace: stack);
    }
  }

  /// Complete the current session
  Future<void> completeSession({
    Map<String, dynamic>? performance,
    List<String>? completedObjectives,
  }) async {
    if (_currentSession == null) {
      throw ServiceException('No active session to complete');
    }

    try {
      final now = DateTime.now();
      final completeEvent = SessionEvent(
        id: _generateEventId(),
        type: SessionEventType.complete,
        timestamp: now,
        data: {},
      );

      _currentSession = _currentSession!.copyWith(
        endTime: now,
        duration: now.difference(_currentSession!.startTime),
        status: SessionStatus.completed,
        progressPercentage: 100.0,
        events: [..._currentSession!.events, completeEvent],
        performance: performance ?? _currentSession!.performance,
        completedObjectives: completedObjectives ?? _currentSession!.completedObjectives,
      );

      // Stop timer
      _sessionTimer?.cancel();

      // Notify listeners
      _sessionController.add(_currentSession);

      // Save to database
      await _dataService.saveLearningSession(_currentSession!);

      _logger.info('Learning session completed: ${_currentSession!.id}');

      // Clear current session
      _currentSession = null;
      _sessionController.add(null);
    } catch (e, stack) {
      _logger.error('Failed to complete session', error: e, stackTrace: stack);
      throw ServiceException('Failed to complete session: $e');
    }
  }

  /// End current session (abandon if not completed)
  Future<void> endCurrentSession() async {
    if (_currentSession == null) return;

    try {
      final now = DateTime.now();
      final endEvent = SessionEvent(
        id: _generateEventId(),
        type: SessionEventType.abandon,
        timestamp: now,
        data: {},
      );

      _currentSession = _currentSession!.copyWith(
        endTime: now,
        duration: now.difference(_currentSession!.startTime),
        status: SessionStatus.abandoned,
        events: [..._currentSession!.events, endEvent],
      );

      // Stop timer
      _sessionTimer?.cancel();

      // Save to database
      await _dataService.saveLearningSession(_currentSession!);

      _logger.info('Learning session ended: ${_currentSession!.id}');

      // Clear current session
      _currentSession = null;
      _sessionController.add(null);
    } catch (e, stack) {
      _logger.error('Failed to end session', error: e, stackTrace: stack);
    }
  }

  /// Get user's session history for a lesson
  Future<List<LearningSession>> getSessionHistory(String userId, String lessonId) async {
    try {
      return await _dataService.getUserSessions(userId, lessonId);
    } catch (e, stack) {
      _logger.error('Failed to get session history', error: e, stackTrace: stack);
      throw ServiceException('Failed to get session history: $e');
    }
  }

  /// Get user's recent sessions
  Future<List<LearningSession>> getRecentSessions(String userId, {int limit = 20}) async {
    try {
      return await _dataService.getRecentSessions(userId, limit: limit);
    } catch (e, stack) {
      _logger.error('Failed to get recent sessions', error: e, stackTrace: stack);
      throw ServiceException('Failed to get recent sessions: $e');
    }
  }

  /// Start session tracking timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentSession != null && _currentSession!.status == SessionStatus.active) {
        // Auto-save session every 30 seconds
        _dataService.saveLearningSession(_currentSession!).catchError((e) {
          _logger.error('Failed to auto-save session', error: e);
        });
      }
    });
  }

  /// Generate unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  /// Generate unique event ID
  String _generateEventId() {
    return 'event_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt((chars.length * 0.5).round())));
  }

  /// Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    _sessionController.close();
  }
}
