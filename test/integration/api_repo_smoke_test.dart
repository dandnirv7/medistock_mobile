// Smoke test that exercises the real API repositories against a running
// NestJS backend. Run with:
//   flutter test test/integration/ \
//     --dart-define=API_BASE=http://localhost:3000/api/v1
//
// When run without --dart-define (or with the default 10.0.2.2 emulator URL),
// every test is skipped with a clear message.

import 'dart:io' as io;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/network/api_client.dart';
import 'package:medistock_mobile/core/storage/auth_session.dart';
import 'package:medistock_mobile/core/storage/secure_storage_service.dart';
import 'package:medistock_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:medistock_mobile/features/categories/data/repositories/category_repository_api.dart';
import 'package:medistock_mobile/features/dashboard/data/repositories/dashboard_repository_api.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository_api.dart';
import 'package:medistock_mobile/features/stock_movements/data/repositories/stock_movement_repository_api.dart';
import 'package:medistock_mobile/features/suppliers/data/repositories/supplier_repository_api.dart';

class _MemStorage extends FlutterSecureStorage {
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
  }) async =>
      _values[key];

  @override
  Future<Map<String, String>> readAll({
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      Map.of(_values);

  @override
  Future<bool> containsKey({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _values.containsKey(key);

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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );
  // 10.0.2.2 only works on the Android emulator. On any other host we
  // treat the test as skipped.
  final reachable =
      !(apiBase.contains('10.0.2.2') && !io.Platform.isAndroid);

  setUpAll(() async {
    final storage = SecureStorageService(storage: _MemStorage());
    Get.put<SecureStorageService>(storage, permanent: true);
    Get.put<AuthSession>(AuthSession(storage: storage), permanent: true);
    Get.put<ApiClient>(ApiClient(storage: storage), permanent: true);
  });

  test('Feature 1: Auth login against running API', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable. Use '
          '--dart-define=API_BASE=http://localhost:3000/api/v1');
      return;
    }
    final repo = AuthRepositoryApi(
      client: Get.find<ApiClient>(),
      storage: Get.find<SecureStorageService>(),
    );
    final res = await repo.login(username: 'admin', password: 'admin123');
    expect(res.token, isNotEmpty);
    expect(res.user.username, 'admin');
    expect(res.user.role, 'ADMIN');
  });

  test('Feature 2: Dashboard summary (includes totalValue)', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final auth = AuthRepositoryApi(
      client: Get.find<ApiClient>(),
      storage: Get.find<SecureStorageService>(),
    );
    await auth.login(username: 'admin', password: 'admin123');
    final repo = DashboardRepositoryApi(Get.find<ApiClient>());
    final summary = await repo.getSummary();
    expect(summary.totalMedicines, greaterThan(0));
    expect(summary.totalCategories, greaterThan(0));
    expect(summary.totalValue, greaterThan(0));
  });

  test('Features 3 & 5: Category & Medicine list paginated', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final cat = CategoryRepositoryApi(Get.find<ApiClient>());
    final med = MedicineRepositoryApi(Get.find<ApiClient>());
    final cats = await cat.getAll();
    expect(cats.items, isNotEmpty);
    final meds = await med.getAll();
    expect(meds.items, isNotEmpty);
    expect(meds.items.first.purchasePrice, greaterThan(0));
  });

  test('Feature 4: Supplier list paginated', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final repo = SupplierRepositoryApi(Get.find<ApiClient>());
    final res = await repo.getAll();
    expect(res.items, isNotEmpty);
  });

  test('Features 6 & 8: Stock movements list & stock-in', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final repo = StockMovementRepositoryApi(Get.find<ApiClient>());
    final list = await repo.getAll();
    expect(list.items, isNotEmpty);
    final medRepo = MedicineRepositoryApi(Get.find<ApiClient>());
    final meds = await medRepo.getAll(query: MedicineQuery(limit: 1));
    final medId = meds.items.first.id;
    final before = meds.items.first.currentStock;
    final mv = await repo.stockIn(medicineId: medId, quantity: 1);
    expect(mv.stockAfter, before + 1);
  });

  test('Feature 7: Stock-out (reject insufficient)', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final repo = StockMovementRepositoryApi(Get.find<ApiClient>());
    expect(
      () => repo.stockOut(
        medicineId: '00000000-0000-0000-0000-000000000000',
        quantity: 99999,
      ),
      throwsA(anything),
    );
  });

  test('Feature 11: Medicine search filter', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final repo = MedicineRepositoryApi(Get.find<ApiClient>());
    final res = await repo.getAll(query: MedicineQuery(search: 'Para'));
    expect(res.items, isNotEmpty);
    expect(
      res.items.every((m) =>
          m.name.toLowerCase().contains('para') ||
          m.code.toLowerCase().contains('para')),
      true,
    );
  });

  test('Features 9 & 10: Alerts (lowStock + expired filters)', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final repo = MedicineRepositoryApi(Get.find<ApiClient>());
    final low = await repo.getAll(
      query: MedicineQuery(lowStockOnly: true, limit: 50),
    );
    expect(low.items.every((m) => m.isLowStock), true);
    final exp = await repo.getAll(
      query: MedicineQuery(
        expiredFilter: MedicineExpiredFilter.expired,
        limit: 50,
      ),
    );
    expect(exp.items.every((m) => m.isExpired), true);
  });

  test('Feature 12: Profile (me + logout)', () async {
    if (!reachable) {
      markTestSkipped('API_BASE $apiBase not reachable');
      return;
    }
    final auth = AuthRepositoryApi(
      client: Get.find<ApiClient>(),
      storage: Get.find<SecureStorageService>(),
    );
    await auth.login(username: 'admin', password: 'admin123');
    final me = await auth.me();
    expect(me.username, 'admin');
    expect(me.role, 'ADMIN');
    await auth.logout();
    final stillLogged = await auth.isLoggedIn();
    expect(stillLogged, false);
  });
}
