import 'package:get/get.dart';

import '../../../core/config/dummy_flag.dart';
import '../../../core/network/api_client.dart';
import '../controllers/stock_in_controller.dart';
import '../controllers/stock_movement_list_controller.dart';
import '../controllers/stock_out_controller.dart';
import '../data/repositories/stock_movement_repository.dart';
import '../data/repositories/stock_movement_repository_api.dart';
import '../data/repositories/stock_movement_repository_dummy.dart';

class StockMovementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockMovementRepository>(
      () => kUseDummyData
          ? StockMovementRepositoryDummy()
          : StockMovementRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() =>
        StockMovementListController(Get.find<StockMovementRepository>()));
    Get.lazyPut(() => StockInController(Get.find<StockMovementRepository>()));
    Get.lazyPut(() => StockOutController(Get.find<StockMovementRepository>()));
  }
}
