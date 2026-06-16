import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/features/medicines/controllers/medicine_list_controller.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository.dart';
import 'package:medistock_mobile/features/medicines/data/repositories/medicine_repository_dummy.dart';
import 'package:medistock_mobile/features/medicines/views/medicine_list_view.dart';

import '../../../test_helpers.dart';

void main() {
  testWidgets('medicine list renders data from dummy store', (tester) async {
    await registerTestServices();
    Get.put<MedicineRepository>(MedicineRepositoryDummy(), permanent: true);
    Get.put<MedicineListController>(
      MedicineListController(Get.find<MedicineRepository>()),
      permanent: true,
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: const MedicineListView()));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await tester.pump();
    });

    expect(find.text('Paracetamol 500 mg'), findsWidgets);
  });
}
