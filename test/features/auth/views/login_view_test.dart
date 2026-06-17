import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:medistock_mobile/features/auth/controllers/login_controller.dart';
import 'package:medistock_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:medistock_mobile/features/auth/data/repositories/auth_repository_dummy.dart';
import 'package:medistock_mobile/features/auth/views/login_view.dart';

import '../../../test_helpers.dart';

void main() {
  testWidgets('login view renders form fields', (tester) async {
    await registerTestServices();
    Get.testMode = true;
    Get.put<AuthRepository>(
      AuthRepositoryDummy(storage: Get.find()),
      permanent: true,
    );
    Get.put<LoginController>(LoginController(Get.find<AuthRepository>()));

    await tester.pumpWidget(
      const GetMaterialApp(home: LoginView()),
    );
    await tester.pump();

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Email / Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
