enum StockMovementType { stockIn, stockOut }

enum StockMovementReason {
  purchase,
  sale,
  damaged,
  expired,
  lost,
  adjustment,
  other,
}

extension StockMovementTypeX on StockMovementType {
  String get apiValue => switch (this) {
        StockMovementType.stockIn => 'IN',
        StockMovementType.stockOut => 'OUT',
      };

  String get label => switch (this) {
        StockMovementType.stockIn => 'Masuk',
        StockMovementType.stockOut => 'Keluar',
      };

  static StockMovementType fromApi(String? value) {
    switch (value) {
      case 'OUT':
        return StockMovementType.stockOut;
      case 'IN':
      default:
        return StockMovementType.stockIn;
    }
  }
}

extension StockMovementReasonX on StockMovementReason {
  String get apiValue => switch (this) {
        StockMovementReason.purchase => 'PURCHASE',
        StockMovementReason.sale => 'SALE',
        StockMovementReason.damaged => 'DAMAGED',
        StockMovementReason.expired => 'EXPIRED',
        StockMovementReason.lost => 'LOST',
        StockMovementReason.adjustment => 'ADJUSTMENT',
        StockMovementReason.other => 'OTHER',
      };

  String get label => switch (this) {
        StockMovementReason.purchase => 'Pembelian',
        StockMovementReason.sale => 'Penjualan',
        StockMovementReason.damaged => 'Rusak',
        StockMovementReason.expired => 'Expired',
        StockMovementReason.lost => 'Hilang',
        StockMovementReason.adjustment => 'Penyesuaian',
        StockMovementReason.other => 'Lainnya',
      };

  static StockMovementReason fromApi(String? value) {
    switch (value) {
      case 'SALE':
        return StockMovementReason.sale;
      case 'DAMAGED':
        return StockMovementReason.damaged;
      case 'EXPIRED':
        return StockMovementReason.expired;
      case 'LOST':
        return StockMovementReason.lost;
      case 'ADJUSTMENT':
        return StockMovementReason.adjustment;
      case 'OTHER':
        return StockMovementReason.other;
      case 'PURCHASE':
      default:
        return StockMovementReason.purchase;
    }
  }
}

class StockMovementModel {
  StockMovementModel({
    required this.id,
    required this.type,
    this.reason = StockMovementReason.purchase,
    required this.medicineId,
    this.medicineCode,
    this.medicineName,
    this.medicineUnit,
    this.supplierId,
    this.supplierName,
    this.userId,
    this.userName,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.transactionDate,
    this.notes,
    this.createdAt,
  });

  final String id;
  final StockMovementType type;
  final StockMovementReason reason;
  final String medicineId;
  final String? medicineCode;
  final String? medicineName;
  final String? medicineUnit;
  final String? supplierId;
  final String? supplierName;
  final String? userId;
  final String? userName;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final DateTime? transactionDate;
  final String? notes;
  final DateTime? createdAt;

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    final medicine = json['medicine'] as Map<String, dynamic>?;
    final supplier = json['supplier'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    return StockMovementModel(
      id: (json['id'] ?? '').toString(),
      type: StockMovementTypeX.fromApi(json['type']?.toString()),
      reason: StockMovementReasonX.fromApi(json['reason']?.toString()),
      medicineId: (json['medicineId'] ?? medicine?['id'] ?? '').toString(),
      medicineCode:
          (json['medicineCode'] ?? medicine?['code']) as String?,
      medicineName:
          (json['medicineName'] ?? medicine?['name']) as String?,
      medicineUnit:
          (json['medicineUnit'] ?? medicine?['unit']) as String?,
      supplierId:
          (json['supplierId'] ?? supplier?['id'])?.toString(),
      supplierName:
          (json['supplierName'] ?? supplier?['name']) as String?,
      userId: (json['userId'] ?? user?['id'])?.toString(),
      userName: (json['userName'] ?? user?['name']) as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      stockBefore: (json['stockBefore'] as num?)?.toInt() ?? 0,
      stockAfter: (json['stockAfter'] as num?)?.toInt() ?? 0,
      transactionDate:
          DateTime.tryParse(json['transactionDate']?.toString() ?? '') ??
              DateTime.tryParse(json['date']?.toString() ?? ''),
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.apiValue,
        'reason': reason.apiValue,
        'medicineId': medicineId,
        'medicineCode': medicineCode,
        'medicineName': medicineName,
        'medicineUnit': medicineUnit,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'userId': userId,
        'userName': userName,
        'quantity': quantity,
        'stockBefore': stockBefore,
        'stockAfter': stockAfter,
        'transactionDate': transactionDate?.toIso8601String().split('T').first,
        'date': transactionDate?.toIso8601String().split('T').first,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
      };
}
