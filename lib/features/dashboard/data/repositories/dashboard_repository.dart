import '../../models/dashboard_summary_model.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getSummary();
}
