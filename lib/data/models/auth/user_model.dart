// lib/data/models/auth/user_model.dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? fcmToken;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.fcmToken,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      fcmToken: json['fcm_token'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'fcm_token': fcmToken,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? fcmToken,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      fcmToken: fcmToken ?? this.fcmToken,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isCustomer => role == 'customer';
  bool get isDriver => role == 'driver';
  bool get isStore => role == 'store';
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  bool get hasFcmToken => fcmToken != null && fcmToken!.isNotEmpty;

  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  String get displayName => name;
  String get displayRole {
    switch (role) {
      case 'customer':
        return 'Customer';
      case 'driver':
        return 'Driver';
      case 'store':
        return 'Store Owner';
      default:
        return role;
    }
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, role: $role}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
