import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';

/// Default splash delay matches the mockup's brand flash (~1.5s).
/// Devs can override via `--dart-define=SPLASH_DURATION_MS=300` for fast
/// inner-loop iteration; tests can pass 0.
const int _kSplashDurationMs = int.fromEnvironment(
  'SPLASH_DURATION_MS',
  defaultValue: 1500,
);

class SplashController extends GetxController {
  SplashController({AuthSession? session})
      : _session = session ?? Get.find<AuthSession>();

  final AuthSession _session;
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    debugPrint(
      '[Splash] onReady fired, scheduling navigation '
      'in ${_kSplashDurationMs}ms',
    );
    if (_kSplashDurationMs <= 0) {
      // Allow skipping the wait entirely (used in tests / instant dev).
      _navigate();
      return;
    }
    _timer = Timer(
      Duration(milliseconds: _kSplashDurationMs),
      _navigate,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  void _navigate() {
    if (!Get.isRegistered<GetMaterialController>()) return;
    debugPrint(
      '[Splash] navigating, isAuthenticated=${_session.isAuthenticated}',
    );
    if (_session.isAuthenticated) {
      Get.offAllNamed<void>(AppRoutes.home);
    } else {
      Get.offAllNamed<void>(AppRoutes.login);
    }
  }
}
