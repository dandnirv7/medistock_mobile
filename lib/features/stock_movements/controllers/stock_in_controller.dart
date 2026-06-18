import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../medicines/data/repositories/medicine_repository.dart';
import '../../medicines/models/medicine_model.dart';
import '../../suppliers/data/repositories/supplier_repository.dart';
import '../../suppliers/models/supplier_model.dart';
import '../data/repositories/stock_movement_repository.dart';

class StockInController extends GetxController {
  StockInController(this._repo);

  final StockMovementRepository _repo;

  final formKey = GlobalKey<FormState>();
  final quantityCtrl = TextEditingController(text: '0');
  final notesCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final RxnString medicineId = RxnString();
  final RxnString supplierId = RxnString();
  final RxList<MedicineModel> medicines = <MedicineModel>[].obs;
  final RxList<SupplierModel> suppliers = <SupplierModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  DateTime transactionDate = DateTime.now();
  MedicineModel? selectedMedicine;

  @override
  void onInit() {
    super.onInit();
    dateCtrl.text = _formatDate(transactionDate);
    // First load only — subsequent opens read from the cached lists.
    _loadLookups();
  }

  @override
  void onClose() {
    quantityCtrl.dispose();
    notesCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }

  /// Fetch medicines + suppliers for the lookup dropdowns.
  ///
  /// Skipped when both lists already have data, so navigating away and
  /// back to the StockIn screen does not re-hit the API. Pass
  /// [force] = true to bypass the cache — used after a successful
  /// stock-in so the picker reflects the new stock levels.
  Future<void> _loadLookups({bool force = false}) async {
    if (!force &&
        medicines.isNotEmpty &&
        suppliers.isNotEmpty) {
      return;
    }
    if (Get.isRegistered<MedicineRepository>()) {
      final repo = Get.find<MedicineRepository>();
      final res = await repo.getAll(query: MedicineQuery(limit: 100));
      medicines.assignAll(res.items);
    }
    if (Get.isRegistered<SupplierRepository>()) {
      final repo = Get.find<SupplierRepository>();
      final res = await repo.getAll(query: SupplierQuery(limit: 100));
      suppliers.assignAll(res.items);
    }
  }

  /// Public wrapper so views can trigger a pull-to-refresh style reload.
  Future<void> refreshLookups() => _loadLookups(force: true);

  void setMedicine(String? id) {
    medicineId.value = id;
    selectedMedicine = id == null
        ? null
        : medicines.firstWhereOrNull((m) => m.id == id);
  }

  void setSupplier(String? id) {
    supplierId.value = id;
  }

  void setDate(DateTime d) {
    transactionDate = d;
    dateCtrl.text = _formatDate(d);
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

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
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _repo.stockIn(
        medicineId: medicineId.value!,
        quantity: int.parse(quantityCtrl.text),
        supplierId: supplierId.value,
        transactionDate: transactionDate,
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );
      // Successful write — refresh the lookup list so the picker shows
      // the updated stock levels on next open.
      await _loadLookups(force: true);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
