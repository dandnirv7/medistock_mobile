import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/models/user_model.dart';
import '../../categories/bindings/category_binding.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../medicines/bindings/medicine_binding.dart';
import '../../medicines/views/medicine_list_view.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../profile/views/profile_view.dart';
import '../../stock_movements/bindings/stock_movement_binding.dart';
import '../../stock_movements/views/stock_movement_list_view.dart';
import '../controllers/home_shell_controller.dart';

/// Host scaffold with persistent bottom navigation.
///
/// The shell renders only the *active* tab's view as its body. Switching
/// tabs destroys the previous tab's view so its controller is also
/// disposed and won't keep firing API calls in the background — that
/// is what was causing the ThrottlerException / Too Many Requests when
/// the user hopped between tabs. Each tab push still goes through
/// GetX routing via `Get.offAllNamed`, so its `GetPage.binding` fires
/// normally and the controller is registered before the view builds.
class HomeShellView extends GetView<HomeShellController> {
  const HomeShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.currentIndex.value;
      final tab = HomeShellController.tabs[index];
      return Scaffold(
        appBar: AppBar(
          title: Text(tab.label),
          centerTitle: false,
        ),
        drawer: const _AppDrawer(),
        body: _TabBody(tab: tab),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.changeTab,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          destinations: [
            for (final t in HomeShellController.tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon),
                label: t.label,
              ),
          ],
        ),
      );
    });
  }
}

/// One frame after first build, hydrate the controller's tab index from
/// the GetX arguments. Wrapped in a stateful widget so we can hook into
/// `initState` without rebuilding the controller.
class _TabBody extends StatefulWidget {
  const _TabBody({required this.tab});

  final HomeTabSpec tab;

  @override
  State<_TabBody> createState() => _TabBodyState();
}

class _TabBodyState extends State<_TabBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureBindings();
    });
  }

  void _ensureBindings() {
    switch (widget.tab.route) {
      case AppRoutes.dashboard:
        DashboardBinding().dependencies();
        break;
      case AppRoutes.medicines:
        MedicineBinding().dependencies();
        break;
      case AppRoutes.stockMovements:
        StockMovementBinding().dependencies();
        break;
      case AppRoutes.profile:
        ProfileBinding().dependencies();
        break;
    }
    // Categories drawer destination is also a popular push from inside
    // the Obat tab, so register it preemptively.
    CategoryBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.tab.route) {
      case AppRoutes.dashboard:
        return const DashboardView();
      case AppRoutes.medicines:
        return const MedicineListView();
      case AppRoutes.stockMovements:
        return const StockMovementListView();
      case AppRoutes.profile:
        return const ProfileView();
      default:
        return Center(child: Text(widget.tab.label));
    }
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final session = Get.find<AuthSession>();
    final user = session.user;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(user: user),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    tabIndex: 0,
                  ),
                  _DrawerItem(
                    icon: Icons.medication_outlined,
                    label: 'Data Obat',
                    tabIndex: 1,
                  ),
                  _DrawerItem(
                    icon: Icons.category_outlined,
                    label: 'Kategori',
                    tabIndex: 1,
                    navigateTo: AppRoutes.categories,
                  ),
                  _DrawerItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Supplier',
                    tabIndex: 1,
                    navigateTo: AppRoutes.suppliers,
                  ),
                  _DrawerItem(
                    icon: Icons.arrow_downward,
                    label: 'Stok Masuk',
                    tabIndex: 2,
                    navigateTo: AppRoutes.stockIn,
                  ),
                  _DrawerItem(
                    icon: Icons.arrow_upward,
                    label: 'Stok Keluar',
                    tabIndex: 2,
                    navigateTo: AppRoutes.stockOut,
                  ),
                  _DrawerItem(
                    icon: Icons.swap_horiz,
                    label: 'Mutasi Stok',
                    tabIndex: 2,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await Get.find<AuthRepository>().logout();
                await Get.find<AuthSession>().clear();
                Get.offAllNamed<void>(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'MediStock';
    final role = user?.role ?? 'User';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_pharmacy,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'MediStock',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Text(
            'Inventory',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            role,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.tabIndex,
    this.navigateTo,
  });

  final IconData icon;
  final String label;
  final int tabIndex;
  final String? navigateTo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        final shell = Get.find<HomeShellController>();
        shell.changeTab(tabIndex);
        final target = navigateTo;
        if (target != null) {
          // Schedule the push after the shell has settled on the new
          // tab so the destination is stacked on top of the right root.
          Future.microtask(() => Get.toNamed<void>(target));
        }
      },
    );
  }
}
