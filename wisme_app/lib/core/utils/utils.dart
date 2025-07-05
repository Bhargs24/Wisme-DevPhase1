import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

/// Date and time utilities
class DateTimeUtils {
  /// Format date for display
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? 'MMM dd, yyyy');
    return formatter.format(date);
  }
  
  /// Format time for display
  static String formatTime(DateTime time, {bool use24Hour = false}) {
    final formatter = DateFormat(use24Hour ? 'HH:mm' : 'h:mm a');
    return formatter.format(time);
  }
  
  /// Format duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  /// Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// Get start of week
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }
  
  /// Get end of week
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }
  
  /// Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

/// String utilities
class StringUtils {
  /// Check if string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }
  
  /// Check if string is null, empty, or whitespace
  static bool isNullOrWhitespace(String? value) {
    return value == null || value.trim().isEmpty;
  }
  
  /// Capitalize first letter
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
  
  /// Capitalize each word
  static String capitalizeWords(String value) {
    return value.split(' ').map(capitalize).join(' ');
  }
  
  /// Truncate string with ellipsis
  static String truncate(String value, int maxLength, {String suffix = '...'}) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength - suffix.length) + suffix;
  }
  
  /// Remove special characters
  static String removeSpecialCharacters(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }
  
  /// Convert to slug (URL-friendly)
  static String toSlug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
  
  /// Extract initials from name
  static String getInitials(String name, {int maxChars = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .where((word) => word.isNotEmpty)
        .take(maxChars)
        .map((word) => word[0].toUpperCase())
        .join();
    return initials;
  }
  
  /// Mask email for privacy
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    
    final maskedUsername = username[0] + 
        '*' * (username.length - 2) + 
        username[username.length - 1];
    
    return '$maskedUsername@$domain';
  }
  
  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  /// Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
}

/// Validation utilities
class ValidationUtils {
  /// Validate email
  static String? validateEmail(String? value) {
    if (StringUtils.isNullOrWhitespace(value)) {
      return 'Email is required';
    }
    if (!StringUtils.isValidEmail(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate password
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (StringUtils.isNullOrWhitespace(value)) {
      return 'Password is required';
    }
    if (value!.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }
  
  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (StringUtils.isNullOrWhitespace(value)) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  /// Validate name
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (StringUtils.isNullOrWhitespace(value)) {
      return '$fieldName is required';
    }
    if (value!.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }
  
  /// Validate phone number
  static String? validatePhone(String? value) {
    if (StringUtils.isNullOrWhitespace(value)) {
      return 'Phone number is required';
    }
    final cleaned = value!.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  /// Validate age
  static String? validateAge(int? value, {int minAge = 13, int maxAge = 120}) {
    if (value == null) {
      return 'Age is required';
    }
    if (value < minAge) {
      return 'You must be at least $minAge years old';
    }
    if (value > maxAge) {
      return 'Please enter a valid age';
    }
    return null;
  }
  
  /// Validate required field
  static String? validateRequired(dynamic value, String fieldName) {
    if (value == null || 
        (value is String && StringUtils.isNullOrWhitespace(value))) {
      return '$fieldName is required';
    }
    return null;
  }
}

/// Math utilities
class MathUtils {
  /// Clamp value between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
  
  /// Linear interpolation
  static double lerp(double a, double b, double t) {
    return a + (b - a) * clamp(t, 0.0, 1.0);
  }
  
  /// Map value from one range to another
  static double mapRange(double value, double inMin, double inMax, double outMin, double outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }
  
  /// Round to decimal places
  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final mod = pow(10.0, decimalPlaces);
    return (value * mod).round().toDouble() / mod;
  }
  
  /// Calculate percentage
  static double percentage(num value, num total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
  
  /// Calculate average
  static double average(List<num> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  /// Generate random number in range
  static int randomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }
  
  /// Generate random double in range
  static double randomDouble(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }
}

/// Encryption utilities
class EncryptionUtils {
  /// Generate MD5 hash
  static String md5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
  
  /// Generate SHA256 hash
  static String sha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
  
  /// Generate unique ID
  static String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return md5Hash('$timestamp$random');
  }
  
  /// Generate API key
  static String generateApiKey({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }
}

/// Debouncer utility for rate limiting function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({required this.delay});
  
  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler utility for rate limiting function calls
class Throttler {
  final Duration duration;
  DateTime? _lastCall;
  
  Throttler({required this.duration});
  
  bool call(VoidCallback callback) {
    final now = DateTime.now();
    if (_lastCall == null || now.difference(_lastCall!) >= duration) {
      _lastCall = now;
      callback();
      return true;
    }
    return false;
  }
}

/// List utilities
class ListUtils {
  /// Check if list is null or empty
  static bool isNullOrEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }
  
  /// Safely get item at index
  static T? safeGet<T>(List<T>? list, int index) {
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }
  
  /// Chunk list into smaller lists
  static List<List<T>> chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, min(i + size, list.length)));
    }
    return chunks;
  }
  
  /// Remove duplicates while preserving order
  static List<T> removeDuplicates<T>(List<T> list) {
    final seen = <T>{};
    return list.where((item) => seen.add(item)).toList();
  }
  
  /// Shuffle list
  static List<T> shuffle<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }
}

/// File size utilities
class FileSizeUtils {
  /// Format bytes to human readable size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Parse size string to bytes
  static int parseSize(String size) {
    final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*(B|KB|MB|GB)$', caseSensitive: false);
    final match = regex.firstMatch(size.trim());
    
    if (match == null) throw ArgumentError('Invalid size format: $size');
    
    final value = double.parse(match.group(1)!);
    final unit = match.group(2)!.toLowerCase();
    
    switch (unit) {
      case 'b':
        return value.round();
      case 'kb':
        return (value * 1024).round();
      case 'mb':
        return (value * 1024 * 1024).round();
      case 'gb':
        return (value * 1024 * 1024 * 1024).round();
      default:
        throw ArgumentError('Unknown size unit: $unit');
    }
  }
}

/// Platform utilities
class PlatformUtils {
  /// Check if running on mobile
  static bool get isMobile {
    // This would need to be implemented with platform-specific code
    // For now, return false
    return false;
  }
  
  /// Check if running on tablet
  static bool get isTablet {
    // This would need to be implemented with screen size detection
    return false;
  }
  
  /// Check if running on desktop
  static bool get isDesktop {
    return !isMobile && !isTablet;
  }
}

/// Type definitions
typedef VoidCallback = void Function();
