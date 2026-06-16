import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/suppliers/models/supplier_model.dart';

void main() {
  group('SupplierModel', () {
    test('fromJson parses api response', () {
      final s = SupplierModel.fromJson({
        'id': 'sup-1',
        'name': 'PT Kimia Farma',
        'phone': '021-5551234',
        'email': 'order@kimiafarma.co.id',
        'address': 'Jakarta',
        'notes': 'Utama',
        'isActive': true,
        'medicineCount': 10,
      });
      expect(s.id, 'sup-1');
      expect(s.name, 'PT Kimia Farma');
      expect(s.phone, '021-5551234');
      expect(s.email, 'order@kimiafarma.co.id');
      expect(s.isActive, true);
    });

    test('toJson round-trips', () {
      final s = SupplierModel(
        id: 'sup-1',
        name: 'PT Kimia Farma',
        phone: '021-5551234',
        email: 'order@kimiafarma.co.id',
        address: 'Jakarta',
      );
      final s2 = SupplierModel.fromJson(s.toJson());
      expect(s2.name, s.name);
      expect(s2.email, s.email);
    });
  });
}
