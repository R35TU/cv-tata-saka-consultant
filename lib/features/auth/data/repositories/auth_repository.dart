import '../datasources/local_auth_data_source.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<void> init();
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> login(String username, String password);
  Future<void> saveSession(UserModel user, {required bool rememberMe});
  Future<void> clearSession();
  Future<void> updateUserName(String userId, String newName);
  Future<void> changePassword(String userId, String currentPassword, String newPassword);
  Future<List<UserModel>> getAllUsers();
  Future<void> addUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> resetUserPassword(String userId, String newPassword);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<void> init() => localDataSource.init();

  @override
  Future<UserModel?> getCurrentUser() => localDataSource.getCurrentUser();

  @override
  Future<UserModel?> login(String username, String password) => localDataSource.login(username, password);

  @override
  Future<void> saveSession(UserModel user, {required bool rememberMe}) => localDataSource.saveSession(user, rememberMe: rememberMe);

  @override
  Future<void> clearSession() => localDataSource.clearSession();

  @override
  Future<void> updateUserName(String userId, String newName) => localDataSource.updateUserName(userId, newName);

  @override
  Future<void> changePassword(String userId, String currentPassword, String newPassword) =>
      localDataSource.changePassword(userId, currentPassword, newPassword);

  @override
  Future<List<UserModel>> getAllUsers() => localDataSource.getAllUsers();

  @override
  Future<void> addUser(UserModel user) => localDataSource.addUser(user);

  @override
  Future<void> updateUser(UserModel user) => localDataSource.updateUser(user);

  @override
  Future<void> resetUserPassword(String userId, String newPassword) =>
      localDataSource.resetUserPassword(userId, newPassword);
}
