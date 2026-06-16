import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../auth/data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  ProfileController({AuthRepository? authRepo})
      : _authRepo = authRepo ?? Get.find<AuthRepository>();

  final AuthRepository _authRepo;

  AuthSession get session => Get.find<AuthSession>();

  Future<void> logout() async {
    try {
      await _authRepo.logout();
    } catch (_) {
      // Ignore network errors; we clear local state regardless.
    }
    try {
      await session.clear();
    } catch (_) {
      // Storage clear failure shouldn't block sign-out: the in-memory
      // Rxn fields are already null after clear() succeeded partially.
    }
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
