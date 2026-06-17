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

  /// Called by `Get.offAllNamed(..., arguments: {'tab': i})` so the shell
  /// re-syncs the active tab after a drawer / quick-action navigation.
  void _readTabArgument() {
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final i = (args['tab'] as int).clamp(0, tabs.length - 1);
      currentIndex.value = i;
    }
  }

  /// Tap on bottom nav: rebuild the shell with the new active tab. We use
  /// `Get.offAllNamed` to clear the navigation stack and stay inside the
  /// shell so the bottom navigation and drawer stay visible.
  void changeTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    Get.offAllNamed<void>(
      AppRoutes.home,
      arguments: {'tab': index},
    );
  }

  /// Called from view to refresh the active tab when arguments arrive
  /// after the first frame.
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
