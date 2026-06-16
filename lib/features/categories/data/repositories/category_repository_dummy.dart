import '../../../../data/dummy/dummy_store.dart';
import '../../../../core/models/paginated.dart';
import '../../models/category_model.dart';
import 'category_repository.dart';

class CategoryRepositoryDummy implements CategoryRepository {
  CategoryRepositoryDummy() : _store = DummyStore.instance;

  final DummyStore _store;

  List<CategoryModel> _applyQuery(CategoryQuery q, List<CategoryModel> source) {
    var items = source.where((c) => c.isActive).toList();
    if (q.search != null && q.search!.trim().isNotEmpty) {
      final s = q.search!.toLowerCase();
      items = items
          .where((c) =>
              c.name.toLowerCase().contains(s) ||
              (c.description?.toLowerCase().contains(s) ?? false))
          .toList();
    }
    return items;
  }

  @override
  Future<Paginated<CategoryModel>> getAll({CategoryQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query ?? CategoryQuery();
    final filtered = _applyQuery(q, _store.categoriesMutable);
    final total = filtered.length;
    final start = (q.page - 1) * q.limit;
    final end = (start + q.limit).clamp(0, total);
    final pageItems =
        start >= total ? <CategoryModel>[] : filtered.sublist(start, end);
    final totalPages = (total / q.limit).ceil().clamp(1, 1 << 30);
    return Paginated<CategoryModel>(
      items: pageItems,
      page: q.page,
      limit: q.limit,
      total: total,
      totalPages: totalPages == 0 ? 1 : totalPages,
    );
  }

  @override
  Future<CategoryModel> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.categoriesMutable.firstWhere((c) => c.id == id);
  }

  @override
  Future<CategoryModel> create({
    required String name,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final exists = _store.categoriesMutable
        .any((c) => c.name.toLowerCase() == name.toLowerCase() && c.isActive);
    if (exists) {
      throw Exception('Kategori dengan nama tersebut sudah ada');
    }
    final id =
        'cat-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    final now = DateTime.now();
    final created = CategoryModel(
      id: id,
      name: name,
      description: description,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    _store.categoriesMutable.add(created);
    return created;
  }

  @override
  Future<CategoryModel> update(
    String id, {
    String? name,
    String? description,
    bool? isActive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _store.categoriesMutable.indexWhere((c) => c.id == id);
    if (idx < 0) throw Exception('Kategori tidak ditemukan');
    final current = _store.categoriesMutable[idx];
    final updated = current.copyWith(
      name: name,
      description: description,
      isActive: isActive,
    );
    _store.categoriesMutable[idx] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _store.categoriesMutable.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    final current = _store.categoriesMutable[idx];
    _store.categoriesMutable[idx] =
        current.copyWith(isActive: false);
  }
}
