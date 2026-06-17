import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
import '../../medicines/data/repositories/medicine_repository.dart' show MedicineQuery, MedicineRepository;
import '../../medicines/models/medicine_model.dart';
import '../data/repositories/stock_movement_repository.dart';
import '../models/stock_movement_model.dart';

class StockMovementListController extends GetxController {
  StockMovementListController(this._repo);

  final StockMovementRepository _repo;

  final RxList<StockMovementModel> items = <StockMovementModel>[].obs;
  final RxInt page = 1.obs;
  static const int limit = 20;
  final RxInt total = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();
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
        query: StockMovementQuery(
          page: page.value,
          limit: limit,
          type: typeFilter.value,
          startDate: startDate.value,
          endDate: endDate.value,
          medicineId: medicineId.value,
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

  void _apply(Paginated<StockMovementModel> result, {required bool reset}) {
    final filtered = _filterClientSide(result.items);
    if (reset) {
      items.assignAll(filtered);
    } else {
      items.addAll(filtered);
    }
    total.value = result.total;
    totalPages.value = result.totalPages;
  }

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
    if (isLoading.value || isLoadingMore.value) return;
    if (page.value >= totalPages.value) return;
    page.value += 1;
    await fetch(reset: false);
  }

  Future<void> setType(StockMovementType? type) async {
    typeFilter.value = type;
    await fetch();
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    startDate.value = start;
    endDate.value = end;
    await fetch();
  }

  Future<void> setMedicine(String? id) async {
    medicineId.value = id;
    await fetch();
  }

  Future<void> setNoteQuery(String? query) async {
    noteQuery.value = (query ?? '').isEmpty ? null : query;
    // No fetch — handled by client-side filter
    items.assignAll(_filterClientSide(items.toList()));
  }

  Future<void> setSearch(String value) async {
    search.value = value;
    items.assignAll(_filterClientSide(items.toList()));
  }

  Future<void> resetFilters() async {
    typeFilter.value = null;
    startDate.value = null;
    endDate.value = null;
    medicineId.value = null;
    noteQuery.value = null;
    search.value = '';
    await fetch();
  }

  @override
  Future<void> refresh() => fetch();
}
