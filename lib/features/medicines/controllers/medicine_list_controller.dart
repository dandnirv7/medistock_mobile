import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/ui_state.dart';
import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class MedicineListController extends GetxController
    with AsyncListState<MedicineModel> {
  MedicineListController(this._repo, {ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final MedicineRepository _repo;
  final ApiClient _apiClient;

  // Monotonic token for load() calls. A response whose token does not match
  // the latest request is discarded, so filter swaps (e.g. tab changes in
  // Alerts) never let a stale response overwrite the current state.
  int _loadToken = 0;
  CancelToken? _activeToken;

  final RxInt page = 1.obs;
  static const int limit = 20;
  final RxInt total = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool isLoadingMore = false.obs;

  final RxString search = ''.obs;
  final RxnString categoryFilter = RxnString();
  final RxnString supplierFilter = RxnString();
  final RxBool lowStockOnly = false.obs;
  final Rx<MedicineExpiredFilter> expiredFilter =
      Rx<MedicineExpiredFilter>(MedicineExpiredFilter.all);

  /// Sort key + direction. Mirrors the API's accepted values.
  final RxString sortBy = 'createdAt'.obs;
  final RxString sortOrder = 'desc'.obs;

  // Debounces search-term changes so we issue one request after the user
  // pauses typing instead of one per keystroke.
  Worker? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    _searchDebounce = debounce<String>(
      search,
      (_) => load(),
      time: const Duration(milliseconds: 350),
    );
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  @override
  Future<void> load() async {
    final token = ++_loadToken;
    _activeToken?.cancel('superseded');
    final cancelToken = _apiClient.beginMedicinesRequest();
    _activeToken = cancelToken;
    page.value = 1;
    await runLoad(() async {
      try {
        final result =
            await _fetch(cancelToken: cancelToken);
        if (token != _loadToken || cancelToken.isCancelled) {
          return <MedicineModel>[];
        }
        total.value = result.total;
        totalPages.value = result.totalPages;
        return result.items;
      } on DioException catch (e) {
        // Cancelled in-flight requests are expected when the user changes
        // filters rapidly. Don't surface them as a user-visible error.
        if (CancelToken.isCancel(e)) {
          return <MedicineModel>[];
        }
        rethrow;
      }
    });
  }

  Future<void> fetch({bool reset = true}) async {
    final token = ++_loadToken;
    _activeToken?.cancel('superseded');
    final cancelToken = _apiClient.beginMedicinesRequest();
    _activeToken = cancelToken;

    if (reset) {
      page.value = 1;
    }
    isLoadingMore.value = !reset;
    state.value = ViewState.loading;
    errorMessage.value = '';
    try {
      final result = await _fetch(cancelToken: cancelToken);
      if (token != _loadToken || cancelToken.isCancelled) {
        return;
      }
      if (reset) {
        items.assignAll(result.items);
      } else {
        items.addAll(result.items);
      }
      total.value = result.total;
      totalPages.value = result.totalPages;
      state.value = items.isEmpty ? ViewState.empty : ViewState.content;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return;
      }
      errorMessage.value = _formatError(e);
      state.value = ViewState.error;
    } catch (e) {
      if (token != _loadToken || cancelToken.isCancelled) return;
      errorMessage.value = _formatError(e);
      state.value = ViewState.error;
    } finally {
      if (identical(_activeToken, cancelToken)) {
        _activeToken = null;
      }
      isLoadingMore.value = false;
    }
  }

  Future<Paginated<MedicineModel>> _fetch({CancelToken? cancelToken}) async {
    return _repo.getAll(
      query: MedicineQuery(
        page: page.value,
        limit: limit,
        search: search.value.trim().isEmpty ? null : search.value.trim(),
        categoryId: categoryFilter.value,
        supplierId: supplierFilter.value,
        lowStockOnly: lowStockOnly.value,
        expiredFilter: expiredFilter.value,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      ),
      cancelToken: cancelToken,
    );
  }

  Future<void> loadMore() async {
    if (state.value == ViewState.loading) return;
    if (isLoadingMore.value) return;
    if (page.value >= totalPages.value) return;
    page.value += 1;
    await fetch(reset: false);
  }

  Future<void> setSearch(String value) async {
    // Just record the term; the debounce worker triggers the actual load
    // once typing settles, avoiding a request per keystroke.
    search.value = value;
  }

  Future<void> setCategoryFilter(String? id) async {
    categoryFilter.value = id;
    await load();
  }

  Future<void> setSupplierFilter(String? id) async {
    supplierFilter.value = id;
    await load();
  }

  Future<void> setLowStockOnly(bool value) async {
    lowStockOnly.value = value;
    await load();
  }

  Future<void> setExpiredFilter(MedicineExpiredFilter f) async {
    expiredFilter.value = f;
    await load();
  }

  /// Apply a new sort key + direction and reload.
  Future<void> setSort(String by, String order) async {
    sortBy.value = by;
    sortOrder.value = order;
    await load();
  }

  Future<void> resetFilters() async {
    search.value = '';
    categoryFilter.value = null;
    supplierFilter.value = null;
    lowStockOnly.value = false;
    expiredFilter.value = MedicineExpiredFilter.all;
    await load();
  }

  Future<void> delete(MedicineModel m) async {
    await _repo.delete(m.id);
    items.removeWhere((e) => e.id == m.id);
  }

  @override
  void onClose() {
    // Cancel any in-flight medicines request so its callbacks cannot
    // mutate state after the controller is disposed (e.g. when leaving the
    // medicine list while a query is still pending).
    _searchDebounce?.dispose();
    _apiClient.cancelActiveMedicinesRequest();
    _activeToken = null;
    super.onClose();
  }

  @override
  Future<void> refresh() async {
    final token = ++_loadToken;
    _activeToken?.cancel('superseded');
    final cancelToken = _apiClient.beginMedicinesRequest();
    _activeToken = cancelToken;
    await runRefresh(() async {
      try {
        final result =
            await _fetch(cancelToken: cancelToken);
        if (token != _loadToken || cancelToken.isCancelled) {
          return items.toList();
        }
        return result.items;
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) {
          return items.toList();
        }
        rethrow;
      }
    });
  }

  String _formatError(Object e) {
    return ApiException.messageFrom(e);
  }
}
