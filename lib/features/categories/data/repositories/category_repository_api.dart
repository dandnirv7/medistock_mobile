import '../../../../core/models/paginated.dart';
import '../../../../core/network/api_client.dart';
import '../../models/category_model.dart';
import 'category_repository.dart';

class CategoryRepositoryApi implements CategoryRepository {
  CategoryRepositoryApi(this._client);

  final ApiClient _client;

  @override
  Future<Paginated<CategoryModel>> getAll({CategoryQuery? query}) async {
    final q = query ?? CategoryQuery();
    final res = await _client.raw.get<Map<String, dynamic>>(
      '/categories',
      queryParameters: {
        'page': q.page,
        'limit': q.limit,
        if (q.search != null && q.search!.isNotEmpty) 'search': q.search,
      },
    );
    return Paginated.fromJson(
      res.data ?? const {},
      CategoryModel.fromJson,
    );
  }

  @override
  Future<CategoryModel> getById(String id) async {
    final res = await _client.raw.get<Map<String, dynamic>>('/categories/$id');
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return CategoryModel.fromJson(data);
  }

  @override
  Future<CategoryModel> create({
    required String name,
    String? description,
  }) async {
    final res = await _client.raw.post<Map<String, dynamic>>(
      '/categories',
      data: {'name': name, 'description': description},
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return CategoryModel.fromJson(data);
  }

  @override
  Future<CategoryModel> update(
    String id, {
    String? name,
    String? description,
    bool? isActive,
  }) async {
    final res = await _client.raw.patch<Map<String, dynamic>>(
      '/categories/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive,
      },
    );
    final data = (res.data?['data'] as Map<String, dynamic>?) ?? const {};
    return CategoryModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) async {
    await _client.raw.delete<Map<String, dynamic>>('/categories/$id');
  }
}
