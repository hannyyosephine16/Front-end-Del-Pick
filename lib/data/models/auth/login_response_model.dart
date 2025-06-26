// lib/data/models/auth/login_response_model.dart - SESUAI BACKEND
import 'package:del_pick/data/models/auth/user_model.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import 'package:del_pick/data/models/store/store_model.dart';

class LoginResponseModel {
  final String token;
  final UserModel user;
  final DriverModel? driver;
  final StoreModel? store;

  LoginResponseModel({
    required this.token,
    required this.user,
    this.driver,
    this.store,
  });

  // ✅ Factory untuk backend DelPick response format
  factory LoginResponseModel.fromBackendResponse(Map<String, dynamic> json) {
    // Backend DelPick format: { token, user, driver?, store? }
    return LoginResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      store: json['store'] != null
          ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  // ✅ Alternative factory untuk format lain
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel.fromBackendResponse(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'driver': driver?.toJson(),
      'store': store?.toJson(),
    };
  }

  // Helper getters
  bool get hasDriver => driver != null;
  bool get hasStore => store != null;

  String get userRole => user.role;
  bool get isCustomer => user.role == 'customer';
  bool get isDriver => user.role == 'driver';
  bool get isStore => user.role == 'store';

  /// Returns the appropriate role-specific data
  Map<String, dynamic>? get roleSpecificData {
    if (isDriver) return driver?.toJson();
    if (isStore) return store?.toJson();
    return null;
  }

  /// Returns display name based on role
  String get displayName {
    if (isStore && store != null) return store!.name;
    return user.name;
  }

  /// Returns phone number from role-specific data if available
  String? get phone {
    if (isStore && store != null) return store!.phone;
    if (isDriver) return user.phone; // Driver phone is in user data
    return user.phone;
  }

  /// Returns phone number with fallback to empty string
  String get phoneOrEmpty {
    return phone ?? '';
  }

  /// Returns phone number with custom fallback
  String phoneWithFallback(String fallback) {
    return phone ?? fallback;
  }

  @override
  String toString() {
    return 'LoginResponseModel{token: ${token.substring(0, 20)}..., user: ${user.name}, role: ${user.role}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponseModel &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          user == other.user &&
          driver == other.driver &&
          store == other.store;

  @override
  int get hashCode =>
      token.hashCode ^ user.hashCode ^ driver.hashCode ^ store.hashCode;
}
