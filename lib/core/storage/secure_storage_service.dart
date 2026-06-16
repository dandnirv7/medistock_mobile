import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: StorageKeys.accessToken);

  Future<void> writeToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<void> deleteToken() => _storage.delete(key: StorageKeys.accessToken);

  Future<String?> readUser() => _storage.read(key: StorageKeys.user);

  Future<void> writeUser(String json) =>
      _storage.write(key: StorageKeys.user, value: json);

  Future<void> deleteUser() => _storage.delete(key: StorageKeys.user);

  Future<void> clearAuth() async {
    await deleteToken();
    await deleteUser();
  }
}
