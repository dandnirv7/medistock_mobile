/// DTO for a batch entry inside a stock-report item.
/// Mirrors the `batches[]` field from `GET /reports/stock` (Req 3.2).
class StockReportBatchModel {
  final String batchNumber;

  /// Expiry date in YYYY-MM-DD format.
  final String expiredDate;

  final int quantity;

  const StockReportBatchModel({
    required this.batchNumber,
    required this.expiredDate,
    required this.quantity,
  });

  factory StockReportBatchModel.fromJson(Map<String, dynamic> json) {
    return StockReportBatchModel(
      batchNumber: (json['batchNumber'] ?? '').toString(),
      expiredDate: (json['expiredDate'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'batchNumber': batchNumber,
        'expiredDate': expiredDate,
        'quantity': quantity,
      };
}

/// DTO for a single medicine entry in the stock report.
/// `status` is one of: `low`, `expired`, `healthy` (computed server-side).
class StockReportItemModel {
  final String id;
  final String code;
  final String name;
  final String unit;
  final int currentStock;
  final int minimumStock;
  final String? categoryName;
  final String? supplierName;

  /// Server-computed status: `low` | `expired` | `healthy`
  final String status;

  final List<StockReportBatchModel> batches;

  const StockReportItemModel({
    required this.id,
    required this.code,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.minimumStock,
    this.categoryName,
    this.supplierName,
    required this.status,
    required this.batches,
  });

  factory StockReportItemModel.fromJson(Map<String, dynamic> json) {
    final rawBatches = json['batches'] as List<dynamic>? ?? [];
    return StockReportItemModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      minimumStock: (json['minimumStock'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String?,
      supplierName: json['supplierName'] as String?,
      status: (json['status'] ?? 'healthy').toString(),
      batches: rawBatches
          .map((e) => StockReportBatchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'unit': unit,
        'currentStock': currentStock,
        'minimumStock': minimumStock,
        'categoryName': categoryName,
        'supplierName': supplierName,
        'status': status,
        'batches': batches.map((b) => b.toJson()).toList(),
      };
}
