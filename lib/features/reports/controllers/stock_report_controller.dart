import 'package:get/get.dart';

import '../../../data/models/stock_report_model.dart';
import '../../../data/repositories/reports_repository.dart';

class StockReportController extends GetxController {
  StockReportController(this._repo);

  final ReportsRepository _repo;

  final RxBool isLoading = false.obs;
  final RxList<StockReportItemModel> items = <StockReportItemModel>[].obs;
  final RxString errorMessage = ''.obs;

  // Filters
  final RxString categoryId = ''.obs;
  final RxString supplierId = ''.obs;
  final RxString status = ''.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repo.getStockReport(
        categoryId: categoryId.value.isEmpty ? null : categoryId.value,
        supplierId: supplierId.value.isEmpty ? null : supplierId.value,
        status: status.value.isEmpty ? null : status.value,
      );
      items.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter({String? category, String? supplier, String? stockStatus}) {
    if (category != null) categoryId.value = category;
    if (supplier != null) supplierId.value = supplier;
    if (stockStatus != null) status.value = stockStatus;
    load();
  }

  void clearFilters() {
    categoryId.value = '';
    supplierId.value = '';
    status.value = '';
    load();
  }
}
