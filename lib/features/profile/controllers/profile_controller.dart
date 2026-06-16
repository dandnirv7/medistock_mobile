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
    await session.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
