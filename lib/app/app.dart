import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_motion.dart';
import '../core/theme/app_theme.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class MediStockApp extends StatelessWidget {
  const MediStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppMotion.assertBands();
    final reduced = AppMotion.reduceMotion(context);
    return GetMaterialApp(
      title: 'MediStock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: _resolveInitialRoute(),
      getPages: AppPages.pages,
      // Centralized page transition (req 8.1, 8.3, 8.4).
      defaultTransition: reduced ? Transition.fadeIn : Transition.rightToLeft,
      transitionDuration: AppMotion.page,
    );
  }

  String _resolveInitialRoute() => AppRoutes.login;
}
