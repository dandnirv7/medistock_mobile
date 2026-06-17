import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

class HomeShellController extends GetxController {
  /// Active tab index (0..4). Hydrated from `Get.arguments['tab']` and
  /// kept in sync with the current route when the user pushes deeper
  /// screens and pops back.
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

  @override
  void onReady() {
    super.onReady();
    _readTabArgument();
  }

  /// Called whenever the shell becomes visible (after returning from a
  /// pushed route) so the active tab indicator matches the current
  /// GetX route.
  void syncFromCurrentRoute() {
    final route = Get.currentRoute;
    for (final tab in tabs) {
      if (tab.route == route) {
        if (currentIndex.value != tab.index) {
          currentIndex.value = tab.index;
        }
        return;
      }
    }
  }

  void _readTabArgument() {
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final i = (args['tab'] as int).clamp(0, tabs.length - 1);
      currentIndex.value = i;
    } else {
      syncFromCurrentRoute();
    }
  }

  /// Tap on a bottom nav destination. We push the tab's root route via
  /// GetX so its `GetPage.binding` fires (registers the controller
  /// lazily) and the view is fully wired. `Get.offAllNamed` clears
  /// the navigation stack so the back button returns to the previous
  /// logical destination rather than cycling through previously
  /// selected tabs.
  void changeTab(int index) {
    final tab = tabs[index];
    currentIndex.value = tab.index;
    Get.offAllNamed<void>(tab.route);
  }
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
