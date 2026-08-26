import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../core/enums/app_role.dart';

class AuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  AuthService() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    fb_auth.FirebaseAuth.instance.authStateChanges().listen((fb_auth.User? user) async {
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          data['id'] = doc.id;
          if (!data.containsKey('username')) data['username'] = user.email ?? '';
          if (!data.containsKey('password')) data['password'] = '';
          if (!data.containsKey('phone')) data['phone'] = '';
          _currentUser = UserModel.fromJson(data);
        } else {
          // Fallback if custom user data does not exist
          _currentUser = UserModel(
            id: user.uid,
            name: user.displayName ?? 'User',
            username: user.email ?? '',
            password: '',
            email: user.email ?? '',
            phone: '',
            role: AppRole.eksternal,
          );
        }
      } else {
        _currentUser = null;
      }
    });
  }

  Future<UserModel?> initializeSession() async {
    await fb_auth.FirebaseAuth.instance.authStateChanges().first;
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        if (!data.containsKey('username')) data['username'] = fbUser.email ?? '';
        if (!data.containsKey('password')) data['password'] = '';
        if (!data.containsKey('phone')) data['phone'] = '';
        _currentUser = UserModel.fromJson(data);
      } else {
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          username: fbUser.email ?? '',
          password: '',
          email: fbUser.email ?? '',
          phone: '',
          role: AppRole.eksternal,
        );
      }
    } else {
      _currentUser = null;
    }
    return _currentUser;
  }

  Future<void> seedDefaultUser() async {
    // Seeding is now handled via Firebase Console / Firebase Auth dashboard
  }

  Future<UserModel?> signIn(String email, String password, {bool rememberMe = false}) async {
    assert(email.isNotEmpty, 'Email tidak boleh kosong');
    assert(password.isNotEmpty, 'Password tidak boleh kosong');

    try {
      try {
        await fb_auth.FirebaseAuth.instance.setPersistence(
            rememberMe ? fb_auth.Persistence.LOCAL : fb_auth.Persistence.SESSION);
      } catch (_) {}

      final fb_auth.UserCredential creds = await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = creds.user;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          data['id'] = doc.id;
          if (!data.containsKey('username')) data['username'] = user.email ?? '';
          if (!data.containsKey('password')) data['password'] = '';
          if (!data.containsKey('phone')) data['phone'] = '';
          _currentUser = UserModel.fromJson(data);
          return _currentUser;
        } else {
          _currentUser = UserModel(
            id: user.uid,
            name: user.displayName ?? 'User',
            username: user.email ?? '',
            password: '',
            email: user.email ?? '',
            phone: '',
            role: AppRole.eksternal,
          );
          return _currentUser;
        }
      }
      return null;
    } catch (e) {
      throw Exception("Gagal login: $e");
    }
  }

  Future<void> signOut() async {
    await fb_auth.FirebaseAuth.instance.signOut();
    _currentUser = null;
  }
}
