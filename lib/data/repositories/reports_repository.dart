import '../../core/network/api_client.dart';
import '../models/stock_out_report_model.dart';
import '../models/stock_report_model.dart';

abstract class ReportsRepository {
  Future<List<StockReportItemModel>> getStockReport({
    String? categoryId,
    String? supplierId,
    String? status,
  });

  Future<StockOutReportModel> getStockOutReport({
    required String dateFrom,
    required String dateTo,
    String? medicineId,
    String? supplierId,
  });
}

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<StockReportItemModel>> getStockReport({
    String? categoryId,
    String? supplierId,
    String? status,
  }) async {
    final res = await _client.raw.get<Map<String, dynamic>>(
      '/reports/stock',
      queryParameters: {
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
        if (supplierId != null && supplierId.isNotEmpty)
          'supplierId': supplierId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final raw = (res.data?['data'] as List<dynamic>?) ?? [];
    return raw
        .map((e) =>
            StockReportItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StockOutReportModel> getStockOutReport({
    required String dateFrom,
    required String dateTo,
    String? medicineId,
    String? supplierId,
  }) async {
    final res = await _client.raw.get<Map<String, dynamic>>(
      '/reports/stock-out',
      queryParameters: {
        'date_from': dateFrom,
        'date_to': dateTo,
        if (medicineId != null && medicineId.isNotEmpty)
          'medicine_id': medicineId,
        if (supplierId != null && supplierId.isNotEmpty)
          'supplier_id': supplierId,
      },
    );
    final data =
        (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return StockOutReportModel.fromJson(data);
  }
}
