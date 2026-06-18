import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/features/dashboard/models/dashboard_summary_model.dart';
import 'package:medistock_mobile/features/medicines/models/medicine_model.dart';

void main() {
  group('DashboardSummary from API payload', () {
    test('fromJson parses full backend response shape', () {
      // Mirrors what DashboardService.summary() actually returns
      // (see DashboardSummary interface in dashboard.service.ts).
      final s = DashboardSummary.fromJson({
        'totalMedicines': 87,
        'totalStock': 4250,
        'totalValue': 12500000.5,
        'totalCategories': 12,
        'totalSuppliers': 9,
        'lowStockCount': 4,
        'expiredSoonCount': 6,
        'expiredCount': 1,
        'lowStockMedicines': [
          {
            'id': 'med-1',
            'code': 'PAR-500',
            'name': 'Paracetamol 500 mg',
            'unit': 'Tablet',
            'currentStock': 3,
            'minimumStock': 10,
          },
        ],
        'expiredSoonMedicines': [
          {
            'id': 'med-2',
            'code': 'AMX-500',
            'name': 'Amoxicillin 500 mg',
            'unit': 'Kapsul',
            'expiredDate': '2026-07-30',
            'currentStock': 45,
          },
        ],
      });
      expect(s.totalMedicines, 87);
      expect(s.totalStock, 4250);
      expect(s.totalValue, 12500000.5);
      expect(s.totalCategories, 12);
      expect(s.totalSuppliers, 9);
      expect(s.lowStockCount, 4);
      expect(s.expiredSoonCount, 6);
      expect(s.expiredCount, 1);
      expect(s.lowStockMedicines, hasLength(1));
      expect(s.expiredSoonMedicines, hasLength(1));
      expect(s.lowStockMedicines.first.code, 'PAR-500');
      expect(s.expiredSoonMedicines.first.code, 'AMX-500');
    });

    test('fromJson tolerates empty lists and missing totalValue', () {
      final s = DashboardSummary.fromJson({
        'totalMedicines': 0,
        'totalStock': 0,
        'totalCategories': 0,
        'totalSuppliers': 0,
        'lowStockCount': 0,
        'expiredSoonCount': 0,
        'expiredCount': 0,
        // No totalValue key — must default to 0.0
        'lowStockMedicines': <Map<String, dynamic>>[],
        'expiredSoonMedicines': <Map<String, dynamic>>[],
      });
      expect(s.totalValue, 0.0);
      expect(s.lowStockMedicines, isEmpty);
      expect(s.expiredSoonMedicines, isEmpty);
    });

    test('expiredSoonMedicines items surface as MedicineModel', () {
      final s = DashboardSummary.fromJson({
        'totalMedicines': 1,
        'totalStock': 5,
        'totalCategories': 1,
        'totalSuppliers': 1,
        'lowStockCount': 0,
        'expiredSoonCount': 1,
        'expiredCount': 0,
        'lowStockMedicines': <Map<String, dynamic>>[],
        'expiredSoonMedicines': [
          {
            'id': 'med-9',
            'code': 'VIT-C',
            'name': 'Vitamin C',
            'unit': 'Tablet',
            'expiredDate': '2026-08-15',
            'currentStock': 5,
          },
        ],
      });
      // The list elements are MedicineModel instances (parsers tolerate the
      // smaller payload — non-mapped fields default safely).
      final m = s.expiredSoonMedicines.first;
      expect(m, isA<MedicineModel>());
      expect(m.id, 'med-9');
      expect(m.code, 'VIT-C');
    });
  });
}
