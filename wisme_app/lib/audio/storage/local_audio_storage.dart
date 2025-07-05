import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/stored_audio_file.dart';
import '../models/local_audio_cache.dart';
import '../models/audio_hashtag_system.dart';
import '../models/audio_metadata.dart';

/// Production-grade local audio storage service
/// Manages local audio file storage, caching, and metadata persistence
class LocalAudioStorage {
  static const String _audioDirectoryName = 'audio_files';
  static const String _metadataDirectoryName = 'audio_metadata';
  static const String _cacheDirectoryName = 'audio_cache';
  static const String _hashtagsFileName = 'hashtags.json';

  Directory? _audioDirectory;
  Directory? _metadataDirectory;
  Directory? _cacheDirectory;
  AudioHashtagSystem? _hashtagSystem;

  /// Initialize local storage directories
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    
    _audioDirectory = Directory('${appDir.path}/$_audioDirectoryName');
    _metadataDirectory = Directory('${appDir.path}/$_metadataDirectoryName');
    _cacheDirectory = Directory('${appDir.path}/$_cacheDirectoryName');

    // Create directories if they don't exist
    await _audioDirectory!.create(recursive: true);
    await _metadataDirectory!.create(recursive: true);
    await _cacheDirectory!.create(recursive: true);

    // Load hashtag system
    await _loadHashtagSystem();
  }

  /// Store audio file locally with metadata
  Future<StoredAudioFile> storeAudioFile({
    required Uint8List audioData,
    required String fileName,
    required AudioMetadata metadata,
    List<String> hashtags = const [],
  }) async {
    await _ensureInitialized();

    // Generate unique file ID and hash
    final fileId = _generateFileId();
    final dataHash = _generateDataHash(audioData);
    
    // Create file paths
    final audioFilePath = '${_audioDirectory!.path}/$fileId.mp3';
    final metadataFilePath = '${_metadataDirectory!.path}/$fileId.json';

    try {
      // Write audio data
      final audioFile = File(audioFilePath);
      await audioFile.writeAsBytes(audioData);

      // Create stored audio file object
      final storedFile = StoredAudioFile(
        id: fileId,
        fileName: fileName,
        localPath: audioFilePath,
        fileSize: audioData.length,
        dataHash: dataHash,
        metadata: metadata,
        hashtags: hashtags,
        createdAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
      );

      // Save metadata
      await _saveMetadata(storedFile, metadataFilePath);

      // Update hashtag system
      if (hashtags.isNotEmpty) {
        _hashtagSystem!.addHashtagsToFile(fileId, hashtags);
        await _saveHashtagSystem();
      }

      return storedFile;
    } catch (e) {
      // Clean up on error
      await _cleanupFailedStorage(audioFilePath, metadataFilePath);
      rethrow;
    }
  }

  /// Retrieve audio file by ID
  Future<StoredAudioFile?> getAudioFile(String fileId) async {
    await _ensureInitialized();

    final metadataFilePath = '${_metadataDirectory!.path}/$fileId.json';
    final metadataFile = File(metadataFilePath);

    if (!await metadataFile.exists()) {
      return null;
    }

    try {
      final metadataJson = await metadataFile.readAsString();
      final storedFile = StoredAudioFile.fromJson(jsonDecode(metadataJson));

      // Update last accessed time
      final updatedFile = storedFile.copyWith(lastAccessedAt: DateTime.now());
      await _saveMetadata(updatedFile, metadataFilePath);

      return updatedFile;
    } catch (e) {
      // Handle corrupted metadata
      print('Error reading metadata for file $fileId: $e');
      return null;
    }
  }

  /// Get audio file data
  Future<Uint8List?> getAudioData(String fileId) async {
    await _ensureInitialized();

    final storedFile = await getAudioFile(fileId);
    if (storedFile == null) return null;

    final audioFile = File(storedFile.localPath);
    if (!await audioFile.exists()) {
      // File missing, clean up metadata
      await deleteAudioFile(fileId);
      return null;
    }

    return await audioFile.readAsBytes();
  }

  /// Delete audio file and its metadata
  Future<bool> deleteAudioFile(String fileId) async {
    await _ensureInitialized();

    bool success = true;

    // Delete audio file
    final audioFilePath = '${_audioDirectory!.path}/$fileId.mp3';
    final audioFile = File(audioFilePath);
    if (await audioFile.exists()) {
      try {
        await audioFile.delete();
      } catch (e) {
        success = false;
        print('Error deleting audio file: $e');
      }
    }

    // Delete metadata file
    final metadataFilePath = '${_metadataDirectory!.path}/$fileId.json';
    final metadataFile = File(metadataFilePath);
    if (await metadataFile.exists()) {
      try {
        await metadataFile.delete();
      } catch (e) {
        success = false;
        print('Error deleting metadata file: $e');
      }
    }

    // Remove from hashtag system
    _hashtagSystem!.removeFile(fileId);
    await _saveHashtagSystem();

    return success;
  }

  /// List all stored audio files
  Future<List<StoredAudioFile>> listAudioFiles() async {
    await _ensureInitialized();

    final metadataFiles = await _metadataDirectory!.list().toList();
    final audioFiles = <StoredAudioFile>[];

    for (final file in metadataFiles) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final metadataJson = await file.readAsString();
          final storedFile = StoredAudioFile.fromJson(jsonDecode(metadataJson));
          audioFiles.add(storedFile);
        } catch (e) {
          print('Error reading metadata file ${file.path}: $e');
        }
      }
    }

    // Sort by creation date (newest first)
    audioFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return audioFiles;
  }

  /// Search audio files by hashtags
  Future<List<StoredAudioFile>> searchByHashtags(List<String> hashtags) async {
    await _ensureInitialized();

    final matchingFileIds = _hashtagSystem!.findFilesByHashtags(hashtags);
    final matchingFiles = <StoredAudioFile>[];

    for (final fileId in matchingFileIds) {
      final file = await getAudioFile(fileId);
      if (file != null) {
        matchingFiles.add(file);
      }
    }

    return matchingFiles;
  }

  /// Get cache information
  Future<LocalAudioCache> getCacheInfo() async {
    await _ensureInitialized();

    final audioFiles = await listAudioFiles();
    final totalSize = audioFiles.fold<int>(0, (sum, file) => sum + file.fileSize);
    final oldestAccess = audioFiles.isEmpty 
        ? DateTime.now() 
        : audioFiles.map((f) => f.lastAccessedAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final newestAccess = audioFiles.isEmpty 
        ? DateTime.now() 
        : audioFiles.map((f) => f.lastAccessedAt).reduce((a, b) => a.isAfter(b) ? a : b);

    return LocalAudioCache(
      totalFiles: audioFiles.length,
      totalSizeBytes: totalSize,
      oldestFileAccess: oldestAccess,
      newestFileAccess: newestAccess,
      lastCleanupAt: DateTime.now(), // TODO: Track actual cleanup time
    );
  }

  /// Clean up old cached files
  Future<int> cleanupOldFiles({
    Duration maxAge = const Duration(days: 30),
    int? maxFiles,
    int? maxSizeBytes,
  }) async {
    await _ensureInitialized();

    final audioFiles = await listAudioFiles();
    final cutoffDate = DateTime.now().subtract(maxAge);
    int deletedCount = 0;

    // Sort by last accessed time (oldest first)
    audioFiles.sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));

    for (final file in audioFiles) {
      bool shouldDelete = false;

      // Check age
      if (file.lastAccessedAt.isBefore(cutoffDate)) {
        shouldDelete = true;
      }

      // Check file count limit
      if (maxFiles != null && audioFiles.length > maxFiles) {
        shouldDelete = true;
      }

      // Check size limit
      if (maxSizeBytes != null) {
        final currentSize = audioFiles.fold<int>(0, (sum, f) => sum + f.fileSize);
        if (currentSize > maxSizeBytes) {
          shouldDelete = true;
        }
      }

      if (shouldDelete) {
        if (await deleteAudioFile(file.id)) {
          deletedCount++;
        }
      }
    }

    return deletedCount;
  }

  /// Get hashtag system
  AudioHashtagSystem get hashtagSystem => _hashtagSystem!;

  // Private helper methods

  Future<void> _ensureInitialized() async {
    if (_audioDirectory == null) {
      await initialize();
    }
  }

  String _generateFileId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return '${timestamp}_$random';
  }

  String _generateDataHash(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  Future<void> _saveMetadata(StoredAudioFile storedFile, String filePath) async {
    final metadataFile = File(filePath);
    final metadataJson = jsonEncode(storedFile.toJson());
    await metadataFile.writeAsString(metadataJson);
  }

  Future<void> _loadHashtagSystem() async {
    final hashtagsFile = File('${_metadataDirectory!.path}/$_hashtagsFileName');
    
    if (await hashtagsFile.exists()) {
      try {
        final hashtagsJson = await hashtagsFile.readAsString();
        _hashtagSystem = AudioHashtagSystem.fromJson(jsonDecode(hashtagsJson));
      } catch (e) {
        print('Error loading hashtag system: $e');
        _hashtagSystem = AudioHashtagSystem();
      }
    } else {
      _hashtagSystem = AudioHashtagSystem();
    }
  }

  Future<void> _saveHashtagSystem() async {
    final hashtagsFile = File('${_metadataDirectory!.path}/$_hashtagsFileName');
    final hashtagsJson = jsonEncode(_hashtagSystem!.toJson());
    await hashtagsFile.writeAsString(hashtagsJson);
  }

  Future<void> _cleanupFailedStorage(String audioFilePath, String metadataFilePath) async {
    try {
      final audioFile = File(audioFilePath);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }

      final metadataFile = File(metadataFilePath);
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }
}
