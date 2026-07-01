import '../../../../core/models/paginated.dart';
import '../../models/stock_movement_model.dart';

class StockMovementQuery {
  StockMovementQuery({
    this.page = 1,
    this.limit = 10,
    this.medicineId,
    this.type,
    this.reason,
    this.startDate,
    this.endDate,
  });

  final int page;
  final int limit;
  final String? medicineId;
  final StockMovementType? type;
  final StockMovementReason? reason;
  final DateTime? startDate;
  final DateTime? endDate;
}

abstract class StockMovementRepository {
  Future<Paginated<StockMovementModel>> getAll({StockMovementQuery? query});

  Future<StockMovementModel> stockIn({
    required String medicineId,
    int quantity = 0,
    String? supplierId,
    DateTime? transactionDate,
    String? notes,
    String? batchNumber,
    DateTime? expiredDate,
  });

  Future<StockMovementModel> stockOut({
    required String medicineId,
    int quantity = 0,
    DateTime? transactionDate,
    String? reasonLabel,
    String? notes,
  });
}
