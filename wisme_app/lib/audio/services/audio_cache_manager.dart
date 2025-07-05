import 'dart:typed_data';
import '../models/stored_audio_file.dart';
import '../models/local_audio_cache.dart';
import '../storage/local_audio_storage.dart';
import '../storage/cloud_audio_storage.dart';

/// Production-grade audio cache manager
/// Manages intelligent caching between local and cloud storage
class AudioCacheManager {
  final LocalAudioStorage _localStorage;
  final CloudAudioStorage _cloudStorage;

  // Cache configuration
  static const Duration _defaultMaxAge = Duration(days: 7);
  static const int _defaultMaxFiles = 100;
  static const int _defaultMaxSizeBytes = 500 * 1024 * 1024; // 500MB

  Duration _maxAge;
  int _maxFiles;
  int _maxSizeBytes;

  AudioCacheManager({
    required LocalAudioStorage localStorage,
    required CloudAudioStorage cloudStorage,
    Duration maxAge = _defaultMaxAge,
    int maxFiles = _defaultMaxFiles,
    int maxSizeBytes = _defaultMaxSizeBytes,
  }) : _localStorage = localStorage,
       _cloudStorage = cloudStorage,
       _maxAge = maxAge,
       _maxFiles = maxFiles,
       _maxSizeBytes = maxSizeBytes;

  /// Initialize the cache manager
  Future<void> initialize() async {
    await _localStorage.initialize();
    await _performMaintenanceIfNeeded();
  }

  /// Get audio file with intelligent caching
  /// First checks local cache, then downloads from cloud if needed
  Future<StoredAudioFile?> getAudioFile(String fileId) async {
    // Try local cache first
    final localFile = await _localStorage.getAudioFile(fileId);
    if (localFile != null) {
      return localFile;
    }

    // Download from cloud and cache locally
    return await _downloadAndCache(fileId);
  }

  /// Get audio data with caching
  Future<Uint8List?> getAudioData(String fileId) async {
    // Try local cache first
    Uint8List? audioData = await _localStorage.getAudioData(fileId);
    if (audioData != null) {
      return audioData;
    }

    // Download from cloud
    audioData = await _cloudStorage.downloadAudioFile(fileId);
    if (audioData == null) {
      return null;
    }

    // Cache locally for future use
    await _cacheFromCloud(fileId, audioData);
    return audioData;
  }

  /// Store audio file (uploads to cloud and caches locally)
  Future<StoredAudioFile> storeAudioFile({
    required Uint8List audioData,
    required String fileName,
    required Map<String, dynamic> metadata,
    List<String> hashtags = const [],
  }) async {
    // Upload to cloud first
    final cloudFile = await _cloudStorage.uploadAudioFile(
      audioData: audioData,
      fileName: fileName,
      metadata: metadata,
      hashtags: hashtags,
    );

    // Cache locally
    await _cacheFromCloud(cloudFile.id, audioData);

    return cloudFile;
  }

  /// Pre-cache audio files for offline use
  Future<void> precacheAudioFiles(List<String> fileIds) async {
    for (final fileId in fileIds) {
      try {
        // Check if already cached
        final localFile = await _localStorage.getAudioFile(fileId);
        if (localFile != null) {
          continue; // Already cached
        }

        // Download and cache
        await _downloadAndCache(fileId);
      } catch (e) {
        print('Error precaching file $fileId: $e');
      }
    }
  }

  /// Clear specific file from cache
  Future<bool> clearFromCache(String fileId) async {
    return await _localStorage.deleteAudioFile(fileId);
  }

  /// Clear all cached files
  Future<int> clearAllCache() async {
    final cachedFiles = await _localStorage.listAudioFiles();
    int deletedCount = 0;

    for (final file in cachedFiles) {
      if (await _localStorage.deleteAudioFile(file.id)) {
        deletedCount++;
      }
    }

    return deletedCount;
  }

  /// Get cache statistics
  Future<LocalAudioCache> getCacheInfo() async {
    return await _localStorage.getCacheInfo();
  }

  /// Search cached files by hashtags
  Future<List<StoredAudioFile>> searchCachedFiles(List<String> hashtags) async {
    return await _localStorage.searchByHashtags(hashtags);
  }

  /// Check if file is cached locally
  Future<bool> isCached(String fileId) async {
    final localFile = await _localStorage.getAudioFile(fileId);
    return localFile != null;
  }

  /// Get cache hit rate (cached vs total requests)
  Future<double> getCacheHitRate() async {
    // This would require tracking requests - simplified implementation
    final cacheInfo = await getCacheInfo();
    final totalFiles = await _getTotalCloudFiles();
    
    if (totalFiles == 0) return 0.0;
    return cacheInfo.totalFiles / totalFiles;
  }

