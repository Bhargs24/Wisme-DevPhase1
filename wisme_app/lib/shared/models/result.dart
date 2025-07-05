/// Result type for handling success and failure states
/// 
/// A functional approach to error handling that avoids exceptions
library;

sealed class Result<T> {
  const Result();

  /// Create a success result
  const factory Result.success(T data) = Success<T>;

  /// Create a failure result
  const factory Result.failure(Exception error) = Failure<T>;

  /// Create a failure result with a message
  factory Result.error(String message) = _ErrorResult<T>;

  /// Check if this result is a success
  bool get isSuccess => this is Success<T>;

  /// Check if this result is a failure
  bool get isFailure => this is Failure<T>;

  /// Get the data if success, otherwise return null
  T? get data => switch (this) {
    Success<T> success => success.data,
    Failure<T> _ => null,
  };

  /// Get the error if failure, otherwise return null
  Exception? get error => switch (this) {
    Success<T> _ => null,
    Failure<T> failure => failure.error,
  };

  /// Transform the success value
  Result<U> map<U>(U Function(T) transform) {
    return switch (this) {
      Success<T> success => Result.success(transform(success.data)),
      Failure<T> failure => Result.failure(failure.error),
    };
  }

  /// Transform the failure error
  Result<T> mapError(Exception Function(Exception) transform) {
    return switch (this) {
      Success<T> success => success,
      Failure<T> failure => Result.failure(transform(failure.error)),
    };
  }

  /// Chain operations on success
  Result<U> flatMap<U>(Result<U> Function(T) transform) {
    return switch (this) {
      Success<T> success => transform(success.data),
      Failure<T> failure => Result.failure(failure.error),
    };
  }

  /// Execute a function if success
  Result<T> onSuccess(void Function(T) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Execute a function if failure
  Result<T> onFailure(void Function(Exception) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).error);
    }
    return this;
  }

  /// Get the value or throw the error
  T getOrThrow() {
    return switch (this) {
      Success<T> success => success.data,
      Failure<T> failure => throw failure.error,
    };
  }

  /// Get the value or return a default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T> success => success.data,
      Failure<T> _ => defaultValue,
    };
  }
}

/// Success result
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T> && data == other.data);
  }

  @override
  int get hashCode => data.hashCode;
}

/// Failure result
final class Failure<T> extends Result<T> {
  final Exception error;

  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Failure<T> && error == other.error);
  }

  @override
  int get hashCode => error.hashCode;
}

/// Error result with message
final class _ErrorResult<T> extends Result<T> implements Failure<T> {
  @override
  final Exception error;

  _ErrorResult(String message) : error = Exception(message);

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _ErrorResult<T> && error.toString() == other.error.toString());
  }

  @override
  int get hashCode => error.toString().hashCode;
}

/// Extension methods for Future<Result<T>>
extension ResultFuture<T> on Future<Result<T>> {
  /// Transform the success value asynchronously
  Future<Result<U>> mapAsync<U>(Future<U> Function(T) transform) async {
    final result = await this;
    return switch (result) {
      Success<T> success => Result.success(await transform(success.data)),
      Failure<T> failure => Result.failure(failure.error),
    };
  }

  /// Chain async operations on success
  Future<Result<U>> flatMapAsync<U>(Future<Result<U>> Function(T) transform) async {
    final result = await this;
    return switch (result) {
      Success<T> success => await transform(success.data),
      Failure<T> failure => Result.failure(failure.error),
    };
  }
}
