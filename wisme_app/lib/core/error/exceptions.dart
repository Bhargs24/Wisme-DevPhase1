/// Base exception class for all Wisme app exceptions
abstract class WismeException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  const WismeException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() => 'WismeException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication-related exceptions
class AuthException extends WismeException {
  const AuthException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory AuthException.userNotFound() => const AuthException(
    'User not found',
    code: 'user-not-found',
  );
  
  factory AuthException.wrongPassword() => const AuthException(
    'Wrong password',
    code: 'wrong-password',
  );
  
  factory AuthException.emailAlreadyInUse() => const AuthException(
    'Email already in use',
    code: 'email-already-in-use',
  );
  
  factory AuthException.weakPassword() => const AuthException(
    'Password is too weak',
    code: 'weak-password',
  );
  
  factory AuthException.invalidEmail() => const AuthException(
    'Invalid email address',
    code: 'invalid-email',
  );
  
  factory AuthException.accountDisabled() => const AuthException(
    'Account has been disabled',
    code: 'account-disabled',
  );
  
  factory AuthException.biometricNotAvailable() => const AuthException(
    'Biometric authentication not available',
    code: 'biometric-not-available',
  );
}

/// Network-related exceptions
class NetworkException extends WismeException {
  const NetworkException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory NetworkException.noConnection() => const NetworkException(
    'No internet connection',
    code: 'no-connection',
  );
  
  factory NetworkException.timeout() => const NetworkException(
    'Request timeout',
    code: 'timeout',
  );
  
  factory NetworkException.serverError() => const NetworkException(
    'Server error',
    code: 'server-error',
  );
  
  factory NetworkException.badRequest() => const NetworkException(
    'Bad request',
    code: 'bad-request',
  );
  
  factory NetworkException.unauthorized() => const NetworkException(
    'Unauthorized access',
    code: 'unauthorized',
  );
  
  factory NetworkException.forbidden() => const NetworkException(
    'Forbidden access',
    code: 'forbidden',
  );
  
  factory NetworkException.notFound() => const NetworkException(
    'Resource not found',
    code: 'not-found',
  );
}

/// Data-related exceptions
class DataException extends WismeException {
  const DataException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory DataException.notFound(String resourceType) => DataException(
    '$resourceType not found',
    code: 'data-not-found',
  );
  
  factory DataException.saveFailed(String resourceType) => DataException(
    'Failed to save $resourceType',
    code: 'save-failed',
  );
  
  factory DataException.loadFailed(String resourceType) => DataException(
    'Failed to load $resourceType',
    code: 'load-failed',
  );
  
  factory DataException.deleteFailed(String resourceType) => DataException(
    'Failed to delete $resourceType',
    code: 'delete-failed',
  );
  
  factory DataException.validation(String field) => DataException(
    'Validation error for $field',
    code: 'validation-error',
  );
  
  factory DataException.duplicate(String resourceType) => DataException(
    '$resourceType already exists',
    code: 'duplicate',
  );
}

/// Audio-related exceptions
class AudioException extends WismeException {
  const AudioException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory AudioException.playbackFailed() => const AudioException(
    'Audio playback failed',
    code: 'playback-failed',
  );
  
  factory AudioException.generationFailed() => const AudioException(
    'Audio generation failed',
    code: 'generation-failed',
  );
  
  factory AudioException.downloadFailed() => const AudioException(
    'Audio download failed',
    code: 'download-failed',
  );
  
  factory AudioException.uploadFailed() => const AudioException(
    'Audio upload failed',
    code: 'upload-failed',
  );
  
  factory AudioException.unsupportedFormat() => const AudioException(
    'Unsupported audio format',
    code: 'unsupported-format',
  );
  
  factory AudioException.storagePermissionDenied() => const AudioException(
    'Storage permission denied',
    code: 'storage-permission-denied',
  );
}

/// Learning-related exceptions
class LearningException extends WismeException {
  const LearningException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory LearningException.sessionNotFound() => const LearningException(
    'Learning session not found',
    code: 'session-not-found',
  );
  
  factory LearningException.lessonNotAvailable() => const LearningException(
    'Lesson not available',
    code: 'lesson-not-available',
  );
  
  factory LearningException.progressSaveFailed() => const LearningException(
    'Failed to save learning progress',
    code: 'progress-save-failed',
  );
  
  factory LearningException.prerequisiteNotMet() => const LearningException(
    'Prerequisite not met',
    code: 'prerequisite-not-met',
  );
  
  factory LearningException.contentLocked() => const LearningException(
    'Content is locked',
    code: 'content-locked',
  );
}

