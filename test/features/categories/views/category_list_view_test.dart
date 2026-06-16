import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/features/categories/controllers/category_list_controller.dart';
import 'package:medistock_mobile/features/categories/data/repositories/category_repository.dart';
import 'package:medistock_mobile/features/categories/data/repositories/category_repository_dummy.dart';
import 'package:medistock_mobile/features/categories/views/category_list_view.dart';

import '../../../test_helpers.dart';

void main() {
  testWidgets('category list renders seed categories', (tester) async {
    await registerTestServices();
    Get.put<CategoryRepository>(CategoryRepositoryDummy(), permanent: true);
    Get.put<CategoryListController>(
      CategoryListController(Get.find<CategoryRepository>()),
      permanent: true,
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: const CategoryListView()));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await tester.pump();
    });

    expect(find.text('Analgesik'), findsOneWidget);
  });
}
