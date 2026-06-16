import 'package:get/get.dart';

import '../../medicines/controllers/medicine_list_controller.dart';
import '../../medicines/data/repositories/medicine_repository.dart';

class AlertsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MedicineListController>()) {
      Get.lazyPut(
          () => MedicineListController(Get.find<MedicineRepository>()));
    }
  }
}
