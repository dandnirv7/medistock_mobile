import 'dart:async';
import 'dart:convert';

import 'dart:math' as math;

import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../models/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryDummy implements AuthRepository {
  AuthRepositoryDummy({required SecureStorageService storage}) : _storage = storage;

  final SecureStorageService _storage;
  final UserModel _seedUser = UserModel(
    id: 'user-1',
    name: 'Admin Apotek',
    username: 'admin',
    email: 'admin@apotek.test',
    role: 'ADMIN',
  );

  @override
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (username.trim().toLowerCase() != 'admin' || password != 'admin123') {
      throw ApiException(
        code: 'UNAUTHORIZED',
        message: 'Username atau password salah',
        statusCode: 401,
      );
    }
    final token = _generateToken();
    await _storage.writeToken(token);
    await _storage.writeUser(jsonEncode(_seedUser.toJson()));
    return LoginResponse(token: token, user: _seedUser);
  }

  @override
  Future<UserModel> me() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final raw = await _storage.readUser();
    if (raw == null) {
      throw ApiException(
        code: 'UNAUTHORIZED',
        message: 'Sesi berakhir, silakan login ulang',
        statusCode: 401,
      );
    }
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _storage.clearAuth();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.readToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserModel?> currentUser() async {
    final raw = await _storage.readUser();
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String _generateToken() {
    final r = math.Random();
    final hex = List.generate(
      32,
      (_) => r.nextInt(16).toRadixString(16),
    ).join();
    return 'dummy_$hex';
  }
}
