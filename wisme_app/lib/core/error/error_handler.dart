import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'exceptions.dart';

/// Error handling result
class ErrorResult {
  final String userMessage;
  final String? technicalMessage;
  final String? code;
  final ErrorSeverity severity;
  final bool shouldReport;
  final Map<String, dynamic>? context;
  
  const ErrorResult({
    required this.userMessage,
    this.technicalMessage,
    this.code,
    required this.severity,
    required this.shouldReport,
    this.context,
  });
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Centralized error handling service
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();
  
  // Error reporting callbacks
  void Function(WismeException exception, StackTrace? stackTrace)? _onError;
  void Function(String message, ErrorSeverity severity)? _onUserMessage;
  
  /// Initialize error handler with callbacks
  void initialize({
    void Function(WismeException exception, StackTrace? stackTrace)? onError,
    void Function(String message, ErrorSeverity severity)? onUserMessage,
  }) {
    _onError = onError;
    _onUserMessage = onUserMessage;
  }
  
  /// Handle any error and return user-friendly result
  ErrorResult handleError(dynamic error, [StackTrace? stackTrace]) {
    late final ErrorResult result;
    
    if (error is WismeException) {
      result = _handleWismeException(error, stackTrace);
    } else {
      result = _handleGenericError(error, stackTrace);
    }
    
    // Log error
    _logError(error, stackTrace, result);
    
    // Report error if needed
    if (result.shouldReport && _onError != null) {
      final wismeException = error is WismeException 
          ? error 
          : DataException('Unexpected error: ${error.toString()}', originalError: error);
      _onError!(wismeException, stackTrace);
    }
    
    // Show user message if callback is set
    if (_onUserMessage != null) {
      _onUserMessage!(result.userMessage, result.severity);
    }
    
    return result;
  }
  
  /// Handle WismeException specifically
  ErrorResult _handleWismeException(WismeException exception, StackTrace? stackTrace) {
    switch (exception.runtimeType) {
      case AuthException:
        return _handleAuthException(exception as AuthException);
      case NetworkException:
        return _handleNetworkException(exception as NetworkException);
      case DataException:
        return _handleDataException(exception as DataException);
      case AudioException:
        return _handleAudioException(exception as AudioException);
      case LearningException:
        return _handleLearningException(exception as LearningException);
      case CoachException:
        return _handleCoachException(exception as CoachException);
      case StorageException:
        return _handleStorageException(exception as StorageException);
      case AnalyticsException:
        return _handleAnalyticsException(exception as AnalyticsException);
      case PaymentException:
        return _handlePaymentException(exception as PaymentException);
      case ValidationException:
        return _handleValidationException(exception as ValidationException);
      case PermissionException:
        return _handlePermissionException(exception as PermissionException);
      default:
        return _handleGenericWismeException(exception);
    }
  }
  
  /// Handle authentication exceptions
  ErrorResult _handleAuthException(AuthException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.medium;
    
    switch (exception.code) {
      case 'user-not-found':
        userMessage = 'No account found with this email address.';
        break;
      case 'wrong-password':
        userMessage = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        userMessage = 'An account with this email already exists.';
        break;
      case 'weak-password':
        userMessage = 'Password is too weak. Please choose a stronger password.';
        break;
      case 'invalid-email':
        userMessage = 'Please enter a valid email address.';
        break;
      case 'account-disabled':
        userMessage = 'Your account has been disabled. Please contact support.';
        severity = ErrorSeverity.high;
        break;
      case 'biometric-not-available':
        userMessage = 'Biometric authentication is not available on this device.';
        break;
      default:
        userMessage = 'Authentication failed. Please try again.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: severity == ErrorSeverity.high,
    );
  }
  
  /// Handle network exceptions
  ErrorResult _handleNetworkException(NetworkException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.medium;
    
    switch (exception.code) {
      case 'no-connection':
        userMessage = 'No internet connection. Please check your network settings.';
        break;
      case 'timeout':
        userMessage = 'Request timed out. Please try again.';
        break;
      case 'server-error':
        userMessage = 'Server error. Please try again later.';
        severity = ErrorSeverity.high;
        break;
      case 'unauthorized':
        userMessage = 'Session expired. Please log in again.';
        break;
      case 'forbidden':
        userMessage = 'Access denied. You don\'t have permission for this action.';
        break;
      case 'not-found':
        userMessage = 'Requested resource not found.';
        break;
      default:
        userMessage = 'Network error. Please check your connection and try again.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: severity == ErrorSeverity.high,
    );
  }
  
