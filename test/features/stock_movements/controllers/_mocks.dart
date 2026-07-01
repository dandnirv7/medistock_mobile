import 'package:dio/dio.dart';
import 'package:medistock_mobile/core/models/paginated.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository.dart';
import 'package:medistock_mobile/features/medicines/models/medicine_model.dart';
import 'package:medistock_mobile/features/stock_movements/data/repositories/stock_movement_repository.dart';
import 'package:medistock_mobile/features/stock_movements/models/stock_movement_model.dart';
import 'package:medistock_mobile/features/suppliers/data/repositories/supplier_repository.dart';
import 'package:medistock_mobile/features/suppliers/models/supplier_model.dart';

/// Counts how many times each method is called. Tests assert on these
/// counters to verify the cache behaviour in [StockInController] and
/// [StockOutController].
class CountingMedicineRepository implements MedicineRepository {
  int getAllCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int getByIdCalls = 0;

  MedicineModel? _nextResult;

  void seed(MedicineModel m) {
    _nextResult = m;
  }

  @override
  Future<Paginated<MedicineModel>> getAll({
    MedicineQuery? query,
    CancelToken? cancelToken,
  }) async {
    getAllCalls += 1;
    return Paginated<MedicineModel>(
      items: _nextResult == null
          ? <MedicineModel>[]
          : <MedicineModel>[_nextResult!],
      page: 1,
      limit: 100,
      total: _nextResult == null ? 0 : 1,
      totalPages: 1,
    );
  }

  @override
  Future<MedicineModel> getById(String id) async {
    getByIdCalls += 1;
    return _nextResult!;
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
    createCalls += 1;
    return _nextResult!;
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
    updateCalls += 1;
    return _nextResult!;
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls += 1;
  }
}

class CountingSupplierRepository implements SupplierRepository {
  int getAllCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int getByIdCalls = 0;

  SupplierModel? _nextResult;

  void seed(SupplierModel s) {
    _nextResult = s;
  }

  @override
  Future<Paginated<SupplierModel>> getAll({SupplierQuery? query}) async {
    getAllCalls += 1;
    return Paginated<SupplierModel>(
      items: _nextResult == null
          ? <SupplierModel>[]
          : <SupplierModel>[_nextResult!],
      page: 1,
      limit: 100,
      total: _nextResult == null ? 0 : 1,
      totalPages: 1,
    );
  }

  @override
  Future<SupplierModel> getById(String id) async {
    getByIdCalls += 1;
    return _nextResult!;
  }

  @override
  Future<SupplierModel> create({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    createCalls += 1;
    return _nextResult!;
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
    updateCalls += 1;
    return _nextResult!;
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls += 1;
  }
}

/// Lightweight stock movement repository stub. Tests can flip
/// [throwOnStockIn] / [throwOnStockOut] to simulate failures.
class StubStockMovementRepository implements StockMovementRepository {
  int stockInCalls = 0;
  int stockOutCalls = 0;
  bool throwOnStockIn = false;
  bool throwOnStockOut = false;

  StockMovementModel? _nextResult;
  void seed(StockMovementModel m) {
    _nextResult = m;
  }

  @override
  Future<Paginated<StockMovementModel>> getAll(
      {StockMovementQuery? query}) async {
    return Paginated<StockMovementModel>(
      items: const <StockMovementModel>[],
      page: 1,
      limit: 10,
      total: 0,
      totalPages: 1,
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
    stockInCalls += 1;
    if (throwOnStockIn) {
      throw Exception('boom');
    }
    return _nextResult!;
  }

  @override
  Future<StockMovementModel> stockOut({
    required String medicineId,
    int quantity = 0,
    DateTime? transactionDate,
    String? reasonLabel,
    String? notes,
  }) async {
    stockOutCalls += 1;
    if (throwOnStockOut) {
      throw Exception('boom');
    }
    return _nextResult!;
  }
}

/// Build a MedicineModel with the bare minimum the controller needs.
MedicineModel buildMedicine({
  String id = 'med-1',
  String code = 'PAR-500',
  String name = 'Paracetamol 500 mg',
  int currentStock = 50,
  int minimumStock = 20,
}) {
  return MedicineModel(
    id: id,
    code: code,
    name: name,
    unit: 'Tablet',
    purchasePrice: 250,
    sellingPrice: 500,
    currentStock: currentStock,
    minimumStock: minimumStock,
  );
}

SupplierModel buildSupplier({String id = 'sup-1', String name = 'PT Test'}) {
  return SupplierModel(
    id: id,
    name: name,
    phone: '021-5551234',
    email: 'test@x.com',
    address: 'Jakarta',
  );
}

StockMovementModel buildMovement({
  String id = 'mv-1',
  String medicineId = 'med-1',
  int quantity = 10,
}) {
  return StockMovementModel(
    id: id,
    type: StockMovementType.stockIn,
    reason: StockMovementReason.purchase,
    medicineId: medicineId,
    medicineCode: 'PAR-500',
    medicineName: 'Paracetamol 500 mg',
    medicineUnit: 'Tablet',
    quantity: quantity,
    stockBefore: 50,
    stockAfter: 60,
    transactionDate: DateTime(2025, 5, 10),
    notes: null,
  );
}
