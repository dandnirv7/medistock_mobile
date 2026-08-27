import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/storage/auth_session.dart';
import '../../categories/data/repositories/category_repository.dart';
import '../../categories/models/category_model.dart';
import '../../suppliers/data/repositories/supplier_repository.dart';
import '../../suppliers/models/supplier_model.dart';
import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineFormController extends GetxController {
  MedicineFormController(
    this._repo, [
    CategoryRepository? categoryRepo,
    SupplierRepository? supplierRepo,
  ])  : _categoryRepo = categoryRepo ?? Get.find<CategoryRepository>(),
        _supplierRepo = supplierRepo ?? Get.find<SupplierRepository>();

  final MedicineRepository _repo;
  final CategoryRepository _categoryRepo;
  final SupplierRepository _supplierRepo;

  final formKey = GlobalKey<FormState>();
  final codeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final unitCtrl = TextEditingController(text: 'Tablet');
  final purchasePriceCtrl = TextEditingController(text: '0');
  final sellingPriceCtrl = TextEditingController(text: '0');
  final currentStockCtrl = TextEditingController(text: '0');
  final minimumStockCtrl = TextEditingController(text: '0');
  final expiredDateCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<SupplierModel> suppliers = <SupplierModel>[].obs;
  final RxnString categoryId = RxnString();
  final RxnString supplierId = RxnString();
  final RxBool isLoading = false.obs;
  final RxBool isLookupsLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxnString lookupsError = RxnString();
  final RxBool isActive = true.obs;
  DateTime? expiredDate;
  MedicineModel? editing;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is MedicineModel) {
      editing = args;
      codeCtrl.text = args.code;
      nameCtrl.text = args.name;
      unitCtrl.text = args.unit;
      purchasePriceCtrl.text = args.purchasePrice.toStringAsFixed(0);
      sellingPriceCtrl.text = args.sellingPrice.toStringAsFixed(0);
      currentStockCtrl.text = args.currentStock.toString();
      minimumStockCtrl.text = args.minimumStock.toString();
      descriptionCtrl.text = args.description ?? '';
      expiredDate = args.expiredDate;
      expiredDateCtrl.text = _formatDate(args.expiredDate);
      categoryId.value = args.categoryId;
      supplierId.value = args.supplierId;
      isActive.value = args.isActive;
    }
    _loadLookups();
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    nameCtrl.dispose();
    unitCtrl.dispose();
    purchasePriceCtrl.dispose();
    sellingPriceCtrl.dispose();
    currentStockCtrl.dispose();
    minimumStockCtrl.dispose();
    expiredDateCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadLookups() async {
    isLookupsLoading.value = true;
    lookupsError.value = null;
    try {
      final catPage = await _categoryRepo.getAll(
        query: CategoryQuery(limit: 100),
      );
      final supPage = await _supplierRepo.getAll(
        query: SupplierQuery(limit: 100),
      );
      categories.assignAll(catPage.items);
      suppliers.assignAll(supPage.items);
      if (categories.isEmpty && suppliers.isEmpty) {
        lookupsError.value =
            'Tidak ada kategori & supplier. Tambahkan data master dulu atau periksa koneksi.';
      } else if (categories.isEmpty) {
        lookupsError.value = 'Tidak ada kategori. Tambahkan kategori dulu.';
      } else if (suppliers.isEmpty) {
        lookupsError.value = 'Tidak ada supplier. Tambahkan supplier dulu.';
      }
    } catch (e) {
      lookupsError.value = 'Gagal memuat kategori/supplier: ${e.toString()}';
    } finally {
      isLookupsLoading.value = false;
    }
  }

  Future<void> reloadLookups() => _loadLookups();

  void setExpiredDate(DateTime date) {
    expiredDate = date;
    expiredDateCtrl.text = _formatDate(date);
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  String? requiredText(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String? numberText(String? v, String label, {bool integer = false}) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    final cleaned = v.replaceAll('.', '').replaceAll(',', '.');
    final n = num.tryParse(cleaned);
    if (n == null) return '$label tidak valid';
    if (integer && n != n.roundToDouble()) return '$label harus bilangan bulat';
    if (n < 0) return '$label tidak boleh negatif';
    return null;
  }

  Future<bool> submit() async {
    if (Get.isRegistered<AuthSession>() &&
        !Get.find<AuthSession>().isAdmin) {
      errorMessage.value = 'Hanya admin yang dapat menyimpan perubahan';
      return false;
    }
    if (isLoading.value) return false;
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (categoryId.value == null || categoryId.value!.isEmpty) {
      errorMessage.value = 'Kategori wajib dipilih';
      return false;
    }
    if (supplierId.value == null || supplierId.value!.isEmpty) {
      errorMessage.value = 'Supplier wajib dipilih';
      return false;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      if (editing == null) {
        await _repo.create(
          code: codeCtrl.text.trim(),
          name: nameCtrl.text.trim(),
          categoryId: categoryId.value,
          supplierId: supplierId.value,
          unit: unitCtrl.text.trim(),
          purchasePrice:
              double.parse(purchasePriceCtrl.text.replaceAll(',', '.')),
          sellingPrice:
              double.parse(sellingPriceCtrl.text.replaceAll(',', '.')),
          currentStock: int.parse(currentStockCtrl.text),
          minimumStock: int.parse(minimumStockCtrl.text),
          expiredDate: expiredDate,
          description: descriptionCtrl.text.trim().isEmpty
              ? null
              : descriptionCtrl.text.trim(),
        );
      } else {
        await _repo.update(
          editing!.id,
          code: codeCtrl.text.trim(),
          name: nameCtrl.text.trim(),
          categoryId: categoryId.value,
          supplierId: supplierId.value,
          unit: unitCtrl.text.trim(),
          purchasePrice:
              double.parse(purchasePriceCtrl.text.replaceAll(',', '.')),
          sellingPrice:
              double.parse(sellingPriceCtrl.text.replaceAll(',', '.')),
          minimumStock: int.parse(minimumStockCtrl.text),
          expiredDate: expiredDate,
          description: descriptionCtrl.text.trim(),
          isActive: isActive.value,
        );
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
