import 'package:get/get.dart';

import '../../../core/config/dummy_flag.dart';
import '../../../core/network/api_client.dart';
import '../controllers/medicine_detail_controller.dart';
import '../controllers/medicine_form_controller.dart';
import '../controllers/medicine_list_controller.dart';
import '../data/repositories/medicine_repository.dart';
import '../data/repositories/medicine_repository_api.dart';
import '../data/repositories/medicine_repository_dummy.dart';

class MedicineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicineRepository>(
      () => kUseDummyData
          ? MedicineRepositoryDummy()
          : MedicineRepositoryApi(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
        () => MedicineListController(Get.find<MedicineRepository>()));
    Get.lazyPut(
        () => MedicineFormController(Get.find<MedicineRepository>()));
    Get.lazyPut(
        () => MedicineDetailController(Get.find<MedicineRepository>()));
  }
}
