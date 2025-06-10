// lib/core/utils/result.dart
class Result<T> {
  final T? data;
  final String? message;
  final bool isSuccess;
  final String? error;

  Result._({
    this.data,
    this.message,
    required this.isSuccess,
    this.error,
  });

  factory Result.success(T data, [String? message]) {
    return Result._(
      data: data,
      message: message,
      isSuccess: true,
    );
  }

  factory Result.failure(String error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  bool get isFailure => !isSuccess;

  T get value {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception('Tried to get value from failed result');
  }

  String get errorMessage => error ?? 'Unknown error';

  // Helper methods for handling results
  R fold<R>(
    R Function(String error) onFailure,
    R Function(T data) onSuccess,
  ) {
    if (isSuccess && data != null) {
      return onSuccess(data!);
    } else {
      return onFailure(error ?? 'Unknown error');
    }
  }

  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return Result.success(mapper(data!), message);
      } catch (e) {
        return Result.failure(e.toString());
      }
    } else {
      return Result.failure(error ?? 'Unknown error');
    }
  }

  Future<Result<R>> asyncMap<R>(Future<R> Function(T data) mapper) async {
    if (isSuccess && data != null) {
      try {
        final result = await mapper(data!);
        return Result.success(result, message);
      } catch (e) {
        return Result.failure(e.toString());
      }
    } else {
      return Result.failure(error ?? 'Unknown error');
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success(data: $data, message: $message)';
    } else {
      return 'Result.failure(error: $error)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other.data == data &&
        other.message == message &&
        other.isSuccess == isSuccess &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(data, message, isSuccess, error);
  }
}
