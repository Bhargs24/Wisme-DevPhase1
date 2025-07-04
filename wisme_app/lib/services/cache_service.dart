// Cache management service

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CacheService {
  static const String _audioCacheDir = 'audio_cache';
  static const String _metadataCacheKey = 'audio_metadata_cache';
  static const int _maxCacheSizeMB = 500; // 500MB cache limit
  
  /// Generate cache key for topic
  String _generateCacheKey(String topic, String coachVoice) {
    final input = '$topic-$coachVoice'.toLowerCase().trim();
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_audioCacheDir');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    return cacheDir;
  }

  /// Check if audio is cached locally
  Future<File?> getCachedAudio(String topic, String coachVoice) async {
    try {
      final cacheKey = _generateCacheKey(topic, coachVoice);
      final cacheDir = await _getCacheDirectory();
      final audioFile = File('${cacheDir.path}/$cacheKey.mp3');
      
      if (await audioFile.exists()) {
        // Update last accessed time
        await _updateLastAccessed(cacheKey);
        return audioFile;
      }
      
      return null;
    } catch (e) {
      print('Error checking cached audio: $e');
      return null;
    }
  }

  /// Cache audio file locally
  Future<void> cacheAudio({
    required String topic,
    required String coachVoice,
    required Uint8List audioData,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final cacheKey = _generateCacheKey(topic, coachVoice);
      final cacheDir = await _getCacheDirectory();
      final audioFile = File('${cacheDir.path}/$cacheKey.mp3');
      
      // Write audio file
      await audioFile.writeAsBytes(audioData);
      
      // Store metadata
      await _storeMetadata(cacheKey, {
        ...metadata,
        'cachedAt': DateTime.now().toIso8601String(),
        'fileSize': audioData.length,
        'filePath': audioFile.path,
      });
      
      // Check and enforce cache size limit
      await _enforceCacheLimit();
      
    } catch (e) {
      print('Error caching audio: $e');
    }
  }

  /// Store metadata in SharedPreferences
  Future<void> _storeMetadata(String cacheKey, Map<String, dynamic> metadata) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_metadataCacheKey);
      
      Map<String, dynamic> allMetadata = {};
      if (existingData != null) {
        allMetadata = Map<String, dynamic>.from(json.decode(existingData));
      }
      
      allMetadata[cacheKey] = metadata;
      await prefs.setString(_metadataCacheKey, json.encode(allMetadata));
    } catch (e) {
      print('Error storing metadata: $e');
    }
  }

  /// Get metadata for cached item
  Future<Map<String, dynamic>?> getMetadata(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_metadataCacheKey);
      
      if (existingData != null) {
        final allMetadata = Map<String, dynamic>.from(json.decode(existingData));
        return allMetadata[cacheKey];
      }
      
      return null;
    } catch (e) {
      print('Error getting metadata: $e');
      return null;
    }
  }

  /// Update last accessed time
  Future<void> _updateLastAccessed(String cacheKey) async {
    try {
      final metadata = await getMetadata(cacheKey);
      if (metadata != null) {
        metadata['lastAccessed'] = DateTime.now().toIso8601String();
        await _storeMetadata(cacheKey, metadata);
      }
    } catch (e) {
      print('Error updating last accessed: $e');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      int totalSize = 0;
      
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Enforce cache size limit by removing oldest files
  Future<void> _enforceCacheLimit() async {
    try {
      final cacheSize = await getCacheSize();
      final limitBytes = _maxCacheSizeMB * 1024 * 1024;
      
      if (cacheSize > limitBytes) {
        await _cleanupOldestFiles(cacheSize - limitBytes);
      }
    } catch (e) {
      print('Error enforcing cache limit: $e');
    }
  }

  /// Remove oldest cached files to free up space
  Future<void> _cleanupOldestFiles(int bytesToFree) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_metadataCacheKey);
      
      if (existingData == null) return;
      
      final allMetadata = Map<String, dynamic>.from(json.decode(existingData));
      
      // Sort by last accessed time (oldest first)
      final sortedEntries = allMetadata.entries.toList()
        ..sort((a, b) {
          final aTime = DateTime.tryParse(a.value['lastAccessed'] ?? '') ?? DateTime(2000);
          final bTime = DateTime.tryParse(b.value['lastAccessed'] ?? '') ?? DateTime(2000);
          return aTime.compareTo(bTime);
        });
      
      int freedBytes = 0;
      final toRemove = <String>[];
      
      for (final entry in sortedEntries) {
        if (freedBytes >= bytesToFree) break;
        
        final metadata = entry.value;
        final filePath = metadata['filePath'] as String?;
        final fileSize = metadata['fileSize'] as int? ?? 0;
        
        if (filePath != null) {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            freedBytes += fileSize;
            toRemove.add(entry.key);
          }
        }
      }
      
      // Remove metadata for deleted files
      for (final key in toRemove) {
        allMetadata.remove(key);
      }
      
      await prefs.setString(_metadataCacheKey, json.encode(allMetadata));
      
      print('Cleaned up ${toRemove.length} cached files, freed ${freedBytes ~/ 1024}KB');
    } catch (e) {
      print('Error cleaning up old files: $e');
    }
  }

  /// Clear all cached audio
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_metadataCacheKey);
      
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_metadataCacheKey);
      final cacheSize = await getCacheSize();
      
      int fileCount = 0;
      if (existingData != null) {
        final allMetadata = Map<String, dynamic>.from(json.decode(existingData));
        fileCount = allMetadata.length;
      }
      
      return {
        'totalFiles': fileCount,
        'totalSizeBytes': cacheSize,
        'totalSizeMB': (cacheSize / (1024 * 1024)).toStringAsFixed(2),
        'maxSizeMB': _maxCacheSizeMB,
        'usagePercentage': ((cacheSize / (_maxCacheSizeMB * 1024 * 1024)) * 100).toStringAsFixed(1),
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {};
    }
  }
}
