import '../../../../data/dummy/dummy_store.dart';
import '../../../../core/models/paginated.dart';
import '../../../categories/models/category_model.dart';
import '../../../suppliers/models/supplier_model.dart';
import '../../models/medicine_model.dart';
import 'medicine_repository.dart';

class MedicineRepositoryDummy implements MedicineRepository {
  MedicineRepositoryDummy() : _store = DummyStore.instance;

  final DummyStore _store;

  List<MedicineModel> _applyQuery(MedicineQuery q, List<MedicineModel> src) {
    var items = src.where((m) => m.isActive).toList();

    if (q.search != null && q.search!.trim().isNotEmpty) {
      final s = q.search!.toLowerCase();
      items = items
          .where((m) =>
              m.name.toLowerCase().contains(s) ||
              m.code.toLowerCase().contains(s) ||
              (m.supplierName?.toLowerCase().contains(s) ?? false) ||
              (m.categoryName?.toLowerCase().contains(s) ?? false))
          .toList();
    }
    if (q.categoryId != null) {
      items = items.where((m) => m.categoryId == q.categoryId).toList();
    }
    if (q.supplierId != null) {
      items = items.where((m) => m.supplierId == q.supplierId).toList();
    }
    if (q.lowStockOnly) {
      items = items.where((m) => m.isLowStock).toList();
    }
    switch (q.expiredFilter) {
      case MedicineExpiredFilter.soon:
        items = items.where((m) => m.isExpiredSoon).toList();
        break;
      case MedicineExpiredFilter.expired:
        items = items.where((m) => m.isExpired).toList();
        break;
      case MedicineExpiredFilter.safe:
        items = items.where((m) =>
            m.expiredDate != null &&
            !m.isExpired &&
            !m.isExpiredSoon).toList();
        break;
      case MedicineExpiredFilter.all:
        break;
    }
    return items;
  }

  @override
  Future<Paginated<MedicineModel>> getAll({MedicineQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query ?? MedicineQuery();
    final filtered = _applyQuery(q, _store.medicinesMutable);
    final total = filtered.length;
    final start = (q.page - 1) * q.limit;
    final end = (start + q.limit).clamp(0, total);
    final pageItems =
        start >= total ? <MedicineModel>[] : filtered.sublist(start, end);
    final totalPages = (total / q.limit).ceil().clamp(1, 1 << 30);
    return Paginated<MedicineModel>(
      items: pageItems,
      page: q.page,
      limit: q.limit,
      total: total,
      totalPages: totalPages == 0 ? 1 : totalPages,
    );
  }

  @override
  Future<MedicineModel> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.medicinesMutable.firstWhere((m) => m.id == id);
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
    await Future.delayed(const Duration(milliseconds: 300));
    final exists = _store.medicinesMutable
        .any((m) => m.code.toLowerCase() == code.toLowerCase() && m.isActive);
    if (exists) {
      throw Exception('Kode obat sudah digunakan');
    }
    final id =
        'med-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    final now = DateTime.now();
    final category = categoryId == null
        ? null
        : _store.categoriesMutable
            .where((c) => c.id == categoryId)
            .cast<CategoryModel?>()
            .firstWhere((_) => true, orElse: () => null);
    final supplier = supplierId == null
        ? null
        : _store.suppliersMutable
            .where((s) => s.id == supplierId)
            .cast<SupplierModel?>()
            .firstWhere((_) => true, orElse: () => null);
    final created = MedicineModel(
      id: id,
      code: code,
      name: name,
      categoryId: categoryId,
      categoryName: category?.name,
      supplierId: supplierId,
      supplierName: supplier?.name,
      unit: unit,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minimumStock: minimumStock,
      expiredDate: expiredDate,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    _store.medicinesMutable.add(created);
    return created;
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
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _store.medicinesMutable.indexWhere((m) => m.id == id);
    if (idx < 0) throw Exception('Obat tidak ditemukan');
    final current = _store.medicinesMutable[idx];
    String? catName = current.categoryName;
    String? supName = current.supplierName;
    if (categoryId != null) {
      final match = _store.categoriesMutable
          .where((c) => c.id == categoryId)
          .toList();
      catName = match.isEmpty ? null : match.first.name;
    }
    if (supplierId != null) {
      final match = _store.suppliersMutable
          .where((s) => s.id == supplierId)
          .toList();
      supName = match.isEmpty ? null : match.first.name;
    }
    final updated = current.copyWith(
      code: code,
      name: name,
      categoryId: categoryId,
      categoryName: catName,
      supplierId: supplierId,
      supplierName: supName,
      unit: unit,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      minimumStock: minimumStock,
      expiredDate: expiredDate,
      description: description,
      isActive: isActive,
    );
    _store.medicinesMutable[idx] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _store.medicinesMutable.indexWhere((m) => m.id == id);
    if (idx < 0) return;
    final current = _store.medicinesMutable[idx];
    _store.medicinesMutable[idx] = current.copyWith(isActive: false);
  }
}
