/// Industrial-grade Result type for error handling and API responses
sealed class Result<T> {
  const Result();

  /// Create a successful result
  const factory Result.success(T data) = Success<T>;

  /// Create a failure result
  const factory Result.failure(WismeFailure failure) = Failure<T>;

  /// Create a loading result
  const factory Result.loading([String? message]) = Loading<T>;

  /// Check if result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Check if result is loading
  bool get isLoading => this is Loading<T>;

  /// Get data if success, null otherwise
  T? get data => switch (this) {
    Success<T>(data: final data) => data,
    _ => null,
  };

  /// Get error if failure, null otherwise
  WismeFailure? get error => switch (this) {
    Failure<T>(failure: final failure) => failure,
    _ => null,
  };

  /// Get loading message if loading, null otherwise
  String? get loadingMessage => switch (this) {
    Loading<T>(message: final message) => message,
    _ => null,
  };

  /// Transform the data if successful
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(data: final data) => Result.success(transform(data)),
      Failure<T>(failure: final failure) => Result.failure(failure),
      Loading<T>(message: final message) => Result.loading(message),
    };
  }

  /// Transform the data if successful, otherwise return the error
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T>(data: final data) => transform(data),
      Failure<T>(failure: final failure) => Result.failure(failure),
      Loading<T>(message: final message) => Result.loading(message),
    };
  }

  /// Execute a function when successful
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Execute a function when failed
  Result<T> onFailure(void Function(WismeFailure error) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).failure);
    }
    return this;
  }

  /// Execute a function when loading
  Result<T> onLoading(void Function(String? message) action) {
    if (this is Loading<T>) {
      action((this as Loading<T>).message);
    }
    return this;
  }

  /// Get data or throw an exception
  T get dataOrThrow => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>(failure: final failure) => throw failure.exception ?? Exception(failure.message),
    Loading<T>() => throw StateError('Result is still loading'),
  };

  /// Get data or return default value
  T dataOr(T defaultValue) => switch (this) {
    Success<T>(data: final data) => data,
    _ => defaultValue,
  };

  /// Get data or return result of function
  T dataOrElse(T Function() defaultValue) => switch (this) {
    Success<T>(data: final data) => data,
    _ => defaultValue(),
  };
}

/// Success result containing data
final class Success<T> extends Result<T> {
  @override
  final T data;
  
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Failure result containing error information
final class Failure<T> extends Result<T> {
  final WismeFailure failure;
  
  const Failure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure($failure)';
}

/// Loading result indicating operation in progress
final class Loading<T> extends Result<T> {
  final String? message;
  
  const Loading([this.message]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loading<T> &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Loading($message)';
}

/// Base failure class for all app errors
abstract class WismeFailure {
  final String message;
  final String code;
  final Exception? exception;
  final StackTrace? stackTrace;
  final Map<String, dynamic> metadata;

  const WismeFailure({
    required this.message,
    required this.code,
    this.exception,
    this.stackTrace,
    this.metadata = const {},
  });

  /// Convert to user-friendly message
  String get userMessage => message;

  /// Check if failure is retryable
  bool get isRetryable => false;

  /// Check if failure requires authentication
  bool get requiresAuth => false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WismeFailure &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'WismeFailure{code: $code, message: $message}';
}

/// Network-related failures
class NetworkFailure extends WismeFailure {
  const NetworkFailure({
    required super.message,
    required super.code,
    super.exception,
    super.stackTrace,
    super.metadata,
  });

  @override
  bool get isRetryable => true;

  @override
  String get userMessage {
    switch (code) {
      case 'no_internet':
        return 'No internet connection. Please check your network and try again.';
      case 'timeout':
        return 'Request timed out. Please try again.';
      case 'server_error':
        return 'Server error. Please try again later.';
      default:
        return 'Network error. Please check your connection.';
    }
  }
}

/// Authentication-related failures
class AuthFailure extends WismeFailure {
  const AuthFailure({
    required super.message,
    required super.code,
    super.exception,
    super.stackTrace,
    super.metadata,
  });

  @override
  bool get requiresAuth => true;