/// Coach-related exceptions
class CoachException extends WismeException {
  const CoachException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory CoachException.aiServiceUnavailable() => const CoachException(
    'AI service is currently unavailable',
    code: 'ai-service-unavailable',
  );
  
  factory CoachException.conversationFailed() => const CoachException(
    'Failed to process conversation',
    code: 'conversation-failed',
  );
  
  factory CoachException.coachNotFound() => const CoachException(
    'Coach not found',
    code: 'coach-not-found',
  );
  
  factory CoachException.sessionExpired() => const CoachException(
    'Coaching session expired',
    code: 'session-expired',
  );
  
  factory CoachException.rateLimitExceeded() => const CoachException(
    'Rate limit exceeded for AI requests',
    code: 'rate-limit-exceeded',
  );
}

/// Storage-related exceptions
class StorageException extends WismeException {
  const StorageException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory StorageException.uploadFailed() => const StorageException(
    'File upload failed',
    code: 'upload-failed',
  );
  
  factory StorageException.downloadFailed() => const StorageException(
    'File download failed',
    code: 'download-failed',
  );
  
  factory StorageException.deleteFailed() => const StorageException(
    'File deletion failed',
    code: 'delete-failed',
  );
  
  factory StorageException.insufficientSpace() => const StorageException(
    'Insufficient storage space',
    code: 'insufficient-space',
  );
  
  factory StorageException.permissionDenied() => const StorageException(
    'Storage permission denied',
    code: 'permission-denied',
  );
  
  factory StorageException.fileNotFound() => const StorageException(
    'File not found',
    code: 'file-not-found',
  );
}

/// Analytics-related exceptions
class AnalyticsException extends WismeException {
  const AnalyticsException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory AnalyticsException.trackingFailed() => const AnalyticsException(
    'Failed to track event',
    code: 'tracking-failed',
  );
  
  factory AnalyticsException.insightsGenerationFailed() => const AnalyticsException(
    'Failed to generate insights',
    code: 'insights-generation-failed',
  );
  
  factory AnalyticsException.dataProcessingFailed() => const AnalyticsException(
    'Failed to process analytics data',
    code: 'data-processing-failed',
  );
}

/// Payment-related exceptions
class PaymentException extends WismeException {
  const PaymentException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory PaymentException.paymentFailed() => const PaymentException(
    'Payment failed',
    code: 'payment-failed',
  );
  
  factory PaymentException.paymentCancelled() => const PaymentException(
    'Payment was cancelled',
    code: 'payment-cancelled',
  );
  
  factory PaymentException.subscriptionExpired() => const PaymentException(
    'Subscription has expired',
    code: 'subscription-expired',
  );
  
  factory PaymentException.invalidPaymentMethod() => const PaymentException(
    'Invalid payment method',
    code: 'invalid-payment-method',
  );
  
  factory PaymentException.insufficientFunds() => const PaymentException(
    'Insufficient funds',
    code: 'insufficient-funds',
  );
}

/// Validation-related exceptions
class ValidationException extends WismeException {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationException(
    String message, {
    String? code,
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory ValidationException.field(String field, String error) => ValidationException(
    'Validation error for $field: $error',
    code: 'field-validation',
    fieldErrors: {field: [error]},
  );
  
  factory ValidationException.multiple(Map<String, List<String>> errors) => ValidationException(
    'Multiple validation errors',
    code: 'multiple-validation',
    fieldErrors: errors,
  );
  
  factory ValidationException.required(String field) => ValidationException(
    '$field is required',
    code: 'required-field',
    fieldErrors: {field: ['This field is required']},
  );
  
  factory ValidationException.format(String field, String expectedFormat) => ValidationException(
    '$field format is invalid. Expected: $expectedFormat',
    code: 'invalid-format',
    fieldErrors: {field: ['Invalid format. Expected: $expectedFormat']},
  );
}

/// Permission-related exceptions
class PermissionException extends WismeException {
  const PermissionException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, code: code, originalError: originalError, stackTrace: stackTrace);
  
  factory PermissionException.cameraPermissionDenied() => const PermissionException(
    'Camera permission denied',
    code: 'camera-permission-denied',
  );
  
  factory PermissionException.microphonePermissionDenied() => const PermissionException(
    'Microphone permission denied',
    code: 'microphone-permission-denied',
  );
  
  factory PermissionException.storagePermissionDenied() => const PermissionException(
    'Storage permission denied',
    code: 'storage-permission-denied',
  );
  
  factory PermissionException.locationPermissionDenied() => const PermissionException(
    'Location permission denied',
    code: 'location-permission-denied',
  );
  
  factory PermissionException.notificationPermissionDenied() => const PermissionException(
    'Notification permission denied',
    code: 'notification-permission-denied',
  );
}
