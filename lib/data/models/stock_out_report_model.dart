/// DTO for one entry in the top-5 stock-out list (Req 4.7).
class StockOutTop5Model {
  final String medicineId;
  final String code;
  final String name;
  final int totalQuantity;
  final double totalValue;

  const StockOutTop5Model({
    required this.medicineId,
    required this.code,
    required this.name,
    required this.totalQuantity,
    required this.totalValue,
  });

  factory StockOutTop5Model.fromJson(Map<String, dynamic> json) {
    return StockOutTop5Model(
      medicineId: (json['medicineId'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      totalValue: _toDouble(json['totalValue']),
    );
  }

  Map<String, dynamic> toJson() => {
        'medicineId': medicineId,
        'code': code,
        'name': name,
        'totalQuantity': totalQuantity,
        'totalValue': totalValue,
      };
}

/// DTO for the stock-out report response from `GET /reports/stock-out` (Req 4.5).
class StockOutReportModel {
  /// Total quantity of all OUT movements in the requested period.
  final int totalQuantity;

  /// Total value = Σ(quantity × selling_price) for OUT movements.
  final double totalValue;

  /// Up to 5 medicines with the highest total quantity moved out.
  final List<StockOutTop5Model> top5;

  const StockOutReportModel({
    required this.totalQuantity,
    required this.totalValue,
    required this.top5,
  });

  factory StockOutReportModel.fromJson(Map<String, dynamic> json) {
    final rawTop5 = json['top5'] as List<dynamic>? ?? [];
    return StockOutReportModel(
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      totalValue: _toDouble(json['totalValue']),
      top5: rawTop5
          .map((e) => StockOutTop5Model.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalQuantity': totalQuantity,
        'totalValue': totalValue,
        'top5': top5.map((e) => e.toJson()).toList(),
      };
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
