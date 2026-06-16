enum StockStatus { safe, low, out }

enum ExpiredStatus { safe, soon, expired, unknown }

extension StockStatusX on StockStatus {
  String get label => switch (this) {
        StockStatus.safe => 'Aman',
        StockStatus.low => 'Stok Rendah',
        StockStatus.out => 'Habis',
      };

  String get apiValue => switch (this) {
        StockStatus.safe => 'SAFE',
        StockStatus.low => 'LOW_STOCK',
        StockStatus.out => 'LOW_STOCK',
      };

  static StockStatus fromApi(String? value) {
    switch (value) {
      case 'LOW_STOCK':
        return StockStatus.low;
      case 'SAFE':
      default:
        return StockStatus.safe;
    }
  }
}

extension ExpiredStatusX on ExpiredStatus {
  String get label => switch (this) {
        ExpiredStatus.safe => 'Aman',
        ExpiredStatus.soon => 'Segera Expired',
        ExpiredStatus.expired => 'Expired',
        ExpiredStatus.unknown => 'Tidak Diketahui',
      };

  String get apiValue => switch (this) {
        ExpiredStatus.safe => 'SAFE',
        ExpiredStatus.soon => 'EXPIRED_SOON',
        ExpiredStatus.expired => 'EXPIRED',
        ExpiredStatus.unknown => 'UNKNOWN',
      };

  static ExpiredStatus fromApi(String? value) {
    switch (value) {
      case 'EXPIRED_SOON':
        return ExpiredStatus.soon;
      case 'EXPIRED':
        return ExpiredStatus.expired;
      case 'UNKNOWN':
        return ExpiredStatus.unknown;
      case 'SAFE':
      default:
        return ExpiredStatus.safe;
    }
  }
}

class MedicineModel {
  MedicineModel({
    required this.id,
    required this.code,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.supplierId,
    this.supplierName,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    this.expiredDate,
    this.description,
    this.stockStatus = StockStatus.safe,
    this.expiredStatus = ExpiredStatus.unknown,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String code;
  final String name;
  final String? categoryId;
  final String? categoryName;
  final String? supplierId;
  final String? supplierName;
  final String unit;
  final double purchasePrice;
  final double sellingPrice;
  final int currentStock;
  final int minimumStock;
  final DateTime? expiredDate;
  final String? description;
  final StockStatus stockStatus;
  final ExpiredStatus expiredStatus;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isLowStock => currentStock <= minimumStock;

  bool get isExpired {
    if (expiredDate == null) return false;
    return expiredDate!.isBefore(DateTime.now());
  }

  bool get isExpiredSoon {
    if (expiredDate == null) return false;
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 30));
    return !isExpired &&
        !expiredDate!.isBefore(now) &&
        !expiredDate!.isAfter(cutoff);
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final supplier = json['supplier'] as Map<String, dynamic>?;
    return MedicineModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      categoryId:
          (json['categoryId'] ?? category?['id'])?.toString(),
      categoryName:
          (json['categoryName'] ?? category?['name']) as String?,
      supplierId:
          (json['supplierId'] ?? supplier?['id'])?.toString(),
      supplierName:
          (json['supplierName'] ?? supplier?['name']) as String?,
      unit: (json['unit'] ?? '').toString(),
      purchasePrice: _toDouble(json['purchasePrice']),
      sellingPrice: _toDouble(json['sellingPrice']),
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      minimumStock: (json['minimumStock'] as num?)?.toInt() ?? 0,
      expiredDate: DateTime.tryParse(json['expiredDate']?.toString() ?? ''),
      description: json['description'] as String?,
      stockStatus: StockStatusX.fromApi(json['stockStatus']?.toString()),
      expiredStatus:
          ExpiredStatusX.fromApi(json['expiredStatus']?.toString()),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'unit': unit,
        'purchasePrice': purchasePrice,
        'sellingPrice': sellingPrice,
        'currentStock': currentStock,
        'minimumStock': minimumStock,
        'expiredDate': expiredDate?.toIso8601String().split('T').first,
        'description': description,
        'stockStatus': stockStatus.apiValue,
        'expiredStatus': expiredStatus.apiValue,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  MedicineModel copyWith({
    String? id,
    String? code,
    String? name,
    String? categoryId,
    String? categoryName,
    String? supplierId,
    String? supplierName,
    String? unit,
    double? purchasePrice,
    double? sellingPrice,
    int? currentStock,
    int? minimumStock,
    DateTime? expiredDate,
    String? description,
    bool? isActive,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      expiredDate: expiredDate ?? this.expiredDate,
      description: description ?? this.description,
      stockStatus: StockStatusX.fromApi(
        (currentStock ?? this.currentStock) <=
                (minimumStock ?? this.minimumStock)
            ? 'LOW_STOCK'
            : 'SAFE',
      ),
      expiredStatus: _resolveExpiredStatus(expiredDate ?? this.expiredDate),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static ExpiredStatus _resolveExpiredStatus(DateTime? date) {
    if (date == null) return ExpiredStatus.unknown;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isBefore(today)) return ExpiredStatus.expired;
    if (!date.isAfter(today.add(const Duration(days: 30)))) {
      return ExpiredStatus.soon;
    }
    return ExpiredStatus.safe;
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
