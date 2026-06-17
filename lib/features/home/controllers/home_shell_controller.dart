import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../categories/bindings/category_binding.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../medicines/bindings/medicine_binding.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../stock_movements/bindings/stock_movement_binding.dart';

class HomeShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  static const List<HomeTabSpec> tabs = <HomeTabSpec>[
    HomeTabSpec(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.dashboard,
      index: 0,
    ),
    HomeTabSpec(
      label: 'Obat',
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication,
      route: AppRoutes.medicines,
      index: 1,
    ),
    HomeTabSpec(
      label: 'Stok',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: AppRoutes.stockMovements,
      index: 2,
    ),
    HomeTabSpec(
      label: 'Riwayat',
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      route: AppRoutes.stockMovements,
      index: 3,
    ),
    HomeTabSpec(
      label: 'Profil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: AppRoutes.profile,
      index: 4,
    ),
  ];

  bool _bootstrapped = false;

  @override
  void onReady() {
    super.onReady();
    _bootstrapBindings();
    _readTabArgument();
  }

  /// Eagerly call every binding the tab roots need. GetX `Bindings.dependencies()`
  /// is idempotent when the target is already registered, so calling it on
  /// every shell mount is safe. This is required because the tab roots are
  /// mounted inside a nested Navigator whose pages are NOT routed through
  /// GetX — therefore GetPage.binding never fires for them.
  void _bootstrapBindings() {
    if (_bootstrapped) return;
    _bootstrapped = true;
    DashboardBinding().dependencies();
    MedicineBinding().dependencies();
    StockMovementBinding().dependencies();
    ProfileBinding().dependencies();
    // CategoryBinding is also needed so the Kategori drawer destination
    // (pushed on the root navigator) can resolve its controller.
    CategoryBinding().dependencies();
  }

  void _readTabArgument() {
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final i = (args['tab'] as int).clamp(0, tabs.length - 1);
      currentIndex.value = i;
    }
  }

  void changeTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    Get.offAllNamed<void>(
      AppRoutes.home,
      arguments: {'tab': index},
    );
  }

  void syncFromArguments() => _readTabArgument();
}

class HomeTabSpec {
  const HomeTabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    required this.index,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final int index;
}
