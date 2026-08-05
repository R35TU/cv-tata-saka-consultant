import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/enums/app_role.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/database/hive_database_service.dart';
import '../../../../core/database/hive_models.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> init();
  Future<UserModel?> getCurrentUser();
  Future<void> saveSession(UserModel user, {required bool rememberMe});
  Future<void> clearSession();
  Future<UserModel?> login(String username, String password);
  Future<void> seedUsers();
  Future<void> updateUserName(String userId, String newName);
  Future<void> changePassword(String userId, String currentPassword, String newPassword);
  Future<List<UserModel>> getAllUsers();
  Future<void> addUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> resetUserPassword(String userId, String newPassword);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> init() async {
    await HiveDatabaseService.initDb();
  }

  String hashPassword(String pwd) {
    final bytes = utf8.encode(pwd);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.userIdKey);
    if (userId == null) return null;

    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    final timestamp = prefs.getInt('session_timestamp');
    if (!rememberMe && timestamp != null) {
      final diff = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (diff > 7200000) { 
        await clearSession();
        return null;
      }
      await prefs.setInt('session_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
    
    final box = Hive.box<UserHive>('users');
    final raw = box.get(userId);
    if (raw == null) return null;
    return UserModel(
      id: raw.userId,
      name: raw.name,
      username: raw.username,
      password: raw.password,
      role: AppRole.fromString(raw.role),
      email: raw.email,
      phone: raw.phone,
      isActive: raw.isActive,
    );
  }

  @override
  Future<void> saveSession(UserModel user, {required bool rememberMe}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userIdKey, user.id);
    await prefs.setString(AppConstants.roleKey, user.role.name);
    await prefs.setBool(AppConstants.rememberMeKey, rememberMe);
    await prefs.setInt('session_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    final box = Hive.box<UserHive>('users');
    final hiveUser = UserHive()
        ..userId = user.id
        ..name = user.name
        ..username = user.username
        ..password = user.password
        ..role = user.role.name
        ..email = user.email
        ..phone = user.phone
        ..isActive = user.isActive;
    await box.put(user.id, hiveUser);
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.roleKey);
    await prefs.remove(AppConstants.rememberMeKey);
    await prefs.remove('session_timestamp');
  }

  @override
  Future<void> updateUserName(String userId, String newName) async {
    final box = Hive.box<UserHive>('users');
    final raw = box.get(userId);
    if (raw == null) throw Exception('User tidak ditemukan');
    raw.name = newName.trim();
    await raw.save();
  }

  @override
  Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    final box = Hive.box<UserHive>('users');
    final raw = box.get(userId);
    if (raw == null) throw Exception('User tidak ditemukan');
    final hashedCurrent = hashPassword(currentPassword);
    if (raw.password != hashedCurrent && raw.password != currentPassword) {
      throw Exception('Password saat ini salah');
    }
    raw.password = hashPassword(newPassword);
    await raw.save();
  }

  @override
  Future<UserModel?> login(String username, String password) async {
    final box = Hive.box<UserHive>('users');
    final hashedPassword = hashPassword(password);
    
    final rawMatches = box.values.where((u) => u.username.toLowerCase() == username.toLowerCase());
        
    if (rawMatches.isEmpty) {
      throw Exception('Username tidak ditemukan');
    }
    
    final raw = rawMatches.first;
    
    if (raw.password != hashedPassword && raw.password != password) {
      throw Exception('Password salah');
    }
    
    if (!raw.isActive) {
      throw Exception('Akun Anda tidak aktif');
    }
    
    return UserModel(
      id: raw.userId,
      name: raw.name,
      username: raw.username,
      password: raw.password,
      role: AppRole.fromString(raw.role),
      email: raw.email,
      phone: raw.phone,
      isActive: raw.isActive,
    );
  }

  @override
  Future<void> seedUsers() async {}

  @override
  Future<List<UserModel>> getAllUsers() async {
    final box = Hive.box<UserHive>('users');
    final rawList = box.values.toList();
    return rawList.map((raw) => UserModel(
      id: raw.userId,
      name: raw.name,
      username: raw.username,
      password: raw.password,
      role: AppRole.fromString(raw.role),
      email: raw.email,
      phone: raw.phone,
      isActive: raw.isActive,
    )).toList();
  }

  @override
  Future<void> addUser(UserModel user) async {
    final box = Hive.box<UserHive>('users');
    final existing = box.get(user.id);
    if (existing != null) throw Exception('User ID sudah ada.');
    final usernameCheck = box.values.where((u) => u.username.toLowerCase() == user.username.toLowerCase());
    if (usernameCheck.isNotEmpty) throw Exception('Username sudah digunakan.');
    
    final hiveUser = UserHive()
      ..userId = user.id
      ..name = user.name
      ..username = user.username
      ..password = hashPassword(user.password)
      ..role = user.role.name
      ..email = user.email
      ..phone = user.phone
      ..isActive = user.isActive;
    await box.put(user.id, hiveUser);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final box = Hive.box<UserHive>('users');
    final raw = box.get(user.id);
    if (raw == null) throw Exception('User tidak ditemukan');
    raw
      ..name = user.name
      ..role = user.role.name
      ..email = user.email
      ..phone = user.phone
      ..isActive = user.isActive;
    await raw.save();
  }

  @override
  Future<void> resetUserPassword(String userId, String newPassword) async {
    final box = Hive.box<UserHive>('users');
    final raw = box.get(userId);
    if (raw == null) throw Exception('User tidak ditemukan');
    raw.password = hashPassword(newPassword);
    await raw.save();
  }
}
