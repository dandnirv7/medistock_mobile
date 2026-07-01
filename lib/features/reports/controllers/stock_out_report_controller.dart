import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/stock_out_report_model.dart';
import '../../../data/repositories/reports_repository.dart';

class StockOutReportController extends GetxController {
  StockOutReportController(this._repo);

  final ReportsRepository _repo;

  final RxBool isLoading = false.obs;
  final Rxn<StockOutReportModel> report = Rxn<StockOutReportModel>();
  final RxString errorMessage = ''.obs;

  // Date range — default to current month
  late final Rx<DateTime> dateFrom;
  late final Rx<DateTime> dateTo;

  // Optional filters
  final RxString medicineId = ''.obs;
  final RxString supplierId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    dateFrom = DateTime(now.year, now.month, 1).obs;
    dateTo = DateTime(now.year, now.month + 1, 0).obs;
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repo.getStockOutReport(
        dateFrom: _fmt(dateFrom.value),
        dateTo: _fmt(dateTo.value),
        medicineId:
            medicineId.value.isEmpty ? null : medicineId.value,
        supplierId:
            supplierId.value.isEmpty ? null : supplierId.value,
      );
      report.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setDateRange(DateTime from, DateTime to) {
    dateFrom.value = from;
    dateTo.value = to;
    load();
  }

  void setFilter({String? medicine, String? supplier}) {
    if (medicine != null) medicineId.value = medicine;
    if (supplier != null) supplierId.value = supplier;
    load();
  }

  void clearFilters() {
    medicineId.value = '';
    supplierId.value = '';
    load();
  }

  String _fmt(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
}
