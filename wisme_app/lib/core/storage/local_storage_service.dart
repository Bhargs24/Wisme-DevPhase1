/// Local storage service for offline data persistence
/// 
/// Provides secure and efficient local storage capabilities
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import '../../shared/models/result.dart';

/// Local storage service for managing offline data
class LocalStorageService {
  static LocalStorageService? _instance;
  static bool _isInitialized = false;

  SharedPreferences? _prefs;
  Directory? _documentsDir;
  Directory? _tempDir;
  Directory? _cacheDir;

  LocalStorageService._();

  /// Get singleton instance
  factory LocalStorageService() {
    return _instance ??= LocalStorageService._();
  }

  /// Initialize the service
  Future<Result<void>> initialize() async {
    try {
      if (_isInitialized) return const Result.success(null);

      _prefs = await SharedPreferences.getInstance();
      _documentsDir = await getApplicationDocumentsDirectory();
      _tempDir = await getTemporaryDirectory();
      _cacheDir = await getApplicationCacheDirectory();

      _isInitialized = true;
      AppLogger.info('LocalStorageService initialized successfully');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Failed to initialize LocalStorageService: $e');
      return Result.failure(Exception('Failed to initialize local storage: $e'));
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  // MARK: - Preferences Storage

  /// Store a string value
  Future<Result<void>> setString(String key, String value) async {
    try {
      await _ensureInitialized();
      final success = await _prefs!.setString(key, value);
      if (success) {
        return const Result.success(null);
      } else {
        return Result.failure(Exception('Failed to store string'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to store string: $e'));
    }
  }

  /// Get a string value
  Result<String?> getString(String key) {
    try {
      _checkInitialized();
      final value = _prefs!.getString(key);
      return Result.success(value);
    } catch (e) {
      return Result.failure(Exception('Failed to get string: $e'));
    }
  }

  /// Store an integer value
  Future<Result<void>> setInt(String key, int value) async {
    try {
      await _ensureInitialized();
      final success = await _prefs!.setInt(key, value);
      if (success) {
        return const Result.success(null);
      } else {
        return Result.failure(Exception('Failed to store integer'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to store integer: $e'));
    }
  }

  /// Get an integer value
  Result<int?> getInt(String key) {
    try {
      _checkInitialized();
      final value = _prefs!.getInt(key);
      return Result.success(value);
    } catch (e) {
      return Result.failure(Exception('Failed to get integer: $e'));
    }
  }

  /// Store a boolean value
  Future<Result<void>> setBool(String key, bool value) async {
    try {
      await _ensureInitialized();
      final success = await _prefs!.setBool(key, value);
      if (success) {
        return const Result.success(null);
      } else {
        return Result.failure(Exception('Failed to store boolean'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to store boolean: $e'));
    }
  }

  /// Get a boolean value
  Result<bool?> getBool(String key) {
    try {
      _checkInitialized();
      final value = _prefs!.getBool(key);
      return Result.success(value);
    } catch (e) {
      return Result.failure(Exception('Failed to get boolean: $e'));
    }
  }

  /// Store a JSON object
  Future<Result<void>> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      return Result.failure(Exception('Failed to store JSON: $e'));
    }
  }

  /// Get a JSON object
  Result<Map<String, dynamic>?> getJson(String key) {
    try {
      final stringResult = getString(key);
      if (stringResult.isFailure) return Result.failure(stringResult.error!);
      
      final jsonString = stringResult.data;
      if (jsonString == null) return const Result.success(null);
      
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Result.success(json);
    } catch (e) {
      return Result.failure(Exception('Failed to get JSON: $e'));
    }
  }

  /// Remove a key
  Future<Result<void>> remove(String key) async {
    try {
      await _ensureInitialized();
      final success = await _prefs!.remove(key);
      if (success) {
        return const Result.success(null);
      } else {
        return Result.failure(Exception('Failed to remove key'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to remove key: $e'));
    }
  }

  /// Check if key exists
  Result<bool> containsKey(String key) {
    try {
      _checkInitialized();
      final exists = _prefs!.containsKey(key);
      return Result.success(exists);
    } catch (e) {
      return Result.failure(Exception('Failed to check key existence: $e'));
    }
  }

  /// Clear all preferences
  Future<Result<void>> clear() async {
    try {
      await _ensureInitialized();
      final success = await _prefs!.clear();
      if (success) {
        return const Result.success(null);
      } else {
        return Result.failure(Exception('Failed to clear preferences'));
      }
    } catch (e) {
      return Result.failure(Exception('Failed to clear preferences: $e'));
    }
  }

  // MARK: - File Storage

  /// Write bytes to a file
  Future<Result<void>> writeFile(String filePath, Uint8List bytes) async {
    try {
      await _ensureInitialized();
      final file = File(_getFullPath(filePath));
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Failed to write file: $e'));
    }
  }

  /// Read bytes from a file
  Future<Result<Uint8List?>> readFile(String filePath) async {
    try {
      await _ensureInitialized();
      final file = File(_getFullPath(filePath));
      if (!await file.exists()) {
        return const Result.success(null);
      }
      final bytes = await file.readAsBytes();
      return Result.success(bytes);
    } catch (e) {
      return Result.failure(Exception('Failed to read file: $e'));
    }
  }

  /// Write string to a file
  Future<Result<void>> writeTextFile(String filePath, String content) async {
    try {
      await _ensureInitialized();
      final file = File(_getFullPath(filePath));
      await file.create(recursive: true);
      await file.writeAsString(content);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Failed to write text file: $e'));
    }
  }

  /// Read string from a file
  Future<Result<String?>> readTextFile(String filePath) async {
    try {
      await _ensureInitialized();
      final file = File(_getFullPath(filePath));
      if (!await file.exists()) {
        return const Result.success(null);
      }
      final content = await file.readAsString();
      return Result.success(content);
    } catch (e) {
      return Result.failure(Exception('Failed to read text file: $e'));
    }
  }

  /// Delete a file
  Future<Result<void>> deleteFile(String filePath) async {
    try {
      await _ensureInitialized();
      final file = File(_getFullPath(filePath));
      if (await file.exists()) {
        await file.delete();
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Failed to delete file: $e'));
    }
  }

  /// Check if file exists
  Future<Result<bool>> fileExists(String filePath) async {
    try {
      await _ensureInitialized();
      final file = File(_getFullPath(filePath));
      final exists = await file.exists();
      return Result.success(exists);
    } catch (e) {
      return Result.failure(Exception('Failed to check file existence: $e'));
    }
  }

  /// Get file size in bytes
  Future<Result<int?>> getFileSize(String filePath) async {
    try {
      await _ensureInitialized();
      final file = File(_getFullPath(filePath));
      if (!await file.exists()) {
        return const Result.success(null);
      }
      final size = await file.length();
      return Result.success(size);
    } catch (e) {
      return Result.failure(Exception('Failed to get file size: $e'));
    }
  }

  /// Get cache directory size
  Future<Result<int>> getCacheSize() async {
    try {
      await _ensureInitialized();
      int totalSize = 0;
      
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      
      return Result.success(totalSize);
    } catch (e) {
      return Result.failure(Exception('Failed to get cache size: $e'));
    }
  }

  /// Clear cache directory
  Future<Result<void>> clearCache() async {
    try {
      await _ensureInitialized();
      
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          await entity.delete(recursive: true);
        }
      }
      
      return const Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Failed to clear cache: $e'));
    }
  }

  // MARK: - Directory Management

  /// Get documents directory path
  String? get documentsPath => _documentsDir?.path;

  /// Get cache directory path
  String? get cachePath => _cacheDir?.path;

  /// Get temp directory path
  String? get tempPath => _tempDir?.path;

  // MARK: - Private Methods

  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('LocalStorageService not initialized');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final result = await initialize();
      if (result.isFailure) {
        throw Exception('Failed to initialize LocalStorageService');
      }
    }
  }

  String _getFullPath(String relativePath) {
    if (_documentsDir == null) {
      throw Exception('Documents directory not available');
    }
    return '${_documentsDir!.path}/$relativePath';
  }
}
