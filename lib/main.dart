import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_session.dart';
import 'core/storage/secure_storage_service.dart';
import 'data/dummy/dummy_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Eagerly register persistent services that InitialBinding also handles,
  // so the initial route decision can read hydrated auth state.
  Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
  Get.put<AuthSession>(AuthSession(), permanent: true);
  Get.put<ApiClient>(
    ApiClient(storage: Get.find<SecureStorageService>()),
    permanent: true,
  );
  Get.put<DummyStore>(DummyStore(), permanent: true);
  await Get.find<AuthSession>().hydrate();
  runApp(const MediStockApp());
}
