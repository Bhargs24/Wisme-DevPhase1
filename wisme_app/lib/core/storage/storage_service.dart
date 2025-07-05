import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../error/exceptions.dart';

/// Local storage service for persistent data
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();
  
  SharedPreferences? _prefs;
  
  /// Initialize local storage
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Ensure preferences are initialized
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StorageException('Local storage not initialized');
    }
    return _prefs!;
  }
  
  // String operations
  
  /// Store string value
  Future<void> setString(String key, String value) async {
    try {
      await _preferences.setString(key, value);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get string value
  String? getString(String key) {
    try {
      return _preferences.getString(key);
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  // Integer operations
  
  /// Store integer value
  Future<void> setInt(String key, int value) async {
    try {
      await _preferences.setInt(key, value);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get integer value
  int? getInt(String key) {
    try {
      return _preferences.getInt(key);
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  // Double operations
  
  /// Store double value
  Future<void> setDouble(String key, double value) async {
    try {
      await _preferences.setDouble(key, value);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get double value
  double? getDouble(String key) {
    try {
      return _preferences.getDouble(key);
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  // Boolean operations
  
  /// Store boolean value
  Future<void> setBool(String key, bool value) async {
    try {
      await _preferences.setBool(key, value);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get boolean value
  bool? getBool(String key) {
    try {
      return _preferences.getBool(key);
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  // List operations
  
  /// Store string list
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _preferences.setStringList(key, value);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get string list
  List<String>? getStringList(String key) {
    try {
      return _preferences.getStringList(key);
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  // JSON operations
  
  /// Store object as JSON
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await setString(key, jsonString);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get object from JSON
  Map<String, dynamic>? getObject(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  /// Store list of objects as JSON
  Future<void> setObjectList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      await setString(key, jsonString);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get list of objects from JSON
  List<Map<String, dynamic>>? getObjectList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  // Utility operations
  
  /// Check if key exists
  bool containsKey(String key) {
    try {
      return _preferences.containsKey(key);
    } catch (e) {
      return false;
    }
  }
  
  /// Remove key
  Future<void> remove(String key) async {
    try {
      await _preferences.remove(key);
    } catch (e) {
      throw StorageException.deleteFailed();
    }
  }
  
  /// Clear all data
  Future<void> clear() async {
    try {
      await _preferences.clear();
    } catch (e) {
      throw StorageException.deleteFailed();
    }
  }
  
  /// Get all keys
  Set<String> getKeys() {
    try {
      return _preferences.getKeys();
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  /// Get storage size (approximate)
  int getStorageSize() {
    try {
      final keys = getKeys();
      int totalSize = 0;
      
      for (final key in keys) {
        final value = getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

/// File storage service for larger data files
class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();
  factory FileStorageService() => _instance;
  FileStorageService._internal();
  
  Directory? _documentsDirectory;
  Directory? _cacheDirectory;
  Directory? _tempDirectory;
  
  /// Initialize file storage
  Future<void> initialize() async {
    try {
      _documentsDirectory = await getApplicationDocumentsDirectory();
      _cacheDirectory = await getTemporaryDirectory();
      _tempDirectory = await getTemporaryDirectory();
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get documents directory
  Directory get documentsDirectory {
    if (_documentsDirectory == null) {
      throw StorageException('File storage not initialized');
    }
    return _documentsDirectory!;
  }
  
  /// Get cache directory
  Directory get cacheDirectory {
    if (_cacheDirectory == null) {
      throw StorageException('File storage not initialized');
    }
    return _cacheDirectory!;
  }
  
  /// Get temp directory
  Directory get tempDirectory {
    if (_tempDirectory == null) {
      throw StorageException('File storage not initialized');
    }
    return _tempDirectory!;
  }
  
  /// Write string to file
  Future<void> writeString(String fileName, String content, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final file = _getFile(fileName, location);
      await file.writeAsString(content);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Read string from file
  Future<String?> readString(String fileName, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final file = _getFile(fileName, location);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  /// Write bytes to file
  Future<void> writeBytes(String fileName, List<int> bytes, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final file = _getFile(fileName, location);
      await file.writeAsBytes(bytes);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Read bytes from file
  Future<List<int>?> readBytes(String fileName, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final file = _getFile(fileName, location);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  /// Write JSON to file
  Future<void> writeJson(String fileName, Map<String, dynamic> data, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final jsonString = jsonEncode(data);
      await writeString(fileName, jsonString, location: location);
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Read JSON from file
  Future<Map<String, dynamic>?> readJson(String fileName, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final jsonString = await readString(fileName, location: location);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists(String fileName, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final file = _getFile(fileName, location);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Delete file
  Future<void> deleteFile(String fileName, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final file = _getFile(fileName, location);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw StorageException.deleteFailed();
    }
  }
  
  /// Get file size
  Future<int> getFileSize(String fileName, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final file = _getFile(fileName, location);
      if (!await file.exists()) return 0;
      return await file.length();
    } catch (e) {
      return 0;
    }
  }
  
  /// List files in directory
  Future<List<String>> listFiles({StorageLocation location = StorageLocation.documents}) async {
    try {
      final directory = _getDirectory(location);
      if (!await directory.exists()) return [];
      
      final entities = await directory.list().toList();
      return entities
          .whereType<File>()
          .map((file) => file.path.split('/').last)
          .toList();
    } catch (e) {
      throw StorageException.downloadFailed();
    }
  }
  
  /// Get directory size
  Future<int> getDirectorySize({StorageLocation location = StorageLocation.documents}) async {
    try {
      final directory = _getDirectory(location);
      if (!await directory.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
  
  /// Clear directory
  Future<void> clearDirectory({StorageLocation location = StorageLocation.cache}) async {
    try {
      final directory = _getDirectory(location);
      if (await directory.exists()) {
        await for (final entity in directory.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      throw StorageException.deleteFailed();
    }
  }
  
  /// Create subdirectory
  Future<Directory> createSubdirectory(String name, {StorageLocation location = StorageLocation.documents}) async {
    try {
      final parentDirectory = _getDirectory(location);
      final subdirectory = Directory('${parentDirectory.path}/$name');
      
      if (!await subdirectory.exists()) {
        await subdirectory.create(recursive: true);
      }
      
      return subdirectory;
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Copy file
  Future<void> copyFile(
    String sourceFileName, 
    String destinationFileName, {
    StorageLocation sourceLocation = StorageLocation.documents,
    StorageLocation destinationLocation = StorageLocation.documents,
  }) async {
    try {
      final sourceFile = _getFile(sourceFileName, sourceLocation);
      final destinationFile = _getFile(destinationFileName, destinationLocation);
      
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationFile.path);
      } else {
        throw StorageException.fileNotFound();
      }
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Move file
  Future<void> moveFile(
    String sourceFileName, 
    String destinationFileName, {
    StorageLocation sourceLocation = StorageLocation.documents,
    StorageLocation destinationLocation = StorageLocation.documents,
  }) async {
    try {
      final sourceFile = _getFile(sourceFileName, sourceLocation);
      final destinationFile = _getFile(destinationFileName, destinationLocation);
      
      if (await sourceFile.exists()) {
        await sourceFile.rename(destinationFile.path);
      } else {
        throw StorageException.fileNotFound();
      }
    } catch (e) {
      throw StorageException.uploadFailed();
    }
  }
  
  /// Get file
  File _getFile(String fileName, StorageLocation location) {
    final directory = _getDirectory(location);
    return File('${directory.path}/$fileName');
  }
  
  /// Get directory for location
  Directory _getDirectory(StorageLocation location) {
    switch (location) {
      case StorageLocation.documents:
        return documentsDirectory;
      case StorageLocation.cache:
        return cacheDirectory;
      case StorageLocation.temp:
        return tempDirectory;
    }
  }
}

/// Storage location enumeration
enum StorageLocation {
  documents,
  cache,
  temp,
}

/// Storage utilities
class StorageUtils {
  /// Format storage size
  static String formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Get file extension
  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }
  
  /// Get file name without extension
  static String getFileNameWithoutExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }
  
  /// Check if file is image
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }
  
  /// Check if file is audio
  static bool isAudioFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'].contains(extension);
  }
  
  /// Check if file is video
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(extension);
  }
  
  /// Check if file is document
  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['pdf', 'doc', 'docx', 'txt', 'rtf', 'odt'].contains(extension);
  }
  
  /// Generate unique file name
  static String generateUniqueFileName(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${baseName}_$timestamp.$extension';
  }
  
  /// Sanitize file name
  static String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
