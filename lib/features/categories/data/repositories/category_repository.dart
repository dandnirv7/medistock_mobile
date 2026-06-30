import '../../../../core/models/paginated.dart';
import '../../models/category_model.dart';

class CategoryQuery {
  CategoryQuery({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.sortBy,
    this.sortOrder,
  });

  final int page;
  final int limit;
  final String? search;

  /// One of: name, createdAt, medicineCount.
  final String? sortBy;

  /// 'asc' or 'desc'. Defaults to 'asc' when null.
  final String? sortOrder;
}

abstract class CategoryRepository {
  Future<Paginated<CategoryModel>> getAll({CategoryQuery? query});

  Future<CategoryModel> getById(String id);

  Future<CategoryModel> create({required String name, String? description});

  Future<CategoryModel> update(
    String id, {
    String? name,
    String? description,
    bool? isActive,
  });

  Future<void> delete(String id);
}
