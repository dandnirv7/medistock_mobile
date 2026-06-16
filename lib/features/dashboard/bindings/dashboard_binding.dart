import 'package:get/get.dart';

import '../../../core/config/dummy_flag.dart';
import '../../../core/network/api_client.dart';
import '../controllers/dashboard_controller.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/dashboard_repository_api.dart';
import '../data/repositories/dashboard_repository_dummy.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardRepository>(
      () => kUseDummyData
          ? DashboardRepositoryDummy()
          : DashboardRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => DashboardController(Get.find<DashboardRepository>()));
  }
}
