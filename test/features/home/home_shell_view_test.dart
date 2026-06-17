import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/storage/auth_session.dart';
import 'package:medistock_mobile/core/theme/app_theme.dart';
import 'package:medistock_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:medistock_mobile/features/auth/data/repositories/auth_repository_dummy.dart';
import 'package:medistock_mobile/features/home/controllers/home_shell_controller.dart';
import 'package:medistock_mobile/features/home/views/home_shell_view.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('home shell renders bottom nav with 5 tabs', (tester) async {
    await registerTestServices();
    Get.put<AuthSession>(AuthSession());
    await Get.find<AuthSession>().hydrate();
    Get.put<AuthRepository>(AuthRepositoryDummy(storage: Get.find()));
    Get.put<HomeShellController>(HomeShellController());

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        home: const HomeShellView(),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsWidgets);
    for (final tab in HomeShellController.tabs) {
      expect(find.text(tab.label), findsWidgets);
    }
  });
}
