import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/storage/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/models/user_model.dart';
import '../controllers/home_shell_controller.dart';

/// Persistent host shell. Renders an appbar, drawer, and bottom nav
/// around an IndexedStack of per-tab root views. Sub-routes pushed
/// from inside a tab (e.g. Category, Supplier, Stok In/Out) are
/// pushed via `Get.toNamed(...)` on the root Navigator, so the back
/// button returns to the tab root with the shell still mounted.
///
/// All tab roots are mounted eagerly (one widget each), so switching
/// tabs is O(1) and does not refire API calls.
class HomeShellView extends GetView<HomeShellController> {
  const HomeShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.currentIndex.value;
      final tab = controller.tabs[index];
      return Scaffold(
        appBar: AppBar(
          title: Text(tab.label),
          centerTitle: false,
        ),
        drawer: const _AppDrawer(),
        body: IndexedStack(
          index: index,
          children: [
            for (var i = 0; i < controller.tabs.length; i++)
              _TabRootView(tabIndex: i),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.changeTab,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          destinations: [
            for (final t in controller.tabs)
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

/// Mounts the root view for the tab at [tabIndex]. Using a wrapper
/// keeps the IndexedStack children list stable (one child per tab) so
/// switching tabs does not rebuild widget identities and refire
/// fetches. Bindings still fire lazily because each tab's binding
/// resolves when the tab root view is first built — and since the
/// IndexedStack keeps every tab mounted, that happens once per tab
/// per shell mount.
class _TabRootView extends StatelessWidget {
  const _TabRootView({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeShellController>();
    return controller.buildTabRoot(tabIndex);
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
    final role = user?.userRole.label ?? 'User';
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
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            role,
            style: const TextStyle(
              color: AppColors.primaryDark,
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
          // Push the sub-route on the root Navigator (handled by
          // GetMaterialApp). Switching tabs first ensures the
          // sub-route is opened on top of the right tab root.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed<void>(target);
          });
        }
      },
    );
  }
}
