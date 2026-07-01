import 'package:get/get.dart';

import '../data/repositories/dashboard_repository.dart';
import '../models/dashboard_summary_model.dart';

class DashboardController extends GetxController {
  DashboardController(this._repo);

  final DashboardRepository _repo;

  final Rx<DashboardSummary?> summary = Rx<DashboardSummary?>(null);
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
      summary.value = await _repo.getSummary();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
