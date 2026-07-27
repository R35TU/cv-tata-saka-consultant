import '../../../../core/enums/app_role.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String password;
  final AppRole role;
  final String email;
  final String phone;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    required this.email,
    required this.phone,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: AppRole.fromString(json['role'] as String),
      email: json['email'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'password': password,
        'role': role.name,
        'email': email,
        'phone': phone,
        'isActive': isActive,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    AppRole? role,
    String? email,
    String? phone,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}
