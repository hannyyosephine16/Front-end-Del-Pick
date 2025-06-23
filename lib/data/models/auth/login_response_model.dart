// lib/data/models/auth/login_response_model.dart
import 'user_model.dart';
import '../driver/driver_model.dart';
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

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
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
}
