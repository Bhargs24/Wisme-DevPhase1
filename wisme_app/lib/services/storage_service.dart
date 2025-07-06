import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

class StorageService {
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  final Logger _logger = Logger();
  
  // Collection references
  static const String _lessonsCollection = 'lessons';
  static const String _topicsCollection = 'topics';
  static const String _audioStoragePath = 'generated_audio';

  StorageService() {
    try {
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _logger.i('✅ StorageService: Firebase Storage initialized');
    } catch (e) {
      _logger.w('⚠️ StorageService: Firebase not available (this is expected in offline mode): $e');
      // The app will continue to work, Firebase-dependent features will show errors
    }
  }

  /// Normalize topic name for consistent storage
  String _normalizeTopicName(String topic) {
    return topic
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Generate lesson ID from subtopic and create unique lesson identifier
  String _generateLessonId(String subtopic, String lessonTitle) {
    final subtopicNormalized = subtopic
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    
    final titleNormalized = lessonTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    
    // Create unique lesson ID combining subtopic and title
    return '${subtopicNormalized}_$titleNormalized';
  }

  /// Check if a lesson already exists for a subtopic with specific voice
  Future<Map<String, dynamic>?> findExistingLesson(String subtopic, String lessonTitle, {String? coachVoice}) async {
    try {
      final lessonId = _generateLessonId(subtopic, lessonTitle);
      
      // Search by lesson_id and voice (exact match)
      var query = _firestore
          .collection(_lessonsCollection)
          .where('lesson_id', isEqualTo: lessonId);
      
      if (coachVoice != null) {
        query = query.where('coach_voice', isEqualTo: coachVoice);
      }
      
      final exactQuery = await query.limit(1).get();
      
      if (exactQuery.docs.isNotEmpty) {
        return exactQuery.docs.first.data();
      }
      
      // Search by tags (semantic match)
      final keywords = subtopic.toLowerCase().split(' ');
      final tagQuery = await _firestore
          .collection(_lessonsCollection)
          .where('tags', arrayContainsAny: keywords)
          .limit(5)
          .get();
      
      // Find best semantic match
      for (final doc in tagQuery.docs) {
        final data = doc.data();
        final title = (data['title'] as String).toLowerCase();
        final summary = (data['summary'] as String).toLowerCase();
        
        // Check if query intent matches existing content
        if (_hasSemanticMatch(subtopic.toLowerCase(), title, summary)) {
          return data;
        }
      }
      
      return null;
    } catch (e) {
      _logger.e('Error finding existing lesson: $e');
      return null;
    }
  }

  /// Check semantic similarity between query and existing content
  bool _hasSemanticMatch(String query, String title, String summary) {
    final queryWords = query.split(' ');
    final contentWords = [...title.split(' '), ...summary.split(' ')];
    
    int matches = 0;
    for (final word in queryWords) {
      if (word.length > 3 && contentWords.any((w) => w.contains(word))) {
        matches++;
      }
    }
    
    // Consider it a match if 60% of query words are found
    return matches >= (queryWords.length * 0.6);
  }

  /// Store a new lesson with hierarchical voice-first structure
  Future<String> storeNewLesson({
    required String topic,
    required String subtopic,
    required String title,
    required String lessonContent,
    required Uint8List audioData,
    required int durationSeconds,
    required List<String> tags,
    String? summary,
    String coachVoice = 'default',
  }) async {
    try {
      final normalizedTopic = _normalizeTopicName(topic);
      final normalizedSubtopic = _normalizeTopicName(subtopic);
      final lessonId = _generateLessonId(subtopic, title);
      
      // Create new hierarchical storage path: generated_audio/voice_name/topic/subtopic/lesson.mp3
      final fileName = '$lessonId.mp3';
      final storagePath = '$_audioStoragePath/$coachVoice/$normalizedTopic/$normalizedSubtopic/$fileName';
      final storageRef = _storage.ref().child(storagePath);
      
      // Upload audio file
      final uploadTask = await storageRef.putData(
        audioData,
        SettableMetadata(
          contentType: 'audio/mpeg',
          customMetadata: {
            'topic': topic,
            'subtopic': subtopic,
            'lesson_id': lessonId,
            'generated_at': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      final audioUrl = await uploadTask.ref.getDownloadURL();
      
      // Store lesson metadata with voice-first document ID structure
      final docId = '${coachVoice}_$lessonId';
      final lessonData = {
        'lesson_id': lessonId,
        'topic': topic,
        'subtopic': subtopic,
        'title': title,
        'audio_url': audioUrl,
        'text': lessonContent,
        'summary': summary ?? _generateSummary(lessonContent),
        'word_count': lessonContent.split(' ').length,
        'duration_seconds': durationSeconds,
        'length': _formatDuration(durationSeconds),
        'tags': [...tags, ...topic.toLowerCase().split(' ')],
        'coach_voice': coachVoice,
        'created_at': FieldValue.serverTimestamp(),
        'access_count': 0,
        'last_accessed_at': null,
        'file_size': audioData.length,
        'storage_path': storagePath,
      };
      
      // Store in Firestore with voice-specific document ID
      await _firestore.collection(_lessonsCollection).doc(docId).set(lessonData);
      
      // Update topic metadata
      await _updateTopicMetadata(topic, subtopic, lessonId);
      
      return audioUrl;
    } catch (e) {
      throw Exception('Failed to store lesson: $e');
    }
  }

  /// Update topic metadata for better organization
  Future<void> _updateTopicMetadata(String topic, String subtopic, String lessonId) async {
    try {
      final normalizedTopic = _normalizeTopicName(topic);
      final topicRef = _firestore.collection(_topicsCollection).doc(normalizedTopic);
      
      await topicRef.set({
        'topic_name': topic,
        'normalized_name': normalizedTopic,
        'subtopics': FieldValue.arrayUnion([subtopic]),
        'lesson_ids': FieldValue.arrayUnion([lessonId]),
        'lesson_count': FieldValue.increment(1),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _logger.e('Error updating topic metadata: $e');
    }
  }

  /// Generate a summary from lesson content
  String _generateSummary(String content) {
    final sentences = content.split('. ');
    if (sentences.length <= 2) return content;
    
    // Take first 2 sentences as summary
    return '${sentences[0]}. ${sentences[1]}.';
  }

  /// Format duration in human-readable format
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  /// Get all voice variations for a specific lesson
  Future<List<Map<String, dynamic>>> getVoiceVariations(String subtopic, String lessonTitle) async {
    try {
      final lessonId = _generateLessonId(subtopic, lessonTitle);
      
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .where('lesson_id', isEqualTo: lessonId)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.e('Error getting voice variations: $e');
      return [];
    }
  }

  /// Get lesson content (text) without voice - for generating new voice variations
  Future<Map<String, dynamic>?> getLessonContent(String subtopic, String lessonTitle) async {
    try {
      final lessonId = _generateLessonId(subtopic, lessonTitle);
      
      // Get any voice variation to extract the text content
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .where('lesson_id', isEqualTo: lessonId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return {
          'lesson_id': data['lesson_id'],
          'topic': data['topic'],
          'subtopic': data['subtopic'],
          'title': data['title'],
          'text': data['text'],
          'summary': data['summary'],
          'word_count': data['word_count'],
          'tags': data['tags'],
        };
      }
      
      return null;
    } catch (e) {
      _logger.e('Error getting lesson content: $e');
      return null;
    }
  }

  /// Generate new voice variation for existing lesson content
  Future<String> generateVoiceVariation({
    required String lessonId,
    required String topic,
    required String subtopic,
    required String title,
    required String lessonContent,
    required String newCoachVoice,
    required Uint8List audioData,
    required int durationSeconds,
    required List<String> tags,
  }) async {
    try {
      final normalizedTopic = _normalizeTopicName(topic);
      final normalizedSubtopic = _normalizeTopicName(subtopic);
      
      // Create storage path for new voice variation using new hierarchy
      final fileName = '$lessonId.mp3';
      final storagePath = '$_audioStoragePath/$newCoachVoice/$normalizedTopic/$normalizedSubtopic/$fileName';
      final storageRef = _storage.ref().child(storagePath);
      
      // Upload audio file
      final uploadTask = await storageRef.putData(
        audioData,
        SettableMetadata(
          contentType: 'audio/mpeg',
          customMetadata: {
            'topic': topic,
            'subtopic': subtopic,
            'lesson_id': lessonId,
            'coach_voice': newCoachVoice,
            'generated_at': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      final audioUrl = await uploadTask.ref.getDownloadURL();
      
      // Store new voice variation with voice-first document ID
      final docId = '${newCoachVoice}_$lessonId';
      final lessonData = {
        'lesson_id': lessonId,
        'topic': topic,
        'subtopic': subtopic,
        'title': title,
        'audio_url': audioUrl,
        'text': lessonContent,
        'summary': _generateSummary(lessonContent),
        'word_count': lessonContent.split(' ').length,
        'duration_seconds': durationSeconds,
        'length': _formatDuration(durationSeconds),
        'tags': tags,
        'coach_voice': newCoachVoice,
        'created_at': FieldValue.serverTimestamp(),
        'access_count': 0,
        'last_accessed_at': null,
        'file_size': audioData.length,
        'storage_path': storagePath,
      };
      
      await _firestore.collection(_lessonsCollection).doc(docId).set(lessonData);
      
      return audioUrl;
    } catch (e) {
      throw Exception('Failed to generate voice variation: $e');
    }
  }

  /// Increment access count for specific voice variation
  Future<void> incrementLessonAccess(String lessonId, String coachVoice) async {
    try {
      final docId = '${coachVoice}_$lessonId';
      await _firestore.collection(_lessonsCollection).doc(docId).update({
        'access_count': FieldValue.increment(1),
        'last_accessed_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Error incrementing access count: $e');
    }
  }

  /// Get lessons by topic for building learning paths
  Future<List<Map<String, dynamic>>> getLessonsByTopic(String topic) async {
    try {
      final normalizedTopic = _normalizeTopicName(topic);
      
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .where('topic', isEqualTo: normalizedTopic)
          .orderBy('created_at', descending: false)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.e('Error getting lessons by topic: $e');
      return [];
    }
  }

  /// Search lessons by tags and keywords
  Future<List<Map<String, dynamic>>> searchLessons(String query) async {
    try {
      final keywords = query.toLowerCase().split(' ').where((w) => w.length > 2).toList();
      
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .where('tags', arrayContainsAny: keywords)
          .orderBy('access_count', descending: true)
          .limit(20)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.e('Error searching lessons: $e');
      return [];
    }
  }

  /// Get popular lessons for recommendations
  Future<List<Map<String, dynamic>>> getPopularLessons({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .orderBy('access_count', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.e('Error getting popular lessons: $e');
      return [];
    }
  }

  /// Get related lessons based on tags
  Future<List<Map<String, dynamic>>> getRelatedLessons(String lessonId, {int limit = 5}) async {
    try {
      // Get current lesson
      final currentDoc = await _firestore.collection(_lessonsCollection).doc(lessonId).get();
      if (!currentDoc.exists) return [];
      
      final currentTags = List<String>.from(currentDoc.data()!['tags'] ?? []);
      
      // Find lessons with similar tags
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .where('tags', arrayContainsAny: currentTags)
          .orderBy('access_count', descending: true)
          .limit(limit + 1) // +1 to exclude current lesson
          .get();
      
      return snapshot.docs
          .where((doc) => doc.id != lessonId)
          .take(limit)
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      _logger.e('Error getting related lessons: $e');
      return [];
    }
  }

  /// Get all topics with their lesson counts
  Future<List<Map<String, dynamic>>> getAllTopics() async {
    try {
      final snapshot = await _firestore
          .collection(_topicsCollection)
          .orderBy('lesson_count', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.e('Error getting topics: $e');
      return [];
    }
  }

  /// Clean up unused lessons (cost optimization)
  Future<void> cleanupUnusedLessons({int daysOld = 90, int minAccessCount = 2}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .where('created_at', isLessThan: Timestamp.fromDate(cutoffDate))
          .where('access_count', isLessThan: minAccessCount)
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final audioUrl = data['audio_url'] as String;
        
        // Delete from Storage
        try {
          final ref = _storage.refFromURL(audioUrl);
          await ref.delete();
        } catch (e) {
          _logger.e('Error deleting storage file: $e');
        }
        
        // Delete lesson document
        await doc.reference.delete();
        
        // Update topic metadata
        final topic = data['topic'] as String;
        final lessonId = data['lesson_id'] as String;
        await _removeFromTopicMetadata(topic, lessonId);
      }
      
      _logger.i('Cleaned up ${snapshot.docs.length} unused lessons');
    } catch (e) {
      _logger.e('Error during cleanup: $e');
    }
  }

  /// Remove lesson from topic metadata
  Future<void> _removeFromTopicMetadata(String topic, String lessonId) async {
    try {
      final normalizedTopic = _normalizeTopicName(topic);
      await _firestore.collection(_topicsCollection).doc(normalizedTopic).update({
        'lesson_ids': FieldValue.arrayRemove([lessonId]),
        'lesson_count': FieldValue.increment(-1),
      });
    } catch (e) {
      _logger.e('Error removing from topic metadata: $e');
    }
  }
}
