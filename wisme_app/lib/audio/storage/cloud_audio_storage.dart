import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/stored_audio_file.dart';
import '../models/audio_metadata.dart';
import '../models/audio_hashtag_system.dart';
import '../../core/error/audio_exceptions.dart';
import '../../core/utils/helpers/app_logger.dart';

/// Crystal clear cloud storage service for audio files
/// Replaces the confusing generic "StorageService"
class CloudAudioStorage {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  static const String _audioCollection = 'audio_files';
  static const String _metadataCollection = 'audio_metadata';
  static const String _hashtagsCollection = 'audio_hashtags';
  static const String _storageBasePath = 'generated_audio';

  CloudAudioStorage({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  /// Upload audio file to cloud storage with organized structure
  Future<StoredAudioFile> uploadAudioFile({
    required String audioId,
    required Uint8List audioData,
    required String originalTopic,
    required String coachVoice,
    required AudioMetadata metadata,
    required AudioHashtagCollection hashtags,
    Map<String, dynamic>? customMetadata,
  }) async {
    try {
      AppLogger.info('🔄 Uploading audio file: $audioId');
      
      // Create organized storage path: generated_audio/coach_voice/topic_hash/audio_id.mp3
      final topicHash = _generateTopicHash(originalTopic);
      final storagePath = '$_storageBasePath/$coachVoice/$topicHash/$audioId.mp3';
      final storageRef = _storage.ref().child(storagePath);
      
      // Upload with metadata
      final uploadTask = await storageRef.putData(
        audioData,
        SettableMetadata(
          contentType: 'audio/mpeg',
          customMetadata: {
            'audio_id': audioId,
            'original_topic': originalTopic,
            'coach_voice': coachVoice,
            'generated_at': DateTime.now().toIso8601String(),
            'duration_seconds': metadata.duration.inSeconds.toString(),
            'file_size': audioData.length.toString(),
            'hashtag_count': hashtags.allHashtags.length.toString(),
            ...?customMetadata,
          },
        ),
      );
      
      final cloudUrl = await uploadTask.ref.getDownloadURL();
      
      // Create stored audio file record
      final storedAudio = StoredAudioFile(
        id: audioId,
        topicHash: topicHash,
        originalTopic: originalTopic,
        coachVoice: coachVoice,
        cloudUrl: cloudUrl,
        createdAt: DateTime.now(),
        durationSeconds: metadata.duration.inSeconds,
        fileSizeBytes: audioData.length,
        hashtags: hashtags.allHashtagStrings,
        metadata: customMetadata ?? {},
      );
      
      // Store in Firestore with batch write for consistency
      final batch = _firestore.batch();
      
      // Main audio record
      batch.set(
        _firestore.collection(_audioCollection).doc(audioId),
        storedAudio.toJson(),
      );
      
      // Detailed metadata
      batch.set(
        _firestore.collection(_metadataCollection).doc(audioId),
        metadata.toJson(),
      );
      
      // Hashtags for searchability
      batch.set(
        _firestore.collection(_hashtagsCollection).doc(audioId),
        hashtags.toJson(),
      );
      
      await batch.commit();
      
      AppLogger.info('✅ Audio file uploaded successfully: $audioId');
      return storedAudio;
      
    } catch (e) {
      AppLogger.error('❌ Failed to upload audio file $audioId: $e');
      throw AudioUploadException('Failed to upload audio: $e');
    }
  }

  /// Download audio file from cloud storage
  Future<Uint8List> downloadAudioFile(String audioId) async {
    try {
      AppLogger.info('🔄 Downloading audio file: $audioId');
      
      final audioRecord = await getStoredAudioFile(audioId);
      if (audioRecord == null) {
        throw AudioNotFoundException('Audio file not found: $audioId');
      }
      
      final storageRef = _storage.refFromURL(audioRecord.cloudUrl);
      final audioData = await storageRef.getData();
      
      if (audioData == null) {
        throw AudioDownloadException('Failed to download audio data');
      }
      
      AppLogger.info('✅ Audio file downloaded: $audioId (${audioData.length} bytes)');
      return audioData;
      
    } catch (e) {
      AppLogger.error('❌ Failed to download audio file $audioId: $e');
      rethrow;
    }
  }

  /// Get stored audio file record
  Future<StoredAudioFile?> getStoredAudioFile(String audioId) async {
    try {
      final doc = await _firestore.collection(_audioCollection).doc(audioId).get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return StoredAudioFile.fromJson(doc.data()!);
      
    } catch (e) {
      AppLogger.error('❌ Failed to get audio file $audioId: $e');
      rethrow;
    }
  }

  /// Get audio metadata
  Future<AudioMetadata?> getAudioMetadata(String audioId) async {
    try {
      final doc = await _firestore.collection(_metadataCollection).doc(audioId).get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return AudioMetadata.fromJson(doc.data()!);
      
    } catch (e) {
      AppLogger.error('❌ Failed to get audio metadata $audioId: $e');
      rethrow;
    }
  }

  /// Get audio hashtags
  Future<AudioHashtagCollection?> getAudioHashtags(String audioId) async {
    try {
      final doc = await _firestore.collection(_hashtagsCollection).doc(audioId).get();
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      
      return AudioHashtagCollection.fromJson(doc.data()!);
      
    } catch (e) {
      AppLogger.error('❌ Failed to get audio hashtags $audioId: $e');
      rethrow;
    }
  }

  /// Search audio files by hashtags
  Future<List<StoredAudioFile>> searchByHashtags(List<String> hashtags, {int limit = 20}) async {
    try {
      AppLogger.info('🔍 Searching audio by hashtags: ${hashtags.join(', ')}');
      
      final query = await _firestore
          .collection(_audioCollection)
          .where('hashtags', arrayContainsAny: hashtags)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      final results = query.docs
          .map((doc) => StoredAudioFile.fromJson(doc.data()))
          .toList();
      
      AppLogger.info('✅ Found ${results.length} audio files matching hashtags');
      return results;
      
    } catch (e) {
      AppLogger.error('❌ Failed to search by hashtags: $e');
      rethrow;
    }
  }

  /// Search audio files by coach voice
  Future<List<StoredAudioFile>> searchByCoachVoice(String coachVoice, {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection(_audioCollection)
          .where('coachVoice', isEqualTo: coachVoice)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return query.docs
          .map((doc) => StoredAudioFile.fromJson(doc.data()))
          .toList();
      
    } catch (e) {
      AppLogger.error('❌ Failed to search by coach voice $coachVoice: $e');
      rethrow;
    }
  }

  /// Get recently created audio files
  Future<List<StoredAudioFile>> getRecentAudioFiles({int limit = 20}) async {
    try {
      final query = await _firestore
          .collection(_audioCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return query.docs
          .map((doc) => StoredAudioFile.fromJson(doc.data()))
          .toList();
      
    } catch (e) {
      AppLogger.error('❌ Failed to get recent audio files: $e');
      rethrow;
    }
  }

  /// Delete audio file from cloud storage
  Future<void> deleteAudioFile(String audioId) async {
    try {
      AppLogger.info('🗑️ Deleting audio file: $audioId');
      
      final audioRecord = await getStoredAudioFile(audioId);
      if (audioRecord == null) {
        AppLogger.warning('⚠️ Audio file not found for deletion: $audioId');
        return;
      }
      
      // Delete from storage
      final storageRef = _storage.refFromURL(audioRecord.cloudUrl);
      await storageRef.delete();
      
      // Delete from Firestore with batch
      final batch = _firestore.batch();
      batch.delete(_firestore.collection(_audioCollection).doc(audioId));
      batch.delete(_firestore.collection(_metadataCollection).doc(audioId));
      batch.delete(_firestore.collection(_hashtagsCollection).doc(audioId));
      await batch.commit();
      
      AppLogger.info('✅ Audio file deleted successfully: $audioId');
      
    } catch (e) {
      AppLogger.error('❌ Failed to delete audio file $audioId: $e');
      throw AudioDeletionException('Failed to delete audio: $e');
    }
  }

  /// Update audio file access statistics
  Future<void> updateAccessStats(String audioId) async {
    try {
      await _firestore.collection(_audioCollection).doc(audioId).update({
        'lastAccessedAt': FieldValue.serverTimestamp(),
        'accessCount': FieldValue.increment(1),
      });
      
    } catch (e) {
      AppLogger.error('❌ Failed to update access stats for $audioId: $e');
      // Don't throw - this is non-critical
    }
  }

  /// Get storage usage statistics
  Future<CloudStorageStats> getStorageStats() async {
    try {
      final totalQuery = await _firestore.collection(_audioCollection).get();
      final totalFiles = totalQuery.docs.length;
      
      final totalSizeBytes = totalQuery.docs
          .map((doc) => (doc.data()['fileSizeBytes'] as int?) ?? 0)
          .fold<int>(0, (sum, size) => sum + size);
      
      final last30Days = DateTime.now().subtract(const Duration(days: 30));
      final recentQuery = await _firestore
          .collection(_audioCollection)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(last30Days))
          .get();
      
      return CloudStorageStats(
        totalFiles: totalFiles,
        totalSizeBytes: totalSizeBytes,
        recentFiles: recentQuery.docs.length,
        lastUpdated: DateTime.now(),
      );
      
    } catch (e) {
      AppLogger.error('❌ Failed to get storage stats: $e');
      rethrow;
    }
  }

  /// Generate consistent topic hash for organization
  String _generateTopicHash(String topic) {
    final normalized = topic.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    return normalized.length > 20 ? normalized.substring(0, 20) : normalized;
  }
}

/// Cloud storage statistics
class CloudStorageStats {
  final int totalFiles;
  final int totalSizeBytes;
  final int recentFiles;
  final DateTime lastUpdated;

  const CloudStorageStats({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.recentFiles,
    required this.lastUpdated,
  });

  String get formattedTotalSize {
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    if (totalSizeBytes < 1024 * 1024 * 1024) return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
  }

  @override
  String toString() {
    return 'CloudStorageStats(files: $totalFiles, size: $formattedTotalSize, recent: $recentFiles)';
  }
}
