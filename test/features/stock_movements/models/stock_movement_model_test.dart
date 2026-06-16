import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/stock_movements/models/stock_movement_model.dart';

void main() {
  group('StockMovementModel', () {
    test('fromJson parses list response with nested medicine/supplier/user', () {
      final m = StockMovementModel.fromJson({
        'id': 'mv-1',
        'type': 'IN',
        'reason': 'PURCHASE',
        'quantity': 50,
        'stockBefore': 20,
        'stockAfter': 70,
        'transactionDate': '2025-05-10',
        'notes': 'Pembelian rutin',
        'medicine': {
          'id': 'med-1',
          'code': 'PAR-500',
          'name': 'Paracetamol 500 mg',
          'unit': 'Tablet',
        },
        'supplier': {'id': 'sup-1', 'name': 'PT Kimia Farma'},
        'user': {'id': 'user-1', 'name': 'Admin Apotek'},
        'createdAt': '2025-05-10T00:00:00.000Z',
      });
      expect(m.type, StockMovementType.stockIn);
      expect(m.reason, StockMovementReason.purchase);
      expect(m.medicineId, 'med-1');
      expect(m.medicineName, 'Paracetamol 500 mg');
      expect(m.supplierName, 'PT Kimia Farma');
      expect(m.userName, 'Admin Apotek');
      expect(m.quantity, 50);
    });

    test('apiValue and labels', () {
      expect(StockMovementType.stockIn.apiValue, 'IN');
      expect(StockMovementType.stockOut.apiValue, 'OUT');
      expect(StockMovementType.stockIn.label, 'Masuk');
      expect(StockMovementReason.sale.label, 'Penjualan');
    });
  });
}
