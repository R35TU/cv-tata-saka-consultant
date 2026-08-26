import '../../core/enums/app_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final AppRole role;
  final String? perusahaanId;
  final String? username;
  final String? nomorHp;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.perusahaanId,
    this.username,
    this.nomorHp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id, String email) {
    return UserModel(
      id: id,
      name: json['nama'] ?? json['name'] ?? 'Unknown',
      email: email, // Auth email
      role: AppRole.fromString(json['peran'] ?? 'client'),
      perusahaanId: json['perusahaan_id']?.toString(),
      username: json['username'],
      nomorHp: json['nomor_hp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': name,
      'peran': role.name,
      'perusahaan_id': perusahaanId,
      'username': username,
      'nomor_hp': nomorHp,
    };
  }
}
