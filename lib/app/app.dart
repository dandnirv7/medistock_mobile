import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class MediStockApp extends StatelessWidget {
  const MediStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediStock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: _resolveInitialRoute(),
      getPages: AppPages.pages,
    );
  }

  String _resolveInitialRoute() => AppRoutes.login;
}
