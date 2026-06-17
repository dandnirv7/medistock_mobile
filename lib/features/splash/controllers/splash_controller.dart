import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';

class SplashController extends GetxController {
  SplashController({AuthSession? session})
      : _session = session ?? Get.find<AuthSession>();

  final AuthSession _session;
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    debugPrint('[Splash] onReady fired, scheduling navigation');
    _timer = Timer(const Duration(milliseconds: 1500), _navigate);
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