  /// Handle data exceptions
  ErrorResult _handleDataException(DataException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.medium;
    
    switch (exception.code) {
      case 'data-not-found':
        userMessage = 'Requested data not found.';
        break;
      case 'save-failed':
        userMessage = 'Failed to save data. Please try again.';
        break;
      case 'load-failed':
        userMessage = 'Failed to load data. Please try again.';
        break;
      case 'delete-failed':
        userMessage = 'Failed to delete data. Please try again.';
        break;
      case 'validation-error':
        userMessage = 'Invalid data format. Please check your input.';
        break;
      case 'duplicate':
        userMessage = 'This item already exists.';
        break;
      default:
        userMessage = 'Data operation failed. Please try again.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: severity == ErrorSeverity.high,
    );
  }
  
  /// Handle audio exceptions
  ErrorResult _handleAudioException(AudioException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.medium;
    
    switch (exception.code) {
      case 'playback-failed':
        userMessage = 'Audio playback failed. Please try again.';
        break;
      case 'generation-failed':
        userMessage = 'Failed to generate audio. Please try again.';
        break;
      case 'download-failed':
        userMessage = 'Failed to download audio. Please check your connection.';
        break;
      case 'upload-failed':
        userMessage = 'Failed to upload audio. Please try again.';
        break;
      case 'unsupported-format':
        userMessage = 'Audio format not supported.';
        break;
      case 'storage-permission-denied':
        userMessage = 'Storage permission required for audio features.';
        break;
      default:
        userMessage = 'Audio operation failed. Please try again.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: false,
    );
  }
  
  /// Handle learning exceptions
  ErrorResult _handleLearningException(LearningException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.medium;
    
    switch (exception.code) {
      case 'session-not-found':
        userMessage = 'Learning session not found.';
        break;
      case 'lesson-not-available':
        userMessage = 'This lesson is not available yet.';
        break;
      case 'progress-save-failed':
        userMessage = 'Failed to save your progress. Please try again.';
        break;
      case 'prerequisite-not-met':
        userMessage = 'Please complete the prerequisite lessons first.';
        break;
      case 'content-locked':
        userMessage = 'This content is locked. Upgrade to access it.';
        break;
      default:
        userMessage = 'Learning operation failed. Please try again.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: false,
    );
  }
  
  /// Handle coach exceptions
  ErrorResult _handleCoachException(CoachException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.medium;
    
    switch (exception.code) {
      case 'ai-service-unavailable':
        userMessage = 'AI coach is temporarily unavailable. Please try again later.';
        severity = ErrorSeverity.high;
        break;
      case 'conversation-failed':
        userMessage = 'Failed to process conversation. Please try again.';
        break;
      case 'coach-not-found':
        userMessage = 'Coach not found.';
        break;
      case 'session-expired':
        userMessage = 'Your coaching session has expired. Please start a new session.';
        break;
      case 'rate-limit-exceeded':
        userMessage = 'Too many requests. Please wait a moment and try again.';
        break;
      default:
        userMessage = 'Coach operation failed. Please try again.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: severity == ErrorSeverity.high,
    );
  }
  
  /// Handle storage exceptions
  ErrorResult _handleStorageException(StorageException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.medium;
    
    switch (exception.code) {
      case 'upload-failed':
        userMessage = 'File upload failed. Please try again.';
        break;
      case 'download-failed':
        userMessage = 'File download failed. Please check your connection.';
        break;
      case 'delete-failed':
        userMessage = 'File deletion failed. Please try again.';
        break;
      case 'insufficient-space':
        userMessage = 'Insufficient storage space. Please free up some space.';
        break;
      case 'permission-denied':
        userMessage = 'Storage permission required.';
        break;
      case 'file-not-found':
        userMessage = 'File not found.';
        break;
      default:
        userMessage = 'Storage operation failed. Please try again.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: false,
    );
  }
  
