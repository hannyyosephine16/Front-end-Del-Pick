// lib/core/errors/exceptions.dart

class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ConnectionException extends NetworkException {
  const ConnectionException() : super('No internet connection');
}

class TimeoutException extends NetworkException {
  const TimeoutException() : super('Request timed out');
}

// Authentication exceptions - sesuai dengan backend auth errors
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class UnauthorizedException extends AuthException {
  const UnauthorizedException() : super('Unauthorized access');
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException() : super('Token expired');
}

class ForbiddenException extends AuthException {
  const ForbiddenException() : super('Access denied');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Invalid email or password');
}

class AccountNotVerifiedException extends AuthException {
  const AccountNotVerifiedException() : super('Account not verified');
}

// Data exceptions
class DataException extends AppException {
  const DataException(super.message, {super.code});
}

class ValidationException extends DataException {
  final Map<String, List<String>>? errors;

  const ValidationException(super.message, {this.errors, super.code});
}

class NotFoundException extends DataException {
  const NotFoundException(super.message);
}

class AlreadyExistsException extends DataException {
  const AlreadyExistsException(super.message);
}

class DataParsingException extends DataException {
  const DataParsingException() : super('Failed to parse data');
}

// Location exceptions - uncommented dan diperbaiki
class LocationException extends AppException {
  const LocationException(super.message, {super.code});
}

class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException()
      : super('Location permission denied');
}

class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException()
      : super('Location service is disabled');
}

class LocationTimeoutException extends LocationException {
  const LocationTimeoutException() : super('Location request timed out');
}

// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message);
}

class CacheException extends StorageException {
  const CacheException(super.message);
}

class DatabaseException extends StorageException {
  const DatabaseException(super.message);
}

// File exceptions
class FileException extends AppException {
  const FileException(super.message);
}

class FileNotFoundException extends FileException {
  const FileNotFoundException(String path) : super('File not found: $path');
}

class FileSizeExceededException extends FileException {
  final int maxSizeMB;

  const FileSizeExceededException(this.maxSizeMB)
      : super('File size exceeds the maximum limit of $maxSizeMB MB');
}

class UnsupportedFileTypeException extends FileException {
  const UnsupportedFileTypeException(super.message);
}

// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(super.message);
}

class CameraPermissionDeniedException extends PermissionException {
  const CameraPermissionDeniedException() : super('Camera permission denied');
}

class StoragePermissionDeniedException extends PermissionException {
  const StoragePermissionDeniedException() : super('Storage permission denied');
}

class NotificationPermissionDeniedException extends PermissionException {
  const NotificationPermissionDeniedException()
      : super('Notification permission denied');
}

// Business logic exceptions - disesuaikan dengan backend
class BusinessLogicException extends AppException {
  const BusinessLogicException(super.message, {super.code});
}

// Order exceptions - sesuai dengan backend order handling
class OrderException extends BusinessLogicException {
  const OrderException(super.message, {super.code});
}

class OrderNotFoundException extends OrderException {
  const OrderNotFoundException() : super('Order not found');
}

class OrderCancellationException extends OrderException {
  const OrderCancellationException()
      : super('Order cannot be cancelled at this stage');
}

// Payment exceptions
class PaymentException extends BusinessLogicException {
  const PaymentException(super.message, {super.code});
}

class PaymentDeclinedException extends PaymentException {
  const PaymentDeclinedException() : super('Payment was declined');
}

class InsufficientFundsException extends PaymentException {
  const InsufficientFundsException() : super('Insufficient funds');
}

// Delivery exceptions - sesuai dengan backend tracking
class DeliveryException extends BusinessLogicException {
  const DeliveryException(super.message, {super.code});
}

class DriverNotFoundException extends DeliveryException {
  const DriverNotFoundException() : super('No driver available in your area');
}

class DriverBusyException extends DeliveryException {
  const DriverBusyException() : super('Driver is currently busy');
}

// Cart exceptions
class CartException extends BusinessLogicException {
  const CartException(super.message);
}

class EmptyCartException extends CartException {
  const EmptyCartException() : super('Your cart is empty');
}

class CartItemNotFoundException extends CartException {
  const CartItemNotFoundException() : super('Item not found in cart');
}

class StoreConflictException extends CartException {
  const StoreConflictException()
      : super('Cannot add items from different stores to cart');
}

class ItemOutOfStockException extends CartException {
  const ItemOutOfStockException(String itemName)
      : super('$itemName is out of stock');
}

// Store exceptions - disesuaikan dengan backend store logic
class StoreException extends BusinessLogicException {
  const StoreException(super.message, {super.code});
}

class StoreClosedException extends StoreException {
  const StoreClosedException(String storeName)
      : super('$storeName is currently closed');
}

class StoreNotFoundException extends StoreException {
  const StoreNotFoundException() : super('Store not found');
}

class MenuItemNotAvailableException extends StoreException {
  const MenuItemNotAvailableException(String itemName)
      : super('$itemName is currently not available');
}

// Driver exceptions - disesuaikan dengan backend driver logic
class DriverException extends BusinessLogicException {
  const DriverException(super.message, {super.code});
}

class DriverNotActiveException extends DriverException {
  const DriverNotActiveException() : super('Driver is not currently active');
}

class DriverRequestExpiredException extends DriverException {
  const DriverRequestExpiredException() : super('Driver request has expired');
}

// Rate limiting exception
class TooManyRequestsException extends NetworkException {
  const TooManyRequestsException()
      : super('Too many requests. Please try again later.');
}

// Server exceptions untuk handling 500+ errors
class ServerException extends AppException {
  final int statusCode;

  const ServerException(this.statusCode, super.message, {super.code});
}

class InternalServerException extends ServerException {
  const InternalServerException() : super(500, 'Internal server error');
}

class BadGatewayException extends ServerException {
  const BadGatewayException() : super(502, 'Bad gateway');
}

class ServiceUnavailableException extends ServerException {
  const ServiceUnavailableException() : super(503, 'Service unavailable');
}

class GatewayTimeoutException extends ServerException {
  const GatewayTimeoutException() : super(504, 'Gateway timeout');
}
