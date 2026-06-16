import '../../../../core/models/paginated.dart';
import '../../../../core/network/api_client.dart';
import '../../models/supplier_model.dart';
import 'supplier_repository.dart';

class SupplierRepositoryApi implements SupplierRepository {
  SupplierRepositoryApi(this._client);

  final ApiClient _client;

  @override
  Future<Paginated<SupplierModel>> getAll({SupplierQuery? query}) async {
    final q = query ?? SupplierQuery();
    final res = await _client.raw.get<Map<String, dynamic>>(
      '/suppliers',
      queryParameters: {
        'page': q.page,
        'limit': q.limit,
        if (q.search != null && q.search!.isNotEmpty) 'search': q.search,
      },
    );
    return Paginated.fromJson(
      res.data ?? const {},
      SupplierModel.fromJson,
    );
  }

  @override
  Future<SupplierModel> getById(String id) async {
    final res = await _client.raw.get<Map<String, dynamic>>('/suppliers/$id');
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return SupplierModel.fromJson(data);
  }

  @override
  Future<SupplierModel> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    final res = await _client.raw.post<Map<String, dynamic>>(
      '/suppliers',
      data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (notes != null) 'notes': notes,
      },
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return SupplierModel.fromJson(data);
  }

  @override
  Future<SupplierModel> update(
    String id, {
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    bool? isActive,
  }) async {
    final res = await _client.raw.patch<Map<String, dynamic>>(
      '/suppliers/$id',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (notes != null) 'notes': notes,
        if (isActive != null) 'isActive': isActive,
      },
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return SupplierModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await _client.raw.delete<Map<String, dynamic>>('/suppliers/$id');
  }
}