  @override
  String get userMessage {
    switch (code) {
      case 'user_not_found':
        return 'Account not found. Please check your credentials.';
      case 'wrong_password':
        return 'Incorrect password. Please try again.';
      case 'email_not_verified':
        return 'Please verify your email address before continuing.';
      case 'account_disabled':
        return 'Your account has been disabled. Please contact support.';
      case 'too_many_requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

/// Validation-related failures
class ValidationFailure extends WismeFailure {
  const ValidationFailure({
    required super.message,
    required super.code,
    super.exception,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get userMessage {
    switch (code) {
      case 'invalid_email':
        return 'Please enter a valid email address.';
      case 'weak_password':
        return 'Password must be at least 8 characters with uppercase, lowercase, and numbers.';
      case 'passwords_dont_match':
        return 'Passwords do not match.';
      case 'invalid_topic':
        return 'Please enter a valid learning topic.';
      default:
        return message;
    }
  }
}

/// Storage-related failures
class StorageFailure extends WismeFailure {
  const StorageFailure({
    required super.message,
    required super.code,
    super.exception,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get userMessage {
    switch (code) {
      case 'insufficient_space':
        return 'Not enough storage space. Please free up some space and try again.';
      case 'file_not_found':
        return 'Content not found. Please try downloading again.';
      case 'permission_denied':
        return 'Storage permission required. Please grant access in settings.';
      default:
        return 'Storage error. Please try again.';
    }
  }
}

/// AI service-related failures
class AIFailure extends WismeFailure {
  const AIFailure({
    required super.message,
    required super.code,
    super.exception,
    super.stackTrace,
    super.metadata,
  });

  @override
  bool get isRetryable => code != 'quota_exceeded';

  @override
  String get userMessage {
    switch (code) {
      case 'api_key_invalid':
        return 'AI service unavailable. Please contact support.';
      case 'quota_exceeded':
        return 'AI service limit reached. Please try again later.';
      case 'content_filtered':
        return 'Content cannot be processed. Please try a different topic.';
      case 'generation_failed':
        return 'Failed to generate content. Please try again.';
      default:
        return 'AI service error. Please try again later.';
    }
  }
}

/// Audio-related failures
class AudioFailure extends WismeFailure {
  const AudioFailure({
    required super.message,
    required super.code,
    super.exception,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get userMessage {
    switch (code) {
      case 'playback_failed':
        return 'Failed to play audio. Please try again.';
      case 'audio_not_available':
        return 'Audio content not available. Please try downloading again.';
      case 'codec_not_supported':
        return 'Audio format not supported on this device.';
      case 'permission_denied':
        return 'Audio permission required. Please grant access in settings.';
      default:
        return 'Audio error. Please try again.';
    }
  }
}

/// Cache-related failures
class CacheFailure extends WismeFailure {
  const CacheFailure({
    required super.message,
    required super.code,
    super.exception,
    super.stackTrace,
    super.metadata,
  });

  @override
  String get userMessage {
    switch (code) {
      case 'cache_corrupted':
        return 'Data corrupted. Refreshing content...';
      case 'cache_expired':
        return 'Content expired. Refreshing...';
      default:
        return 'Cache error. Refreshing content...';
    }
  }
}

/// Unknown or unexpected failures
class UnknownFailure extends WismeFailure {
  const UnknownFailure({
    required super.message,
    super.exception,
    super.stackTrace,
    super.metadata,
  }) : super(code: 'unknown');

  @override
  String get userMessage => 'An unexpected error occurred. Please try again.';
}

/// Utility functions for creating common failures
extension ResultHelpers on Never {
  static Result<T> networkError<T>(String message, {Exception? exception}) {
    return Result.failure(NetworkFailure(
      message: message,
      code: 'network_error',
      exception: exception,
    ));
  }

  static Result<T> authError<T>(String message, String code, {Exception? exception}) {
    return Result.failure(AuthFailure(
      message: message,
      code: code,
      exception: exception,
    ));
  }

  static Result<T> validationError<T>(String message, String code) {
    return Result.failure(ValidationFailure(
      message: message,
      code: code,
    ));
  }

  static Result<T> storageError<T>(String message, String code, {Exception? exception}) {
    return Result.failure(StorageFailure(
      message: message,
      code: code,
      exception: exception,
    ));
  }

  static Result<T> aiError<T>(String message, String code, {Exception? exception}) {
    return Result.failure(AIFailure(
      message: message,
      code: code,
      exception: exception,
    ));
  }

  static Result<T> audioError<T>(String message, String code, {Exception? exception}) {
    return Result.failure(AudioFailure(
      message: message,
      code: code,
      exception: exception,
    ));
  }

  static Result<T> unknownError<T>(String message, {Exception? exception}) {
    return Result.failure(UnknownFailure(
      message: message,
      exception: exception,
    ));
  }
}
