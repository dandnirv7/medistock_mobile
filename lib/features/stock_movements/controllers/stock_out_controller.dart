import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/utils/date_formatter.dart';
import '../../medicines/data/repositories/medicine_repository.dart';
import '../../medicines/models/medicine_model.dart';
import '../data/repositories/stock_movement_repository.dart';
import '../models/stock_movement_model.dart';

class StockOutController extends GetxController {
  StockOutController(this._repo);

  final StockMovementRepository _repo;

  final formKey = GlobalKey<FormState>();
  final quantityCtrl = TextEditingController(text: '0');
  final notesCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final RxnString medicineId = RxnString();
  final Rx<StockMovementReason> reason =
      Rx<StockMovementReason>(StockMovementReason.sale);
  final RxList<MedicineModel> medicines = <MedicineModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  DateTime transactionDate = DateTime.now();
  MedicineModel? selectedMedicine;

  @override
  void onInit() {
    super.onInit();
    dateCtrl.text = _formatDate(transactionDate);
    _loadMedicines();
  }

  @override
  void onClose() {
    quantityCtrl.dispose();
    notesCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }

  /// Fetch medicines for the picker dropdown.
  ///
  /// Skipped when the list is already populated, so navigating away and
  /// back to the StockOut screen does not re-hit the API. Pass
  /// [force] = true to bypass the cache — used after a successful
  /// stock-out so the picker reflects the new stock levels.
  Future<void> _loadMedicines({bool force = false}) async {
    if (!force && medicines.isNotEmpty) return;
    if (!Get.isRegistered<MedicineRepository>()) return;
    final repo = Get.find<MedicineRepository>();
    final res = await repo.getAll(query: MedicineQuery(limit: 100));
    medicines.assignAll(res.items);
  }

  /// Public wrapper so views can trigger a pull-to-refresh style reload.
  Future<void> refreshMedicines() => _loadMedicines(force: true);

  void setMedicine(String? id) {
    medicineId.value = id;
    selectedMedicine = id == null
        ? null
        : medicines.firstWhereOrNull((m) => m.id == id);
  }

  void setReason(StockMovementReason r) => reason.value = r;

  void setDate(DateTime d) {
    transactionDate = d;
    dateCtrl.text = _formatDate(d);
  }

  String _formatDate(DateTime d) => DateFormatter.toDisplayId(d);

  String? requiredText(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String? positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Jumlah wajib diisi';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Jumlah tidak valid';
    if (n <= 0) return 'Jumlah harus lebih dari 0';
    return null;
  }

  Future<bool> submit() async {
    if (isLoading.value) return false;
    if (medicineId.value == null) {
      errorMessage.value = 'Pilih obat terlebih dahulu';
      return false;
    }
    if (!(formKey.currentState?.validate() ?? false)) return false;
    final qty = int.parse(quantityCtrl.text);
    if (selectedMedicine != null && qty > selectedMedicine!.currentStock) {
      errorMessage.value =
          'Stok tidak mencukupi. Sisa stok: ${selectedMedicine!.currentStock}';
      return false;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repo.stockOut(
        medicineId: medicineId.value!,
        quantity: qty,
        transactionDate: transactionDate,
        reasonLabel: reason.value.apiValue,
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );
      // Successful write — refresh the lookup list so the picker shows
      // the updated stock levels on next open.
      await _loadMedicines(force: true);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
