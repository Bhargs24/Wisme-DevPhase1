import 'dart:developer' as developer;

class AppLogger {
  static void info(String message) {
    developer.log(message, name: 'Wisme.Info');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'Wisme.Error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message) {
    developer.log(message, name: 'Wisme.Warning');
  }

  static void debug(String message) {
    developer.log(message, name: 'Wisme.Debug');
  }
}
