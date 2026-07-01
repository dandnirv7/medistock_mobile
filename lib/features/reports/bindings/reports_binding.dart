import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../data/repositories/reports_repository.dart';
import '../controllers/stock_out_report_controller.dart';
import '../controllers/stock_report_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsRepository>(
      () => ReportsRepositoryImpl(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => StockReportController(Get.find<ReportsRepository>()),
    );
    Get.lazyPut(
      () => StockOutReportController(Get.find<ReportsRepository>()),
    );
  }
}
