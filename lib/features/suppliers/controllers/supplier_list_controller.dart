import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
import '../../../core/utils/ui_state.dart';
import '../data/repositories/supplier_repository.dart';
import '../models/supplier_model.dart';

class SupplierListController extends GetxController
    with AsyncListState<SupplierModel> {
  SupplierListController(this._repo);

  final SupplierRepository _repo;

  final RxInt page = 1.obs;
  static const int limit = 20;
  final RxInt total = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString search = ''.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  @override
  Future<void> load() async {
    page.value = 1;
    await runLoad(_fetchItems);
  }

  Future<void> fetch({bool reset = true}) async {
    if (reset) {
      page.value = 1;
    }
    isLoadingMore.value = !reset;
    state.value = ViewState.loading;
    errorMessage.value = '';
    try {
      final result = await _fetch();
      if (reset) {
        items.assignAll(result.items);
      } else {
        items.addAll(result.items);
      }
      total.value = result.total;
      totalPages.value = result.totalPages;
      state.value = items.isEmpty ? ViewState.empty : ViewState.content;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ViewState.error;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<List<SupplierModel>> _fetchItems() async => (await _fetch()).items;
  Future<Paginated<SupplierModel>> _fetch() => _repo.getAll(
        query: SupplierQuery(
          page: page.value,
          limit: limit,
          search: search.value.trim().isEmpty ? null : search.value.trim(),
        ),
      );

  Future<void> loadMore() async {
    if (state.value == ViewState.loading) return;
    if (isLoadingMore.value) return;
    if (page.value >= totalPages.value) return;
    page.value += 1;
    await fetch(reset: false);
  }

  Future<void> setSearch(String value) async {
    search.value = value;
    await load();
  }

  Future<void> delete(SupplierModel s) async {
    await _repo.delete(s.id);
    items.removeWhere((e) => e.id == s.id);
  }

  @override
  Future<void> refresh() => runRefresh(_fetchItems);
}
