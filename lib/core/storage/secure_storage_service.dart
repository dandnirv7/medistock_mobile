import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Storage backend abstraction. The default delegates to
/// [FlutterSecureStorage], which on Linux desktop depends on a keyring
/// (gnome-keyring/libsecret) that is frequently absent in CI / minimal
/// desktop environments. When that happens, every read/write blocks
/// indefinitely. We mitigate that by wrapping each call in a short
/// timeout and falling back to an in-memory map.
abstract class _StorageBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _SecureStorageBackend implements _StorageBackend {
  _SecureStorageBackend([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class _MemoryStorageBackend implements _StorageBackend {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }
}

/// Timeout (ms) before we give up on the secure storage backend and
/// fall back to in-memory. 500ms is plenty for a healthy keyring; a
/// hung DBus call is the only realistic way to exceed it.
const int _kStorageTimeoutMs = 500;

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _primary = _SecureStorageBackend(storage),
        _fallback = _MemoryStorageBackend();

  final _StorageBackend _primary;
  final _StorageBackend _fallback;

  Future<T> _withFallback<T>(Future<T> Function(_StorageBackend) op) async {
    try {
      return await op(_primary).timeout(const Duration(milliseconds: _kStorageTimeoutMs));
    } catch (_) {
      return op(_fallback);
    }
  }

  Future<String?> readToken() => _withFallback((s) => s.read(StorageKeys.accessToken));

  Future<void> writeToken(String token) =>
      _withFallback((s) => s.write(StorageKeys.accessToken, token));

  Future<void> deleteToken() =>
      _withFallback((s) => s.delete(StorageKeys.accessToken));

  Future<String?> readUser() => _withFallback((s) => s.read(StorageKeys.user));

  Future<void> writeUser(String json) =>
      _withFallback((s) => s.write(StorageKeys.user, json));

  Future<void> deleteUser() => _withFallback((s) => s.delete(StorageKeys.user));

  Future<void> clearAuth() async {
    await deleteToken();
    await deleteUser();
  }
}
