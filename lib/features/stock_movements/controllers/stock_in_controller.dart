import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../medicines/data/repositories/medicine_repository.dart';
import '../../medicines/models/medicine_model.dart';
import '../../suppliers/data/repositories/supplier_repository.dart';
import '../../suppliers/models/supplier_model.dart';
import '../data/repositories/stock_movement_repository.dart';

class StockInController extends GetxController {
  StockInController(
    this._repo, [
    MedicineRepository? medicineRepo,
    SupplierRepository? supplierRepo,
  ])  : _medicineRepo = medicineRepo ?? Get.find<MedicineRepository>(),
        _supplierRepo = supplierRepo ?? Get.find<SupplierRepository>();

  final StockMovementRepository _repo;
  final MedicineRepository _medicineRepo;
  final SupplierRepository _supplierRepo;

  final formKey = GlobalKey<FormState>();
  final quantityCtrl = TextEditingController(text: '0');
  final notesCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final RxnString medicineId = RxnString();
  final RxnString supplierId = RxnString();
  final RxList<MedicineModel> medicines = <MedicineModel>[].obs;
  final RxList<SupplierModel> suppliers = <SupplierModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLookupsLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxnString lookupsError = RxnString();
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
  /// Always hits the API on first open (via injected repos) so the
  /// picker never shows only "Tanpa supplier". Subsequent opens reuse
  /// cache unless [force] is true (after successful stock-in).
  Future<void> _loadLookups({bool force = false}) async {
    if (!force && medicines.isNotEmpty && suppliers.isNotEmpty) {
      isLookupsLoading.value = false;
      return;
    }
    isLookupsLoading.value = true;
    lookupsError.value = null;
    try {
      final medPage = await _medicineRepo.getAll(
        query: MedicineQuery(limit: 100),
      );
      final supPage = await _supplierRepo.getAll(
        query: SupplierQuery(limit: 100),
      );
      medicines.assignAll(medPage.items);
      suppliers.assignAll(supPage.items);
      if (medicines.isEmpty) {
        lookupsError.value = 'Tidak ada obat. Tambahkan obat dulu.';
      } else if (suppliers.isEmpty) {
        lookupsError.value =
            'Tidak ada supplier. Supplier akan tercatat sebagai "Tanpa supplier".';
      }
    } catch (e) {
      lookupsError.value = 'Gagal memuat data: ${e.toString()}';
    } finally {
      isLookupsLoading.value = false;
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
