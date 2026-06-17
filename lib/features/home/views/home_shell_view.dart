import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/models/user_model.dart';
import '../controllers/home_shell_controller.dart';

/// Persistent host shell. Renders an appbar, drawer, and bottom nav
/// around an IndexedStack of per-tab Navigators. Sub-routes pushed
/// from inside a tab (e.g. Category, Supplier, Stok In/Out) stay
/// inside that tab's nested Navigator, so:
///
///  * the shell (appbar + bottom nav) stays mounted,
///  * the back button returns to the tab root instead of exiting the app,
///  * scroll/state in the tab root is preserved when the user pops
///    back from a sub-route,
///  * switching tabs is O(1) and does not refire API calls.
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
        body: IndexedStack(
          index: index,
          children: [
            for (var i = 0; i < HomeShellController.tabs.length; i++)
              _TabNavigatorHost(tabIndex: i),
          ],
        ),
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

/// Thin wrapper that asks the controller for a tab-scoped Navigator.
/// The actual root view is resolved through GetX's route table so each
/// tab's `GetPage.binding` still fires lazily on first build.
class _TabNavigatorHost extends StatelessWidget {
  const _TabNavigatorHost({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeShellController>();
    return controller.buildTabNavigator(tabIndex);
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
          // Defer the push so the IndexedStack can swap to the new tab
          // first; the push then lands on that tab's nested Navigator
          // so the back button returns to the tab root with the shell
          // still mounted.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navState = HomeShellController.navigatorKeyFor(tabIndex)
                .currentState;
            navState?.pushNamed(target);
          });
        }
      },
    );
  }
}
