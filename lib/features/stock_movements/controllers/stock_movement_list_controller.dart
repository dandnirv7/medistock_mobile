import 'package:get/get.dart';

import '../../../core/models/paginated.dart';
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
        query: StockMovementQuery(
          page: page.value,
          limit: limit,
          type: typeFilter.value,
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

  Future<void> setType(StockMovementType? type) async {
    typeFilter.value = type;
    await fetch();
  }

  @override
  Future<void> refresh() => fetch();
}
