import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/config/dummy_flag.dart';
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
  final apiClient = ApiClient(storage: Get.find<SecureStorageService>());
  Get.put<ApiClient>(apiClient, permanent: true);
  Get.put<DummyStore>(DummyStore(), permanent: true);
  await Get.find<AuthSession>().hydrate();
  _logStartupMode(apiClient.resolvedBaseUrl);
  unawaited(_probeApiHealth(apiClient));
  runApp(const MediStockApp());
}

// ---------------------------------------------------------------------------
// Startup diagnostics
// ---------------------------------------------------------------------------

/// Prints which data source the current build is wired to. Visible in
/// `flutter run` console; stripped from release builds.
void _logStartupMode(String baseUrl) {
  if (!kDebugMode) return;
  if (kUseDummyData) {
    debugPrint('[MediStock] data source: DUMMY (in-memory)');
  } else {
    debugPrint('[MediStock] data source: API @ $baseUrl');
  }
}

/// Fire-and-forget `GET /health` against the backend so connection issues
/// surface immediately in the console, before the user attempts login.
///
/// - No-op when running in dummy mode.
/// - Never blocks the UI: the future is intentionally not awaited.
/// - 3-second timeout so a hung server doesn't keep the probe pending.
Future<void> _probeApiHealth(ApiClient client) async {
  if (!kDebugMode) return;
  if (kUseDummyData) return;

  final stopwatch = Stopwatch()..start();
  try {
    final res = await client.raw
        .get<String>(
          '/health',
          options: Options(
            responseType: ResponseType.plain,
            receiveTimeout: const Duration(seconds: 3),
            sendTimeout: const Duration(seconds: 3),
          ),
        )
        .timeout(const Duration(seconds: 3));
    stopwatch.stop();
    if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
      debugPrint(
        '[MediStock] API health: OK (${stopwatch.elapsedMilliseconds}ms)',
      );
    } else {
      debugPrint(
        '[MediStock] API health: NON-2xx (${res.statusCode}) after '
        '${stopwatch.elapsedMilliseconds}ms',
      );
    }
  } catch (e) {
    stopwatch.stop();
    debugPrint(
      '[MediStock] API health: UNREACHABLE — $e. '
      'Requests will fail until the backend is reachable.',
    );
  }
}

/// Minimal `unawaited` shim — avoids importing `dart:async` just for this.
void unawaited(Future<void> future) {
  // Intentionally empty: any errors are surfaced through the probe's own
  // try/catch, so we don't need a `.catchError` here.
  future.then((Object? _) {}, onError: (Object? e, StackTrace? s) {});
}
