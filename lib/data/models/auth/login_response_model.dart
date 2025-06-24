import '../auth/user_model.dart'; // ✅ FIXED import path
import 'package:del_pick/data/models/driver/driver_model.dart';
import '../store/store_model.dart';
import 'package:del_pick/core/utils/parsing_helper.dart';

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

  // ✅ FIXED: Handle backend response structure correctly
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend returns: { message, data: { token, user, driver?, store? } }
    // But this fromJson receives only the 'data' part
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
  bool get isDriver => user.isDriver && hasDriver;
  bool get isStore => user.isStore && hasStore;
  bool get isCustomer => user.isCustomer;

  @override
  String toString() {
    return 'LoginResponseModel{token: ${token.substring(0, 10)}..., user: ${user.name}, role: ${user.role}}';
  }
}
