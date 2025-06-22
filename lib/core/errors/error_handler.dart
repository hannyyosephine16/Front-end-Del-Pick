// lib/core/errors/error_handler.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:del_pick/core/errors/exceptions.dart' as exceptions;
import 'package:del_pick/core/errors/failures.dart';

class ErrorHandler {
  // Convert exceptions to failures
  static Failure handleException(Exception exception) {
    if (kDebugMode) {
      debugPrint('ErrorHandler: ${exception.toString()}');
    }

    if (exception is DioException) {
      return _handleDioException(exception);
    } else if (exception is SocketException) {
      return const ConnectionFailure();
    } else if (exception is HttpException) {
      return ServerFailure(500, exception.message);
    } else if (exception is FormatException) {
      return const DataParsingFailure();
    } else if (exception is exceptions.AppException) {
      return _handleAppException(exception);
    } else {
      return const UnknownFailure();
    }
  }

  // Handle Dio exceptions - disesuaikan dengan backend response
  static Failure _handleDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const ConnectionFailure();

      case DioExceptionType.badResponse:
        return _handleResponseError(dioException);

      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled');

      case DioExceptionType.unknown:
      default:
        if (dioException.error is SocketException) {
          return const ConnectionFailure();
        }
        return const UnknownFailure();
    }
  }

  // Handle HTTP response errors - disesuaikan dengan backend error format
  static Failure _handleResponseError(DioException dioException) {
    final statusCode = dioException.response?.statusCode ?? 0;
    final data = dioException.response?.data;

    String message = 'An error occurred';
    String? code;
    Map<String, List<String>>? validationErrors;

    // Extract error information from backend response format
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;
      code = data['code']?.toString();

      // Handle validation errors - backend mengirim errors sebagai object atau string
      if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is Map<String, dynamic>) {
          validationErrors = <String, List<String>>{};
          errors.forEach((key, value) {
            if (value is List) {
              validationErrors![key] = value.cast<String>();
            } else if (value is String) {
              validationErrors![key] = [value];
            }
          });
        } else if (errors is String) {
          // Backend kadang mengirim errors sebagai string
          validationErrors = {
            'general': [errors]
          };
        }
      }
    }

    // Handle specific status codes sesuai dengan backend
    switch (statusCode) {
      case 400:
        if (validationErrors != null) {
          return ValidationFailure(message,
              errors: validationErrors, code: code);
        }
        return ValidationFailure(message, code: code);

      case 401:
        // Check if it's token related error
        if (message.toLowerCase().contains('token') ||
            message.toLowerCase().contains('unauthorized') ||
            message.toLowerCase().contains('expired')) {
          return const TokenExpiredFailure();
        }
        return const UnauthorizedFailure();

      case 403:
        return const ForbiddenFailure();

      case 404:
        return NotFoundFailure(message);

      case 409:
        return AlreadyExistsFailure(message);

      case 422:
        return ValidationFailure(message, errors: validationErrors, code: code);

      case 429:
        return const NetworkFailure(
            'Too many requests. Please try again later.');

      case 500:
        return ServerFailure(statusCode, 'Internal server error');

      case 502:
        return ServerFailure(statusCode, 'Bad gateway');

      case 503:
        return ServerFailure(statusCode, 'Service unavailable');

      case 504:
        return ServerFailure(statusCode, 'Gateway timeout');

      default:
        return ServerFailure(statusCode, message);
    }
  }

  // Handle app-specific exceptions
  static Failure _handleAppException(exceptions.AppException exception) {
    if (exception is exceptions.NetworkException) {
      return NetworkFailure(exception.message, code: exception.code);
    } else if (exception is exceptions.AuthException) {
      if (exception is exceptions.UnauthorizedException) {
        return const UnauthorizedFailure();
      } else if (exception is exceptions.ForbiddenException) {
        return const ForbiddenFailure();
      } else if (exception is exceptions.TokenExpiredException) {
        return const TokenExpiredFailure();
      } else if (exception is exceptions.InvalidCredentialsException) {
        return const InvalidCredentialsFailure();
      } else if (exception is exceptions.AccountNotVerifiedException) {
        return const AccountNotVerifiedFailure();
      }
      return AuthFailure(exception.message, code: exception.code);
    } else if (exception is exceptions.ValidationException) {
      return ValidationFailure(
        exception.message,
        errors: exception.errors,
        code: exception.code,
      );
    } else if (exception is exceptions.DataException) {
      if (exception is exceptions.NotFoundException) {
        return NotFoundFailure(exception.message);
      } else if (exception is exceptions.AlreadyExistsException) {
        return AlreadyExistsFailure(exception.message);
      } else if (exception is exceptions.DataParsingException) {
        return const DataParsingFailure();
      }
      return DataFailure(exception.message, code: exception.code);
    } else if (exception is exceptions.LocationException) {
      if (exception is exceptions.LocationPermissionDeniedException) {
        return const LocationPermissionDeniedFailure();
      } else if (exception is exceptions.LocationServiceDisabledException) {
        return const LocationServiceDisabledFailure();
      } else if (exception is exceptions.LocationTimeoutException) {
        return const LocationTimeoutFailure();
      }
      return LocationFailure(exception.message, code: exception.code);
    } else if (exception is exceptions.StorageException) {
      if (exception is exceptions.CacheException) {
        return CacheFailure(exception.message);
      } else if (exception is exceptions.DatabaseException) {
        return const DatabaseFailure();
      }
      return StorageFailure(exception.message);
    } else if (exception is exceptions.FileException) {
      if (exception is exceptions.FileNotFoundException) {
        return FileNotFoundFailure(exception.message);
      } else if (exception is exceptions.FileSizeExceededException) {
        return FileSizeExceededFailure(exception.maxSizeMB);
      } else if (exception is exceptions.UnsupportedFileTypeException) {
        return UnsupportedFileTypeFailure(exception.message);
      }
      return FileFailure(exception.message);
    } else if (exception is exceptions.PermissionException) {
      if (exception is exceptions.CameraPermissionDeniedException) {
        return const CameraPermissionDeniedFailure();
      } else if (exception is exceptions.StoragePermissionDeniedException) {
        return const StoragePermissionDeniedFailure();
      } else if (exception
          is exceptions.NotificationPermissionDeniedException) {
        return const NotificationPermissionDeniedFailure();
      }
      return PermissionFailure(exception.message);
    } else if (exception is exceptions.BusinessLogicException) {
      if (exception is exceptions.OrderException) {
        if (exception is exceptions.OrderNotFoundException) {
          return const OrderNotFoundFailure();
        } else if (exception is exceptions.OrderCancellationException) {
          return const OrderCancellationFailure();
        }
        return OrderFailure(exception.message, code: exception.code);
      } else if (exception is exceptions.PaymentException) {
        if (exception is exceptions.PaymentDeclinedException) {
          return const PaymentDeclinedFailure();
        } else if (exception is exceptions.InsufficientFundsException) {
          return const InsufficientFundsFailure();
        }
        return PaymentFailure(exception.message, code: exception.code);
      } else if (exception is exceptions.DeliveryException) {
        if (exception is exceptions.DriverNotFoundException) {
          return const DriverNotFoundFailure();
        }
        return DeliveryFailure(exception.message, code: exception.code);
      } else if (exception is exceptions.CartException) {
        if (exception is exceptions.EmptyCartException) {
          return const EmptyCartFailure();
        } else if (exception is exceptions.CartItemNotFoundException) {
          return const CartItemNotFoundFailure();
        } else if (exception is exceptions.StoreConflictException) {
          return const StoreConflictFailure();
        } else if (exception is exceptions.ItemOutOfStockException) {
          final itemName = exception.message.split(' is out of stock').first;
          return ItemOutOfStockFailure(itemName);
        }
        return CartFailure(exception.message);
      } else if (exception is exceptions.StoreException) {
        if (exception is exceptions.StoreClosedException) {
          final storeName =
              exception.message.split(' is currently closed').first;
          return StoreClosedFailure(storeName);
        } else if (exception is exceptions.StoreNotFoundException) {
          return const StoreNotFoundFailure();
        } else if (exception is exceptions.MenuItemNotAvailableException) {
          final itemName =
              exception.message.split(' is currently not available').first;
          return MenuItemNotAvailableFailure(itemName);
        }
        return StoreFailure(exception.message);
      } else if (exception is exceptions.DriverException) {
        if (exception is exceptions.DriverNotActiveException) {
          return const DriverNotActiveFailure();
        } else if (exception is exceptions.DriverBusyException) {
          return const DriverBusyFailure();
        }
        return DriverFailure(exception.message);
      }
      return BusinessLogicFailure(exception.message, code: exception.code);
    } else if (exception is exceptions.ServerException) {
      return ServerFailure(exception.statusCode, exception.message);
    }

    return Failure(exception.message, code: exception.code);
  }

  // Get user-friendly error message - disesuaikan dengan bahasa Indonesia
  static String getErrorMessage(Failure failure) {
    if (failure is ConnectionFailure) {
      return 'Tidak ada koneksi internet. Periksa pengaturan jaringan Anda.';
    } else if (failure is TimeoutFailure) {
      return 'Permintaan timeout. Silakan coba lagi.';
    } else if (failure is UnauthorizedFailure) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (failure is TokenExpiredFailure) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (failure is ForbiddenFailure) {
      return 'Anda tidak memiliki izin untuk melakukan tindakan ini.';
    } else if (failure is ValidationFailure) {
      // Return the first validation error
      if (failure.errors != null && failure.errors!.isNotEmpty) {
        final firstError = failure.errors!.values.first;
        if (firstError.isNotEmpty) {
          return firstError.first;
        }
      }
      return failure.message;
    } else if (failure is ServerFailure) {
      if (failure.statusCode >= 500) {
        return 'Terjadi kesalahan server. Silakan coba lagi nanti.';
      }
      return failure.message;
    } else if (failure is OrderNotFoundFailure) {
      return 'Pesanan tidak ditemukan.';
    } else if (failure is DriverNotFoundFailure) {
      return 'Tidak ada driver yang tersedia di area Anda.';
    } else if (failure is StoreClosedFailure) {
      return failure.message;
    } else if (failure is EmptyCartFailure) {
      return 'Keranjang kosong. Tambahkan item untuk melanjutkan.';
    }

    return failure.message;
  }

  // Check if error is recoverable (user can retry)
  static bool isRecoverable(Failure failure) {
    return failure is TimeoutFailure ||
        failure is ConnectionFailure ||
        failure is ServerFailure ||
        failure is NetworkFailure;
  }

  // Check if error requires authentication
  static bool requiresAuth(Failure failure) {
    return failure is UnauthorizedFailure ||
        failure is TokenExpiredFailure ||
        failure is ForbiddenFailure;
  }

  // Check if error is business logic related
  static bool isBusinessLogicError(Failure failure) {
    return failure is BusinessLogicFailure ||
        failure is OrderFailure ||
        failure is PaymentFailure ||
        failure is DeliveryFailure ||
        failure is CartFailure ||
        failure is StoreFailure ||
        failure is DriverFailure;
  }

  // Get error category for analytics
  static String getErrorCategory(Failure failure) {
    if (failure is NetworkFailure ||
        failure is ConnectionFailure ||
        failure is TimeoutFailure) {
      return 'network';
    } else if (failure is AuthFailure ||
        failure is UnauthorizedFailure ||
        failure is ForbiddenFailure) {
      return 'authentication';
    } else if (failure is ValidationFailure) {
      return 'validation';
    } else if (failure is BusinessLogicFailure) {
      return 'business_logic';
    } else if (failure is ServerFailure) {
      return 'server';
    } else {
      return 'unknown';
    }
  }

  // Log error for debugging
  static void logError(Object error, StackTrace stackTrace,
      {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');
      if (context != null) {
        debugPrint('Context: $context');
      }
    }

    // In production, you might want to send errors to a crash reporting service
    // like Firebase Crashlytics or Sentry
  }
}
