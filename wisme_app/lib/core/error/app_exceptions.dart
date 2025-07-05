/// Application-specific exceptions for error handling
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.originalError});
}

/// Server exceptions
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.originalError});
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.originalError});
}

/// Content generation exceptions
class ContentException extends AppException {
  const ContentException(super.message, {super.code, super.originalError});
}

/// User not found exception
class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('User not found');
}

/// Invalid credentials exception
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Invalid email or password');
}

/// Email already in use exception
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException() : super('Email is already in use');
}

/// Weak password exception
class WeakPasswordException extends AuthException {
  const WeakPasswordException() : super('Password is too weak');
}

/// No internet connection exception
class NoInternetException extends NetworkException {
  const NoInternetException() : super('No internet connection available');
}

/// Timeout exception
class TimeoutException extends NetworkException {
  const TimeoutException() : super('Request timed out');
}

/// Offline related exceptions
class OfflineException extends AppException {
  const OfflineException(super.message, {super.code, super.originalError});
}
