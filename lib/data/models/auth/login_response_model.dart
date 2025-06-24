import '../auth/user_model.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';
import '../store/store_model.dart';

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

  /// Creates LoginResponseModel from backend response
  /// Backend returns: { message, data: { token, user, driver?, store? } }
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      store: json['store'] != null
          ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Creates LoginResponseModel from complete backend response (including message)
  factory LoginResponseModel.fromBackendResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return LoginResponseModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      if (driver != null) 'driver': driver!.toJson(),
      if (store != null) 'store': store!.toJson(),
    };
  }

  // Helper getters
  bool get hasDriver => driver != null;
  bool get hasStore => store != null;
  bool get isDriver => user.isDriver && hasDriver;
  bool get isStore => user.isStore && hasStore;
  bool get isCustomer => user.isCustomer;

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
    return 'LoginResponseModel{token: ${token.substring(0, 10)}..., user: ${user.name}, role: ${user.role}}';
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
