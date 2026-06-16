import 'package:get/get.dart';

import '../../../core/config/dummy_flag.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_dummy.dart';
import '../controllers/login_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => kUseDummyData
          ? AuthRepositoryDummy(storage: Get.find<SecureStorageService>())
          : AuthRepositoryApi(
              client: Get.find<ApiClient>(),
              storage: Get.find<SecureStorageService>(),
            ),
      fenix: true,
    );
    Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
  }
}
