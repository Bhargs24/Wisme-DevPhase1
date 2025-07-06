import '../core/exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
class FirestoreService {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;
  final Logger _logger = Logger();

  FirestoreService() {
    _initializeFirestore();
  }

  void _initializeFirestore() {
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseAvailable = true;
        _logger.i('✅ FirestoreService: Firebase is available');
      } else {
        _logger.w('⚠️ FirestoreService: Firebase not initialized - Firestore features disabled');
        _isFirebaseAvailable = false;
      }
    } catch (e) {
      _logger.w('⚠️ FirestoreService: Firebase initialization check failed: $e');
      _isFirebaseAvailable = false;
    }
  }

  void _checkFirebaseAvailability() {
    if (!_isFirebaseAvailable || _firestore == null) {
      throw Exception('Firestore is not available. Please configure Firebase to use this feature.');
    }
  }

  // User operations
  Future<void> createUser(UserModel user) async {
    _checkFirebaseAvailability();
    await _firestore!.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String userId) async {
    _checkFirebaseAvailability();
    final doc = await _firestore!.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    _checkFirebaseAvailability();
    await _firestore!.collection('users').doc(userId).update(data);
  }

  Future<void> deleteUser(String userId) async {
    _checkFirebaseAvailability();
    await _firestore!.collection('users').doc(userId).delete();
  }

  // Content Block operations
  Future<String> createContentBlock(ContentBlock block) async {
    _checkFirebaseAvailability();
    final docRef = await _firestore!.collection('content_blocks').add(block.toFirestore());
    return docRef.id;
  }

  Future<ContentBlock?> getContentBlock(String blockId) async {
    _checkFirebaseAvailability();
    final doc = await _firestore!.collection('content_blocks').doc(blockId).get();
    if (doc.exists) {
      return ContentBlock.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateContentBlock(String blockId, Map<String, dynamic> data) async {
    _checkFirebaseAvailability();
    await _firestore!.collection('content_blocks').doc(blockId).update(data);
  }

  Future<void> deleteContentBlock(String blockId) async {
    _checkFirebaseAvailability();
    await _firestore!.collection('content_blocks').doc(blockId).delete();
  }

  Future<List<ContentBlock>> getContentBlocks({
    String? category,
    String? level,
    int? limit,
  }) async {
    _checkFirebaseAvailability();
    Query query = _firestore!.collection('content_blocks');
    
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (level != null) {
      query = query.where('level', isEqualTo: level);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ContentBlock.fromFirestore(doc))
        .toList();
  }

  // Learning Journey operations
  Future<String> createLearningJourney(LearningJourney journey) async {
    _checkFirebaseAvailability();
    final docRef = await _firestore!.collection('learning_journeys').add(journey.toFirestore());
    return docRef.id;
  }

  Future<LearningJourney?> getLearningJourney(String journeyId) async {
    _checkFirebaseAvailability();
    final doc = await _firestore!.collection('learning_journeys').doc(journeyId).get();
    if (doc.exists) {
      return LearningJourney.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateLearningJourney(String journeyId, Map<String, dynamic> data) async {
    _checkFirebaseAvailability();
    await _firestore!.collection('learning_journeys').doc(journeyId).update(data);
  }

  Future<void> deleteLearningJourney(String journeyId) async {
    _checkFirebaseAvailability();
    await _firestore!.collection('learning_journeys').doc(journeyId).delete();
  }

  Future<List<LearningJourney>> getUserJourneys(String userId) async {
    _checkFirebaseAvailability();
    final snapshot = await _firestore!
        .collection('learning_journeys')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => LearningJourney.fromFirestore(doc))
        .toList();
  }

  // User Progress operations
  Future<void> updateUserProgress(UserProgress progress) async {
    _checkFirebaseAvailability();
    await _firestore!
        .collection('users')
        .doc(progress.userId)
        .collection('progress')
        .doc(progress.id)
        .set(progress.toMap());
  }

  Future<UserProgress?> getUserProgress(String userId, String progressId) async {
    _checkFirebaseAvailability();
    final doc = await _firestore!
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(progressId)
        .get();
    
    if (doc.exists) {
      return UserProgress.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Block Progress operations
  Future<void> saveBlockProgress(String userId, String blockId, BlockProgress progress) async {
    _checkFirebaseAvailability();
    await _firestore!
        .collection('users')
        .doc(userId)
        .collection('block_progress')
        .doc(blockId)
        .set(progress.toMap());
  }

  Future<BlockProgress?> getBlockProgress(String userId, String blockId) async {
    _checkFirebaseAvailability();
    final doc = await _firestore!
        .collection('users')
        .doc(userId)
        .collection('block_progress')
        .doc(blockId)
        .get();
    
    if (doc.exists) {
      return BlockProgress.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<BlockProgress>> getUserBlockProgress(String userId) async {
    _checkFirebaseAvailability();
    final snapshot = await _firestore!
        .collection('users')
        .doc(userId)
        .collection('block_progress')
        .get();
    
    return snapshot.docs
        .map((doc) => BlockProgress.fromMap(doc.data()))
        .toList();
  }

  // Analytics and Metrics
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    final userProgress = await getUserBlockProgress(userId);
    final completedBlocks = userProgress.where((p) => p.isCompleted).length;
    final totalListeningTime = userProgress
        .map((p) => p.listeningTime)
        .fold(Duration.zero, (prev, curr) => prev + curr);

    return {
      'totalBlocks': userProgress.length,
      'completedBlocks': completedBlocks,
      'completionRate': userProgress.isNotEmpty ? completedBlocks / userProgress.length : 0.0,
      'totalListeningTime': totalListeningTime.inMinutes,
      'averageSessionLength': userProgress.isNotEmpty 
          ? totalListeningTime.inMinutes / userProgress.length 
          : 0.0,
    };
  }

  // Batch operations
  Future<void> batchUpdateBlocks(List<ContentBlock> blocks) async {
    _checkFirebaseAvailability();
    final batch = _firestore!.batch();
    
    for (final block in blocks) {
      final docRef = _firestore!.collection('content_blocks').doc(block.id);
      batch.set(docRef, block.toFirestore());
    }
    
    await batch.commit();
  }

  // Search operations
  Future<List<ContentBlock>> searchContentBlocks(String query) async {
    _checkFirebaseAvailability();
    final snapshot = await _firestore!
        .collection('content_blocks')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    
    return snapshot.docs
        .map((doc) => ContentBlock.fromFirestore(doc))
        .toList();
  }

  // Content matching operations
  Future<void> saveUserListeningHistory(String userId, dynamic history) async {
    _checkFirebaseAvailability();
    await _firestore!
        .collection('users')
        .doc(userId)
        .collection('listening_history')
        .doc('current')
        .set(history.toMap());
  }

  Future<dynamic> getUserListeningHistory(String userId) async {
    _checkFirebaseAvailability();
    final doc = await _firestore!
        .collection('users')
        .doc(userId)
        .collection('listening_history')
        .doc('current')
        .get();
    
    if (doc.exists) {
      // Return the UserListeningHistory - we'll need to import the model
      return doc.data();
    }
    
    // Return empty history if not found
    return {
      'userId': userId,
      'playedContentIds': [],
      'lastPlayedDates': {},
      'playCount': {},
      'userRatings': {},
      'bookmarkedContent': [],
      'dislikedContent': [],
    };
  }

  Future<void> saveContentTags(String contentId, dynamic tags) async {
    _checkFirebaseAvailability();
    await _firestore!
        .collection('content_tags')
        .doc(contentId)
        .set(tags.toMap());
  }

  Future<dynamic> getContentTags(String contentId) async {
    _checkFirebaseAvailability();
    final doc = await _firestore!
        .collection('content_tags')
        .doc(contentId)
        .get();
    
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}
