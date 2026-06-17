import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

class HomeShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  static const List<HomeTabSpec> tabs = <HomeTabSpec>[
    HomeTabSpec(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.dashboard,
    ),
    HomeTabSpec(
      label: 'Obat',
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication,
      route: AppRoutes.medicines,
    ),
    HomeTabSpec(
      label: 'Stok',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: AppRoutes.stockMovements,
    ),
    HomeTabSpec(
      label: 'Riwayat',
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      route: AppRoutes.stockMovements,
    ),
    HomeTabSpec(
      label: 'Profil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: AppRoutes.profile,
    ),
  ];

  void changeTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    final tab = tabs[index];
    Get.offAllNamed<void>(tab.route);
  }
}

class HomeTabSpec {
  const HomeTabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}

// when building drawer entries.
