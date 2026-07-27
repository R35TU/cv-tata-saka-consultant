import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local_auth_data_source.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

class ProfilePhotoNotifier extends StateNotifier<String?> {
  final String? _userId;
  ProfilePhotoNotifier(this._userId) : super(null) {
    if (_userId != null) {
      _loadPhoto();
    }
  }

  Future<void> _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('profile_photo_$_userId');
  }

  Future<void> updatePhoto(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('profile_photo_$_userId', path);
      state = path;
    } else {
      await prefs.remove('profile_photo_$_userId');
      state = null;
    }
  }
}

final profilePhotoProvider = StateNotifierProvider.family<ProfilePhotoNotifier, String?, String?>((ref, userId) {
  return ProfilePhotoNotifier(userId);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = AuthLocalDataSourceImpl();
  return AuthRepositoryImpl(dataSource);
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      await _repository.init();
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> login(String username, String password, {required bool rememberMe}) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(username, password);
      if (user == null) {
        throw Exception('Username atau password salah');
      }
      await _repository.saveSession(user, rememberMe: rememberMe);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    await _repository.clearSession();
    state = const AsyncValue.data(null);
  }

  Future<void> updateUserName(String userId, String newName) async {
    await _repository.updateUserName(userId, newName);
    // Refresh user state
    final user = await _repository.getCurrentUser();
    state = AsyncValue.data(user);
  }

  Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    await _repository.changePassword(userId, currentPassword, newPassword);
  }
}
