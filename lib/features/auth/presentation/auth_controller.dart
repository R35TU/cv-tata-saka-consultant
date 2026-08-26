import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../backend/services/auth_service.dart';
import '../data/models/user_model.dart';
import '../data/datasources/local_auth_data_source.dart';
import '../data/repositories/auth_repository.dart';
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

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthLocalDataSourceImpl());
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthController(service);
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _service;

  AuthController(this._service) : super(const AsyncValue.loading()) {
    initialize();
  }

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      final user = await _service.initializeSession();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> login(String username, String password, {required bool rememberMe}) async {
    state = const AsyncValue.loading();
    try {
      // username field in UI is used as email for Firebase
      final user = await _service.signIn(username, password, rememberMe: rememberMe);
      if (user == null) {
        throw Exception('Username/Email atau password salah');
      }
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    await _service.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateUserName(String userId, String newName) async {
    // TODO: implement updating firestore user data if needed
  }

  Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    // TODO: implement firebase change password
  }
}
