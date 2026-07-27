import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/enums/app_role.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/database/isar_database_service.dart';
import '../../../../core/database/isar_models.dart';
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
  Isar? _db;

  Future<Isar> get db async {
    if (_db != null) return _db!;
    _db = await IsarDatabaseService.db;
    return _db!;
  }

  String hashPassword(String pwd) {
    final bytes = utf8.encode(pwd);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<void> init() async {
    await db;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.userIdKey);
    if (userId == null) return null;

    // Check remember me & session expiration
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    final timestamp = prefs.getInt('session_timestamp');
    if (!rememberMe && timestamp != null) {
      final diff = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (diff > 7200000) { // 2 hours expiration
        await clearSession();
        return null;
      }
      // Update/slide the session time
      await prefs.setInt('session_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
    
    final database = await db;
    final raw = await database.userIsars.filter().userIdEqualTo(userId).findFirst();
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
    
    final database = await db;
    final existing = await database.userIsars.filter().userIdEqualTo(user.id).findFirst();
    await database.writeTxn(() async {
      final isarUser = (existing ?? UserIsar())
        ..userId = user.id
        ..name = user.name
        ..username = user.username
        ..password = user.password
        ..role = user.role.name
        ..email = user.email
        ..phone = user.phone
        ..isActive = user.isActive;
      await database.userIsars.put(isarUser);
    });
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
    final database = await db;
    final raw = await database.userIsars.filter().userIdEqualTo(userId).findFirst();
    if (raw == null) throw Exception('User tidak ditemukan');
    await database.writeTxn(() async {
      raw.name = newName.trim();
      await database.userIsars.put(raw);
    });
  }

  @override
  Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    final database = await db;
    final raw = await database.userIsars.filter().userIdEqualTo(userId).findFirst();
    if (raw == null) throw Exception('User tidak ditemukan');
    final hashedCurrent = hashPassword(currentPassword);
    // Accept plain-text fallback for legacy stored passwords
    if (raw.password != hashedCurrent && raw.password != currentPassword) {
      throw Exception('Password saat ini salah');
    }
    final hashedNew = hashPassword(newPassword);
    await database.writeTxn(() async {
      raw.password = hashedNew;
      await database.userIsars.put(raw);
    });
  }

  @override
  Future<UserModel?> login(String username, String password) async {
    final database = await db;
    final hashedPassword = hashPassword(password);
    
    final raw = await database.userIsars.filter()
        .usernameEqualTo(username, caseSensitive: false)
        .findFirst();
        
    if (raw == null) {
      throw Exception('Username tidak ditemukan');
    }
    
    print('DEBUG LOGIN: username=$username, typed=$password, hashed=$hashedPassword, db_password=${raw.password}');
    
    // Check password (allows hashed match, or plain-text fallback for existing DB contents)
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
  Future<void> seedUsers() async {
    // Handled in IsarDatabaseService
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final database = await db;
    final rawList = await database.userIsars.where().findAll();
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
    final database = await db;
    final existing = await database.userIsars.filter().userIdEqualTo(user.id).findFirst();
    if (existing != null) throw Exception('User ID sudah ada.');
    final usernameCheck = await database.userIsars.filter()
        .usernameEqualTo(user.username, caseSensitive: false).findFirst();
    if (usernameCheck != null) throw Exception('Username sudah digunakan.');
    await database.writeTxn(() async {
      final isarUser = UserIsar()
        ..userId = user.id
        ..name = user.name
        ..username = user.username
        ..password = hashPassword(user.password)
        ..role = user.role.name
        ..email = user.email
        ..phone = user.phone
        ..isActive = user.isActive;
      await database.userIsars.put(isarUser);
    });
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final database = await db;
    final raw = await database.userIsars.filter().userIdEqualTo(user.id).findFirst();
    if (raw == null) throw Exception('User tidak ditemukan');
    await database.writeTxn(() async {
      raw
        ..name = user.name
        ..role = user.role.name
        ..email = user.email
        ..phone = user.phone
        ..isActive = user.isActive;
      await database.userIsars.put(raw);
    });
  }

  @override
  Future<void> resetUserPassword(String userId, String newPassword) async {
    final database = await db;
    final raw = await database.userIsars.filter().userIdEqualTo(userId).findFirst();
    if (raw == null) throw Exception('User tidak ditemukan');
    await database.writeTxn(() async {
      raw.password = hashPassword(newPassword);
      await database.userIsars.put(raw);
    });
  }
}
