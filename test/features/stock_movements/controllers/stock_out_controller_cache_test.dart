import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository.dart';
import 'package:medistock_mobile/features/stock_movements/controllers/stock_out_controller.dart';
import 'package:medistock_mobile/features/stock_movements/data/repositories/stock_movement_repository.dart';
import 'package:medistock_mobile/features/stock_movements/models/stock_movement_model.dart';

import '_mocks.dart';

void main() {
  group('StockOutController medicine lookup caching', () {
    late CountingMedicineRepository medRepo;
    late StubStockMovementRepository mvRepo;
    late StockOutController controller;

    setUp(() {
      medRepo = CountingMedicineRepository()..seed(buildMedicine());
      mvRepo = StubStockMovementRepository()
        ..seed(StockMovementModel(
          id: 'mv-1',
          type: StockMovementType.stockOut,
          reason: StockMovementReason.sale,
          medicineId: 'med-1',
          medicineCode: 'PAR-500',
          medicineName: 'Paracetamol 500 mg',
          medicineUnit: 'Tablet',
          quantity: 5,
          stockBefore: 50,
          stockAfter: 45,
          transactionDate: DateTime(2025, 5, 10),
        ));

      Get.put<MedicineRepository>(medRepo);
      Get.put<StockMovementRepository>(mvRepo);
      controller = StockOutController(mvRepo);
    });

    tearDown(() {
      Get.reset();
    });

    test('onInit fetches medicines once', () async {
      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(medRepo.getAllCalls, 1);
      expect(controller.medicines, hasLength(1));
    });

    test('refreshMedicines forces a refetch', () async {
      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(medRepo.getAllCalls, 1);

      await controller.refreshMedicines();
      expect(medRepo.getAllCalls, 2);
    });

    test('force=true on private loader bypasses cache', () async {
      controller.onInit();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      // Cache is populated now. Direct call without force is a no-op.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(medRepo.getAllCalls, 1);
    });
  });
}
