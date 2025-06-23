// lib/data/models/auth/profile_update_model.dart
class ProfileUpdateModel {
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? fcmToken;

  ProfileUpdateModel({
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (avatar != null) data['avatar'] = avatar;
    if (fcmToken != null) data['fcm_token'] = fcmToken;

    return data;
  }
}
