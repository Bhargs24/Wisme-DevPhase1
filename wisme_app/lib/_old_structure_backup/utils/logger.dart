import 'dart:developer' as developer;

/// Application logger utility
class AppLogger {
  static const String _name = 'WismeApp';

  /// Log info message
  static void info(String message) {
    developer.log(
      message,
      name: _name,
      level: 800, // INFO level
    );
  }

  /// Log error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: _name,
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning message
  static void warning(String message) {
    developer.log(
      message,
      name: _name,
      level: 900, // WARNING level
    );
  }

  /// Log debug message
  static void debug(String message) {
    developer.log(
      message,
      name: _name,
      level: 700, // DEBUG level
    );
  }

  /// Log verbose message
  static void verbose(String message) {
    developer.log(
      message,
      name: _name,
      level: 500, // VERBOSE level
    );
  }
}