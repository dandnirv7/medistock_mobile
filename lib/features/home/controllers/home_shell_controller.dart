import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../auth/models/user_model.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../medicines/bindings/medicine_binding.dart';
import '../../medicines/controllers/medicine_list_controller.dart';
import '../../medicines/data/repositories/medicine_repository.dart'
    show MedicineExpiredFilter;
import '../../medicines/views/medicine_list_view.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../profile/views/profile_view.dart';
import '../../suppliers/bindings/supplier_binding.dart';
import '../../suppliers/views/supplier_list_view.dart';
import '../../stock_movements/bindings/stock_movement_binding.dart';
import '../../stock_movements/views/stock_level_view.dart';
import '../../stock_movements/views/stock_movement_list_view.dart';
import '../../../core/theme/app_icons.dart';

class HomeShellController extends GetxController {
  /// Active tab index within the role-filtered `tabs` list.
  final RxInt currentIndex = 0.obs;

  /// Tabs visible to the current user. Recomputed when the session
  /// changes (login/logout). Admin sees the master-data tab; staff
  /// does not.
  final RxList<HomeTabSpec> tabs = <HomeTabSpec>[].obs;

  @override
  void onInit() {
    super.onInit();
    _rebuildTabs();
    if (Get.isRegistered<AuthSession>()) {
      ever<UserModel?>(Get.find<AuthSession>().userRx, (_) {
        _rebuildTabs();
      });
    }
  }

  @override
  void onReady() {
    super.onReady();
    _readTabArgument();
  }

  void _rebuildTabs() {
    final isAdmin = Get.isRegistered<AuthSession>()
        ? Get.find<AuthSession>().isAdmin
        : true;
    final list = <HomeTabSpec>[
      const HomeTabSpec(
        label: 'Dashboard',
        icon: AppIcons.home,
        activeIcon: AppIcons.home,
        route: AppRoutes.dashboard,
        index: 0,
      ),
      if (isAdmin)
        const HomeTabSpec(
          label: 'Obat',
          icon: AppIcons.medicationOutlined,
          activeIcon: AppIcons.medication,
          route: AppRoutes.medicines,
          index: 1,
        ),
      if (isAdmin)
        const HomeTabSpec(
          label: 'Supplier',
          icon: AppIcons.localShippingOutlined,
          activeIcon: AppIcons.localShipping,
          route: AppRoutes.suppliers,
          index: 2,
        ),
      // Admins read current stock per-medicine in the Obat list and on the
      // dashboard cards, so a dedicated Stok tab is redundant for them. Staff
      // have no Obat tab, so they keep Stok as their primary stock view.
      if (!isAdmin)
        const HomeTabSpec(
          label: 'Stok',
          icon: AppIcons.inventory2_outlined,
          activeIcon: AppIcons.inventory2,
          route: AppRoutes.stockLevels,
          index: 3,
        ),
      const HomeTabSpec(
        label: 'Riwayat',
        icon: AppIcons.history_outlined,
        activeIcon: AppIcons.history,
        route: AppRoutes.stockMovements,
        index: 4,
      ),
      const HomeTabSpec(
        label: 'Profil',
        icon: AppIcons.person_outline,
        activeIcon: AppIcons.person,
        route: AppRoutes.profile,
        index: 5,
      ),
    ];
    tabs.assignAll(list);
    if (currentIndex.value >= list.length) {
      currentIndex.value = 0;
    }
  }

  void _readTabArgument() {
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final i = (args['tab'] as int).clamp(0, tabs.length - 1);
      currentIndex.value = i;
    }
  }

  /// Switch the active tab. Re-tapping the active tab is a no-op now
  /// (the shell uses a single Navigator, so there is no per-tab
  /// stack to pop). Sub-routes pushed via `Get.toNamed(...)` will
  /// still appear above the shell and the system back button will
  /// pop them.
  void changeTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    currentIndex.value = index;
  }

  /// Switch to the Obat (medicines) tab and pre-apply a filter. Used by the
  /// dashboard alert cards so tapping "Stok Rendah" / "Hampir Expired" lands
  /// the user on the medicine list already filtered to the relevant subset
  /// instead of an unfiltered list.
  void openMedicines({
    bool lowStockOnly = false,
    MedicineExpiredFilter expired = MedicineExpiredFilter.all,
  }) {
    final idx = tabs.indexWhere((t) => t.route == AppRoutes.medicines);
    if (idx < 0) {
      // Staff role has no medicines tab; fall back to a pushed route.
      Get.toNamed(AppRoutes.medicines);
      return;
    }
    changeTab(idx);
    if (Get.isRegistered<MedicineListController>()) {
      final c = Get.find<MedicineListController>();
      c.search.value = '';
      c.categoryFilter.value = null;
      c.supplierFilter.value = null;
      c.lowStockOnly.value = lowStockOnly;
      c.expiredFilter.value = expired;
      c.load();
    }
  }

  /// Tracks which tab bindings have been fired in this shell lifetime
  /// so we don't call `dependencies()` more than once per tab. The
  /// bindings themselves use `Get.lazyPut(..., fenix: true)`, so even
  /// repeated calls are harmless, but skipping the second call saves
  /// work and keeps the call log clean.
  final Set<String> _firedBindings = <String>{};

  /// Build the root widget for a tab. The shell no longer routes
  /// through `GetMaterialApp`'s Navigator, so each `GetPage.binding`
  /// is fired manually here before the view is returned. The
  /// `IndexedStack` keeps the returned widget alive across tab
  /// switches, so the binding fires at most once per tab per shell
  /// mount.
  Widget buildTabRoot(int tabIndex) {
    if (tabIndex < 0 || tabIndex >= tabs.length) {
      return const SizedBox.shrink();
    }
    final route = tabs[tabIndex].route;
    _ensureBinding(route);
    switch (route) {
      case AppRoutes.dashboard:
        return const DashboardView();
      case AppRoutes.medicines:
        return const MedicineListView();
      case AppRoutes.suppliers:
        return const SupplierListView();
      case AppRoutes.stockLevels:
        return const StockLevelView();
      case AppRoutes.stockMovements:
        return const StockMovementListView();
      case AppRoutes.profile:
        return const ProfileView();
      default:
        return const SizedBox.shrink();
    }
  }

  void _ensureBinding(String route) {
    if (_firedBindings.contains(route)) return;
    _firedBindings.add(route);
    switch (route) {
      case AppRoutes.dashboard:
        DashboardBinding().dependencies();
        break;
      case AppRoutes.medicines:
      case AppRoutes.stockLevels:
        MedicineBinding().dependencies();
        break;
      case AppRoutes.suppliers:
        SupplierBinding().dependencies();
        break;
      case AppRoutes.stockMovements:
        StockMovementBinding().dependencies();
        break;
      case AppRoutes.profile:
        ProfileBinding().dependencies();
        break;
    }
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
