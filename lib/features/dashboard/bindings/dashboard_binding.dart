import 'package:get/get.dart';

import '../../../core/config/dummy_flag.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/data/repositories/auth_repository_dummy.dart';
import '../controllers/dashboard_controller.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/dashboard_repository_api.dart';
import '../data/repositories/dashboard_repository_dummy.dart';

class DashboardBinding extends Bindings {
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
    Get.lazyPut<DashboardRepository>(
      () => kUseDummyData
          ? DashboardRepositoryDummy()
          : DashboardRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => DashboardController(Get.find<DashboardRepository>()));
  }
}
