import 'package:get/get.dart';

import '../../stock_movements/data/repositories/stock_movement_repository.dart';
import '../../stock_movements/models/stock_movement_model.dart';
import '../data/repositories/dashboard_repository.dart';
import '../models/dashboard_summary_model.dart';

class DashboardController extends GetxController {
  DashboardController(this._repo) {
    // Pre-fetch movements in parallel through existing repo if registered.
    if (Get.isRegistered<StockMovementRepository>()) {
      _movementRepo = Get.find<StockMovementRepository>();
    }
  }

  final DashboardRepository _repo;
  StockMovementRepository? _movementRepo;

  final Rx<DashboardSummary?> summary = Rx<DashboardSummary?>(null);
  final RxList<StockMovementModel> recentMovements =
      RxList<StockMovementModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    refreshAll();
  }

  Future<void> refreshAll() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _repo.getSummary(),
        _movementRepo?.getAll() ??
            Future.value(<StockMovementModel>[]),
      ]);
      summary.value = results[0] as DashboardSummary;
      // We only need top 5 for the dashboard.
      final fetched = (results[1] as List).cast<StockMovementModel>();
      recentMovements.assignAll(fetched.take(5));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
