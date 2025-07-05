import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coaching_session.dart';
import '../models/ai_coach.dart';
import '../models/coach_relationship.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';

/// Data service for coaching-related operations with Firestore
class CoachDataService {
  static const String _coachesCollection = 'ai_coaches';
  static const String _sessionsCollection = 'coaching_sessions';
  static const String _relationshipsCollection = 'coach_relationships';

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  CoachDataService({
    FirebaseFirestore? firestore,
    AppLogger? logger,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _logger = logger ?? AppLogger();

  // === AI COACH OPERATIONS ===

  /// Get AI coach by ID
  Future<AICoach?> getCoach(String coachId) async {
    try {
      final doc = await _firestore
          .collection(_coachesCollection)
          .doc(coachId)
          .get();

      if (!doc.exists) return null;

      return AICoach.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e, stack) {
      _logger.error('Failed to get coach: $coachId', error: e, stackTrace: stack);
      throw DataException('Failed to fetch coach: $e');
    }
  }

  /// Get all active coaches
  Future<List<AICoach>> getActiveCoaches() async {
    try {
      final query = await _firestore
          .collection(_coachesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt')
          .get();

      return query.docs.map((doc) => AICoach.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get active coaches', error: e, stackTrace: stack);
      throw DataException('Failed to fetch active coaches: $e');
    }
  }

  /// Get coaches by type
  Future<List<AICoach>> getCoachesByType(CoachType type) async {
    try {
      final query = await _firestore
          .collection(_coachesCollection)
          .where('type', isEqualTo: type.name)
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) => AICoach.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get coaches by type', error: e, stackTrace: stack);
      throw DataException('Failed to fetch coaches by type: $e');
    }
  }

  /// Get coaches by specialization
  Future<List<AICoach>> getCoachesBySpecialization(String specialization) async {
    try {
      final query = await _firestore
          .collection(_coachesCollection)
          .where('specializations', arrayContains: specialization)
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) => AICoach.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get coaches by specialization', error: e, stackTrace: stack);
      throw DataException('Failed to fetch coaches by specialization: $e');
    }
  }

  // === COACHING SESSION OPERATIONS ===

  /// Save coaching session
  Future<void> saveCoachingSession(CoachingSession session) async {
    try {
      final data = session.toJson();
      data.remove('id'); // Remove ID from data

      await _firestore
          .collection(_sessionsCollection)
          .doc(session.id)
          .set(data, SetOptions(merge: true));

      _logger.info('Coaching session saved: ${session.id}');
    } catch (e, stack) {
      _logger.error('Failed to save coaching session', error: e, stackTrace: stack);
      throw DataException('Failed to save coaching session: $e');
    }
  }

  /// Get coaching session by ID
  Future<CoachingSession?> getCoachingSession(String sessionId) async {
    try {
      final doc = await _firestore
          .collection(_sessionsCollection)
          .doc(sessionId)
          .get();

      if (!doc.exists) return null;

      return CoachingSession.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e, stack) {
      _logger.error('Failed to get coaching session: $sessionId', error: e, stackTrace: stack);
      throw DataException('Failed to fetch coaching session: $e');
    }
  }

  /// Get user's coaching sessions
  Future<List<CoachingSession>> getUserCoachingSessions(String userId, {int? limit}) async {
    try {
      Query query = _firestore
          .collection(_sessionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) => CoachingSession.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get user coaching sessions', error: e, stackTrace: stack);
      throw DataException('Failed to fetch user coaching sessions: $e');
    }
  }

  /// Get sessions between user and specific coach
  Future<List<CoachingSession>> getSessionsWithCoach(String userId, String coachId) async {
    try {
      final query = await _firestore
          .collection(_sessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('coachId', isEqualTo: coachId)
          .orderBy('startTime', descending: true)
          .get();

      return query.docs.map((doc) => CoachingSession.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get sessions with coach', error: e, stackTrace: stack);
      throw DataException('Failed to fetch sessions with coach: $e');
    }
  }

  /// Get active coaching session for user
  Future<CoachingSession?> getActiveSession(String userId) async {
    try {
      final query = await _firestore
          .collection(_sessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: SessionStatus.active.name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return CoachingSession.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    } catch (e, stack) {
      _logger.error('Failed to get active session', error: e, stackTrace: stack);
      throw DataException('Failed to fetch active session: $e');
    }
  }

  // === COACH RELATIONSHIP OPERATIONS ===

  /// Get coach relationship
  Future<CoachRelationship?> getCoachRelationship(String userId, String coachId) async {
    try {
      final relationshipId = _generateRelationshipId(userId, coachId);
      final doc = await _firestore
          .collection(_relationshipsCollection)
          .doc(relationshipId)
          .get();

      if (!doc.exists) return null;

      return CoachRelationship.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e, stack) {
      _logger.error('Failed to get coach relationship', error: e, stackTrace: stack);
      throw DataException('Failed to fetch coach relationship: $e');
    }
  }

  /// Save coach relationship
  Future<void> saveCoachRelationship(CoachRelationship relationship) async {
    try {
      final data = relationship.toJson();
      data.remove('id'); // Remove ID from data

      await _firestore
          .collection(_relationshipsCollection)
          .doc(relationship.id)
          .set(data, SetOptions(merge: true));

      _logger.info('Coach relationship saved: ${relationship.id}');
    } catch (e, stack) {
      _logger.error('Failed to save coach relationship', error: e, stackTrace: stack);
      throw DataException('Failed to save coach relationship: $e');
    }
  }

  /// Get all user's coach relationships
  Future<List<CoachRelationship>> getUserCoachRelationships(String userId) async {
    try {
      final query = await _firestore
          .collection(_relationshipsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('lastInteraction', descending: true)
          .get();

      return query.docs.map((doc) => CoachRelationship.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      _logger.error('Failed to get user coach relationships', error: e, stackTrace: stack);
      throw DataException('Failed to fetch user coach relationships: $e');
    }
  }

  /// Get strongest coach relationship for user
  Future<CoachRelationship?> getStrongestRelationship(String userId) async {
    try {
      final relationships = await getUserCoachRelationships(userId);
      if (relationships.isEmpty) return null;

      // Sort by relationship strength
      relationships.sort((a, b) => b.relationshipStrength.compareTo(a.relationshipStrength));
      return relationships.first;
    } catch (e, stack) {
      _logger.error('Failed to get strongest relationship', error: e, stackTrace: stack);
      throw DataException('Failed to fetch strongest relationship: $e');
    }
  }

  // === SESSION STATISTICS ===

  /// Get session statistics for user
  Future<Map<String, dynamic>> getSessionStatistics(String userId) async {
    try {
      final sessions = await getUserCoachingSessions(userId);
      
      final totalSessions = sessions.length;
      final completedSessions = sessions.where((s) => s.isCompleted).length;
      final totalDuration = sessions
          .where((s) => s.duration != null)
          .fold<Duration>(Duration.zero, (total, session) => total + session.duration!);
      
      final averageSessionDuration = totalSessions > 0 
          ? Duration(milliseconds: totalDuration.inMilliseconds ~/ totalSessions)
          : Duration.zero;

      // Group by coach
      final coachCounts = <String, int>{};
      for (final session in sessions) {
        coachCounts[session.coachId] = (coachCounts[session.coachId] ?? 0) + 1;
      }

      final mostUsedCoachId = coachCounts.isNotEmpty
          ? coachCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null;

      return {
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'totalDuration': totalDuration.inMinutes,
        'averageSessionDuration': averageSessionDuration.inMinutes,
        'completionRate': totalSessions > 0 ? completedSessions / totalSessions : 0.0,
        'mostUsedCoachId': mostUsedCoachId,
        'coachDistribution': coachCounts,
      };
    } catch (e, stack) {
      _logger.error('Failed to get session statistics', error: e, stackTrace: stack);
      throw DataException('Failed to fetch session statistics: $e');
    }
  }

  /// Generate relationship ID
  String _generateRelationshipId(String userId, String coachId) {
    return 'rel_${userId}_$coachId';
  }
}
