import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
import '../data/repositories/supplier_repository.dart';
import '../models/supplier_model.dart';

class SupplierListController extends GetxController {
  SupplierListController(this._repo);

  final SupplierRepository _repo;

  final RxList<SupplierModel> items = <SupplierModel>[].obs;
  final RxInt page = 1.obs;
  static const int limit = 20;
  final RxInt total = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString search = ''.obs;

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
        query: SupplierQuery(
          page: page.value,
          limit: limit,
          search: search.value.trim().isEmpty ? null : search.value.trim(),
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

  void _apply(Paginated<SupplierModel> result, {required bool reset}) {
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

  Future<void> delete(SupplierModel s) async {
    await _repo.delete(s.id);
    items.removeWhere((e) => e.id == s.id);
  }

  @override
  Future<void> refresh() => fetch();
}
