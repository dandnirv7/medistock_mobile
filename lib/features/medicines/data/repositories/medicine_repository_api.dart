import '../../../../core/models/paginated.dart';
import '../../../../core/network/api_client.dart';
import '../../models/medicine_model.dart';
import 'medicine_repository.dart';

class MedicineRepositoryApi implements MedicineRepository {
  MedicineRepositoryApi(this._client);

  final ApiClient _client;

  Map<String, dynamic> _buildParams(MedicineQuery q) {
    return {
      'page': q.page,
      'limit': q.limit,
      if (q.search != null && q.search!.isNotEmpty) 'search': q.search,
      if (q.categoryId != null) 'categoryId': q.categoryId,
      if (q.supplierId != null) 'supplierId': q.supplierId,
      if (q.lowStockOnly) 'lowStock': 'true',
      if (q.expiredFilter != MedicineExpiredFilter.all)
        'expiredStatus': switch (q.expiredFilter) {
          MedicineExpiredFilter.soon => 'soon',
          MedicineExpiredFilter.expired => 'expired',
          MedicineExpiredFilter.safe => 'safe',
          MedicineExpiredFilter.all => null,
        },
    };
  }

  @override
  Future<Paginated<MedicineModel>> getAll({MedicineQuery? query}) async {
    final q = query ?? MedicineQuery();
    final res = await _client.raw.get<Map<String, dynamic>>(
      '/medicines',
      queryParameters: _buildParams(q),
    );
    return Paginated.fromJson(
      res.data ?? const {},
      MedicineModel.fromJson,
    );
  }

  @override
  Future<MedicineModel> getById(String id) async {
    final res = await _client.raw.get<Map<String, dynamic>>('/medicines/$id');
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return MedicineModel.fromJson(data);
  }

  @override
  Future<MedicineModel> create({
    required String code,
    required String name,
    String? categoryId,
    String? supplierId,
    required String unit,
    required double purchasePrice,
    required double sellingPrice,
    int currentStock = 0,
    required int minimumStock,
    DateTime? expiredDate,
    String? description,
  }) async {
    final res = await _client.raw.post<Map<String, dynamic>>(
      '/medicines',
      data: {
        'code': code,
        'name': name,
        if (categoryId != null) 'categoryId': categoryId,
        if (supplierId != null) 'supplierId': supplierId,
        'unit': unit,
        'purchasePrice': purchasePrice,
        'sellingPrice': sellingPrice,
        'currentStock': currentStock,
        'minimumStock': minimumStock,
        if (expiredDate != null) 'expiredDate': expiredDate.toIso8601String().split('T').first,
        if (description != null) 'description': description,
      },
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    // Server returns only id/code/name/currentStock — enrich from request body.
    return MedicineModel.fromJson({
      'id': data['id'],
      'code': data['code'] ?? code,
      'name': data['name'] ?? name,
      'unit': unit,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'currentStock': data['currentStock'] ?? currentStock,
      'minimumStock': minimumStock,
      'expiredDate': expiredDate?.toIso8601String().split('T').first,
      'description': description,
      'categoryId': categoryId,
      'supplierId': supplierId,
    });
  }

  @override
  Future<MedicineModel> update(
    String id, {
    String? code,
    String? name,
    String? categoryId,
    String? supplierId,
    String? unit,
    double? purchasePrice,
    double? sellingPrice,
    int? minimumStock,
    DateTime? expiredDate,
    String? description,
    bool? isActive,
  }) async {
    final res = await _client.raw.patch<Map<String, dynamic>>(
      '/medicines/$id',
      data: {
        if (code != null) 'code': code,
        if (name != null) 'name': name,
        if (categoryId != null) 'categoryId': categoryId,
        if (supplierId != null) 'supplierId': supplierId,
        if (unit != null) 'unit': unit,
        if (purchasePrice != null) 'purchasePrice': purchasePrice,
        if (sellingPrice != null) 'sellingPrice': sellingPrice,
        if (minimumStock != null) 'minimumStock': minimumStock,
        if (expiredDate != null) 'expiredDate': expiredDate.toIso8601String().split('T').first,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive,
      },
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return MedicineModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await _client.raw.delete<Map<String, dynamic>>('/medicines/$id');
  }
}
