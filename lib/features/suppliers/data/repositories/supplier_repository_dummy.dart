import '../../../../data/dummy/dummy_store.dart';
import '../../../../core/models/paginated.dart';
import '../../models/supplier_model.dart';
import 'supplier_repository.dart';

class SupplierRepositoryDummy implements SupplierRepository {
  SupplierRepositoryDummy() : _store = DummyStore.instance;

  final DummyStore _store;

  List<SupplierModel> _applyQuery(
    SupplierQuery q,
    List<SupplierModel> source,
  ) {
    var items = source.where((s) => s.isActive).toList();
    if (q.search != null && q.search!.trim().isNotEmpty) {
      final s = q.search!.toLowerCase();
      items = items
          .where((e) =>
              e.name.toLowerCase().contains(s) ||
              (e.phone?.toLowerCase().contains(s) ?? false) ||
              (e.email?.toLowerCase().contains(s) ?? false))
          .toList();
    }
    return items;
  }

  @override
  Future<Paginated<SupplierModel>> getAll({SupplierQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query ?? SupplierQuery();
    final filtered = _applyQuery(q, _store.suppliersMutable);
    final total = filtered.length;
    final start = (q.page - 1) * q.limit;
    final end = (start + q.limit).clamp(0, total);
    final pageItems =
        start >= total ? <SupplierModel>[] : filtered.sublist(start, end);
    final totalPages = (total / q.limit).ceil().clamp(1, 1 << 30);
    return Paginated<SupplierModel>(
      items: pageItems,
      page: q.page,
      limit: q.limit,
      total: total,
      totalPages: totalPages == 0 ? 1 : totalPages,
    );
  }

  @override
  Future<SupplierModel> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.suppliersMutable.firstWhere((s) => s.id == id);
  }

  @override
  Future<SupplierModel> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final id =
        'sup-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    final now = DateTime.now();
    final created = SupplierModel(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    _store.suppliersMutable.add(created);
    return created;
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
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _store.suppliersMutable.indexWhere((s) => s.id == id);
    if (idx < 0) throw Exception('Supplier tidak ditemukan');
    final current = _store.suppliersMutable[idx];
    final updated = current.copyWith(
      name: name,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
      isActive: isActive,
    );
    _store.suppliersMutable[idx] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _store.suppliersMutable.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    final current = _store.suppliersMutable[idx];
    _store.suppliersMutable[idx] =
        current.copyWith(isActive: false);
  }
}
