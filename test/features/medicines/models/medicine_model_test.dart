import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/medicines/models/medicine_model.dart';

void main() {
  group('MedicineModel', () {
    test('fromJson parses list response with nested category/supplier', () {
      final m = MedicineModel.fromJson({
        'id': 'med-1',
        'code': 'PAR-500',
        'name': 'Paracetamol 500 mg',
        'unit': 'Tablet',
        'purchasePrice': 250,
        'sellingPrice': 500,
        'currentStock': 120,
        'minimumStock': 30,
        'expiredDate': '2025-12-31',
        'stockStatus': 'SAFE',
        'expiredStatus': 'EXPIRED_SOON',
        'category': {'id': 'cat-1', 'name': 'Analgesik'},
        'supplier': {'id': 'sup-1', 'name': 'PT Kimia Farma'},
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-05-01T00:00:00.000Z',
      });
      expect(m.id, 'med-1');
      expect(m.code, 'PAR-500');
      expect(m.categoryId, 'cat-1');
      expect(m.categoryName, 'Analgesik');
      expect(m.supplierId, 'sup-1');
      expect(m.supplierName, 'PT Kimia Farma');
      expect(m.stockStatus, StockStatus.safe);
      expect(m.expiredStatus, ExpiredStatus.soon);
      expect(m.purchasePrice, 250);
      expect(m.sellingPrice, 500);
    });

    test('isLowStock and isExpired helpers', () {
      final m = MedicineModel(
        id: 'm',
        code: 'X',
        name: 'X',
        unit: 'Tablet',
        purchasePrice: 0,
        sellingPrice: 0,
        currentStock: 2,
        minimumStock: 10,
        expiredDate: DateTime(2020, 1, 1),
      );
      expect(m.isLowStock, true);
      expect(m.isExpired, true);
    });

    test('toJson serialises enum api values', () {
      final m = MedicineModel(
        id: 'm',
        code: 'X',
        name: 'X',
        unit: 'Tablet',
        purchasePrice: 100,
        sellingPrice: 200,
        currentStock: 50,
        minimumStock: 10,
      );
      final j = m.toJson();
      expect(j['stockStatus'], 'SAFE');
      expect(j['code'], 'X');
    });
  });

  group('MedicineModel from API payload', () {
    test('parses Decimal-as-string purchase/selling prices', () {
      // Backend (Prisma Decimal) returns prices as strings.
      final m = MedicineModel.fromJson({
        'id': 'med-1',
        'code': 'PAR-500',
        'name': 'Paracetamol 500 mg',
        'unit': 'Tablet',
        'purchasePrice': '250.00',
        'sellingPrice': '500.50',
        'currentStock': 120,
        'minimumStock': 30,
        'stockStatus': 'SAFE',
        'expiredStatus': 'EXPIRED_SOON',
        'category': {'id': 'cat-1', 'name': 'Analgesik'},
        'supplier': {'id': 'sup-1', 'name': 'PT Kimia Farma'},
      });
      expect(m.purchasePrice, 250.0);
      expect(m.sellingPrice, 500.5);
    });

    test('parses missing supplier as null', () {
      final m = MedicineModel.fromJson({
        'id': 'med-2',
        'code': 'OBT-X',
        'name': 'Tanpa Supplier',
        'unit': 'Botol',
        'purchasePrice': '100.00',
        'sellingPrice': '150.00',
        'currentStock': 5,
        'minimumStock': 2,
        'stockStatus': 'SAFE',
        'expiredStatus': 'UNKNOWN',
        'category': {'id': 'cat-1', 'name': 'Lain-lain'},
        'supplier': null,
      });
      expect(m.supplierId, isNull);
      expect(m.supplierName, isNull);
    });

    test('parses stockStatus LOW_STOCK to StockStatus.low', () {
      final m = MedicineModel.fromJson({
        'id': 'med-3',
        'code': 'OBT-Y',
        'name': 'Stok Rendah',
        'unit': 'Strip',
        'purchasePrice': 10,
        'sellingPrice': 15,
        'currentStock': 2,
        'minimumStock': 10,
        'stockStatus': 'LOW_STOCK',
        'expiredStatus': 'SAFE',
        'category': {'id': 'cat-1', 'name': 'Analgesik'},
      });
      expect(m.stockStatus, StockStatus.low);
      expect(m.isLowStock, true);
    });
  });
}