  /// Handle analytics exceptions
  ErrorResult _handleAnalyticsException(AnalyticsException exception) {
    return ErrorResult(
      userMessage: 'Analytics tracking failed. This won\'t affect your experience.',
      technicalMessage: exception.message,
      code: exception.code,
      severity: ErrorSeverity.low,
      shouldReport: false,
    );
  }
  
  /// Handle payment exceptions
  ErrorResult _handlePaymentException(PaymentException exception) {
    String userMessage;
    ErrorSeverity severity = ErrorSeverity.high;
    
    switch (exception.code) {
      case 'payment-failed':
        userMessage = 'Payment failed. Please try again or use a different payment method.';
        break;
      case 'payment-cancelled':
        userMessage = 'Payment was cancelled.';
        severity = ErrorSeverity.low;
        break;
      case 'subscription-expired':
        userMessage = 'Your subscription has expired. Please renew to continue.';
        break;
      case 'invalid-payment-method':
        userMessage = 'Invalid payment method. Please update your payment information.';
        break;
      case 'insufficient-funds':
        userMessage = 'Insufficient funds. Please use a different payment method.';
        break;
      default:
        userMessage = 'Payment error. Please contact support if this continues.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: severity,
      shouldReport: severity == ErrorSeverity.high,
    );
  }
  
  /// Handle validation exceptions
  ErrorResult _handleValidationException(ValidationException exception) {
    String userMessage = exception.message;
    
    if (exception.fieldErrors != null && exception.fieldErrors!.isNotEmpty) {
      final firstError = exception.fieldErrors!.values.first.first;
      userMessage = firstError;
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: ErrorSeverity.low,
      shouldReport: false,
      context: {'fieldErrors': exception.fieldErrors},
    );
  }
  
  /// Handle permission exceptions
  ErrorResult _handlePermissionException(PermissionException exception) {
    String userMessage;
    
    switch (exception.code) {
      case 'camera-permission-denied':
        userMessage = 'Camera permission is required for this feature.';
        break;
      case 'microphone-permission-denied':
        userMessage = 'Microphone permission is required for this feature.';
        break;
      case 'storage-permission-denied':
        userMessage = 'Storage permission is required for this feature.';
        break;
      case 'location-permission-denied':
        userMessage = 'Location permission is required for this feature.';
        break;
      case 'notification-permission-denied':
        userMessage = 'Notification permission is required for this feature.';
        break;
      default:
        userMessage = 'Permission required for this feature.';
    }
    
    return ErrorResult(
      userMessage: userMessage,
      technicalMessage: exception.message,
      code: exception.code,
      severity: ErrorSeverity.medium,
      shouldReport: false,
    );
  }
  
  /// Handle generic WismeException
  ErrorResult _handleGenericWismeException(WismeException exception) {
    return ErrorResult(
      userMessage: 'An error occurred. Please try again.',
      technicalMessage: exception.message,
      code: exception.code,
      severity: ErrorSeverity.medium,
      shouldReport: true,
    );
  }
  
  /// Handle generic errors
  ErrorResult _handleGenericError(dynamic error, StackTrace? stackTrace) {
    return ErrorResult(
      userMessage: 'An unexpected error occurred. Please try again.',
      technicalMessage: error.toString(),
      code: 'unexpected-error',
      severity: ErrorSeverity.high,
      shouldReport: true,
      context: {'originalError': error.toString()},
    );
  }
  
  /// Log error for debugging
  void _logError(dynamic error, StackTrace? stackTrace, ErrorResult result) {
    if (kDebugMode) {
      developer.log(
        'Error: ${result.technicalMessage ?? error.toString()}',
        name: 'Wisme.ErrorHandler',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Quick error handling for futures
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    bool suppressErrors = false,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      if (!suppressErrors) {
        ErrorHandler().handleError(error, stackTrace);
      }
      return defaultValue;
    }
  }
  
  /// Quick error handling for synchronous operations
  static T? handleSync<T>(
    T Function() operation, {
    T? defaultValue,
    bool suppressErrors = false,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      if (!suppressErrors) {
        ErrorHandler().handleError(error, stackTrace);
      }
      return defaultValue;
    }
  }
}
