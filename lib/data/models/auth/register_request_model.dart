// lib/data/models/auth/register_request_model.dart
class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    };
  }
}
