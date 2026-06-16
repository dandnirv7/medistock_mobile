import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
import '../data/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryListController extends GetxController {
  CategoryListController(this._repo);

  final CategoryRepository _repo;

  final RxList<CategoryModel> items = <CategoryModel>[].obs;
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
    isLoading.value = reset ? true : isLoading.value;
    isLoadingMore.value = reset ? false : true;
    errorMessage.value = null;
    try {
      final result = await _repo.getAll(
        query: CategoryQuery(
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

  void _apply(Paginated<CategoryModel> result, {required bool reset}) {
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
    page.value = page.value + 1;
    await fetch(reset: false);
  }

  Future<void> setSearch(String value) async {
    search.value = value;
    await fetch();
  }

  Future<void> delete(CategoryModel c) async {
    await _repo.delete(c.id);
    items.removeWhere((e) => e.id == c.id);
  }

  @override
  Future<void> refresh() => fetch();
}
