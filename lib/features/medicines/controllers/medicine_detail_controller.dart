import 'package:get/get.dart';

import '../../../core/storage/auth_session.dart';
import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineDetailController extends GetxController {
  MedicineDetailController(this._repo);

  final MedicineRepository _repo;

  final Rxn<MedicineModel> medicine = Rxn<MedicineModel>();
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxnString errorMessage = RxnString();

  late final String medicineId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.parameters;
    if (args['id'] != null && args['id'].toString().isNotEmpty) {
      medicineId = args['id'].toString();
    } else if (Get.arguments is Map && (Get.arguments as Map)['id'] != null) {
      medicineId = (Get.arguments as Map)['id'].toString();
    } else {
      medicineId = '';
    }
    if (Get.arguments is MedicineModel) {
      medicine.value = Get.arguments as MedicineModel;
      if (medicineId.isEmpty) medicineId = (Get.arguments as MedicineModel).id;
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

  Future<bool> deleteMedicine() async {
    if (medicineId.isEmpty) {
      errorMessage.value = 'ID obat tidak ditemukan';
      return false;
    }
    if (Get.isRegistered<AuthSession>() &&
        !Get.find<AuthSession>().isAdmin) {
      errorMessage.value = 'Hanya admin yang dapat menghapus obat';
      return false;
    }
    isDeleting.value = true;
    errorMessage.value = null;
    try {
      await _repo.delete(medicineId);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
}
