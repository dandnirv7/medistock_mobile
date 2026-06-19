import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/ui_state.dart';
import '../../medicines/data/repositories/medicine_repository.dart'
    show MedicineQuery, MedicineRepository;
import '../../medicines/models/medicine_model.dart';
import '../data/repositories/stock_movement_repository.dart';
import '../models/stock_movement_model.dart';

class StockMovementListController extends GetxController
    with AsyncListState<StockMovementModel> {
  StockMovementListController(this._repo);

  final StockMovementRepository _repo;

  final RxInt page = 1.obs;
  static const int limit = 20;
  final RxInt total = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool isLoadingMore = false.obs;
  final Rxn<StockMovementType> typeFilter = Rxn<StockMovementType>();
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();
  final RxnString medicineId = RxnString();
  final RxnString noteQuery = RxnString();
  final RxString search = ''.obs;

  // Cached list of medicines used by the filter sheet
  final RxList<MedicineModel> medicineOptions = <MedicineModel>[].obs;

  bool get hasActiveFilters =>
      typeFilter.value != null ||
      startDate.value != null ||
      endDate.value != null ||
      medicineId.value != null ||
      (noteQuery.value != null && noteQuery.value!.isNotEmpty) ||
      search.value.isNotEmpty;

  DateTime? _lastFetchAt;
  static const Duration _cooldown = Duration(seconds: 10);

  @override
  void onReady() {
    super.onReady();
    _loadMedicineOptions();
    _maybeFetch();
  }

  void _maybeFetch({bool reset = true}) {
    if (_lastFetchAt != null &&
        DateTime.now().difference(_lastFetchAt!) < _cooldown) {
      return;
    }
    _lastFetchAt = DateTime.now();
    fetch(reset: reset);
  }

  Future<void> _loadMedicineOptions() async {
    if (!Get.isRegistered<MedicineRepository>()) return;
    final repo = Get.find<MedicineRepository>();
    try {
      final result = await repo.getAll(query: MedicineQuery(limit: 100, page: 1));
      medicineOptions.assignAll(result.items);
    } catch (_) {
      // Best-effort; sheet will simply show empty list.
    }
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
      final filtered = _filterClientSide(result.items);
      if (reset) {
        items.assignAll(filtered);
      } else {
        items.addAll(filtered);
      }
      total.value = result.total;
      totalPages.value = result.totalPages;
      state.value = items.isEmpty ? ViewState.empty : ViewState.content;
    } catch (e) {
      errorMessage.value = ApiException.messageFrom(e);
      state.value = ViewState.error;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<List<StockMovementModel>> _fetchItems() async => _filterClientSide(
        (await _fetch()).items,
      );
  Future<Paginated<StockMovementModel>> _fetch() => _repo.getAll(
        query: StockMovementQuery(
          page: page.value,
          limit: limit,
          type: typeFilter.value,
          startDate: startDate.value,
          endDate: endDate.value,
          medicineId: medicineId.value,
        ),
      );

  /// Client-side filter for things the API does not support (search in
  /// medicine name and note substring).
  List<StockMovementModel> _filterClientSide(List<StockMovementModel> source) {
    final searchLower = search.value.trim().toLowerCase();
    final noteLower = noteQuery.value?.trim().toLowerCase() ?? '';
    if (searchLower.isEmpty && noteLower.isEmpty) return source;
    return source.where((m) {
      if (searchLower.isNotEmpty) {
        final inName = (m.medicineName ?? '').toLowerCase().contains(searchLower);
        final inCode = (m.medicineCode ?? '').toLowerCase().contains(searchLower);
        final inSupplier =
            (m.supplierName ?? '').toLowerCase().contains(searchLower);
        if (!inName && !inCode && !inSupplier) return false;
      }
      if (noteLower.isNotEmpty) {
        if (!(m.notes ?? '').toLowerCase().contains(noteLower)) return false;
      }
      return true;
    }).toList();
  }

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

  Future<void> setType(StockMovementType? type) async {
    typeFilter.value = type;
    await load();
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    startDate.value = start;
    endDate.value = end;
    await load();
  }

  Future<void> setMedicine(String? id) async {
    medicineId.value = id;
    await load();
  }

  Future<void> setNoteQuery(String? query) async {
    noteQuery.value = (query ?? '').isEmpty ? null : query;
    items.assignAll(_filterClientSide(items.toList()));
  }

  Future<void> resetFilters() async {
    typeFilter.value = null;
    startDate.value = null;
    endDate.value = null;
    medicineId.value = null;
    noteQuery.value = null;
    search.value = '';
    await load();
  }

  @override
  Future<void> refresh() => runRefresh(_fetchItems);
}