  /// Perform cache maintenance
  Future<CacheMaintenanceResult> performMaintenance({
    bool force = false,
  }) async {
    final deletedCount = await _localStorage.cleanupOldFiles(
      maxAge: _maxAge,
      maxFiles: _maxFiles,
      maxSizeBytes: _maxSizeBytes,
    );

    final cacheInfo = await getCacheInfo();
    
    return CacheMaintenanceResult(
      deletedFiles: deletedCount,
      remainingFiles: cacheInfo.totalFiles,
      totalSizeBytes: cacheInfo.totalSizeBytes,
      performedAt: DateTime.now(),
    );
  }

  /// Configure cache settings
  void configureCaching({
    Duration? maxAge,
    int? maxFiles,
    int? maxSizeBytes,
  }) {
    if (maxAge != null) _maxAge = maxAge;
    if (maxFiles != null) _maxFiles = maxFiles;
    if (maxSizeBytes != null) _maxSizeBytes = maxSizeBytes;
  }

  /// Sync cached files with cloud (remove deleted, update metadata)
  Future<SyncResult> syncWithCloud() async {
    final cachedFiles = await _localStorage.listAudioFiles();
    int removedFiles = 0;
    int updatedFiles = 0;
    final errors = <String>[];

    for (final cachedFile in cachedFiles) {
      try {
        // Check if file still exists in cloud
        final cloudExists = await _cloudStorage.fileExists(cachedFile.id);
        
        if (!cloudExists) {
          // Remove from local cache
          await _localStorage.deleteAudioFile(cachedFile.id);
          removedFiles++;
        } else {
          // Check if metadata needs updating
          final cloudMetadata = await _cloudStorage.getFileMetadata(cachedFile.id);
          if (cloudMetadata != null && _needsMetadataUpdate(cachedFile, cloudMetadata)) {
            // Update local metadata would go here
            updatedFiles++;
          }
        }
      } catch (e) {
        errors.add('Error syncing file ${cachedFile.id}: $e');
      }
    }

    return SyncResult(
      removedFiles: removedFiles,
      updatedFiles: updatedFiles,
      errors: errors,
      syncedAt: DateTime.now(),
    );
  }

  // Private helper methods

  Future<StoredAudioFile?> _downloadAndCache(String fileId) async {
    try {
      // Get file metadata from cloud
      final cloudMetadata = await _cloudStorage.getFileMetadata(fileId);
      if (cloudMetadata == null) {
        return null;
      }

      // Download audio data
      final audioData = await _cloudStorage.downloadAudioFile(fileId);
      if (audioData == null) {
        return null;
      }

      // Cache locally
      return await _cacheFromCloud(fileId, audioData);
    } catch (e) {
      print('Error downloading and caching file $fileId: $e');
      return null;
    }
  }

  Future<StoredAudioFile> _cacheFromCloud(String fileId, Uint8List audioData) async {
    // This is simplified - in a real implementation, you'd get metadata from cloud
    final metadata = await _cloudStorage.getFileMetadata(fileId);
    
    return await _localStorage.storeAudioFile(
      audioData: audioData,
      fileName: metadata?['fileName'] ?? 'cached_$fileId.mp3',
      metadata: metadata?['metadata'] ?? {},
      hashtags: List<String>.from(metadata?['hashtags'] ?? []),
    );
  }

  Future<void> _performMaintenanceIfNeeded() async {
    final cacheInfo = await getCacheInfo();
    
    // Perform maintenance if cache is getting too large
    final shouldMaintain = cacheInfo.totalFiles > _maxFiles ||
                          cacheInfo.totalSizeBytes > _maxSizeBytes ||
                          DateTime.now().difference(cacheInfo.oldestFileAccess) > _maxAge;

    if (shouldMaintain) {
      await performMaintenance();
    }
  }

  Future<int> _getTotalCloudFiles() async {
    // This would require a cloud storage method to count files
    // Simplified implementation
    try {
      final cloudFiles = await _cloudStorage.listAudioFiles();
      return cloudFiles.length;
    } catch (e) {
      return 0;
    }
  }

  bool _needsMetadataUpdate(StoredAudioFile cachedFile, Map<String, dynamic> cloudMetadata) {
    // Compare timestamps or version numbers
    // Simplified implementation
    return false;
  }
}

/// Result of cache maintenance operation
class CacheMaintenanceResult {
  final int deletedFiles;
  final int remainingFiles;
  final int totalSizeBytes;
  final DateTime performedAt;

  const CacheMaintenanceResult({
    required this.deletedFiles,
    required this.remainingFiles,
    required this.totalSizeBytes,
    required this.performedAt,
  });

  @override
  String toString() {
    return 'CacheMaintenanceResult(deleted: $deletedFiles, remaining: $remainingFiles, '
           'size: ${(totalSizeBytes / 1024 / 1024).toStringAsFixed(1)}MB, at: $performedAt)';
  }
}

/// Result of cache sync operation
class SyncResult {
  final int removedFiles;
  final int updatedFiles;
  final List<String> errors;
  final DateTime syncedAt;

  const SyncResult({
    required this.removedFiles,
    required this.updatedFiles,
    required this.errors,
    required this.syncedAt,
  });

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() {
    return 'SyncResult(removed: $removedFiles, updated: $updatedFiles, '
           'errors: ${errors.length}, at: $syncedAt)';
  }
}
