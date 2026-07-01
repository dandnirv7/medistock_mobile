import '../../medicines/models/medicine_model.dart';

class RecentMovementModel {
  RecentMovementModel({
    required this.id,
    required this.type,
    required this.reason,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.transactionDate,
    required this.medicineName,
    required this.medicineCode,
    required this.userName,
  });

  final String id;

  /// 'IN' or 'OUT'
  final String type;
  final String reason;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final DateTime transactionDate;
  final String medicineName;
  final String medicineCode;
  final String userName;

  bool get isIn => type == 'IN';

  factory RecentMovementModel.fromJson(Map<String, dynamic> json) {
    return RecentMovementModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      stockBefore: (json['stockBefore'] as num?)?.toInt() ?? 0,
      stockAfter: (json['stockAfter'] as num?)?.toInt() ?? 0,
      transactionDate: DateTime.tryParse(
            json['transactionDate'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      medicineName: (json['medicine'] as Map<String, dynamic>?)?['name']
              as String? ??
          json['medicineName'] as String? ??
          '',
      medicineCode: (json['medicine'] as Map<String, dynamic>?)?['code']
              as String? ??
          json['medicineCode'] as String? ??
          '',
      userName: (json['user'] as Map<String, dynamic>?)?['name'] as String? ??
          (json['user'] as Map<String, dynamic>?)?['username'] as String? ??
          json['userName'] as String? ??
          '',
    );
  }
}

class DashboardSummary {
  DashboardSummary({
    required this.totalMedicines,
    required this.totalCategories,
    required this.totalSuppliers,
    required this.totalStock,
    required this.totalValue,
    required this.totalAssetValue,
    required this.lowStockCount,
    required this.expiredSoonCount,
    required this.expiredCount,
    required this.lowStockMedicines,
    required this.expiredSoonMedicines,
    required this.recentMovements,
  });

  final int totalMedicines;
  final int totalCategories;
  final int totalSuppliers;
  final int totalStock;

  /// Legacy field — kept for backward compat with dummy data.
  final double totalValue;

  /// Real asset value from API: Σ(current_stock × purchase_price) (Req 7.2).
  final double totalAssetValue;

  final int lowStockCount;
  final int expiredSoonCount;
  final int expiredCount;
  final List<MedicineModel> lowStockMedicines;
  final List<MedicineModel> expiredSoonMedicines;

  /// 10 most recent stock movements from API (Req 7.5).
  final List<RecentMovementModel> recentMovements;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final low = (json['lowStockMedicines'] as List<dynamic>? ?? [])
        .map((e) => MedicineModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final soon = (json['expiredSoonMedicines'] as List<dynamic>? ?? [])
        .map((e) => MedicineModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final movements =
        (json['recentMovements'] as List<dynamic>? ?? [])
            .map(
              (e) =>
                  RecentMovementModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();

    // totalAssetValue: prefer explicit key, fall back to legacy totalValue.
    final assetValue =
        (json['totalAssetValue'] as num?)?.toDouble() ??
        (json['totalValue'] as num?)?.toDouble() ??
        0.0;

    return DashboardSummary(
      totalMedicines: (json['totalMedicines'] as num?)?.toInt() ?? 0,
      totalCategories: (json['totalCategories'] as num?)?.toInt() ?? 0,
      totalSuppliers: (json['totalSuppliers'] as num?)?.toInt() ?? 0,
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
      totalAssetValue: assetValue,
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
      expiredSoonCount: (json['expiredSoonCount'] as num?)?.toInt() ?? 0,
      expiredCount: (json['expiredCount'] as num?)?.toInt() ?? 0,
      lowStockMedicines: low,
      expiredSoonMedicines: soon,
      recentMovements: movements,
    );
  }
}
