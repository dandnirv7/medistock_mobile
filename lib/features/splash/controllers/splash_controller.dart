import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';

class SplashController extends GetxController {
  SplashController({AuthSession? session})
      : _session = session ?? Get.find<AuthSession>();

  final AuthSession _session;

  @override
  void onReady() {
    super.onReady();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (_session.isAuthenticated) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
