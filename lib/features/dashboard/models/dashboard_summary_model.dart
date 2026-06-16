import '../../medicines/models/medicine_model.dart';

class DashboardSummary {
  DashboardSummary({
    required this.totalMedicines,
    required this.totalCategories,
    required this.totalSuppliers,
    required this.totalStock,
    required this.totalValue,
    required this.lowStockCount,
    required this.expiredSoonCount,
    required this.expiredCount,
    required this.lowStockMedicines,
    required this.expiredSoonMedicines,
  });

  final int totalMedicines;
  final int totalCategories;
  final int totalSuppliers;
  final int totalStock;
  final double totalValue;
  final int lowStockCount;
  final int expiredSoonCount;
  final int expiredCount;
  final List<MedicineModel> lowStockMedicines;
  final List<MedicineModel> expiredSoonMedicines;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final low = (json['lowStockMedicines'] as List<dynamic>? ?? [])
        .map((e) => MedicineModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final soon = (json['expiredSoonMedicines'] as List<dynamic>? ?? [])
        .map((e) => MedicineModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return DashboardSummary(
      totalMedicines: (json['totalMedicines'] as num?)?.toInt() ?? 0,
      totalCategories: (json['totalCategories'] as num?)?.toInt() ?? 0,
      totalSuppliers: (json['totalSuppliers'] as num?)?.toInt() ?? 0,
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
      expiredSoonCount: (json['expiredSoonCount'] as num?)?.toInt() ?? 0,
      expiredCount: (json['expiredCount'] as num?)?.toInt() ?? 0,
      lowStockMedicines: low,
      expiredSoonMedicines: soon,
    );
  }
}
