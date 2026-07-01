import '../../../../data/dummy/dummy_store.dart';
import '../../../../core/models/paginated.dart';
import '../../models/stock_movement_model.dart';
import 'stock_movement_repository.dart';

class StockMovementRepositoryDummy implements StockMovementRepository {
  StockMovementRepositoryDummy() : _store = DummyStore.instance;

  final DummyStore _store;

  List<StockMovementModel> _applyQuery(
    StockMovementQuery q,
    List<StockMovementModel> src,
  ) {
    var items = List<StockMovementModel>.from(src);
    if (q.medicineId != null) {
      items = items.where((m) => m.medicineId == q.medicineId).toList();
    }
    if (q.type != null) {
      items = items.where((m) => m.type == q.type).toList();
    }
    if (q.reason != null) {
      items = items.where((m) => m.reason == q.reason).toList();
    }
    if (q.startDate != null) {
      final start = DateTime(
        q.startDate!.year,
        q.startDate!.month,
        q.startDate!.day,
      );
      items = items.where((m) {
        final date = m.transactionDate;
        if (date == null) return false;
        return !date.isBefore(start);
      }).toList();
    }
    if (q.endDate != null) {
      final end = DateTime(
        q.endDate!.year,
        q.endDate!.month,
        q.endDate!.day,
      ).add(const Duration(days: 1));
      items = items.where((m) {
        final date = m.transactionDate;
        if (date == null) return false;
        return date.isBefore(end);
      }).toList();
    }
    items.sort((a, b) {
      final ad = a.transactionDate ?? a.createdAt ?? DateTime(1970);
      final bd = b.transactionDate ?? b.createdAt ?? DateTime(1970);
      return bd.compareTo(ad);
    });
    return items;
  }

  @override
  Future<Paginated<StockMovementModel>> getAll(
      {StockMovementQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query ?? StockMovementQuery();
    final filtered = _applyQuery(q, _store.movementsMutable);
    final total = filtered.length;
    final start = (q.page - 1) * q.limit;
    final end = (start + q.limit).clamp(0, total);
    final pageItems = start >= total
        ? <StockMovementModel>[]
        : filtered.sublist(start, end);
    final totalPages = (total / q.limit).ceil().clamp(1, 1 << 30);
    return Paginated<StockMovementModel>(
      items: pageItems,
      page: q.page,
      limit: q.limit,
      total: total,
      totalPages: totalPages == 0 ? 1 : totalPages,
    );
  }

  @override
  Future<StockMovementModel> stockIn({
    required String medicineId,
    int quantity = 0,
    String? supplierId,
    DateTime? transactionDate,
    String? notes,
    String? batchNumber,
    DateTime? expiredDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (quantity <= 0) {
      throw Exception('Jumlah harus lebih dari 0');
    }
    final medIdx =
        _store.medicinesMutable.indexWhere((m) => m.id == medicineId);
    if (medIdx < 0) {
      throw Exception('Obat tidak ditemukan');
    }
    final current = _store.medicinesMutable[medIdx];
    final stockBefore = current.currentStock;
    final stockAfter = stockBefore + quantity;
    final updated = current.copyWith(currentStock: stockAfter);
    _store.medicinesMutable[medIdx] = updated;

    String? supplierName;
    if (supplierId != null) {
      final match = _store.suppliersMutable
          .where((s) => s.id == supplierId)
          .toList();
      supplierName = match.isEmpty ? null : match.first.name;
    }
    final now = DateTime.now();
    final movement = StockMovementModel(
      id: 'mv-${now.microsecondsSinceEpoch.toRadixString(16)}',
      type: StockMovementType.stockIn,
      reason: StockMovementReason.purchase,
      medicineId: medicineId,
      medicineCode: updated.code,
      medicineName: updated.name,
      medicineUnit: updated.unit,
      supplierId: supplierId,
      supplierName: supplierName,
      userId: 'user-1',
      userName: 'Admin Apotek',
      quantity: quantity,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      transactionDate: transactionDate ?? now,
      notes: notes,
      createdAt: now,
    );
    _store.movementsMutable.insert(0, movement);
    return movement;
  }

  @override
  Future<StockMovementModel> stockOut({
    required String medicineId,
    int quantity = 0,
    DateTime? transactionDate,
    String? reasonLabel,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (quantity <= 0) {
      throw Exception('Jumlah harus lebih dari 0');
    }
    final medIdx =
        _store.medicinesMutable.indexWhere((m) => m.id == medicineId);
    if (medIdx < 0) {
      throw Exception('Obat tidak ditemukan');
    }
    final current = _store.medicinesMutable[medIdx];
    if (current.currentStock < quantity) {
      throw Exception(
          'Stok tidak mencukupi. Tersisa ${current.currentStock}, diminta $quantity');
    }
    final stockBefore = current.currentStock;
    final stockAfter = stockBefore - quantity;
    final updated = current.copyWith(currentStock: stockAfter);
    _store.medicinesMutable[medIdx] = updated;

    final reason = _resolveReason(reasonLabel);
    final now = DateTime.now();
    final movement = StockMovementModel(
      id: 'mv-${now.microsecondsSinceEpoch.toRadixString(16)}',
      type: StockMovementType.stockOut,
      reason: reason,
      medicineId: medicineId,
      medicineCode: updated.code,
      medicineName: updated.name,
      medicineUnit: updated.unit,
      userId: 'user-1',
      userName: 'Admin Apotek',
      quantity: quantity,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      transactionDate: transactionDate ?? now,
      notes: notes,
      createdAt: now,
    );
    _store.movementsMutable.insert(0, movement);
    return movement;
  }

  StockMovementReason _resolveReason(String? label) {
    if (label == null) return StockMovementReason.sale;
    final upper = label.toUpperCase();
    return StockMovementReasonX.fromApi(upper);
  }
}
