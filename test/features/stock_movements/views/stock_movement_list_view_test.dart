import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/features/stock_movements/controllers/stock_movement_list_controller.dart';
import 'package:medistock_mobile/features/stock_movements/data/repositories/stock_movement_repository.dart';
import 'package:medistock_mobile/features/stock_movements/data/repositories/stock_movement_repository_dummy.dart';
import 'package:medistock_mobile/features/stock_movements/views/stock_movement_list_view.dart';

import '../../../test_helpers.dart';

void main() {
  testWidgets('stock movement list renders seed movements', (tester) async {
    await registerTestServices();
    Get.put<StockMovementRepository>(
      StockMovementRepositoryDummy(),
      permanent: true,
    );
    Get.put<StockMovementListController>(
      StockMovementListController(Get.find<StockMovementRepository>()),
      permanent: true,
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: const StockMovementListView()));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await tester.pump();
    });

    expect(find.text('Paracetamol 500 mg'), findsWidgets);
  });
}
