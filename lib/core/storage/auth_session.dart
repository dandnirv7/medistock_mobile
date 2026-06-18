import 'package:get/get.dart';

import '../../features/auth/models/user_model.dart';
import 'secure_storage_service.dart';

/// Sync, in-memory authentication state. Hydrated from [SecureStorageService]
/// at app start and kept in sync after login/logout.
class AuthSession extends GetxService {
  AuthSession({SecureStorageService? storage})
      : _storage = storage ?? Get.find<SecureStorageService>();

  final SecureStorageService _storage;

  final Rxn<String> _token = Rxn<String>();
  final Rxn<UserModel> _user = Rxn<UserModel>();
  bool _hydrated = false;

  String? get token => _token.value;
  Rxn<UserModel> get userRx => _user;
  UserModel? get user => _user.value;
  bool get isAuthenticated => _token.value != null && _token.value!.isNotEmpty;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isStaff => user?.isStaff ?? false;

  Future<void> hydrate() async {
    if (_hydrated) return;
    _token.value = await _storage.readToken();
    _user.value = await _readUser();
    _hydrated = true;
  }

  Future<void> setAuth({required String token, required UserModel user}) async {
    _token.value = token;
    _user.value = user;
    await _storage.writeToken(token);
    await _storage.writeUser(_encode(user));
  }

  Future<void> updateUser(UserModel user) async {
    _user.value = user;
    await _storage.writeUser(_encode(user));
  }

  Future<void> clear() async {
    _token.value = null;
    _user.value = null;
    await _storage.clearAuth();
  }

  Future<UserModel?> _readUser() async {
    final raw = await _storage.readUser();
    if (raw == null || raw.isEmpty) return null;
    try {
      return _decode(raw);
    } catch (_) {
      return null;
    }
  }

  String _encode(UserModel u) {
    final emailPart = u.email == null ? 'null' : '"${u.email}"';
    return '{"id":"${u.id}","name":"${u.name}",'
        '"username":"${u.username}","email":$emailPart,'
        '"role":"${u.role}"}';
  }

  UserModel? _decode(String raw) {
    String field(String key) {
      final m = RegExp('"$key"\\s*:\\s*"([^"]*)"').firstMatch(raw);
      return m?.group(1) ?? '';
    }

    final id = field('id');
    if (id.isEmpty) return null;
    final email = RegExp('"email"\\s*:\\s*"([^"]*)"').firstMatch(raw)?.group(1);
    return UserModel(
      id: id,
      name: field('name'),
      username: field('username'),
      email: (email == null || email.isEmpty) ? null : email,
      role: field('role').isEmpty ? 'ADMIN' : field('role'),
    );
  }
}
