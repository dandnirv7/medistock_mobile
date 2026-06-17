import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

class HomeShellController extends GetxController {
  /// Active tab index (0..4). Hydrated from `Get.arguments['tab']`.
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

  void _readTabArgument() {
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final i = (args['tab'] as int).clamp(0, tabs.length - 1);
      currentIndex.value = i;
    }
  }

  /// One Navigator per tab so each tab has its own route stack.
  /// Switching tabs does not rebuild the navigator, so scroll/state
  /// is preserved and the shell's appbar + bottom nav stay mounted
  /// even when a sub-route is pushed on top.
  static final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    tabs.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  static GlobalKey<NavigatorState> navigatorKeyFor(int index) =>
      _navigatorKeys[index];

  /// Tap on a bottom nav destination. Re-tapping the active tab pops
  /// its nested stack back to root (standard iOS / Android bottom-nav
  /// behaviour).
  void changeTab(int index) {
    if (currentIndex.value == index) {
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    currentIndex.value = index;
  }

  /// Build a Navigator for the given tab. The tab's root route is the
  /// `home` page; sub-routes are resolved through the same GetX route
  /// table (so `GetPage.binding` still fires).
  Widget buildTabNavigator(int tabIndex) {
    final tab = tabs[tabIndex];
    return Navigator(
      key: _navigatorKeys[tabIndex],
      onGenerateRoute: (settings) {
        if (settings.name == tab.route) {
          return _rootRoute(settings, tab);
        }
        final page = Get.routeTree.matchRoute(settings.name ?? '').route;
        if (page == null) return null;
        return page as Route<dynamic>;
      },
    );
  }

  Route<dynamic> _rootRoute(RouteSettings settings, HomeTabSpec tab) {
    final page = Get.routeTree.matchRoute(tab.route).route;
    if (page == null) {
      throw FlutterError('HomeShellController: tab root route not found: ${tab.route}');
    }
    return page as Route<dynamic>;
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
