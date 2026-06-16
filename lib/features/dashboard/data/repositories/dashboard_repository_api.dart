import '../../../../core/network/api_client.dart';
import '../../models/dashboard_summary_model.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryApi implements DashboardRepository {
  DashboardRepositoryApi(this._client);

  final ApiClient _client;

  @override
  Future<DashboardSummary> getSummary() async {
    final res =
        await _client.raw.get<Map<String, dynamic>>('/dashboard/summary');
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return DashboardSummary.fromJson(data);
  }
}
