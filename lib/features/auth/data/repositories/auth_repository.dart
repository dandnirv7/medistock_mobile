import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../models/user_model.dart';

abstract class AuthRepository {
  Future<LoginResponse> login({
    required String username,
    required String password,
  });

  Future<UserModel> me();

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<UserModel?> currentUser();
}

class AuthRepositoryApi implements AuthRepository {
  AuthRepositoryApi({
    required ApiClient client,
    required SecureStorageService storage,
  })  : _client = client,
        _storage = storage;

  final ApiClient _client;
  final SecureStorageService _storage;

  @override
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final res = await _client.raw.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    final body = res.data ?? const {};
    final parsed = LoginResponse.fromJson(body);
    await _storage.writeToken(parsed.token);
    await _storage.writeUser(jsonEncode(parsed.user.toJson()));
    return parsed;
  }

  @override
  Future<UserModel> me() async {
    final res = await _client.raw.get<Map<String, dynamic>>('/auth/me');
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    final user = UserModel.fromJson(data);
    await _storage.writeUser(jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      await _client.raw.post<Map<String, dynamic>>('/auth/logout');
    } on DioException catch (e) {
      // ignore logout endpoint failure; clear local state regardless
      final err = e.error;
      if (err is! ApiException) rethrow;
    }
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
}
