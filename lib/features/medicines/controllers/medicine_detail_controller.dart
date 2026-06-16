import 'package:get/get.dart';

import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineDetailController extends GetxController {
  MedicineDetailController(this._repo);

  final MedicineRepository _repo;

  final Rxn<MedicineModel> medicine = Rxn<MedicineModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  late final String medicineId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.parameters;
    medicineId = (args['id'] ?? '').toString();
    if (Get.arguments is MedicineModel) {
      medicine.value = Get.arguments as MedicineModel;
    }
    load();
  }

  Future<void> load() async {
    if (medicineId.isEmpty) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _repo.getById(medicineId);
      medicine.value = res;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
