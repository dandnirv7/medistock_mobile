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

  static final List<({String password, UserModel user})> _seedAccounts = [
    (
      password: 'admin123',
      user: UserModel(
        id: 'user-1',
        name: 'Admin Apotek',
        username: 'admin',
        email: 'admin@apotek.test',
        role: 'ADMIN',
      ),
    ),
    (
      password: 'apoteker123',
      user: UserModel(
        id: 'user-2',
        name: 'Apoteker',
        username: 'apoteker',
        email: 'apoteker@apotek.test',
        role: 'STAFF',
      ),
    ),
    (
      password: 'kasir123',
      user: UserModel(
        id: 'user-3',
        name: 'Kasir',
        username: 'kasir',
        email: 'kasir@apotek.test',
        role: 'STAFF',
      ),
    ),
  ];

  @override
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final key = username.trim().toLowerCase();
    final match = _seedAccounts
        .where((a) => a.user.username.toLowerCase() == key)
        .where((a) => a.password == password)
        .firstOrNull;
    if (match == null) {
      throw ApiException(
        code: 'UNAUTHORIZED',
        message: 'Username atau password salah',
        statusCode: 401,
      );
    }
    final token = _generateToken();
    await _storage.writeToken(token);
    await _storage.writeUser(jsonEncode(match.user.toJson()));
    return LoginResponse(token: token, user: match.user);
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
