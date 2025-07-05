import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../shared/models/result.dart';
import '../../core/utils/logger.dart';

/// Production-grade Cloud Storage service for the new architecture
class CloudStorageService {
  FirebaseStorage? _storage;
  bool _isFirebaseAvailable = false;

  CloudStorageService() {
    _initializeStorage();
  }

  void _initializeStorage() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _storage = FirebaseStorage.instance;
        _isFirebaseAvailable = true;
        AppLogger.info('✅ CloudStorageService: Firebase Storage initialized');
      } else {
        AppLogger.warning('⚠️ CloudStorageService: Firebase not initialized - Storage features disabled');
        _isFirebaseAvailable = false;
      }
    } catch (e) {
      AppLogger.warning('⚠️ CloudStorageService: Firebase initialization check failed: $e');
      _isFirebaseAvailable = false;
    }
  }

  void _checkFirebaseAvailability() {
    if (!_isFirebaseAvailable || _storage == null) {
      throw Exception('Firebase Storage is not available. Please configure Firebase to use this feature.');
    }
  }

  /// Upload file to cloud storage
  Future<Result<String>> uploadFile({
    required String path,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double)? onProgress,
  }) async {
    try {
      _checkFirebaseAvailability();

      final ref = _storage!.ref().child(path);
      
      final uploadTask = ref.putData(
        data,
        SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        ),
      );

      // Listen to progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.info('✅ File uploaded successfully: $path');
      return Result.success(downloadUrl);
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Firebase upload failed: ${e.code} - ${e.message}');
      return Result.failure('Upload failed: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ Upload error: $e');
      return Result.failure('Upload error: $e');
    }
  }

  /// Download file from cloud storage
  Future<Result<Uint8List>> downloadFile({
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      _checkFirebaseAvailability();

      final ref = _storage!.ref().child(path);
      final data = await ref.getData();

      if (data != null) {
        AppLogger.info('✅ File downloaded successfully: $path');
        return Result.success(data);
      } else {
        AppLogger.error('❌ File not found: $path');
        return Result.failure('File not found');
      }
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Firebase download failed: ${e.code} - ${e.message}');
      return Result.failure('Download failed: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ Download error: $e');
      return Result.failure('Download error: $e');
    }
  }

  /// Get download URL for a file
  Future<Result<String>> getDownloadUrl({
    required String path,
  }) async {
    try {
      _checkFirebaseAvailability();

      final ref = _storage!.ref().child(path);
      final url = await ref.getDownloadURL();

      AppLogger.info('✅ Download URL retrieved: $path');
      return Result.success(url);
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Failed to get download URL: ${e.code} - ${e.message}');
      return Result.failure('Failed to get URL: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ Get URL error: $e');
      return Result.failure('Get URL error: $e');
    }
  }

  /// Delete file from cloud storage
  Future<Result<void>> deleteFile({
    required String path,
  }) async {
    try {
      _checkFirebaseAvailability();

      final ref = _storage!.ref().child(path);
      await ref.delete();

      AppLogger.info('✅ File deleted successfully: $path');
      return Result.success(null);
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Firebase delete failed: ${e.code} - ${e.message}');
      return Result.failure('Delete failed: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ Delete error: $e');
      return Result.failure('Delete error: $e');
    }
  }

  /// List files in a directory
  Future<Result<List<StorageFile>>> listFiles({
    required String path,
    int? maxResults,
  }) async {
    try {
      _checkFirebaseAvailability();

      final ref = _storage!.ref().child(path);
      final result = await ref.listAll();

      final files = <StorageFile>[];
      
      for (final item in result.items) {
        final metadata = await item.getMetadata();
        final downloadUrl = await item.getDownloadURL();
        
        files.add(StorageFile(
          name: item.name,
          path: item.fullPath,
          downloadUrl: downloadUrl,
          size: metadata.size ?? 0,
          contentType: metadata.contentType,
          timeCreated: metadata.timeCreated,
          updated: metadata.updated,
          customMetadata: metadata.customMetadata ?? {},
        ));
      }

      AppLogger.info('✅ Listed ${files.length} files in: $path');
      return Result.success(files);
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Firebase list failed: ${e.code} - ${e.message}');
      return Result.failure('List failed: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ List error: $e');
      return Result.failure('List error: $e');
    }
  }

  /// Get file metadata
  Future<Result<StorageFileMetadata>> getFileMetadata({
    required String path,
  }) async {
    try {
      _checkFirebaseAvailability();

      final ref = _storage!.ref().child(path);
      final metadata = await ref.getMetadata();

      final fileMetadata = StorageFileMetadata(
        name: ref.name,
        path: ref.fullPath,
        size: metadata.size ?? 0,
        contentType: metadata.contentType,
        timeCreated: metadata.timeCreated,
        updated: metadata.updated,
        md5Hash: metadata.md5Hash,
        customMetadata: metadata.customMetadata ?? {},
      );

      AppLogger.info('✅ File metadata retrieved: $path');
      return Result.success(fileMetadata);
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Failed to get metadata: ${e.code} - ${e.message}');
      return Result.failure('Failed to get metadata: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ Metadata error: $e');
      return Result.failure('Metadata error: $e');
    }
  }

  /// Update file metadata
  Future<Result<void>> updateFileMetadata({
    required String path,
    String? contentType,
    Map<String, String>? customMetadata,
  }) async {
    try {
      _checkFirebaseAvailability();

      final ref = _storage!.ref().child(path);
      
      await ref.updateMetadata(SettableMetadata(
        contentType: contentType,
        customMetadata: customMetadata,
      ));

      AppLogger.info('✅ File metadata updated: $path');
      return Result.success(null);
    } on FirebaseException catch (e) {
      AppLogger.error('❌ Failed to update metadata: ${e.code} - ${e.message}');
      return Result.failure('Failed to update metadata: ${e.message}');
    } catch (e) {
      AppLogger.error('❌ Update metadata error: $e');
      return Result.failure('Update metadata error: $e');
    }
  }

  /// Upload audio file with optimized settings
  Future<Result<String>> uploadAudioFile({
    required String fileName,
    required Uint8List audioData,
    required String coachVoice,
    required String topic,
    required String subtopic,
    Map<String, String>? additionalMetadata,
    void Function(double)? onProgress,
  }) async {
    final normalizedTopic = _normalizeTopicName(topic);
    final normalizedSubtopic = _normalizeTopicName(subtopic);
    
    final path = 'audio/$coachVoice/$normalizedTopic/$normalizedSubtopic/$fileName';
    
    final metadata = <String, String>{
      'topic': topic,
      'subtopic': subtopic,
      'coach_voice': coachVoice,
      'uploaded_at': DateTime.now().toIso8601String(),
      'file_type': 'audio',
      ...?additionalMetadata,
    };

    return uploadFile(
      path: path,
      data: audioData,
      contentType: 'audio/mpeg',
      metadata: metadata,
      onProgress: onProgress,
    );
  }

  /// Upload user profile image
  Future<Result<String>> uploadProfileImage({
    required String userId,
    required Uint8List imageData,
    void Function(double)? onProgress,
  }) async {
    final path = 'users/$userId/profile.jpg';
    
    return uploadFile(
      path: path,
      data: imageData,
      contentType: 'image/jpeg',
      metadata: {
        'user_id': userId,
        'uploaded_at': DateTime.now().toIso8601String(),
        'file_type': 'profile_image',
      },
      onProgress: onProgress,
    );
  }

  /// Clean up old files based on criteria
  Future<Result<int>> cleanupOldFiles({
    required String directoryPath,
    required Duration maxAge,
  }) async {
    try {
      final listResult = await listFiles(path: directoryPath);
      
      if (!listResult.isSuccess) {
        return Result.failure('Failed to list files: ${listResult.error}');
      }

      final cutoffDate = DateTime.now().subtract(maxAge);
      final filesToDelete = listResult.data!
          .where((file) => 
              file.timeCreated != null && 
              file.timeCreated!.isBefore(cutoffDate))
          .toList();

      int deletedCount = 0;
      for (final file in filesToDelete) {
        final deleteResult = await deleteFile(path: file.path);
        if (deleteResult.isSuccess) {
          deletedCount++;
        }
      }

      AppLogger.info('✅ Cleaned up $deletedCount old files from $directoryPath');
      return Result.success(deletedCount);
    } catch (e) {
      AppLogger.error('❌ Cleanup error: $e');
      return Result.failure('Cleanup error: $e');
    }
  }

  /// Check if service is available
  bool get isAvailable => _isFirebaseAvailable;

  /// Get storage reference for advanced operations
  Reference? getStorageReference(String path) {
    if (!_isFirebaseAvailable || _storage == null) return null;
    return _storage!.ref().child(path);
  }

  /// Normalize topic name for consistent storage paths
  String _normalizeTopicName(String topic) {
    return topic
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }
}

/// Storage file information
class StorageFile {
  final String name;
  final String path;
  final String downloadUrl;
  final int size;
  final String? contentType;
  final DateTime? timeCreated;
  final DateTime? updated;
  final Map<String, String> customMetadata;

  const StorageFile({
    required this.name,
    required this.path,
    required this.downloadUrl,
    required this.size,
    this.contentType,
    this.timeCreated,
    this.updated,
    required this.customMetadata,
  });
}

/// Storage file metadata
class StorageFileMetadata {
  final String name;
  final String path;
  final int size;
  final String? contentType;
  final DateTime? timeCreated;
  final DateTime? updated;
  final String? md5Hash;
  final Map<String, String> customMetadata;

  const StorageFileMetadata({
    required this.name,
    required this.path,
    required this.size,
    this.contentType,
    this.timeCreated,
    this.updated,
    this.md5Hash,
    required this.customMetadata,
  });
}
