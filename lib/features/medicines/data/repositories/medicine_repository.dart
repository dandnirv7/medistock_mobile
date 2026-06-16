import '../../../../core/models/paginated.dart';
import '../../models/medicine_model.dart';

enum MedicineExpiredFilter { all, soon, expired, safe }

class MedicineQuery {
  MedicineQuery({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.categoryId,
    this.supplierId,
    this.lowStockOnly = false,
    this.expiredFilter = MedicineExpiredFilter.all,
  });

  final int page;
  final int limit;
  final String? search;
  final String? categoryId;
  final String? supplierId;
  final bool lowStockOnly;
  final MedicineExpiredFilter expiredFilter;
}

abstract class MedicineRepository {
  Future<Paginated<MedicineModel>> getAll({MedicineQuery? query});

  Future<MedicineModel> getById(String id);

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
  });

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
  });

  Future<void> delete(String id);
}
