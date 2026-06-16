import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/core/storage/auth_session.dart';
import 'package:medistock_mobile/core/theme/app_theme.dart';
import 'package:medistock_mobile/features/splash/views/splash_view.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('splash view renders branding and tagline', (tester) async {
    await registerTestServices();
    Get.put<AuthSession>(AuthSession());
    await Get.find<AuthSession>().hydrate();

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        home: const SplashView(),
      ),
    );
    await tester.pump();

    expect(find.text('MediStock'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.textContaining('Kelola Stok Obat'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
