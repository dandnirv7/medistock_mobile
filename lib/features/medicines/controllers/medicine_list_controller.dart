import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineListController extends GetxController {
  MedicineListController(this._repo);

  final MedicineRepository _repo;

  final RxList<MedicineModel> items = <MedicineModel>[].obs;
  final RxInt page = 1.obs;
  static const int limit = 20;
  final RxInt total = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();

  final RxString search = ''.obs;
  final RxnString categoryFilter = RxnString();
  final RxnString supplierFilter = RxnString();
  final RxBool lowStockOnly = false.obs;
  final Rx<MedicineExpiredFilter> expiredFilter =
      Rx<MedicineExpiredFilter>(MedicineExpiredFilter.all);

  @override
  void onReady() {
    super.onReady();
    fetch();
  }

  Future<void> fetch({bool reset = true}) async {
    if (reset) {
      page.value = 1;
      items.clear();
    }
    isLoading.value = reset;
    isLoadingMore.value = !reset;
    errorMessage.value = null;
    try {
      final result = await _repo.getAll(
        query: MedicineQuery(
          page: page.value,
          limit: limit,
          search: search.value.trim().isEmpty ? null : search.value.trim(),
          categoryId: categoryFilter.value,
          supplierId: supplierFilter.value,
          lowStockOnly: lowStockOnly.value,
          expiredFilter: expiredFilter.value,
        ),
      );
      _apply(result, reset: reset);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _apply(Paginated<MedicineModel> result, {required bool reset}) {
    if (reset) {
      items.assignAll(result.items);
    } else {
      items.addAll(result.items);
    }
    total.value = result.total;
    totalPages.value = result.totalPages;
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value) return;
    if (page.value >= totalPages.value) return;
    page.value += 1;
    await fetch(reset: false);
  }

  Future<void> setSearch(String value) async {
    search.value = value;
    await fetch();
  }

  Future<void> setCategoryFilter(String? id) async {
    categoryFilter.value = id;
    await fetch();
  }

  Future<void> setSupplierFilter(String? id) async {
    supplierFilter.value = id;
    await fetch();
  }

  Future<void> setLowStockOnly(bool value) async {
    lowStockOnly.value = value;
    await fetch();
  }

  Future<void> setExpiredFilter(MedicineExpiredFilter f) async {
    expiredFilter.value = f;
    await fetch();
  }

  Future<void> resetFilters() async {
    search.value = '';
    categoryFilter.value = null;
    supplierFilter.value = null;
    lowStockOnly.value = false;
    expiredFilter.value = MedicineExpiredFilter.all;
    await fetch();
  }

  Future<void> delete(MedicineModel m) async {
    await _repo.delete(m.id);
    items.removeWhere((e) => e.id == m.id);
  }

  @override
  Future<void> refresh() => fetch();
}
