import 'package:del_pick/Models/driver.dart';
import 'package:del_pick/data/models/driver/driver_model.dart';

import '../../../Models/store.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DriverModel? driver;
  final StoreModel? store;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.store,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'driver': driver?.toJson(),
      'store': store?.toJson(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    DriverModel? driver,
    StoreModel? store,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driver: driver ?? this.driver,
      store: store ?? this.store,
    );
  }

  bool get isCustomer => role == 'customer';
  bool get isDriver => role == 'driver';
  bool get isStore => role == 'store';
  bool get isAdmin => role == 'admin';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, role: $role}';
  }
}
