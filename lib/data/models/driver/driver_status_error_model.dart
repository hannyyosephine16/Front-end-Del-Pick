/// Model untuk error response dengan business rules
class DriverStatusErrorModel {
  final String message;
  final String businessRule;
  final Map<String, dynamic>? data;
  final int? waitTime;

  DriverStatusErrorModel({
    required this.message,
    required this.businessRule,
    this.data,
    this.waitTime,
  });

  factory DriverStatusErrorModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusErrorModel(
      message: json['message'] as String,
      businessRule: json['businessRule'] as String,
      data: json['data'] as Map<String, dynamic>?,
      waitTime: json['waitTime'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'businessRule': businessRule,
      'data': data,
      'waitTime': waitTime,
    };
  }

  // Business rule checks
  bool get isDeliveryBlocking =>
      businessRule == 'CANNOT_OFFLINE_DURING_DELIVERY';
  bool get isActiveOrdersBlocking =>
      businessRule == 'CANNOT_OFFLINE_WITH_ACTIVE_ORDERS';
  bool get isRateLimited => businessRule == 'STATUS_UPDATE_RATE_LIMIT';
  bool get isBusyStatusRestricted => businessRule == 'BUSY_STATUS_AUTO_ONLY';
  bool get isLocationRequired => businessRule == 'LOCATION_PERMISSION_REQUIRED';

  // User-friendly messages
  String get userFriendlyMessage {
    switch (businessRule) {
      case 'CANNOT_OFFLINE_DURING_DELIVERY':
        return 'Selesaikan pengantaran terlebih dahulu sebelum offline';

      case 'CANNOT_OFFLINE_WITH_ACTIVE_ORDERS':
        final count = data?['activeOrdersCount'] ?? 0;
        return 'Selesaikan $count pesanan aktif terlebih dahulu';

      case 'STATUS_UPDATE_RATE_LIMIT':
        return 'Tunggu ${waitTime ?? 30} detik sebelum mengubah status lagi';

      case 'BUSY_STATUS_AUTO_ONLY':
        return 'Status sibuk akan diatur otomatis saat menerima pesanan';

      case 'LOCATION_PERMISSION_REQUIRED':
        return 'Aktifkan izin lokasi untuk dapat online';

      default:
        return message;
    }
  }

  String get actionRequired {
    switch (businessRule) {
      case 'CANNOT_OFFLINE_DURING_DELIVERY':
        return 'Complete current delivery';

      case 'CANNOT_OFFLINE_WITH_ACTIVE_ORDERS':
        return 'Complete active orders';

      case 'STATUS_UPDATE_RATE_LIMIT':
        return 'Wait and try again';

      case 'LOCATION_PERMISSION_REQUIRED':
        return 'Enable location permission';

      default:
        return 'Check requirements';
    }
  }

  @override
  String toString() {
    return 'DriverStatusErrorModel{businessRule: $businessRule, message: $message}';
  }
}
