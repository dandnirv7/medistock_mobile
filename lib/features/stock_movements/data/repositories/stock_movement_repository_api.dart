import '../../../../core/models/paginated.dart';
import '../../../../core/network/api_client.dart';
import '../../models/stock_movement_model.dart';
import 'stock_movement_repository.dart';

class StockMovementRepositoryApi implements StockMovementRepository {
  StockMovementRepositoryApi(this._client);

  final ApiClient _client;

  Map<String, dynamic> _buildParams(StockMovementQuery q) {
    return {
      'page': q.page,
      'limit': q.limit,
      if (q.medicineId != null) 'medicineId': q.medicineId,
      if (q.type != null) 'type': q.type!.apiValue,
      if (q.reason != null) 'reason': q.reason!.apiValue,
      if (q.startDate != null) 'startDate': q.startDate!.toIso8601String().split('T').first,
      if (q.endDate != null) 'endDate': q.endDate!.toIso8601String().split('T').first,
    };
  }

  @override
  Future<Paginated<StockMovementModel>> getAll(
      {StockMovementQuery? query}) async {
    final q = query ?? StockMovementQuery();
    final res = await _client.raw.get<Map<String, dynamic>>(
      '/stock-movements',
      queryParameters: _buildParams(q),
    );
    return Paginated.fromJson(
      res.data ?? const {},
      StockMovementModel.fromJson,
    );
  }

  @override
  Future<StockMovementModel> stockIn({
    required String medicineId,
    int quantity = 0,
    String? supplierId,
    DateTime? transactionDate,
    String? notes,
  }) async {
    final res = await _client.raw.post<Map<String, dynamic>>(
      '/stock-movements/in',
      data: {
        'medicineId': medicineId,
        'quantity': quantity,
        if (supplierId != null) 'supplierId': supplierId,
        if (transactionDate != null) 'transactionDate': transactionDate.toIso8601String().split('T').first,
        if (notes != null) 'notes': notes,
      },
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return StockMovementModel.fromJson(data);
  }

  @override
  Future<StockMovementModel> stockOut({
    required String medicineId,
    int quantity = 0,
    DateTime? transactionDate,
    String? reasonLabel,
    String? notes,
  }) async {
    final res = await _client.raw.post<Map<String, dynamic>>(
      '/stock-movements/out',
      data: {
        'medicineId': medicineId,
        'quantity': quantity,
        'reason': reasonLabel,
        if (transactionDate != null) 'transactionDate': transactionDate.toIso8601String().split('T').first,
        if (notes != null) 'notes': notes,
      },
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return StockMovementModel.fromJson(data);
  }
}
