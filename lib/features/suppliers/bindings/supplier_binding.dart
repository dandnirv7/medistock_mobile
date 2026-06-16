import 'package:get/get.dart';

import '../../../core/config/dummy_flag.dart';
import '../../../core/network/api_client.dart';
import '../controllers/supplier_form_controller.dart';
import '../controllers/supplier_list_controller.dart';
import '../data/repositories/supplier_repository.dart';
import '../data/repositories/supplier_repository_api.dart';
import '../data/repositories/supplier_repository_dummy.dart';

class SupplierBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupplierRepository>(
      () => kUseDummyData
          ? SupplierRepositoryDummy()
          : SupplierRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(() => SupplierListController(Get.find<SupplierRepository>()));
    Get.lazyPut(() => SupplierFormController(Get.find<SupplierRepository>()));
  }
}
