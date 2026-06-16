import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/network/api_client.dart';
import 'package:medistock_mobile/core/storage/auth_session.dart';
import 'package:medistock_mobile/core/storage/secure_storage_service.dart';
import 'package:medistock_mobile/core/theme/app_theme.dart';
import 'package:medistock_mobile/data/dummy/dummy_store.dart';

class _TestSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _values = {};

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.clear();
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _values[key];
  }

  @override
  Future<Map<String, String>> readAll({
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.of(_values);
  }

  @override
  Future<bool> containsKey({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }
}

Future<void> registerTestServices() async {
  await Get.deleteAll(force: true);
  final storage = SecureStorageService(storage: _TestSecureStorage());
  Get.put<SecureStorageService>(storage, permanent: true);
  Get.put<AuthSession>(AuthSession(storage: storage), permanent: true);
  Get.put<ApiClient>(ApiClient(storage: storage), permanent: true);
  Get.put<DummyStore>(DummyStore(), permanent: true);
  await Get.find<AuthSession>().hydrate();
}

Widget wrap(Widget child, {String? initialRoute, List<GetPage>? pages}) {
  return GetMaterialApp(
    theme: AppTheme.light,
    initialRoute: initialRoute,
    getPages: pages ?? const [],
    home: child,
  );
}
